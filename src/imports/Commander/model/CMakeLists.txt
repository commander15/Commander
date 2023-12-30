qt_target_qml_sources(commander_qml
    QML_FILES
        JsonListModel.qml
        JsonListModelRole.qml
)

target_sources(commander_qml
    PRIVATE
        jsonlistmodel.cpp
)
