#Global variables
set(${PROJECT_NAME}-MultiAbiBuild ON CACHE INTERNAL "" FORCE)

#Detect Qt
find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)

# Module settings
set(CMAKE_SHARED_MODULE_SUFFIX_CXX "_${ANDROID_ABI}.so")
set(CMAKE_SHARED_LIBRARY_SUFFIX_CXX "_${ANDROID_ABI}.so")
set(CMAKE_SHARED_MODULE_SUFFIX_C "_${ANDROID_ABI}.so")
set(CMAKE_SHARED_LIBRARY_SUFFIX_C "_${ANDROID_ABI}.so")

# Match Android's sysroots
set(ANDROID_SYSROOT_armeabi-v7a arm-linux-androideabi)
set(ANDROID_SYSROOT_arm64-v8a aarch64-linux-android)
set(ANDROID_SYSROOT_x86 i686-linux-android)
set(ANDROID_SYSROOT_x86_64 x86_64-linux-android)

# Android SDK
if(NOT ANDROID_SDK)
  get_filename_component(ANDROID_SDK ${ANDROID_NDK}/../ ABSOLUTE)
endif()

# Deployment tool
find_program(ANDROID_DEPLOY_QT androiddeployqt)
get_filename_component(QT_DIR ${ANDROID_DEPLOY_QT}/../../ ABSOLUTE)

# Deployment file template
set(ANDROID_DEPLOYMENT_SETTINGS_FILE_TEMPLATE
    ${B_ROOT}/templates/B/android/android_deployment_settings.json.in
)

# Android ABIs
set(ANDROID_ABIS armeabi-v7a arm64-v8a x86 x86_64)
set(ANDROID_ABI armeabi-v7a CACHE STRING "Android ABI")
set_property(CACHE ANDROID_ABI PROPERTY STRINGS ${ANDROID_ABIS})

option(ANDROID_BUILD_AAB "Enable/disable AAB build" OFF)

# Macros

function(c_add_app name)
    add_library(${name} SHARED ${ARGN})
    target_link_libraries(${name} PRIVATE Qt5::AndroidExtras)
endfunction()

function(c_add_service name)
    add_library(${name} SHARED ${ARGN})
endfunction()

function(c_add_tool name)
    add_executable(${name} ${ARGN})
endfunction()

function(c_add_test name)
    add_executable(${name} ${ARGN})
    add_test(NAME ${name} COMMAND ${name})
endfunction()

function(c_add_plugin name)
    add_library(${name} MODULE ${ARGN})
endfunction()

function(c_add_library name)
    add_library(${name} ${ARGN})
endfunction()

function(c_finalize_target name type)
    if (type STREQUAL APP)
        c_add_apk_target(${name}-apk BASE_TARGET ${name})
    endif()
endfunction()

