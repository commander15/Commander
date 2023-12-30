import Commander

import QtQuick
import QtQuick.Layouts

AppImage {
    id: image

    property url fallbackSource
    property alias fallbackImageItem: fallbackImage

    imageItem.visible: imageItem.status === Image.Ready

    AppImage {
        id: fallbackImage

        source: image.fallbackSource
        sourceSize: image.sourceSize
        cache: false

        horizontalAlignment: image.horizontalAlignment
        verticalAlignment: image.verticalAlignment

        fillMode: image.fillMode

        radius: image.radius
        rounded: image.rounded

        visible: image.imageItem.status !== Image.Ready

        anchors.fill: parent
    }
}
