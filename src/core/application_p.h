#ifndef COMMANDER_APPLICATION_P_H
#define COMMANDER_APPLICATION_P_H

#include "application.h"

#include <QtQml/qqmlapplicationengine.h>

namespace Commander {

class ApplicationPrivate
{
public:
    ApplicationPrivate(Application *qq);

    void init();

    Application *q;

    QString uri;

    QQmlApplicationEngine engine;

private:
    QUrl mainUrl() const;
};

}

#endif // COMMANDER_APPLICATION_P_H
