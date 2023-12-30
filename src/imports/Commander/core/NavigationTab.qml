import QtQuick 2.14
import QtQuick.Controls 2.14

SwipeView {
    id: tab

    readonly property string itemType: "NavigationTab"

    function push(item) {
        addItem(item);
    }
}
