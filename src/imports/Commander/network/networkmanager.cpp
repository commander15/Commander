#include "networkmanager.h"

#include <QtNetwork/qnetworkaccessmanager.h>

#include <QtCore/qtimer.h>

NetworkManager::NetworkManager(QObject *parent) :
    QThread(parent)
{
    setTerminationEnabled(false);
}

NetworkManager::~NetworkManager()
{
    if (isRunning()) {
        requestInterruption();
        wait();
    }

    if (factory)
        delete factory;
}

void NetworkManager::start(NetworkRunnable *runnable)
{
    mutex.lock();
    queue.enqueue(runnable);
    mutex.unlock();

    if (!isRunning())
        QThread::start();
}

void NetworkManager::setFactory(QQmlNetworkAccessManagerFactory *factory)
{
    this->factory = factory;
}

void NetworkManager::run()
{
    QTimer timer;
    timer.setInterval(20);

    if (factory)
        manager = factory->create(&timer);
    else
        manager = new QNetworkAccessManager(&timer);

    connect(&timer, &QTimer::timeout, &timer, [this] {
        if (isInterruptionRequested())
            quit();

        NetworkRunnable *runnable = nullptr;
        mutex.lock();
        if (!queue.isEmpty())
            runnable = queue.dequeue();
        mutex.unlock();

        if (runnable)
            runnable->run(manager);
    });

    timer.start();
    exec();
    manager = nullptr;
}
