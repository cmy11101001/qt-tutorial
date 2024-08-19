#ifndef UPDATEIMAGE_H
#define UPDATEIMAGE_H

#include <QObject>
#include <QQuickImageProvider>

class UpdateImageProvider : public QQuickImageProvider
{
public:
    UpdateImageProvider();

    // 必须实现，给QML获取图片用的
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);

public:
    QPixmap pixmap;
};

class UpdateImage : public QObject
{
    Q_OBJECT
public:
    explicit UpdateImage(QObject *parent = nullptr);

    // 设置图片，发出updatePixmap信号在QML更新
    Q_INVOKABLE void setPixmap(QPixmap pixmap);

public:
    UpdateImageProvider *m_pUpdateImageProvider;

signals:
    void updatePixmap();

};

#endif // UPDATEIMAGE_H
