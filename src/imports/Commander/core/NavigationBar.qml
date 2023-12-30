import Commander 1.0

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

AppToolBar {
    id: toolBar

    property string title: "Commander"

    property string pageTitle
    property Component pageComponent
    property int depth: 0

    property real drawerPosition: 0.0

    readonly property string itemType: "NavigationBar"

    signal drawerRequested()
    signal backRequested()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6

        ToolButton {
            icon.source: "qrc:/qt/qml/Commander/icons/nav_" + (toolBar.depth <= 1 ? "drawer" : "back") + ".png"
            icon.color: "transparent"
            flat: true

            rotation: toolBar.drawerPosition * 360

            onClicked: function() {
                if (toolBar.depth <= 1)
                    toolBar.drawerRequested();
                else
                    toolBar.backRequested();
            }

            Layout.fillHeight: true
        }

        AppLabel {
            text: (toolBar.pageTitle.length > 0 ? toolBar.pageTitle : toolBar.title)
            font.pixelSize: sp(32)
            font.bold: true
            horizontalAlignment: AppLabel.AlignLeft
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Loader {
            sourceComponent: toolBar.pageComponent
            Layout.fillHeight: true
        }
    }
}
