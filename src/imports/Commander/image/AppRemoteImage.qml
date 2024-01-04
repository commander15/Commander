import Commander

import QtQuick
import QtQuick.Layouts

AppImage {
    id: image

    property url remoteSource
    property url fallbackSource
    property alias fallbackImageItem: fallbackImage

    function imageSource(url) {
        if (url.toString().length === 0)
            return "";

        if (cache)
            return "image://commander_image/" + url;
        else
            return url.toString();
    }

    source: imageSource(remoteSource)

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

        visible: image.status !== Image.Ready

        anchors.fill: parent
    }
}
