#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include "ffmpeg/usbcamera2rtsp.h"
#include "ffmpeg/exampleffmpeg.h"

//引入ffmpeg头文件
#include "ffmpeginclude.h"

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
    engine.load(url);

    qDebug() << "版本:" + QString(av_version_info());
    qDebug() << avcodec_configuration();

    ExampleFFMPEG *exampleFFMPEG = new ExampleFFMPEG();
    exampleFFMPEG->encode_audio();
    exampleFFMPEG->encode_video();
    exampleFFMPEG->mux();


//    UsbCamera2RTSP *usbCamera2RTSP = new UsbCamera2RTSP();

    return app.exec();
}
