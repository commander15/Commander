import QtQuick
import QtQuick.Controls

StackView {
    id: stack

    readonly property string currentTitle: (currentPage ? currentPage.title : "")
    readonly property Component currentToolBar: (currentPage ? currentPage.toolBar : null)
    readonly property AppPage currentPage: (currentItem ? currentItem : null)

    readonly property string itemType: "NavigationStack"

    Component.onCompleted: function() {
        if (children.length === 1)
            push(children[0]);
    }
}
