import QtQuick
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

Item {
    id: image

    property url source
    property size sourceSize

    property int horizontalAlignment: Image.AlignHCenter
    property int verticalAlignment: Image.AlignVCenter

    property int fillMode: Image.PreserveAspectFit

    property bool cache: true

    property int radius: 6
    property bool rounded: false

    readonly property alias imageItem: internalImage

    default property alias imageData: internalImage.data

    implicitWidth: internalImage.implicitWidth
    implicitHeight: internalImage.implicitHeight

    onRadiusChanged: function() {
        internalImage.layer.effect = null;
        internalImage.layer.enabled = maskComponent;
    }

    Image {
        id: internalImage

        source: image.source
        sourceSize: image.sourceSize
        asynchronous: true

        horizontalAlignment: image.horizontalAlignment
        verticalAlignment: image.verticalAlignment

        fillMode: image.fillMode

        layer.enabled: image.radius > 0
        layer.effect: maskComponent

        Component {
            id: maskComponent
            OpacityMask {
                maskSource: Item {
                    width: image.width
                    height: image.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: !image.rounded ? image.width : Math.min(
                                                    image.width, image.height)
                        height: !image.rounded ? image.height : width
                        radius: image.radius //Math.min(width, height)
                    }
                }
            }
        }

        anchors.fill: parent
    }
}
