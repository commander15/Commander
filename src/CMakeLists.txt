if (ANDROID)
    set(Platform Android)
else()
    set(Platform Default)
endif()

set(SUPPORT_FILE Commander${Platform}Support.cmake)

configure_file(CommanderConfig.cmake.in ${CMAKE_CURRENT_SOURCE_DIR}/CommanderConfig.cmake @ONLY)
configure_file(CommanderConfigVersion.cmake.in ${CMAKE_CURRENT_SOURCE_DIR}/CommanderConfigVersion.cmake)

set(SOURCES
    CommanderConfig.cmake CommanderConfigVersion.cmake
    CommanderMacros.cmake CommanderInternals.cmake
    CommanderCMakeSupport.cmake
    ${SUPPORT_FILE}
)

add_custom_target(commander SOURCES ${SOURCES})

file(COPY ${SOURCES} DESTINATION ${CMAKE_BINARY_DIR}/lib/cmake/Commander)
install(FILES ${SOURCES} DESTINATION lib/cmake/Commander)