function(c_add_apk_target name)
    set(options)
    set(oneValueArgs BASE_TARGET)
    set(multiValueArgs)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ARG_BASE_TARGET)
        message(FATAL_ERROR "base target not provided")
    endif()

    set(ANDROID_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${ARG_BASE_TARGET}_android)

    # Deployment settings
    c_generate_android_target_deployment_file(${ANDROID_BUILD_DIR}/android_deployment.json)

    # APK output
    get_target_property(APK_OUTPUT_DIR ${ARG_BASE_TARGET} APK_OUTPUT_DIRECTORY)
    if (NOT APK_OUTPUT_DIR)
        set(APK_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    get_target_property(APK_NAME ${ARG_BASE_TARGET} OUTPUT_NAME)
    if (NOT APK_NAME)
        set(APK_NAME ${ARG_BASE_TARGET})
    endif()

    set(APK_FILE ${APK_OUTPUT_DIR}/${APK_NAME}.apk)

    get_target_property(AAB ${ARG_BASE_TARGET} ANDROID_AAB)
    if (AAB)
        set(aab --aab)
    else()
        unset(aab)
    endif()

    get_target_property(PACKAGE_SOURCE_DIR ${ARG_BASE_TARGET} ANDROID_PACKAGE_SOURCE_DIR)

    if (PACKAGE_SOURCE_DIR)
        set(FILES AndroidManifest.xml)

        if (EXISTS ${PACKAGE_SOURCE_DIR}/gradle.properties)
            list(APPEND FILES gradle.properties)
        endif()

        if (EXISTS ${PACKAGE_SOURCE_DIR}/build.gradle)
            list(APPEND FILES build.gradle)
        endif()

        if (EXISTS ${PACKAGE_SOURCE_DIR}/src/)
            file(GLOB_RECURSE SOURCES RELATIVE ${PACKAGE_SOURCE_DIR} "${PACKAGE_SOURCE_DIR}/src/*.java")
            list(APPEND FILES ${SOURCES})
        endif()

        list(TRANSFORM FILES PREPEND ${PACKAGE_SOURCE_DIR}/)

        set(SOURCES SOURCES ${FILES})
    else()
        unset(SOURCES)
    endif()

    get_target_property(keystore ${ARG_BASE_TARGET} ANDROID_KEYSTORE_PATH)
    get_target_property(alias ${ARG_BASE_TARGET}    ANDROID_KEYSTORE_ALIAS)
    get_target_property(password ${ARG_BASE_TARGET} ANDROID_KEYSTORE_PASSWORD)

    if (keystore AND password AND alias)
        set(signing --sign file:///${keystore} ${alias} --storepass ${password})
    else()
        unset(signing)
    endif()

    if (CMAKE_BUILD_TYPE IN_LIST "Release;RelWithDebInfo;MinSizeRel")
        set(release --release)
    else()
        unset(release)
    endif()

    add_custom_target(${name} ALL
        COMMAND ${CMAKE_COMMAND} -E env JAVA_HOME=${JAVA_HOME} ${ANDROID_DEPLOY_QT}
            --input "${ARG_INPUT}"
            --output "${ANDROID_BUILD_DIR}/build"
            --apk "${APK_FILE}"
            ${aab}
            ${signing}
            ${release}
            ${android_deploy_qt_platform}
            ${android_deploy_qt_jdk}
        DEPENDS ${ARG_BASE_TARGET}
        VERBATIM
        ${SOURCES}
    )

    set_target_properties(${ARG_BASE_TARGET}
        PROPERTIES
            ADDITIONAL_CLEAN_FILES "${ARG_INPUT};${ARG_OUTPUT};${target}_android/${ARG_APK}"
    )
endfunction()

function(c_generate_android_target_deployment_file target file)
    # App binary
    get_target_property(QT_APPLICATION_BINARY ${target} OUTPUT_NAME)
    if (NOT QT_APPLICATION_BINARY)
        set(QT_APPLICATION_BINARY ${target})
    endif()

    # App architecture
    set(ARCHITECTURES ${ANDROID_ABI})

    # QML ROOT
    get_target_property(QML_ROOT_PATH ${target} QML_ROOT_PATH)
    if (NOT QML_ROOT_PATH)
        set(QML_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    # QML IMPORT
    get_target_property(QML_IMPORT_PATH2 ${target} QML_IMPORT_PATH)
    if (QML_IMPORT_PATH2)
        set(QML_IMPORT_PATH ${QML_IMPORT_PATH2})
    else()
        set(QML_IMPORT_PATH ${QML_IMPORT_PATH})
    endif()

    # Android properties
    set(PROPERTIES
        PACKAGE_SOURCE_DIR
        VERSION_CODE
        VERSION_NAME
        DEPLOYMENT_DEPENDENCIES
        EXTRA_PLUGINS
        EXTRA_LIBS
    )

    foreach (property ${PROPERTIES})
        get_target_property(ANDROID_${property} ${target} ANDROID_${property})
    endforeach()

    unset(QT_ANDROID_ARCHITECTURES)
    foreach(abi IN LISTS ARCHITECTURES)
        list(APPEND QT_ANDROID_ARCHITECTURES "\"${abi}\" : \"${ANDROID_SYSROOT_${abi}}\"")
    endforeach()
    string(REPLACE ";" ",\n" QT_ANDROID_ARCHITECTURES "${QT_ANDROID_ARCHITECTURES}")

    macro(generate_json_variable_list var_list json_key)
      if (${var_list})
        set(QT_${var_list} "\"${json_key}\": \"")
        string(REPLACE ";" "," joined_var_list "${${var_list}}")
        string(APPEND QT_${var_list} "${joined_var_list}\",")
      endif()
    endmacro()

    macro(generate_json_variable var json_key)
      if (${var})
        set(QT_${var} "\"${json_key}\": \"${${var}}\",")
      endif()
    endmacro()

    generate_json_variable_list(ANDROID_DEPLOYMENT_DEPENDENCIES "deployment-dependencies")
    generate_json_variable_list(ANDROID_EXTRA_PLUGINS "android-extra-plugins")
    generate_json_variable(ANDROID_PACKAGE_SOURCE_DIR "android-package-source-directory")
    generate_json_variable(ANDROID_VERSION_CODE "android-version-code")
    generate_json_variable(ANDROID_VERSION_NAME "android-version-name")
    generate_json_variable_list(ANDROID_EXTRA_LIBS "android-extra-libs")
    generate_json_variable_list(QML_IMPORT_PATH "qml-import-paths")
    #generate_json_variable_list(ANDROID_MIN_SDK_VERSION "android-min-sdk-version")
    #generate_json_variable_list(ANDROID_TARGET_SDK_VERSION "android-target-sdk-version")
endfunction()
