function(add_package name)
    set(options)
    set(oneValueArgs NAME VERSION NAMESPACE EXPORT PARENT)
    set(multiValueArgs)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ARG_NAME)
        set(ARG_NAME ${name})
    endif()

    if (NOT ARG_VERSION)
        set(ARG_VERSION ${CMAKE_PROJECT_VERSION})
    endif()

    if (NOT ARG_NAMESPACE)
        set(ARG_NAMESPACE ${ARG_NAME}::)
    endif()

    if (NOT ARG_EXPORT)
        set(ARG_EXPORT ${ARG_NAME}Targets)
    endif()

    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_NAME}Config.cmake)
        set(COMPONENTS [=[${NAME_FIND_COMPONENTS}]=])
        string(REPLACE "NAME" ${ARG_NAME} COMPONENTS ${COMPONENTS})

        set(TARGETS [=[${CMAKE_CURRENT_LIST_DIR}/NAMETargets.cmake]=])
        string(REPLACE "NAME" ${ARG_NAME} TARGETS ${TARGETS})

        file(WRITE ${ARG_NAME}Config.cmake
            "if (${ARG_NAME}_FOUND)\n"
            "    return()\n"
            "endif()\n"
            "\n"
            "foreach (Component ${COMPONENTS})\n"
            "endforeach()\n\n"
            "# Welcome back Commander !\n\n"
            "#include(${TARGETS})"
        )
    endif()

    include(CMakePackageConfigHelpers)
    write_basic_package_version_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_NAME}ConfigVersion.cmake
        VERSION       ${ARG_VERSION}
        COMPATIBILITY AnyNewerVersion
        ARCH_INDEPENDENT
    )

    add_custom_target(${name} ALL
        SOURCES
            ${ARG_NAME}Config.cmake
            ${ARG_NAME}ConfigVersion.cmake
            ${ARG_UNPARSED_ARGUMENTS}
    )

    set_target_properties(${name} PROPERTIES
        PACKAGE_NAME      ${ARG_NAME}
        PACKAGE_VERSION   ${ARG_VERSION}
        PACKAGE_NAMESPACE ${ARG_NAMESPACE}
        PACKAGE_EXPORT    ${ARG_EXPORT}
        PACKAGE_EXPORTING OFF
    )

    if (ARG_PARENT)
        add_dependencies(${ARG_PARENT} ${name})
    endif()

    __commander_register_target(${name} PACKAGE)
endfunction()

function(package_targets package)
    get_target_property(TARGETS ${package} TARGETS)

    if (TARGETS)
        list(APPEND TARGETS ${ARGN})
    else()
        set(TARGETS ${ARGN})
    endif()

    set_target_properties(${package}
        PROPERTIES TARGETS ${TARGETS}
    )

    add_dependencies(${package} ${ARGN})
endfunction()

function(add_app name)
    commander_add_app(${name} ${ARGN})
    __commander_register_target(${name} APP)
endfunction()

function(app_link_services app)
    get_target_property(SERVICES ${app} APP_SERVICES)
    get_target_property(AR_DIR ${app} ARCHIVE_OUTPUT_DIRECTORY)
    get_target_property(LI_DIR ${app} LIBRARY_OUTPUT_DIRECTORY)
    get_target_property(RU_DIR ${app} RUNTIME_OUTPUT_DIRECTORY)

    if (SERVICES)
        list(APPEND SERVICES ${ARGN})
    else()
        set(SERVICES ${ARGN})
    endif()

    set_target_properties(${app} PROPERTIES APP_SERVICES ${SERVICES})

    set_target_properties(${ARGN} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${AR_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${LI_DIR}
        RUNTIME_OUTPUT_DIRECTORY ${RU_DIR}
    )
endfunction()

function(add_service name)
    commander_add_service(${name} ${ARGN})
    __commander_register_target(${name} SERVICE)
endfunction()

function(add_tool name)
    commander_add_tool(${name} ${ARGN})
    __commander_register_target(${name} TOOL)
endfunction()

function(add_plugin name)
    set(options QML)
    set(oneValueArgs NAME VERSION GROUP)
    set(multiValueArgs QML_SOURCES CPP_SOURCES)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})

    if (NOT ARG_NAME)
        set(ARG_NAME ${name})
    endif()

    if (NOT ARG_VERSION)
        set(ARG_VERSION ${CMAKE_PROJECT_VERSION_MAJOR}.${CMAKE_PROJECT_VERSION_MINOR})
    endif()

    if (NOT ARG_QML AND ARG_QML_SOURCES)
        set(ARG_QML TRUE)
    endif()

    commander_add_plugin(${name}
        ${ARG_QML_SOURCES}
        ${ARG_CPP_SOURCES}
        ${ARG_UNPARSED_ARGUMENTS}
    )

    set_target_properties(${name} PROPERTIES
        PLUGIN_NAME      ${ARG_NAME}
        PLUGIN_VERSION   ${ARG_VERSION}
        PLUGIN_GROUP     "${ARG_GROUP}"
        QML              ${ARG_QML}
        QML_SOURCES      "${ARG_QML_SOURCES}"
    )

    __commander_register_target(${name} PLUGIN)
