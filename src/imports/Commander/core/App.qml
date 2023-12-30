import Commander

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    property NavigationDrawer drawer
    property NavigationBar navBar
    property Item nav

    readonly property string version: CommanderHelper.appVersion

    property real spScale: 1
    property real dpScale: 1
    property real devDpi: CommanderHelper.devDpi

    readonly property bool portrait: height > width
    readonly property bool landscape: width > height

    readonly property bool mobile: (Qt.platform.os === "android") || forceMobile
    readonly property bool tablet: mobile && (Math.sqrt(width ** 2 + height ** 2)) > 480
    readonly property bool desktop: !mobile
    property bool forceMobile: false

    default property alias appData: contentLayout.data

    function objectValue(object, prop, defVal, condition) {
        if (object && prop)
            return value(object[prop], defVal, condition);
        else
            return value(null, defVal, condition);
    }

    function value(val, defVal, condition)
    {
        if (defVal === undefined)
            defVal = "";

        if (condition === undefined)
            condition = (val !== undefined);

        return (condition ? val : defVal);
    }

    function sp(px)
    { return CommanderHelper.sp(px) * spScale; }
    
    function dp(px)
    { return CommanderHelper.dp(px) * dpScale; }

    function fileUrl(fileName)
    { return CommanderHelper.fileUrl(fileName); }

    function readFile(fileName)
    { return CommanderHelper.readFile(fileName); }

    function writeFile(fileName, data)
    { return CommanderHelper.writeFile(fileName, data); }

    signal backRequested()

    width: (mobile ? 480 : 840)
    height: (mobile ? 840 : 480)

    onClosing: function(close) {
        if (Qt.platform.os === "android" && nav) {
            if (nav.depth > 1) {
                nav.pop();
                close.accepted = false;
            } else
                close.accepted = true;
        }
    }

    Component.onCompleted: function() {
        CommanderHelper.init(this);
        visible = true;
    }

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            id: contentLayout
            spacing: 0

            Layout.fillWidth: true
            Layout.fillHeight: true

            Component.onCompleted: function() {
                for (var i = 0; i < children.length; ++i) {
                    var child = children[i];
                    child.Layout.fillWidth = true;

                    if (i === 1 || (i > 0 && i < children.length - 1))
                        child.Layout.fillHeight = true;

                    if (!child.itemType)
                        continue;
                    else if (child.itemType === "NavigationBar")
                        navBar = child;
                    else if (child.itemType === "NavigationStack")
                        nav = child;
                    else if (child.itemType === "NavigationTab")
                        nav = child;
                }

                for (i = 0; i < resources.length; ++i) {
                    child = resources[i];

                    if (!child.itemType)
                        continue;
                    else if (child.itemType === "NavigationDrawer") {
                        window.drawer = child;
                        break;
                    }
                }
            }
        }

        Control {
            background: Rectangle {
                color: "black"
            }

            visible: window.forceMobile && Qt.platform.os !== "android"

            Layout.fillWidth: true
            Layout.preferredHeight: 56

            RowLayout {
                anchors.fill: parent

                Button {
                    icon.source: "qrc:/qt/qml/Commander/icons/nav_drawer.png"
                    visible: window.drawer

                    Layout.preferredWidth: 128
                    Layout.alignment: Qt.AlignVCenter|Qt.AlignRight

                    onClicked: window.drawer.open()
                }

                Button {
                    icon.source: "qrc:/qt/qml/Commander/icons/commander_logo.png"
                    visible: window.nav

                    Layout.preferredWidth: 128
                    Layout.alignment: Qt.AlignCenter

                    onClicked: function() {
                        while (window.nav.depth > 1)
                            window.nav.pop();
                    }
                }

                Button {
                    icon.source: "qrc:/qt/qml/Commander/icons/nav_back.png"
                    visible: window.nav

                    Layout.preferredWidth: 128
                    Layout.alignment: Qt.AlignVCenter|Qt.AlignLeft

                    onClicked: window.nav.pop()
                }
            }
        }
    }
}
