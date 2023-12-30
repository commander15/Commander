import Commander
import RestLink

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

App {
    title: "Commander"

    background: AppRemoteImage {
        source: "https://image.tmdb.org/t/p/w500/2StM8Vavf7ukvuj9mxg1o7nKxmi.jpg"
        fallbackSource: "icon.png"
        fillMode: Image.PreserveAspectCrop
        cache: true
        opacity: 0.3
    }

    forceMobile: true
    //devDpi: 126

    NavigationDrawer {
        id: drawer
        interactive: navStack.depth === 1 || opened
        model: JsonListModel {
            data: JSON.parse(!request.response ? "{}" : request.response.data).results

            JsonListModelRole {
                name: "icon"
                propertyName: ""
                value: "icon.png"
            }

            JsonListModelRole {
                name: "text"
                propertyName: "name"
                aliases: ["title"]
            }
        }

        AppLabel {
            text: "Hello"
            anchors.fill: parent
        }
    }

    NavigationBar {
        id: navBar

        title: "Commander"

        drawerPosition: drawer.position
        onDrawerRequested: drawer.open()

        onBackRequested: navStack.pop()

        pageTitle: navStack.currentTitle
        pageComponent: navStack.currentToolBar
        depth: navStack.depth
    }

    NavigationStack {
        id: navStack

        AppPage {
            title: "Welcome"
            toolBar: RowLayout {
                ToolButton {
                    text: "L"
                    onClicked: navStack.push(listPage)

                    Layout.fillHeight: true
                }

                ToolButton {
                    text: "F"
                    onClicked: navStack.push(filePage)

                    Layout.fillHeight: true
                }

                ToolButton {
                    text: "R"
                    onClicked: navStack.push(responsePage)

                    Layout.fillHeight: true
                }

                ToolButton {
                    text: "IT"
                    onClicked: navStack.push("ImageTestingPage.qml")
                }
            }

            AppCard {
                x: 20
                y: 30
                width: 200
                height: 300

                header: AppLabel {
                    text: "Hello"
                    color: "black"
                    Layout.fillWidth: true
                }

                footer: header

                AppImage {
                    source: "file:///home/commander/Desktop/nJUHX3XL1jMkk8honUZnUmudFb9.jpg"
                    fillMode: Image.PreserveAspectCrop
                    //cache: true
                }
            }

            AppRemoteImage {
                x: 100
                y: 300
                width: 200
                height: 300
                source: "http://image.tmdb.org/t/p/w500/dDtxMHBdspAvc0LbSVEougFuBkW.jpg"
                fallbackSource: "file:///home/commander/Desktop/nJUHX3XL1jMkk8honUZnUmudFb9.jpg"
                fillMode: Image.PreserveAspectFit
                radius: 6
            }
        }
    }

    Component {
        id: listPage

        AppPage {
            title: "List"
            toolBar: ToolButton {
                text: "Go"
            }

            ListView {
                id: view

                delegate: RowLayout {
                    width: view.width
                    height: 32

                    AppImage {
                        source: value("https://image.tmdb.org/t/p/w92" + model.poster, "", model.poster)
                        cache: true

                        Layout.fillHeight: true
                    }

                    AppLabel {
                        text: value(model.name, "NO NAME")

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                clip: true

                model: JsonListModel {
                    data: JSON.parse(!request.response ? "{}" : request.response.data).results

                    JsonListModelRole {
                        name: "name"
                        aliases: ["title"]
                    }

                    JsonListModelRole {
                        name: "poster"
                        propertyName: "poster_path"
                    }
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: request.running
                }
            }
        }
    }

    Component {
        id: filePage

        AppPage {
            title: "File"

            AppLabel {
                text: readFile("{DOWNLOADS}/content.json")
            }
        }
    }

    Component {
        id: responsePage

        AppPage {
            title: "Response"

            ScrollView {
                AppLabel {
                    text: (request.response ? request.response.data : "{}")

                    anchors.fill: parent
                }
            }
        }
    }

    ApiRequest {
        id: request

        endpoint: "/search/movie"
        api: Api {
            configurationUrl: "https://commander-systems.000webhostapp.com/RestLink/APIs/Marvel/Discovery/TMDB3.json"
            //configurationUrl: fileUrl("{DOWNLOADS}/Tmdb3.json")

            ApiRequestParameter {
                name: "language"
                value: "fr"
            }
        }

        ApiRequestParameter {
            name: "query"
            value: "Marvel"
        }
    }
}
