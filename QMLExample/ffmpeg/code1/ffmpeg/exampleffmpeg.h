#ifndef EXAMPLEFFMPEG_H
#define EXAMPLEFFMPEG_H

#include <QObject>

class ExampleFFMPEG : public QObject
{
    Q_OBJECT
public:
    explicit ExampleFFMPEG(QObject *parent = nullptr);

    /** 编码：生成一段音频
     *  encode_audio("./../encode_audio.mp2") */
    void encode_audio(const char *filename);

    /** 编码：生成1秒的视频
     *  encode_video("./../encode_video.mp4", "libx264") */
    void encode_video(const char *filename, const char *codec_name);

    /** 编码：生成一个音视频文件
     *  任意格式都行，会自动推断
     *  mux("./../mux.mp4") */
    void mux(const char *filename);

    /** 解码：一段音频输出原始PCM数据
     *  decode_audio("./../encode_audio.mp2", "./../decode_audio.pcm") */
    void decode_audio(const char *filename, const char *outfilename);

    /** 解码：一段视频输出所有帧图片
     *  decode_video("./../encode_video.mp4", "./../decode_video_frame") */
    void decode_video(const char *filename, const char *outfilename);

    /** 解码：一段音视频输出原始音频文件跟原始视频文件
     *  demux_decode("./../mux.mp4", "./../demux_decode.raw", "./../demux_decode.pcm")
     *  .\ffplay.exe -f rawvideo -video_size 352x288 ..\demux_decode.raw
     *  .\ffplay.exe -ar 44100 -f s16le -i ..\demux_decode.pcm */
    void demux_decode(const char *src_filename, const char *video_dst_filename, const char *audio_dst_filename);
signals:

};

#endif // EXAMPLEFFMPEG_H
