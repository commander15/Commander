import Commander

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AppDrawer {
    id: drawer

    property alias index: itemsView.currentIndex
    property alias model: itemsView.model

    default property alias navDrawerData: contentItem.data

    readonly property string itemType: "NavigationDrawer"

    signal triggered(var item, var properties)

    Flickable {
        contentWidth: drawer.width
        contentHeight: layout.implicitHeight
        clip: true
        anchors.fill: parent

        ColumnLayout {
            id: layout

            anchors.fill: parent

            ListView {
                id: itemsView

                delegate: ItemDelegate {
                    icon.source: model.icon
                    icon.color: "transparent"

                    text: model.text
                    font.pointSize: 12

                    highlighted: ListView.isCurrentItem

                    width: itemsView.width

                    onClicked: function () {
                        drawer.triggered(model.item, value(model.properties))
                        drawer.close()
                    }
                }

                interactive: height < contentHeight
                clip: true

                Layout.fillWidth: true
                Layout.minimumHeight: contentHeight
            }

            Item {
                id: contentItem
                Layout.fillWidth: true

                Component.onCompleted: function() {
                    if (children.length === 1) {
                        children[0].anchors.fill = contentItem;
                        implicitHeight = children[0].implicitHeight;
                    }
                }
            }
        }
    }
}