endfunction()

function(add_library name)
    set(options OBJECT INTERFACE IMPORTED ALIAS)
    set(multiValueArgs)
    set(oneValueArgs)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})

    if (ARG_OBJECT OR ARG_INTERFACE OR ARG_IMPORTED OR ARG_ALIAS)
        add_x_library(${name} ${ARGN})
    else()
        commander_add_library(${name} ${ARGN})
        __commander_register_target(${name} LIBRARY)
    endif()
endfunction()

function(add_test name)
    set(options)
    set(oneValueArgs WORKING_DIRECTORY)
    set(multiValueArgs ARGUMENTS SOURCES)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${type} ${ARGN})

    commander_add_test(${name}
        "${ARG_ARGUMENTS}" "${ARG_WORKING_DIRECTORY}"
        "${ARG_SOURCES}"
    )
    __commander_register_target(${name} TEST)
endfunction()

function(add_translation name)
    add_custom_target(${name} ALL SOURCES ${ARGN})
    __commander_register_target(${name} TRANSLATION)
endfunction()

function(target_headers target)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs PUBLIC PRIVATE)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_target_property(INCLUDE_DIR ${target} INCLUDE_DIRECTORY)
    if (NOT INCLUDE_DIR)
        set(INCLUDE_DIR .)
    endif()
    set(INCLUDE_DIR ${CMAKE_BINARY_DIR}/include/${INCLUDE_DIR})

    if (ARG_PUBLIC)
        commander_generate_nested_headers(${INCLUDE_DIR} ${ARG_PUBLIC})
    endif()

    if (ARG_PRIVATE)
        commander_generate_nested_headers(${INCLUDE_DIR}/private ${ARG_PRIVATE})
    endif()

    get_target_property(PUBLIC_HEADERS ${target} PUBLIC_HEADERS)
    get_target_property(PRIVATE_HEADERS ${target} PRIVATE_HEADERS)

    set_target_properties(${target} PROPERTIES
        PUBLIC_HEADERS  ${PUBLIC_HEADERS};${ARG_PUBLIC_HEADERS}
        PRIVATE_HEADERS ${PRIVATE_HEADERS};${ARG_PRIVATE_HEADERS}
    )
endfunction()

function(install type)
    cmake_language(EVAL CODE
        "cmake_language(DEFER CALL __commander_install ${type} ${ARGN})"
    )
endfunction()

# Substitutes

macro(add_x_executable)
    add_executable(${ARGN})
endmacro()

macro(add_x_library)
    _add_library(${ARGN})
endmacro()

macro(add_x_test)
    _add_test(${ARGN})
endmacro()

macro(x_install)
    _install(${ARGN})
endmacro()

# Utilities

macro(commanger_get_qml_plugin_files target files)
    get_target_property(TMP ${target} QMLDIR_FILE)
    if (TMP)
        list(APPEND ${files} ${TMP})
    endif()

    get_target_property(TMP ${target} QMLTYPES_FILE)
    if (TMP)
        list(APPEND ${files} ${TMP})
    endif()

    get_target_property(TMP ${target} QML_SOURCES)
    if (TMP)
        list(APPEND ${files} ${TMP})
    endif()
endmacro()

macro(commander_generate_nested_headers dir)
    foreach (header ${ARGN})
        if (EXISTS ${header})
        elseif (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${header})
            set(header ${CMAKE_CURRENT_SOURCE_DIR}/${header})
        else()
            message(WARNING "Header file ${header} not found")
        endif()

        string(FIND ${header} / pos REVERSE)
        string(SUBSTRING ${header} ${pos} -1 file)
        set(file ".${file}")

        file(RELATIVE_PATH path ${dir} ${header})
        file(WRITE ${dir}/${file} "#include \"${path}\"")
    endforeach()
endmacro()

macro(comander_get_target_dirs target source_dir binary_dir)
    get_target_property(${source_dir} ${target} SOURCE_DIR)
    get_target_property(${binary_dir} ${target} BINARY_DIR)
endmacro()
