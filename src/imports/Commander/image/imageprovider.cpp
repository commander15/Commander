#include "imageprovider.h"

#include "imageresponse.h"

#include <QtQml/qqmlnetworkaccessmanagerfactory.h>

#include <QtNetwork/qnetworkaccessmanager.h>
#include <QtNetwork/qnetworkdiskcache.h>

#include <QtCore/qstandardpaths.h>

class ImageProviderFactory : public QQmlNetworkAccessManagerFactory
{
public:
    QNetworkAccessManager *create(QObject *parent) override
    {
        QNetworkAccessManager *man = new QNetworkAccessManager(parent);

        QNetworkDiskCache *cache = new QNetworkDiskCache(parent);
        cache->setCacheDirectory(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/Commander/images");
        cache->setMaximumCacheSize(50 * 1024 * 1024);
        man->setCache(cache);

        return man;
    }
};

ImageProvider::ImageProvider()
{
    manager.setFactory(new ImageProviderFactory);
}

ImageProvider::~ImageProvider()
{
}

QQuickImageResponse *ImageProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    class ImageResponse *response = new class ImageResponse;
    response->setId(id);
    response->setSize(requestedSize);
    manager.start(response);
    return response;
}
