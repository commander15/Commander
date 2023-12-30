cm_add_library(core STATIC)

configure_file(config.h.in ${CMAKE_CURRENT_SOURCE_DIR}/config.h @ONLY)

target_headers(core
    PUBLIC
        global.h config.h
        application.h
)

target_sources(core
    PRIVATE
        application.cpp
)

generate_target_headers(core FOLDER Commander)

target_link_libraries(core PUBLIC Qt::Quick)
