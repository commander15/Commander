qt_target_qml_sources(commander_qml
    QML_FILES
        AppIcon.qml
        AppImage.qml
        AppRemoteImage.qml
)

target_sources(commander_qml PRIVATE
    imageprovider.cpp imageresponse.cpp
)
