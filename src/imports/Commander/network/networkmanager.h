#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QtCore/qthread.h>
#include <QtCore/qqueue.h>
#include <QtCore/qmutex.h>

#include <QtQml/qqmlnetworkaccessmanagerfactory.h>

class NetworkRunnable;

class NetworkManager : public QThread
{
    Q_OBJECT

public:
    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    void start(NetworkRunnable *runnable);

    void setFactory(QQmlNetworkAccessManagerFactory *factory);

private:
    void run() override;

    QQueue<NetworkRunnable*> queue;
    QMutex mutex;

    QNetworkAccessManager *manager;
    QQmlNetworkAccessManagerFactory *factory;
};

class NetworkRunnable
{
public:
    virtual void run(QNetworkAccessManager *manager) = 0;
};

#endif // NETWORKMANAGER_H
