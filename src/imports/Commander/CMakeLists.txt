qt_add_qml_module(commander_qml
    URI     Commander
    VERSION 1.0
    RESOURCES
        icons/commander_logo.png
        icons/commander_background.png
        icons/nav_drawer.png
        icons/nav_back.png
        icons/app_search.png
    PLUGIN_TARGET commander_qml
    NO_GENERATE_PLUGIN_SOURCE
    NO_CACHEGEN
)

target_sources(commander_qml
    PRIVATE
        commanderplugin.cpp
        commanderhelper.cpp
        commanderurlinterceptor.cpp
)

target_include_directories(commander_qml
    PRIVATE
        core text image model
)

target_link_libraries(commander_qml PUBLIC Qt::Quick)

add_subdirectory(core)
add_subdirectory(text)
add_subdirectory(image)
add_subdirectory(view)
add_subdirectory(model)
add_subdirectory(network)

install(TARGETS commander_qml
    EXPORT CommanderTargets
    ARCHIVE DESTINATION qml/Commander
    LIBRARY DESTINATION qml/Commander
    RUNTIME DESTINATION qml/Commander
)
qt_query_qml_module(commander_qml
    QMLDIR        DIR
    QML_FILES     FILES
    TYPEINFO      TYPES
    PLUGIN_TARGET TARGET
)

install(FILES ${DIR} ${FILES} ${TYPES} DESTINATION qml/Commander)
