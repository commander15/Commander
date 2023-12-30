### CMake Packaging

set(ROOT ".")
set(QML_IMPORT_PATH "qml")

include(CMakePackageConfigHelpers)

configure_package_config_file(
    CommanderConfig.cmake.in CommanderConfig.cmake
    INSTALL_DESTINATION lib/cmake/Commander
    PATH_VARS           ROOT QML_IMPORT_PATH
)

write_basic_package_version_file(
    CommanderConfigVersion.cmake
    VERSION       ${Commander_VERSION}
    COMPATIBILITY AnyNewerVersion
    ARCH_INDEPENDENT
)

set(CMAKE_SOURCES
    CommanderMacros.cmake
    CommanderTargetsMacros.cmake
    CommanderUtilsMacros.cmake
)

add_custom_target(commanderpkg
    SOURCES
        CommanderConfig.cmake.in
        ${CMAKE_SOURCES}
)

install(FILES
    #${CMAKE_SOURCES}
    ${CMAKE_CURRENT_BINARY_DIR}/CommanderConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/CommanderConfigVersion.cmake
    DESTINATION lib/cmake/Commander
)

### Impl

add_subdirectory(core)

add_subdirectory(imports)

install(EXPORT CommanderTargets
    NAMESPACE   Commander::
    FILE        CommanderTargets.cmake
    DESTINATION lib/cmake/Commander
)
