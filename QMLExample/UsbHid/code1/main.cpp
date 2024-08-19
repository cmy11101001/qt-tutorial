#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "hidapi/cmyusbhid.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

//    CmyUsbHid cmyUsbHid;
//    qDebug() << cmyUsbHid.availableList();
//    qDebug("打开设备:");
//    qDebug() << cmyUsbHid.open("\\\\?\\HID#VID_0483&PID_5750#7&2b6932a&0&0000#{4d1e55b2-f16f-11cf-88cb-001111000030}");
//    cmyUsbHid.startPlot();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("usb_hid", new CmyUsbHid);
    engine.load(url);

    return app.exec();
}
