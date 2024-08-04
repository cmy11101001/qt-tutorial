import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("usb hid通信")

    Button {
        id: search
        anchors.top: parent.top
        anchors.left: parent.left
        text: "搜索usb设备->"
        onClicked: {
            var usbList = usb_hid.availableList();
            usbModel.clear()
            for (let i=0; i<usbList.length; i++) {
                usbModel.append({PATH: usbList[i]})
                console.log(usbList[i])
            }
        }
    }
    ComboBox {
        id: usbCbb
        width: 450
        anchors.left: search.right
        anchors.top: parent.top
        textRole: "PATH"
        model: ListModel {
            id: usbModel
        }
    }
    Button {
        id: open
        anchors.top: parent.top
        anchors.left: usbCbb.right
        text: "连接"
        onClicked: {
            if (usbCbb.currentIndex != -1) {
                usb_hid.open(usbCbb.currentText)
            }
        }
    }
    Button {
        id: plotStart
        anchors.top: search.bottom
        anchors.left: parent.left
        text: "启动"
        onClicked: {
            usb_hid.startPlot()
        }
    }
    Button {
        id: plotStop
        anchors.top: plotStart.top
        anchors.left: plotStart.right
        text: "停止"
        onClicked: {
            usb_hid.stopPlot()
        }
    }
    Label {
        id: label
        anchors.top: plotStart.bottom
        anchors.left: plotStart.left
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "接收数据："
    }
    Text {
        id: text
        width: parent.width - label.width
        anchors.top: label.top
        anchors.left: label.right
        font.bold: true
        font.pointSize: 20
        wrapMode: Text.WrapAnywhere
    }
    Connections {
        target: usb_hid
        onReadStr: (str)=> {
            text.text = str
        }
    }
}
