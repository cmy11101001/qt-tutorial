#include "imageprovider.h"

ImageProvider::ImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{

}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    int width = 100;
    int height = 50;
    if (size) {
        *size = QSize(width, height);
    }
    QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
                   requestedSize.height() > 0 ? requestedSize.height() : height);
    bool ok;
    pixmap.fill(colorVector[id.toUInt(&ok, 10)]);

    return pixmap;
}

QPixmap ImageProvider::getPixmap(const int &id)
{
    QPixmap pixmap(100, 50);
    pixmap.fill(colorVector[id]);
    return pixmap;
}
