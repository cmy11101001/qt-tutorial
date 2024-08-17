#include "updateimage.h"

UpdateImageProvider::UpdateImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap UpdateImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(id)
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    return pixmap;
}

UpdateImage::UpdateImage(QObject *parent)
    : QObject{parent}
    , m_pUpdateImageProvider(new UpdateImageProvider)
{

}

void UpdateImage::setPixmap(QPixmap pixmap)
{
    m_pUpdateImageProvider->pixmap = pixmap;
    emit updatePixmap();
}
