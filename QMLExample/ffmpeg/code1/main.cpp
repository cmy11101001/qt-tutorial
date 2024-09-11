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
    // 编码：生成一段音频
    exampleFFMPEG->encode_audio("./../encode_audio.mp2");
    // 编码：生成1秒的视频
    exampleFFMPEG->encode_video("./../encode_video.mp4", "libx264");
    // 编译：生成一个音视频文件
    exampleFFMPEG->mux("./../mux.mp4");
    // 解码：一段音频输出原始PCM数据
    exampleFFMPEG->decode_audio("./../encode_audio.mp2", "./../decode_audio.pcm");
    // 解码：一段视频输出所有帧图片
    exampleFFMPEG->decode_video("./../encode_video.mp4", "./../decode_video_frame");
    // 解码：一段音视频输出原始音频文件跟原始视频文件
    exampleFFMPEG->demux_decode("./../mux.mp4", "./../demux_decode.raw", "./../demux_decode.pcm");
//    exampleFFMPEG->demux_decode("rtsp://127.0.0.1:8554/1", "./../demux_decode.raw", "./../demux_decode.pcm");

//    UsbCamera2RTSP *usbCamera2RTSP = new UsbCamera2RTSP();

    return app.exec();
}
