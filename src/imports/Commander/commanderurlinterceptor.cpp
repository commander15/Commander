#include "commanderurlinterceptor.h"

#include <QtCore/qcoreapplication.h>
#include <QtCore/qvariant.h>
#include <QtCore/qurl.h>
#include <QtCore/qfile.h>

#define COMMANDER_URL QStringLiteral("/qt/qml/Commander")

CommanderUrlInterceptor::CommanderUrlInterceptor()
{
    QString url = qApp->property("APP_URL").toString();
    if (!url.isEmpty())
        m_baseUrl = url;
    else {
        QString uri = qApp->property("APP_URI").toString();
        m_baseUrl = "qrc:/qt/qml/" + uri;

        qDebug("URL: %s", m_baseUrl.toString().toStdString().c_str());
    }
}

bool CommanderUrlInterceptor::canIntercept(const QUrl &path, DataType type) const
{
    switch (type) {
    case UrlString:
    case QmlFile:
        return !path.path().startsWith("image://")
               && path.path().startsWith(COMMANDER_URL)
               && !QFile::exists(':' + path.path());

    default:
        return false;
    }
}

QUrl CommanderUrlInterceptor::intercept(const QUrl &path, DataType type)
{
    if (canIntercept(path, type)) {
        QString urlPath = path.path();
        urlPath.replace(COMMANDER_URL, m_baseUrl.toString());
        urlPath.replace("//", "/");
        return urlPath;
    } else
        return path;
}

QUrl CommanderUrlInterceptor::m_baseUrl;
