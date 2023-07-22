# CMake plocies
cmake_policy(SET CMP0076 NEW)

string(TOLOWER ${CMAKE_PROJECT_NAME} CPACK_PACKAGE_NAME)
set(CPACK_PACKAGE_VENDOR "Commander")

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    if (UNIX)
        set(PREFIX "/opt")
    elseif(WIN32)
        set(PREFIX "C:")
    endif()

    set(CMAKE_INSTALL_PREFIX ${PREFIX}/${CMAKE_PROJECT_NAME} CACHE PATH "" FORCE)
endif()

# Directories setup
include(GNUInstallDirs)

# CXX config
set(CXX_STANDARD 17)
set(CXX_STANDARD_REQUIRED ON)

# C setup
set(C_STANDARD 11)
set(C_STANDARD_REQUIRED ON)

# Shared libraries setup
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

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
