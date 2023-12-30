import QtQml 2.14

RestLinkApi {
    id: api

    default property list<QtObject> data;

    Component.onCompleted: registerParameters()
}
