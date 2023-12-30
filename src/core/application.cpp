#include "application.h"
#include "application_p.h"

#ifdef Q_OS_ANDROID
#endif

namespace Commander {

Application::Application(int &argc, char **argv) :
    QGuiApplication(argc, argv),
    d(new ApplicationPrivate(this))
{
    d->init();
}

Application::~Application()
{
}

QString Application::uri() const
{
    return d->uri;
}

void Application::setUri(const QString &uri)
{
    d->uri = uri;
}

QQmlApplicationEngine *Application::engine() const
{
    return &d->engine;
}

void Application::hideSplashScreen(QObject *object, const QUrl &)
{
#ifdef Q_OS_ANDROID
    if (object)
        qApp->nativeInterface<QNativeInterface::QAndroidApplication>()->hideSplashScreen(100);
    else
        qApp->quit();
#endif
}

ApplicationPrivate::ApplicationPrivate(Application *qq) :
    q(qq)
{
#ifdef Q_OS_ANDROID
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, qq, &Application::hideSplashScreen);
#endif
}

void ApplicationPrivate::init()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    engine.addImportPath("/opt/Commander/gcc_64");
#elif defined(Q_OS_ANDROID)
    engine.addImportPath("/opt/Commander/android");
#elif defined(Q_OS_WINDOWS)
    engine.addImportPath("C:/Commander/msvc2019_64");
#endif

    engine.load(mainUrl());
}

QUrl ApplicationPrivate::mainUrl() const
{
    return QUrl("qrc:/qt/qml/" + uri + "/main.qml");
}

} // namespace Commander
