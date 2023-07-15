cmake_minimum_required(VERSION 3.20)

project(Commander
    DESCRIPTION "Commander utility cmake package"
    VERSION     1.0.0
)

option(Commander_BUILD_EXAMPLES "Build examples" OFF)

add_subdirectory(src)

if (Commander_BUILD_EXAMPLES)
    find_package(Commander REQUIRED
        PATHS ${CMAKE_BINARY_DIR}/lib/cmake
        HINTS ${CMAKE_BINARY_DIR}/lib/cmake
        NO_DEFAULT_PATH NO_CMAKE_PATH
    )

    add_subdirectory(examples)
endif()
