import Commander

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Control {
    id: header

    property url iconUrl: "qrc:/qt/qml/Commander/icons/commander_logo.png"
    property url backgroundUrl: "qrc:/qt/qml/Commander/icons/commander_background.png"

    property string appName: "Commander"
    property string appDescription: "commandersystemsx@gmail.com"

    property int radius: 6

    function computeImplicitWidth() {
        var name = nameLabel.implicitWidth;
        var desc = descriptionLabel.implicitWidth;
        implicitWidth = Math.max(name, desc, 64) + ((layout.anchors.margins + radius) * 2);
    }

    background: AppImage {
        source: header.backgroundUrl
        fillMode: Image.PreserveAspectCrop

        radius: header.radius
        opacity: 0.3
    }

    implicitHeight: layout.implicitHeight

    Component.onCompleted: computeImplicitWidth()

    ColumnLayout {
        id: layout

        spacing: 0
        clip: true

        anchors.fill: parent
        anchors.margins: 9

        AppIcon {
            id: iconView

            source: header.iconUrl
            size: Qt.size(64, 64)

            Layout.fillHeight: true
        }

        AppLabel {
            id: nameLabel

            text: header.appName

            horizontalAlignment: AppLabel.AlignLeft

            font.pointSize: 16
            font.bold: true

            Layout.fillWidth: true
        }

        AppLabel {
            id: descriptionLabel

            text: header.appDescription

            horizontalAlignment: AppLabel.AlignLeft

            font.pointSize: 14

            Layout.fillWidth: true
        }
    }
}
