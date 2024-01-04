import Commander

import QtQuick
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

Image {
    id: image

    property int radius: 0
    property bool rounded: false

    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter

    fillMode: Image.PreserveAspectFit

    layer.enabled: radius > 0
    layer.smooth: true
    layer.effect: OpacityMask {
        maskSource: Item {
            width: image.width
            height: image.height
            Rectangle {
                radius: !image.rounded ? image.radius : Math.min(width, height)
                width: !image.rounded ? image.width : Math.min(image.width, image.height)
                height: !image.rounded ? image.height : width
                anchors.centerIn: parent
            }
        }
    }
}
