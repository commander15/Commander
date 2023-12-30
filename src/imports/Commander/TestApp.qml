import Commander 1.0

import QtQuick 2.1

App {
    title: "Test"
    forceMobile: true

    Navigation {
        navigationMode: Navigation.StackNavigation

        AppPage {
            id: main

            title: "Main"
            toolBar: AppLabel {
                text: "Hello !"
            }

            Rectangle {
                color: "blue"
                radius: 6
                width: 100
                height: 50
                clip: true
            }

            Timer {
                interval: 3000
                repeat: false
                running: true

                onTriggered: function() {
                    main.title = "Yep !";
                    main.toolBar.text = "Yep Yep";
                    main.parent.push("AppLabel.qml", {"text": "Hello"});
                }
            }
        }
    }
}
