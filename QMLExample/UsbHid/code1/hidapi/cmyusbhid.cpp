#include "cmyusbhid.h"
#include <QDebug>

CmyUsbHid::CmyUsbHid(QObject *parent)
    : QThread{parent},
      devs(nullptr),
      handle(nullptr)
{
    memset(tx_buf, 0, sizeof(tx_buf));
    if (hid_init()) {
        qDebug("hid_init() err...\n");
    }

    connect(this, &CmyUsbHid::readStr, this, [=](QString str) {
        qDebug() << str;
    });

    this->start();
}

CmyUsbHid::~CmyUsbHid()
{
    if (handle) {
        hid_close(handle);
    }
    hid_exit();
}

QStringList CmyUsbHid::availableList(void)
{
    if (devs != nullptr) {
        hid_free_enumeration(devs);
        devs = nullptr;
    }
    devs = hid_enumerate(0, 0);
    QStringList hidList;
    struct hid_device_info *cur_dev = devs;
    for (; cur_dev; cur_dev = cur_dev->next) {
        QString str = QString::fromLatin1(cur_dev->path);
        hidList << str;
    }
    return hidList;
}

bool CmyUsbHid::open(const QString &path)
{
    if (handle) {
        hid_close(handle);
        handle = nullptr;
    }
    struct hid_device_info *cur_dev = devs;
    for (; cur_dev; cur_dev = cur_dev->next) {
        QString str = QString::fromLatin1(cur_dev->path);
        if (str == path) {
            handle = hid_open(cur_dev->vendor_id, cur_dev->product_id, cur_dev->serial_number);
            break;
        }
    }
    if (!handle) {
        return false;
    }
    return true;
}

void CmyUsbHid::close(void)
{
    if (handle) {
        hid_close(handle);
        handle = nullptr;
    }
}

bool CmyUsbHid::startPlot(void)
{
    if (!handle) {
        return false;
    }
    memset(tx_buf, 0, sizeof(tx_buf));
    // 第一个字节tx_buf[0]是report id
    // 下位机没设置report id, 那么report id就是0
    tx_buf[0] = 0x00;
    // 指令->启动plot
    tx_buf[1] = 0x00;
    if (hid_write(handle, tx_buf, sizeof(tx_buf)) == -1) {
        // 出错
        return false;
    }
    return true;
}

void CmyUsbHid::stopPlot(void)
{
    if (!handle) {
        return;
    }
    memset(tx_buf, 0, sizeof(tx_buf));
    // 第一个字节tx_buf[0]是report id
    // 下位机没设置report id, 那么report id就是0
    tx_buf[0] = 0x00;
    // 指令->停止plot
    tx_buf[1] = 0x01;
    if (hid_write(handle, tx_buf, sizeof(tx_buf)) == -1) {
        // 出错
    }
}

void CmyUsbHid::run()
{
    int res = 0;
    while(isRunning()) {
        if (handle) {
            res = hid_read(handle, (unsigned char *)rx_buf, sizeof(rx_buf));
            if (res > 0) {
                emit readData((unsigned char *)rx_buf, res);
                QString str;
                for (int i=0; i<res; i++) {
                    str += QString::number(rx_buf[i]);
                    str += ' ';
                }
                emit readStr(str);
            }
        } else {
            msleep(1);
        }
    }
}
