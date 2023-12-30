### Package

function(cm_add_package name)
    set(options)
    set(oneValueArgs NAME VERSION CONFIG_FILE)
    set(multivalueArgs EXPORTS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_custom_target(${name}
        SOURCES
            ${ARG_CONFIG_FILE}
            ${ARG_UNPARSED_ARGUMENTS}
    )

    set_target_properties(${name} PROPERTIES
        PACKAGE_NAME "${ARG_NAME}"
        VERSION      "${ARG_VERSION}"
        CONFIG_FILE  "${ARG_CONFIG_FILE}"
        EXPORTS      "${ARG_EXPORTS}"
    )

    cm_register_target(${name} PACKAGE)
endfunction()

function(cm_make_package package)
    set(options)
    set(oneValueArgs DIRECTORY DESTINATION FILES_VAR EXPORTS_VAR)
    set(multivalueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_target_property(NAME    ${package} PACKAGE_NAME)
    get_target_property(VERSION ${package} VERSION)
    get_target_property(CONFIG  ${package} CONFIG_FILE)

    set(ROOT ".")

    set(PKG_DIR         ${ARG_DIRECTORY})
    set(PKG_CONFIG_FILE ${PKG_DIR}/${NAME}Config.cmake)
    set(PKG_VER_FILE    ${PKG_DIR}/${NAME}ConfigVersion.cmake)
    file(READ ${CONFIG_FILE} PKG_CONFIG_CONTENT)
    file(WRITE ${PKG_CONFIG_FILE}.in "set(${NAME}_ROOT \"@PACKAGE_ROOT@\")\n\n@PKG_CONFIG_CONTENT@")

    include(CMakePackageConfigHelpers)

    configure_package_config_file(
        ${PKG_CONFIG_FILE}.in ${PKG_CONFIG_FILE}
        INSTALL_DESTINATION ${ARG_DESTINATION}
        PATH_VARS           ROOT
    )

    write_basic_package_version_file(
        ${PKG_VER_FILE}
        VERSION       ${VERSION}
        COMPATIBILITY AnyNewerVersion
        ARCH_INDEPENDENT
    )

    get_target_property(SOURCES ${package} SOURCES)
    get_target_property(EXPORTS ${package} EXPORTS)
    set(${ARG_FILES_VAR} ${PKG_CONFIG_FILE} ${PKG_VER_FILE} ${SOURCES} PARENT_SCOPE)

    get_target_property(EXPORTS ${package} EXPORTS)
    set(${ARG_EXPORTS_VAR} ${EXPORTS} PARENT_SCOPE)
endfunction()

function(cm_generate_package package)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multivalueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    cm_make_package(${package}
        DIRECTORY   "${CMAKE_BINARY_DIR}/lib/cmake/${NAME}"
        DESTINATION "${ARG_DESTINATION}"
        FILES_VARS  FILES
        EXPORTS_VAR EXPORTS
    )

    file(COPY ${FILES} DESTINATION ${ARG_DESTINATION})

    foreach (export ${EXPORTS})
        export(EXPORT ${export} NAMESPACE ${NAME}:: DESTINATION ${ARG_DESTINATION})
    endforeach()
endfunction()

function(cm_install_package package)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multivalueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    cm_make_package(${package}
        DIRECTORY   "${CMAKE_CURRENT_BINARY_DIR}/${NAME}_pkg"
        DESTINATION "${ARG_DESTINATION}"
        FILES_VARS  FILES
        EXPORTS_VAR EXPORTS
    )

    install(FILES ${FILES} DESTINATION ${ARG_DESTINATION})

    foreach (export ${EXPORTS})
        install(EXPORT ${export} NAMESPACE ${NAME}:: DESTINATION ${ARG_DESTINATION})
    endforeach()
endfunction()

### Executable

function(cm_add_executable name)
    qt_add_executable(${name} ${ARGN})
    cm_register_target(${name} EXECUTABLE)
endfunction()

function(cm_install_executable executable)
    install(TARGETS ${executable} ${ARGN})
endfunction()

### Library

function(cm_add_library name)
    qt_add_library(${name} ${ARGN})
    cm_register_target(${name} LIBRARY)
endfunction()

function(cm_install_library library)
    install(TARGETS ${library} ${ARGN})
endfunction()

### Plugin

function(cm_add_plugin name)
    qt_add_plugin(${name} ${ARGN})
    cm_register_target(${name} PLUGIN)
endfunction()

function(cm_install_plugin plugin)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multivalueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    install(TARGETS ${plugin}
        ${ARG_UNPARSED_ARGUMENTS}
        ARCHIVE DESTINATION ${ARG_DESTINATION}
        LIBRARY DESTINATION ${ARG_DESTINATION}
        RUNTIME DESTINATION ${ARG_DESTINATION}
    )
endfunction()

### Module (QML)

function(cm_add_module name)
    qt_add_qml_module(${name} ${ARGN})
    cm_register_target(${name} MODULE)
endfunction()

function(cm_install_module module)
    set(options)
    set(oneValueArgs DESTINATION)
    set(multivalueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    install(TARGETS ${module}
        ${ARG_UNPARSED_ARGUMENTS}
        ARCHIVE DESTINATION ${ARG_DESTINATION}
        LIBRARY DESTINATION ${ARG_DESTINATION}
        RUNTIME DESTINATION ${ARG_DESTINATION}
    )

    qt_query_qml_module(${module}
        QMLDIR    QMLDIR_FILE
        TYPEINFO  TYPEINFO_FILE
        QML_FILES QML_SOURCES
    )

    install(FILES
        ${QMLDIR_FILE} ${TYPEINFO_FILE} ${QML_SOURCES}
        DESTINATION ${ARG_DESTINATION}
    )
endfunction()

### Headers Management

function(target_headers target)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs PUBLIC PRIVATE)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Adding public headers to the target
    if (ARG_PUBLIC)
        list(TRANSFORM ARG_PUBLIC PREPEND ${CMAKE_CURRENT_SOURCE_DIR}/)
        set_property(TARGET ${target} APPEND PROPERTY PUBLIC_HEADER ${ARG_PUBLIC})
    endif()

    # Adding private headers to the target
    if (ARG_PRIVATE)
        list(TRANSFORM ARG_PRIVATE PREPEND ${CMAKE_CURRENT_SOURCE_DIR}/)
        set_property(TARGET ${target} APPEND PROPERTY PRIVATE_HEADER ${ARG_PRIVATE})
    endif()
endfunction()

function(generate_target_headers target)
    set(options)
    set(oneValueArgs DESTINATION FOLDER)
    set(multiValueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ARG_DESTINATION)
        set(ARG_DESTINATION ${CMAKE_BINARY_DIR}/include)
    endif()

    if (NOT ARG_FOLDER)
        set(destination ${ARG_DESTINATION})
    else()
        set(destination ${ARG_DESTINATION}/${ARG_FOLDER})
    endif()

    # Generating public headers on destination
    get_target_property(PUBLIC_HEADERS ${target} PUBLIC_HEADER)
    if (PUBLIC_HEADERS)
        generate_nested_headers(${destination} ${PUBLIC_HEADERS})
    endif()

    # Generating private headers on destination
    get_target_property(PRIVATE_HEADERS ${target} PRIVATE_HEADER)
    if (PRIVATE_HEADERS)
        generate_nested_headers(${destination}/private ${PRIVATE_HEADERS})
    endif()

    # Adding destination to target's include path
    target_include_directories(${target} PUBLIC $<BUILD_INTERFACE:${ARG_DESTINATION}>)
endfunction()

### Common

function(cm_install type)
    if (${type} STREQUAL PACKAGE)
        cm_install_package(${target} ${ARGN})
    elseif (${type} STREQUAL TARGET)
        set(target ${ARGV0})

        get_target_property(TYPE ${target} CM_TYPE)
        string(TOLOWER ${TYPE} type)

        cmake_language(CALL cm_install_${type} ${ARGN})
    else()
        install(${type} ${ARGN})
    endif()
endfunction()

### Internal

function(cm_register_target target type)
    set_target_properties(${target} PROPERTIES
        #AUTOMOC ON
        CM_TYPE ${type}
    )
endfunction()
