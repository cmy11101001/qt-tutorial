#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QVector>

class ImageProvider : public QQuickImageProvider
{
public:
    ImageProvider();

    // 必须实现，给QML获取图片用的
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);

    // 测试用，返回对应id图片
    QPixmap getPixmap(const int &id);

private:
    QVector<QColor> colorVector {
        Qt::red,        // 红色
        Qt::green,      // 绿色
        Qt::blue,       // 蓝色
        Qt::yellow,     // 黄色
        Qt::cyan,       // 青色
        Qt::magenta,    // 洋红色
        Qt::darkGray,   // 深灰色
        Qt::lightGray   // 浅灰色
    };
};

#endif // IMAGEPROVIDER_H
