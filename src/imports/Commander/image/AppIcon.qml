import Commander

import QtQuick 2.14
import QtQuick.Controls 2.14

Item {
    id: icon
    
    property url source
    property size size: Qt.size(dp(64), dp(64))

    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight
    
    Image {
        id: image

        source: icon.source
        sourceSize: icon.size

        fillMode: Image.PreserveAspectFit

        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        anchors.fill: parent
    }
}
