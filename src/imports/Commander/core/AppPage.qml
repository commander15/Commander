import QtQuick 2.14
import QtQuick.Controls 2.14

Page {
    id: page
    
    property Component toolBar

    property bool fillParent: true
    property int contentMargins: 0

    background: null

    Component.onCompleted: function() {
        var c = contentItem.children;
        if (c.length === 1 && fillParent) {
            c[0].anchors.fill = contentItem;
            c[0].anchors.margins = contentMargins;
        }
    }
}
