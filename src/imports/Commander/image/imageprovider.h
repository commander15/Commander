#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QtQuick/qquickimageprovider.h>

#include "../network/networkmanager.h"

class QQmlNetworkAccessManagerFactory;
class QNetworkAccessManager;

class ImageProvider : public QQuickAsyncImageProvider
{
    Q_OBJECT

public:
    ImageProvider();
    ~ImageProvider();

    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;

private:
    NetworkManager manager;
};

#endif // IMAGEPROVIDER_H
