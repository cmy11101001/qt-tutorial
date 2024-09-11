#ifndef USBCAMERA2RTSP_H
#define USBCAMERA2RTSP_H

#include <QObject>
//引入ffmpeg头文件
#include "ffmpeginclude.h"

class UsbCamera2RTSP : public QObject
{
    Q_OBJECT
public:
    explicit UsbCamera2RTSP(QObject *parent = nullptr);

signals:

};

#endif // USBCAMERA2RTSP_H
