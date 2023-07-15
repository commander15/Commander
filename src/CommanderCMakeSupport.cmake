# CMake plocies
cmake_policy(SET CMP0076 NEW)

# CXX config
set(CXX_STANDARD 17)
set(CXX_STANDARD_REQUIRED ON)

# C setup
set(C_STANDARD 11)
set(C_STANDARD_REQUIRED ON)

# Shared libraries setup
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# Output directories
set(CMAKE_APP_OUTPUT_DIRECTORY         ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_TOOL_OUTPUT_DIRECTORY        ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_SERVICE_OUTPUT_DIRECTORY     ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_PLUGIN_OUTPUT_DIRECTORY      ${CMAKE_BINARY_DIR}/plugins)
set(CMAKE_QMLPLUGIN_OUTPUT_DIRECTORY   ${CMAKE_BINARY_DIR}/qml)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY     ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_TRANSLATION_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/translations)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY     ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY     ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY     ${CMAKE_BINARY_DIR}/bin)

# Packages helper
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
    list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
endif()

macro(find_package)
    if (NOT CMAKE_FIND_PACKAGE_NAME)
        _find_package(${ARGN})
    else()
        _find_package(${ARGN} CONFIG)
    endif()
endmacro()

# Qt
set(CMAKE_AUTOMOC ${Qt5_FOUND})