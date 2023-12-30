import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bar

    color: "purple"
    radius: 6

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout

        anchors.fill: parent

        AppIcon {
            source: "icons/app_search.png"
            size: Qt.size(dp(32), dp(32))
        }

        TextField {
            placeholderText: qsTr("Search...")

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
