#ifndef CMYSERIALPORT_H
#define CMYSERIALPORT_H

#include <QObject>
#include <QSerialPort>
#include <QMutex>
#include <QStringList>

class CmySerialPort : public QObject
{
    Q_OBJECT
    // 串口号
    Q_PROPERTY(QString com READ getCom WRITE setCom NOTIFY comChanged)
    // 波特率
    Q_PROPERTY(int baudRate READ getBaudRate WRITE setBaudRate NOTIFY baudRateChanged)
    // 数据位
    Q_PROPERTY(int dataBit READ getDataBit WRITE setDataBit NOTIFY dataBitChanged)
    // 校验位
    Q_PROPERTY(QString parity READ getParity WRITE setParity NOTIFY parityChanged)
    // 停止位
    Q_PROPERTY(float stopBit READ getStopBit WRITE setStopBit NOTIFY stopBitChanged)

public:
    explicit CmySerialPort(QObject *parent = nullptr);

public:
    // 搜索可用串口
    Q_INVOKABLE QStringList availableList(void);
    // 打开串口
    Q_INVOKABLE bool open(void);
    // 关闭串口
    Q_INVOKABLE void close(void);
    //! 指令
    Q_INVOKABLE void startPlot(void);
    Q_INVOKABLE void stopPlot(void);

private:
    QString getCom(void) const;
    void setCom(QString &);

    int getBaudRate(void) const;
    void setBaudRate(int &);

    int getDataBit(void) const;
    void setDataBit(int &);

    QString getParity(void) const;
    void setParity(QString &);

    float getStopBit(void) const;
    void setStopBit(float &);

    // 写数据
    bool writeData(char *data, int len);

signals:
    void comChanged();
    void baudRateChanged();
    void dataBitChanged();
    void parityChanged();
    void stopBitChanged();

    // 读数据
    void readData(QByteArray data);

private:
    QMutex mutex;
    QSerialPort serial;
    QString com;
    int baudRate;
    int dataBit;
    QString parity;
    float stopBit;
};

#endif // CMYSERIALPORT_H
