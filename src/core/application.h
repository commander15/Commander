#ifndef COMMANDER_APPLICATION_H
#define COMMANDER_APPLICATION_H

#include <Commander/global.h>

#include <QtGui/qguiapplication.h>

class QQmlApplicationEngine;

namespace Commander {

class ApplicationPrivate;
class COMMANDER_EXPORT Application : public QGuiApplication
{
public:
    Application(int &argc, char **argv);
    ~Application();

    QString uri() const;
    void setUri(const QString &uri);

    QQmlApplicationEngine *engine() const;

private:
    Q_SLOT void hideSplashScreen(QObject *object, const QUrl &);

    QScopedPointer<ApplicationPrivate> d;

    friend class ApplicationPrivate;
};

} // namespace Commander

#endif // COMMANDER_APPLICATION_H
