#include "imageresponse.h"

#include <QtNetwork/qnetworkreply.h>

ImageResponse::ImageResponse()
{
}

ImageResponse::~ImageResponse()
{
}

void ImageResponse::setId(const QString &id)
{
    m_id = id;
}

void ImageResponse::setSize(const QSize &size)
{
    m_size = size;
}

QQuickTextureFactory *ImageResponse::textureFactory() const
{
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

void ImageResponse::cancel()
{
    emit cancelRequested();
}

QString ImageResponse::errorString() const
{
    return m_errorString;
}

void ImageResponse::run(QNetworkAccessManager *netMan)
{
    QNetworkRequest request((QUrl(m_id)));
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    QNetworkReply *reply = netMan->get(request);

    connect(this, &ImageResponse::cancelRequested, reply, &QNetworkReply::abort);

    connect(reply, &QNetworkReply::finished, reply, [this, reply] {
        if (reply->error() == QNetworkReply::NoError) {
            m_image.loadFromData(reply->readAll());

            if (m_size.isValid())
                m_image = m_image.scaled(m_size);
        } else {
            m_errorString = reply->errorString();
        }
    });

    connect(reply, &QNetworkReply::finished, this, &QQuickImageResponse::finished);

    connect(reply, &QNetworkReply::finished, reply, &QObject::deleteLater);
}
