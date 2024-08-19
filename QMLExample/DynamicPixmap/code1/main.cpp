#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include "imageprovider.h"
#include "updateimage.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    ImageProvider *imageProvider = new ImageProvider;
    engine.addImageProvider(QLatin1String("colors"), imageProvider);
    UpdateImage *updateImage = new UpdateImage;
    engine.rootContext()->setContextProperty("UpdateImage", updateImage);
    engine.addImageProvider(QLatin1String("UpdateImage"), updateImage->m_pUpdateImageProvider);

    engine.load(url);

    //! 测试，循环切换图片，在QML显示
    QTimer *timer = new QTimer(updateImage);
    QObject::connect(timer, &QTimer::timeout, [updateImage, imageProvider]() {
        static int i = 0;
        updateImage->setPixmap(imageProvider->getPixmap(i));
        i++;
        if (i >= 8) {
            i = 0;
        }
    });
    timer->setInterval(100);
    timer->setSingleShot(false);
    timer->start();
    //!

    return app.exec();
}
