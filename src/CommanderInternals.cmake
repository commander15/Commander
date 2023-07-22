find_program(qmlplugindump NAMES qmlplugindump)
if (NOT qmlplugindump)
    message(WARNING "Commander couldn't find qmlplugindump utility needed for qml plugin support")
endif()

find_program(lrelease NAMES lrelease)
if (NOT lrelease)
    message(WARNING "Commander couldn't find lrelease utility, add_translation may fail")
endif()

function(__commander_register_target name type)
    set_target_properties(${name} PROPERTIES
        OUTPUT_NAME       ${name}
        INCLUDE_DIRECTORY ${name}
        COMMANDER_TYPE    ${type}
    )

    set(EXCLUDES PLUGIN TRANSLATION)

    if (${type} IN_LIST EXCLUDES)
        set(EXCLUSIVE TRUE)
    else()
        set(EXCLUSIVE FALSE)
    endif()

    cmake_language(EVAL CODE "
        cmake_language(DEFER CALL __commander_finalize_target ${name} ${type})
        if (NOT EXCLUSIVE)
            cmake_language(DEFER CALL commander_finalize_target ${name} ${type})
        endif()
    ")

    if (CMAKE_${type}_OUTPUT_DIRECTORY AND NOT EXISTS ${CMAKE_${type}_OUTPUT_DIRECTORY})
        file(MAKE_DIRECTORY ${CMAKE_${type}_OUTPUT_DIRECTORY})
    endif()
endfunction()

function(__commander_finalize_target target type)
    get_target_property(HEADERS ${target} PUBLIC_HEADERS)
    if (HEADERS)
        get_target_property(DIR ${target} INCLUDE_DIRECTORY)
        __commander_install_files(include/${DIR} ${HEADERS})
    endif()

    if (type STREQUAL PLUGIN)
        get_target_property(QML ${target} QML)
        if (NOT QML)
            __commander_finalize_plugin(${target})
        else()
            __commander_finalize_qml_plugin(${target})
        endif()
    elseif (type STREQUAL LIBRARY)
        __commander_finalize_library(${target})
    elseif (type STREQUAL TRANSLATION)
        __commander_finalize_translation(${target})
    endif()
endfunction()

function(__commander_finalize_plugin target)
    get_target_property(NAME ${target} PLUGIN_NAME)
    get_target_property(GROUP ${target} PLUGIN_GROUP)
    get_target_property(DIR ${target} PLUGIN_OUTPUT_DIRECTORY)

    if (NOT DIR AND CMAKE_PLUGIN_OUTPUT_DIRECTORY)
        set(DIR ${CMAKE_PLUGIN_OUTPUT_DIRECTORY})
    else()
        set(DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    if (GROUP)
        set(DIR ${DIR}/${GROUP})
    endif()

    set_target_properties(${target} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${DIR}
        LIBRARY_OUTPUT_DIRECTORY ${DIR}
    )
endfunction()

function(__commander_finalize_qml_plugin target)
    get_target_property(NAME ${target} PLUGIN_NAME)
    get_target_property(VERSION ${target} PLUGIN_VERSION)
    get_target_property(DIR ${target} QMLDIR_FILE)
    get_target_property(SOURCES ${target} QML_SOURCES)
    get_target_property(RUN_DIR ${target} QML_OUTPUT_DIRECTORY)

    string(REPLACE "." "/" SUB_DIR ${NAME})

    if (NOT DIR AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/qmldir)
        set(DIR qmldir)
    else()
        unset(DIR)
    endif()

    if (NOT SOURCES)
        message(FATAL_ERROR
            "Commander can't find QML sources for target '${target}', please add some files using QML_SOURCES target property"
        )
    endif()

    if (NOT RUN_DIR AND CMAKE_QMLPLUGIN_OUTPUT_DIRECTORY)
        set(RUN_DIR ${CMAKE_QMLPLUGIN_OUTPUT_DIRECTORY})
    else()
        set(RUN_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    set_target_properties(${target} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${RUN_DIR}/${SUB_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${RUN_DIR}/${SUB_DIR}
        QMLDIR_FILE ${DIR}
        QMLTYPES_FILE ${RUN_DIR}/${SUB_DIR}/${NAME}.types
    )

    if (NOT EXISTS ${RUN_DIR}/${SUB_DIR})
        file(MAKE_DIRECTORY ${RUN_DIR}/${SUB_DIR})
    endif()

    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND
            ${CMAKE_COMMAND} -E copy
                ${DIR} ${SOURCES} "${RUN_DIR}/${SUB_DIR}"
        COMMAND
            ${qmlplugindump} ${NAME} ${VERSION} ${RUN_DIR}
                -output "${RUN_DIR}/${SUB_DIR}/${NAME}.types"
                -v
        COMMAND
            ${CMAKE_COMMAND} -E copy
                "${RUN_DIR}/${SUB_DIR}/${TYPES}" "."
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endfunction()

function(__commander_finalize_library target)
    get_target_property(NAME ${target} LIBRARY_NAME)
    if (NOT NAME)
        string(TOUPPER ${target} NAME)
    endif()

    get_target_property(TYPE ${target} TYPE)
    if (TYPE STREQUAL SHARED_LIBRARY)
        set(BUILD_TYPE SHARED)
    else()
        set(BUILD_TYPE STATIC)
    endif()

    target_compile_definitions(${target}
        PUBLIC
            ${NAME}_LIB ${NAME}_${BUILD_TYPE}
        PRIVATE
            BUILD_${NAME}_LIB
    )

    target_include_directories(${target} PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include>
        $<INSTALL_INTERFACE:include>
    )
endfunction()

function(__commander_finalize_translation target)
    get_target_property(NAME ${target} OUTPUT_NAME)
    get_target_property(DIR ${target} TRANSLATION_OUTPUT_DIRECTORY)
    get_target_property(SOURCES ${target} SOURCES)

    if (NOT NAME)
        set(NAME ${target})
    endif()

    if (NOT DIR)
        if (CMAKE_TRANSLATION_OUTPUT_DIRECTORY)
            set(DIR ${CMAKE_TRANSLATION_OUTPUT_DIRECTORY})
        else()
            get_target_property(DIR ${target} BINARY_DIR)
        endif()
    endif()

    set_target_properties(${target} PROPERTIES
        LOCATION ${DIR}/${NAME}.qm
    )

    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${lrelease} ${SOURCES} -qm "${DIR}/${NAME}.qm"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        VERBATIM
    )
endfunction()

function(__commander_install type)
    if (type STREQUAL PACKAGE)
        set(options)
        set(oneValueArgs PACKAGE DESTINATION)
        set(multiValueArgs)

        cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})

        __commander_install_package(${ARG_PACKAGE} ${ARG_DESTINATION})
    elseif(type STREQUAL TARGETS)
        set(options)
        set(oneValueArgs PACKAGE EXPORT COMPONENT)
        set(multiValueArgs TARGETS APP TOOL SERVICE PLUGIN QMLPLUGIN LIBRARY TRANSLATION)

        cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})

        if (ARG_PACKAGE)
            get_target_property(ARG_EXPORT ${ARG_PACKAGE} PACKAGE_EXPORT)
            set_target_properties(${ARG_PACKAGE} PROPERTIES PACKAGE_EXPORTING TRUE)
        endif()

        foreach(target ${ARG_TARGETS})
            unset(DTYPE)
            get_target_property(TYPE ${target} COMMANDER_TYPE)
            if (NOT ARG_${TYPE})
                message(FATAL_ERROR "Commander can't install '${target}' target"
                    ", please make sure you have specified ${TYPE} DESTINATION"
                )
            elseif (TYPE STREQUAL PLUGIN)
                get_target_property(QML ${target} QML)
                if (QML)
                    set(DTYPE QML)
                endif()
            endif()

            cmake_parse_arguments(ARG_${TYPE} "" "" "DESTINATION" ${ARG_${DTYPE}${TYPE}})

            __commander_install_target(${target}
                TYPE ${TYPE}
                EXPORT ${ARG_EXPORT}
                COMPONENT ${ARG_COMPONENT}
                DESTINATION ${ARG_${TYPE}_DESTINATION}
            )
        endforeach()
    elseif (type STREQUAL DIRECTORIES OR type STREQUAL DIRECTORY)
        set(options)
        set(oneValueArgs DESTINATION)
        set(multiValueArgs DIRECTORIES DIRECTORY)

        cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})
        __commander_install_directories(${ARG_DESTINATION} ${ARG_DIRECTORIES} ${ARG_DIRECTORY})
    elseif (type STREQUAL FILES OR type STREQUAL FILE OR type STREQUAL PROGRAMS)
        set(options)
        set(oneValueArgs DESTINATION)
        set(multiValueArgs FILES PROGRAMS)

        cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})
        __commander_install_files(${ARG_DESTINATION} ${ARG_FILES} ${ARG_PROGRAMS})
    elseif (type STREQUAL EXPORT)
        set(options)
        set(oneValueArgs EXPORT NAMESPACE FILE DESTINATION)
        set(multiValueArgs)

        cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})
        __commander_install_export(${ARG_DESTINATION} ${ARG_EXPORT} ${ARG_NAMESPACE} ${ARG_FILE})
    else()
        x_install(${type} ${ARGN})
    endif()
