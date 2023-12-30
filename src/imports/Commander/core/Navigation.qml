import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: navigation

    enum NavigationMode {
        StackNavigation,
        TabNavigation
    }

    property alias drawerIndex: drawer.index
    property alias drawerModel: drawer.model
    readonly property alias drawer: drawer

    property int depth: contentLoader.item.depth

    property int navigationMode: Navigation.StackNavigation

    default property alias itemData: contentLoader.data

    readonly property bool portrait: height > width

    function push(item, properties, operation) {
        contentLoader.item.push(item, properties, operation);
    }

    function replace(item, properties, operation) {
        contentLoader.item.replace(null, item, properties, operation);
    }

    function pop(operation) {
        contentLoader.item.pop(operation);
    }

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    NavigationDrawer {
        id: drawer

        interactive: contentLoader.item.depth <= 1
    }

    ColumnLayout {
        id: mainLayout

        spacing: 0

        anchors.fill: parent

        NavigationBar {
            id: navBar

            drawerPosition: drawer.position

            Layout.fillWidth: true

            onDrawerRequested: (drawer.interactive ? drawer.open() : drawer.close())
            onBackRequested: navigation.pop()

            Binding {
                target: navBar
                property: "pageTitle"
                value: contentLoader.item.currentTitle
            }

            Binding {
                target: navBar
                property: "pageComponent"
                value: contentLoader.item.currentToolBar
            }

            Binding {
                target: navBar
                property: "depth"
                value: contentLoader.item.depth
            }
        }

        Loader {
            id: contentLoader

            function depth() {
                if (!item)
                    return -1;
                else if (item.depth)
                    return item.depth;
                else if (item.index)
                    return item.index;
                else
                    return -1;
            }

            function navigationComponent(mode) {
                switch (mode) {
                case Navigation.StackNavigation:
                    return stackNav;

                case Navigation.TabNavigation:
                default:
                    return swipeNav;
                }
            }

            sourceComponent: navigationComponent(navigation.navigationMode)
            //asynchronous: false

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component {
        id: stackNav

        NavigationStack {
            id: stack

            initialItem: contentLoader.children[0]
        }
    }

    Component {
        id: swipeNav

        NavigationTab {
            id: swipe
        }
    }
}
