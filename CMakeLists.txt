cmake_minimum_required(VERSION 3.20)

project(Commander
    DESCRIPTION "Commander's QML extender"
    VERSION     1.0.0
    LANGUAGES   CXX C
)

option(Commander_BUILD_APP "Build Commander App" ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY} CACHE STRING "")

find_package(Cm REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_policy(SET QTP0001 NEW)

if (ANDROID)
    qt_policy(SET QTP0002 NEW)
endif()

add_subdirectory(src)

if (Commander_BUILD_APP)
    find_package(RestLink REQUIRED COMPONENTS Qml)
    set(QML_IMPORT_PATH "${QT_QML_OUTPUT_DIRECTORY};${RestLink_QML_IMPORT_PATH}" CACHE STRING "" FORCE)
    add_subdirectory(app)
endif()
