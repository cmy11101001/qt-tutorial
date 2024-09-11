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

    /// 查看ffmpeg版本
    qDebug() << "版本:" + QString(av_version_info());
    qDebug() << avcodec_configuration();

    /// 运行ffmpeg例子
    ExampleFFMPEG *exampleFFMPEG = new ExampleFFMPEG();
    // 编码-输出一段音频
    exampleFFMPEG->encode_audio("./../encode_audio.mp2");
    // 编码-输出一段视频
    exampleFFMPEG->encode_video("./../encode_video.mp4", "libx264");
    // 编译-输出一段音视频
    exampleFFMPEG->mux("./../mux.mp4");
    // 解码-输出一段音频
    exampleFFMPEG->decode_audio("./../encode_audio.mp2", "./../decode_audio.pcm");


//    UsbCamera2RTSP *usbCamera2RTSP = new UsbCamera2RTSP();

    return app.exec();
}
