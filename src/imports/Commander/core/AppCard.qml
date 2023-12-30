import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    property Component header
    property Component footer

    property alias spacing: layout.spacing
    property int margins: 6

    readonly property alias contentItem: content
    default property alias contentData: content.data

    color: "white"
    radius: 6

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        spacing: 0
        anchors.fill: parent
        anchors.topMargin: card.margins
        anchors.bottomMargin: card.margins

        Loader {
            sourceComponent: card.header
            visible: status === Loader.Ready
            Layout.fillWidth: true
        }

        Item {
            id: content

            Component.onCompleted: function () {
                if (children.length === 1) {
                    children[0].anchors.fill = content;
                    implicitHeight = children[0].implicitHeight;
                }
            }

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Loader {
            sourceComponent: card.footer
            Layout.fillWidth: true
        }
    }
}
