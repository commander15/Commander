#include <QtGui/QGuiApplication>

#include <QtQml/QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setProperty("APP_URL", "qrc:/qml/CommanderApp");

    QQmlApplicationEngine engine;
#if defined(Q_OS_LINUX) || defined(Q_OS_WINDOWS)
    engine.addImportPath("../qml");
    engine.addImportPath("/opt/Commander/gcc_64/Debug/qml");
#endif

    const QUrl url("qrc:/qml/CommanderApp/main.qml");
    engine.load(url);

    return app.exec();
}
