#include "hidapitest.h"
#include "hidapi/hidapi.h"

const char *hid_bus_name(hid_bus_type bus_type) {
    static const char *const HidBusTypeName[] = {
        "Unknown",
        "USB",
        "Bluetooth",
        "I2C",
        "SPI",
    };

    if ((int)bus_type < 0)
        bus_type = HID_API_BUS_UNKNOWN;
    if ((int)bus_type >= (int)(sizeof(HidBusTypeName) / sizeof(HidBusTypeName[0])))
        bus_type = HID_API_BUS_UNKNOWN;

    return HidBusTypeName[bus_type];
}

void print_hid_report_descriptor_from_device(hid_device *device) {
    unsigned char descriptor[HID_API_MAX_REPORT_DESCRIPTOR_SIZE];
    int res = 0;

    qDebug("  Report Descriptor: ");
    res = hid_get_report_descriptor(device, descriptor, sizeof(descriptor));
    if (res < 0) {
        qDebug("error getting: %ls", hid_error(device));
    }
    else {
        qDebug("(%d bytes)", res);
    }
    for (int i = 0; i < res; i++) {
        if (i % 10 == 0) {
            qDebug("\n");
        }
        qDebug("0x%02x, ", descriptor[i]);
    }
    qDebug("\n");
}

void print_device(struct hid_device_info *cur_dev) {
    qDebug("Device Found\n  type: %04hx %04hx\n  path: %s\n  serial_number: %ls", cur_dev->vendor_id, cur_dev->product_id, cur_dev->path, cur_dev->serial_number);
    qDebug("\n");
    qDebug("  Manufacturer: %ls\n", cur_dev->manufacturer_string);
    qDebug("  Product:      %ls\n", cur_dev->product_string);
    qDebug("  Release:      %hx\n", cur_dev->release_number);
    qDebug("  Interface:    %d\n",  cur_dev->interface_number);
    qDebug("  Usage (page): 0x%hx (0x%hx)\n", cur_dev->usage, cur_dev->usage_page);
    qDebug("  Bus type: %d (%s)\n", cur_dev->bus_type, hid_bus_name(cur_dev->bus_type));
    qDebug("\n");
}

void print_hid_report_descriptor_from_path(const char *path) {
    hid_device *device = hid_open_path(path);
    if (device) {
        print_hid_report_descriptor_from_device(device);
        hid_close(device);
    }
    else {
        qDebug("  Report Descriptor: Unable to open device by path\n");
    }
}

void print_devices_with_descriptor(struct hid_device_info *cur_dev) {
    for (; cur_dev; cur_dev = cur_dev->next) {
        print_device(cur_dev);
        print_hid_report_descriptor_from_path(cur_dev->path);
    }
}

void print_devices(struct hid_device_info *cur_dev) {
    for (; cur_dev; cur_dev = cur_dev->next) {
        print_device(cur_dev);
    }
}

#define MAX_STR 64
unsigned char buf[MAX_STR];

HidapiTest::HidapiTest(QObject *parent)
    : QObject{parent}
{
    struct hid_device_info *devs;
    if (hid_init()) return;

    devs = hid_enumerate(0, 0);
    print_devices_with_descriptor(devs);
    hid_free_enumeration(devs);

    // Set up the command buffer.
    memset(buf,0x00,sizeof(buf));
    buf[0] = 0x00;
    buf[1] = 0x81;

    hid_device *handle;

    handle = hid_open(0x483, 0x5750, NULL);
    if (!handle) {
        qDebug("unable to open device\n");
        hid_exit();
        return;
    }

    wchar_t wstr[MAX_STR];

    // Read the Manufacturer String
    wstr[0] = 0x0000;
    int res;

    res = hid_get_manufacturer_string(handle, wstr, MAX_STR);
    if (res < 0)
        qDebug("Unable to read manufacturer string\n");
    qDebug("Manufacturer String: %ls\n", wstr);

    // Read the Product String
    wstr[0] = 0x0000;
    res = hid_get_product_string(handle, wstr, MAX_STR);
    if (res < 0)
        qDebug("Unable to read product string\n");
    qDebug("Product String: %ls\n", wstr);

    // Read the Serial Number String
    wstr[0] = 0x0000;
    res = hid_get_serial_number_string(handle, wstr, MAX_STR);
    if (res < 0)
        qDebug("Unable to read serial number string\n");
    qDebug("Serial Number String: (%d) %ls\n", wstr[0], wstr);

    print_hid_report_descriptor_from_device(handle);

    struct hid_device_info* info = hid_get_device_info(handle);
    if (info == NULL) {
        qDebug("Unable to get device info\n");
    } else {
        print_devices(info);
    }

    // Read Indexed String 1
    wstr[0] = 0x0000;
    res = hid_get_indexed_string(handle, 1, wstr, MAX_STR);
    if (res < 0)
        qDebug("Unable to read indexed string 1\n");
    qDebug("Indexed String 1: %ls\n", wstr);

    // Set the hid_read() function to be non-blocking.
//    hid_set_nonblocking(handle, 1);

//    // Try to read from the device. There should be no
//    // data here, but execution should not block.
//    res = hid_read(handle, buf, MAX_STR);

    // Send a Feature Report to the device
    buf[0] = 0x00;
    buf[1] = 0xa0;
    buf[2] = 0x0a;
    buf[3] = 0x00;
    buf[4] = 0x00;
    res = hid_send_feature_report(handle, buf, MAX_STR);
    if (res < 0) {
        qDebug("Unable to send a feature report.\n");
    }

    memset(buf,0,sizeof(buf));

    int i;

    // Read a Feature Report from the device
    buf[0] = 0x00;
    res = hid_get_feature_report(handle, buf, sizeof(buf));
    if (res < 0) {
        qDebug("Unable to get a feature report: %ls\n", hid_error(handle));
    }
    else {
        // Print out the returned buffer.
        qDebug("Feature Report\n   ");
        for (i = 0; i < res; i++)
            qDebug("%02x ", (unsigned int) buf[i]);
        qDebug("\n");
    }

    memset(buf,0,sizeof(buf));

//    // Toggle LED (cmd 0x80). The first byte is the report number (0x1).
//    buf[0] = 0x00;
//    buf[1] = 0x80;
//    res = hid_write(handle, buf, MAX_STR);
//    if (res < 0) {
//        qDebug("Unable to write(): %ls\n", hid_error(handle));
//    }

    // Request state (cmd 0x81). The first byte is the report number (0x1).
    buf[0] = 0x00;
    buf[1] = 0x81;
    hid_write(handle, buf, MAX_STR);
    if (res < 0) {
        qDebug("Unable to write()/2: %ls\n", hid_error(handle));
    }

    // Read requested state. hid_read() has been set to be
    // non-blocking by the call to hid_set_nonblocking() above.
    // This loop demonstrates the non-blocking nature of hid_read().
    res = 0;
    unsigned char rx_buf[MAX_STR];
    memset(rx_buf,0,sizeof(rx_buf));
    res = hid_read(handle, rx_buf, sizeof(rx_buf));
    if (res == 0) {
        qDebug("waiting...\n");
    }
    if (res < 0) {
        qDebug("Unable to read(): %ls\n", hid_error(handle));
    }

    for (i=0; i<MAX_STR; i++) {
        qDebug("i:%d = %d", i, rx_buf[i]);
    }
    qDebug("\nres = %d\n", res);

    hid_close(handle);

    /* Free static HIDAPI objects. */
    hid_exit();

    qDebug("usb hid complete...\n");
}
