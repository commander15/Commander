#ifndef COMMANDERHELPER_H
#define COMMANDERHELPER_H

#include <QtQml/QQmlEngine>

#include <QtQuick/qquickwindow.h>

class CommanderHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)
    Q_PROPERTY(double devDpi READ devDpi WRITE setDevDpi NOTIFY devDpiChanged)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit CommanderHelper(QObject *parent = nullptr);
    ~CommanderHelper();

    QString appVersion() const;

    Q_INVOKABLE void init(QQuickWindow *win);

    Q_INVOKABLE int sp(int size);
    Q_INVOKABLE int dp(int size);

    double devDpi() const;
    Q_SLOT void setDevDpi(double dpi);
    Q_SIGNAL void devDpiChanged();

    Q_INVOKABLE QUrl fileUrl(const QString &fileName);
    Q_INVOKABLE QString readFile(const QString &fileName);
    Q_INVOKABLE bool writeFile(const QString &fileName, const QString &data);

private:
    static QString fileName(QString fileName);

    double m_devDpi;
};

#endif // COMMANDERHELPER_H
