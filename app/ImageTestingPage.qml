import Commander

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AppPage {
    id: page

    title: "Image Testing"

    contentMargins: 32

    ColumnLayout {
        Item {
            id: canva

            Layout.fillWidth: true
            Layout.fillHeight: true

            TestImage {
                source: "file:///home/commander/Desktop/dDtxMHBdspAvc0LbSVEougFuBkW.jpg"
                radius: radiusSlider.value
                height: sizeSlider.value
                width: sizeSlider.value
            }

            MouseArea {
                drag.target: parent
                drag.axis: Drag.XAndYAxis
                drag.maximumX: canva.width
                drag.maximumY: canva.height
                anchors.fill: parent
            }
        }

        Slider {
            id: sizeSlider
            value: canva.width / 2
            from: 0
            to: canva.width
            Layout.fillWidth: true
        }

        Slider {
            id: radiusSlider
            value: 0
            from: 0
            to: 32
            Layout.fillWidth: true
        }
    }
}
