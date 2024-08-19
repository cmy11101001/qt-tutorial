#include "cmyserialport.h"
#include <QSerialPortInfo>

CmySerialPort::CmySerialPort(QObject *parent)
    : QObject{parent}
{
    com = "COM3";
    baudRate = 115200;
    dataBit = 8;
    parity = "No";
    stopBit = 1;

    // 数据接收
    connect(&serial, &QSerialPort::readyRead, this, [=]() {
        // 读取所有可用数据
        QByteArray data = serial.readAll();
        // 处理接收到的数据...
        emit readData(data);
    });
}

QStringList CmySerialPort::availableList(void)
{
    QStringList comList;
    foreach (const QSerialPortInfo &serialPortInfo, QSerialPortInfo::availablePorts()) {
        comList << serialPortInfo.portName();
    }
    return comList;
}

bool CmySerialPort::open(void)
{
    serial.setPortName(com);

    serial.setBaudRate(baudRate);

    QSerialPort::DataBits dataBits = QSerialPort::Data8;
    switch (dataBit) {
    case 7:
        dataBits = QSerialPort::Data7;
        break;
    case 8:
        dataBits = QSerialPort::Data8;
        break;
    default:
        dataBits = QSerialPort::Data8;
        break;
    }
    serial.setDataBits(dataBits);

    QSerialPort::Parity paritys = QSerialPort::NoParity;
    if (!parity.compare("No")) {
        paritys = QSerialPort::NoParity;
    } else if(!parity.compare("Even")) {
        paritys = QSerialPort::EvenParity;
    } else if(!parity.compare("Odd")) {
        paritys = QSerialPort::OddParity;
    }
    serial.setParity(paritys);

    QSerialPort::StopBits stopBits = QSerialPort::OneStop;
    if (stopBit == 1) {
        stopBits = QSerialPort::OneStop;
    } else if(stopBit == 1.5) {
        stopBits = QSerialPort::OneAndHalfStop;
    } else if(stopBit == 2) {
        stopBits = QSerialPort::TwoStop;
    }
    serial.setStopBits(stopBits);

    if(serial.open(QIODevice::ReadWrite)){
        return true;
    }
    return false;
}

void CmySerialPort::close(void)
{
    if(serial.isOpen()){
        serial.close();
    }
}

QString CmySerialPort::getCom(void) const
{
    return com;
}

void CmySerialPort::setCom(QString &com)
{
    if (this->com != com) {
        this->com = com;
        emit comChanged();
    }
}

int CmySerialPort::getBaudRate(void) const
{
    return baudRate;
}

void CmySerialPort::setBaudRate(int &baudRate)
{
    if (this->baudRate != baudRate) {
        this->baudRate = baudRate;
        emit baudRateChanged();
    }
}

int CmySerialPort::getDataBit(void) const
{
    return dataBit;
}

void CmySerialPort::setDataBit(int &dataBit)
{
    if (this->dataBit != dataBit) {
        this->dataBit = dataBit;
        emit dataBitChanged();
    }
}

QString CmySerialPort::getParity(void) const
{
    return parity;
}

void CmySerialPort::setParity(QString &parity)
{
    if (this->parity != parity) {
        this->parity = parity;
        emit parityChanged();
    }
}

float CmySerialPort::getStopBit(void) const
{
    return stopBit;
}

void CmySerialPort::setStopBit(float &stopBit)
{
    if (this->stopBit != stopBit) {
        this->stopBit = stopBit;
        emit stopBitChanged();
    }
}

void CmySerialPort::startPlot(void)
{
    char data = 0;
    writeData(&data, 1);
}
void CmySerialPort::stopPlot(void)
{
    char data = -1;
    writeData(&data, 1);
}

bool CmySerialPort::writeData(char *data, int len)
{
    QMutexLocker lock(&mutex);
    if(!serial.isOpen()){
        // "串口未打开"
        return false;
    }
    serial.write(data, len);
    if(!serial.waitForBytesWritten(100)){
        // "串口数据发送超时"
        return false;
    }
    return true;
}
