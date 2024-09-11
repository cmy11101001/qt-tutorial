#ifndef EXAMPLEFFMPEG_H
#define EXAMPLEFFMPEG_H

#include <QObject>

class ExampleFFMPEG : public QObject
{
    Q_OBJECT
public:
    explicit ExampleFFMPEG(QObject *parent = nullptr);

    /** 生成一段音频
     *  encode_audio("./../encode_audio.mp2") */
    void encode_audio(const char *filename);

    /** 生成1秒的视频
     *  encode_video("./../encode_video.mp4", "libx264") */
    void encode_video(const char *filename, const char *codec_name);

    /** 生成一个音视频文件
     *  任意格式都行，会自动推断
     *  mux("./../mux.mp4") */
    void mux(const char *filename);

    /** 解码一段音频输出原始PCM数据
     *  decode_audio("./../encode_audio.mp2", "./../decode_audio.pcm") */
    void decode_audio(const char *filename, const char *outfilename);

signals:

};

#endif // EXAMPLEFFMPEG_H
