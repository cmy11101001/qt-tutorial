#ifndef EXAMPLEFFMPEG_H
#define EXAMPLEFFMPEG_H

#include <QObject>

class ExampleFFMPEG : public QObject
{
    Q_OBJECT
public:
    explicit ExampleFFMPEG(QObject *parent = nullptr);

    /** 生成一段音频 */
    void encode_audio();

    /** 生成1秒的视频 */
    void encode_video();

    /** 生成一个音视频文件 */
    void mux();

signals:

};

#endif // EXAMPLEFFMPEG_H
