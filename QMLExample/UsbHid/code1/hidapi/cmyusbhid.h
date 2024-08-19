#ifndef CMYUSBHID_H
#define CMYUSBHID_H

#include <QObject>
#include <QThread>
#include <QStringList>
#include "hidapi.h"

class CmyUsbHid : public QThread
{
    Q_OBJECT
public:
    explicit CmyUsbHid(QObject *parent = nullptr);
    virtual ~CmyUsbHid();

    // 枚举USB-HID设备
    Q_INVOKABLE QStringList availableList(void);

    // 打开USB-HID设备
    Q_INVOKABLE bool open(const QString &path);

    // 关闭USB-HID设备
    Q_INVOKABLE void close(void);

    //! 指令
    Q_INVOKABLE bool startPlot(void);
    Q_INVOKABLE void stopPlot(void);

protected:
    void run() override;

signals:
    // 读数据
    void readData(unsigned char *data, int len);
    // 读数据-数字转字符串
    void readStr(QString str);

private:
    QThread readThread;
    struct hid_device_info *devs;
    hid_device *handle;
    unsigned char tx_buf[65];   // 第一个字节是report id
    char rx_buf[64];
};

#endif // CMYUSBHID_H
