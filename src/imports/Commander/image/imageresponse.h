#ifndef IMAGERESPONSE_H
#define IMAGERESPONSE_H

#include <QtQuick/qquickimageprovider.h>

#include "../network/networkmanager.h"

class ImageResponse : public QQuickImageResponse, public NetworkRunnable
{
    Q_OBJECT

public:
    ImageResponse();
    ~ImageResponse();

    void setId(const QString &id);
    void setSize(const QSize &size);

    QQuickTextureFactory *textureFactory() const override;

    Q_SLOT void cancel() override;

    QString errorString() const override;

    void run(QNetworkAccessManager *netMan) override;

private:
    Q_SIGNAL void cancelRequested();

    QString m_id;
    QSize m_size;

    QString m_errorString;
    QImage m_image;
};

#endif // IMAGERESPONSE_H