endfunction()

function(__commander_install_package target destination)
    get_target_property(NAME ${target} PACKAGE_NAME)
    get_target_property(SOURCES ${target} SOURCES)
    set(destination ${destination}/${NAME})

    __commander_install_files(${destination} ${SOURCES})

    get_target_property(EXPORT ${target} PACKAGE_EXPORTING)
    if (EXPORT)
        get_target_property(EXPORT ${target} PACKAGE_EXPORT)
        get_target_property(NAMESPACE ${target} PACKAGE_NAMESPACE)
        __commander_install_export(${destination} ${EXPORT} ${NAMESPACE} ${EXPORT}.cmake)
    endif()
endfunction()

function(__commander_install_target target)
    set(options)
    set(oneValueArgs TYPE EXPORT COMPONENT)
    set(multiValueArgs DESTINATION)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})

    if (ARG_TYPE STREQUAL PLUGIN)
        get_target_property(QML ${target} QML)
        if (NOT QML)
            get_target_property(GROUP ${target} PLUGIN_GROUP)
            if (GROUP)
                set(ARG_DESTINATION ${ARG_DESTINATION}/${GROUP})
            endif()
        else()
            get_target_property(NAME ${target} PLUGIN_NAME)
            set(ARG_DESTINATION ${ARG_DESTINATION}/${NAME})

            commanger_get_qml_plugin_files(${target} QML_FILES)

            x_install(FILES ${QML_FILES}
                DESTINATION ${ARG_DESTINATION}
            )
        endif()
    endif()

    if (ARG_TYPE STREQUAL TRANSLATION)
        get_target_property(file ${target} LOCATION)
        x_install(FILES ${file} DESTINATION ${ARG_DESTINATION})
    elseif (ARG_TYPE AND ARG_DESTINATION)
        commander_install_target(${target} ${ARG_TYPE} "${ARG_DESTINATION}"
            EXPORT ${ARG_EXPORT}
            COMPONENT ${ARG_COMPONENT}
        )
    else()
        message(FATAL_ERROR "Commander can't install target '${target}' to '${ARG_DESTINATION}'")
    endif()

    if (ARG_TYPE STREQUAL LIBRARY)
        get_target_property(HEADERS ${target} PUBLIC_HEADERS)
        if (HEADERS)
            get_target_property(DIR ${target} INCLUDE_DIRECTORY)
            x_install(FILES ${HEADERS} DESTINATION include/${DIR})
        endif()
    endif()
endfunction()

function(__commander_install_directories destination)
    file(COPY ${ARGN} DESTINATION ${CMAKE_BINARY_DIR}/${destination})
    x_install(DIRECTORY ${ARGN} DESTINATION ${destination})
endfunction()

function(__commander_install_files destination)
    file(COPY ${ARGN} DESTINATION ${CMAKE_BINARY_DIR}/${destination})
    x_install(FILES ${ARGN} DESTINATION ${destination})
endfunction()

function(__commander_install_export destination export namespace file)
    export(EXPORT ${export} NAMESPACE ${namespace} FILE ${CMAKE_BINARY_DIR}/${destination}/${file})
    x_install(EXPORT EXPORT ${export} NAMESPACE ${namespace} FILE ${file}
        DESTINATION ${destination}
    )
endfunction()
