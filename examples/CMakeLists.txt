cmake_minimum_required(VERSION 3.20)

project(Project
    DESCRIPTION ""
    VERSION     1.0.0
    LANGUAGES   CXX C
)

find_package(Cm REQUIRED COMPONENTS QtCore)

add_subdirectory(src)
