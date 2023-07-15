add_package(testpkg NAME Test)

add_app(app app.cpp)
add_tool(tool tool.cpp)
add_service(service service.cpp)
add_plugin(plugin NAME Plugin GROUP testing plugin.cpp)
add_plugin(qmlplugin NAME QmlPlugin QML_SOURCES QmlPlugin.qml CPP_SOURCES qmlplugin.cpp)
add_library(lib plugin.cpp qmlplugin.cpp)
add_translation(french test_fr.ts)

install(TARGETS app tool service plugin qmlplugin lib french
    PACKAGE     testpkg
    APP         DESTINATION bin
    TOOL        DESTINATION bin
    SERVICE     DESTINATION bin
    PLUGIN      DESTINATION plugins
    QMLPLUGIN   DESTINATION qml
    LIBRARY     DESTINATION lib bin
    TRANSLATION DESTINATION translations
)

install(PACKAGE testpkg DESTINATION lib/cmake/Test)
