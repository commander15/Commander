import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: drawer

    property alias appName: header.appName
    property alias appDescription: header.appDescription

    property alias iconUrl: header.iconUrl
    property alias backgroundUrl: header.backgroundUrl

    default property alias drawerData: contentItem.data

    opacity: 0.8

    topInset: 0
    topPadding: 0

    width: (desktop || landscape || !parent ? header.implicitWidth : parent.width * (portrait ? 0.8 : 0.4))
    height: (parent ? parent.height : implicitHeight)

    ColumnLayout {
        id: layout

        anchors.fill: parent

        AppDrawerHeader {
            id: header

            radius: drawer.background.radius

            Layout.minimumHeight: drawer.height * 0.2
            Layout.fillWidth: true
        }

        Item {
            id: contentItem

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
