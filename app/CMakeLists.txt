qt_add_executable(app
    main.cpp
)

qt_add_qml_module(app
    URI CommanderApp
    QML_FILES
        main.qml
    RESOURCES
        icon.png
        bad.png
    RESOURCE_PREFIX qml
    IMPORT_PATH ${RestLink_QML_IMPORT_PATH}
    DEPENDENCIES RestLink
    QML_FILES ImageTestingPage.qml
    QML_FILES TestImage.qml
)

qt_target_qml_sources(app
    RESOURCES
        qtquickcontrols2.conf
    PREFIX /
)

set_target_properties(app PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

target_link_libraries(app PRIVATE Qt::Quick RestLink::restlink)
