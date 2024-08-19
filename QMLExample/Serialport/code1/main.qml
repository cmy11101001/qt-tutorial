import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("serial")

    // 串口号
    ComboBox {
        id: comCbb
        model: ListModel {
            id: comModel
        }
        textRole: "COM"

        onPressedChanged: {
            var nowIndex = comCbb.currentIndex
            updateCom()
            comCbb.currentIndex = nowIndex
        }

        // 刷新可用串口
        function updateCom() {
            var comList = serial.availableList()
            comModel.clear()
            for (let i=0; i<comList.length; i++) {
                comModel.append({COM: comList[i]})
            }
        }

        onActivated: (index)=> {
            serial.com = currentText
        }

        Component.onCompleted: {
            updateCom()
            comCbb.currentIndex = 0
        }
    }

    // 波特率
    ComboBox {
        id: baudRateCbb
        anchors.top: comCbb.bottom
        model: ListModel {
            ListElement { baudRate: 9600}
            ListElement { baudRate: 115200 }
            ListElement { baudRate: 2000000 }
        }
        textRole: "baudRate"

        onActivated: (index)=> {
            serial.baudRate = currentText
        }

        Component.onCompleted: {
            baudRateCbb.currentIndex = 1
        }
    }

    // 数据位
    ComboBox {
        id: dataBitCbb
        anchors.top: baudRateCbb.bottom
        model: ListModel {
            ListElement { dataBit: 7}
            ListElement { dataBit: 8 }
        }
        textRole: "dataBit"

        onActivated: (index)=> {
            serial.dataBit = currentText
        }

        Component.onCompleted: {
            dataBitCbb.currentIndex = 1
        }
    }

    // 校验位
    ComboBox {
        id: parityCbb
        anchors.top: dataBitCbb.bottom
        model: ListModel {
            ListElement { parity: "No"}
            ListElement { parity: "Even" }
            ListElement { parity: "Odd" }
        }
        textRole: "parity"

        onActivated: (index)=> {
            serial.parity = currentText
        }

        Component.onCompleted: {
            parityCbb.currentIndex = 0
        }
    }

    // 停止位
    ComboBox {
        id: stopBitCbb
        anchors.top: parityCbb.bottom
        model: ListModel {
            ListElement { stopBit: 1}
            ListElement { stopBit: 1.5 }
            ListElement { stopBit: 2 }
        }
        textRole: "stopBit"

        onActivated: (index)=> {
            serial.stopBit = currentText
        }

        Component.onCompleted: {
            stopBitCbb.currentIndex = 0
        }
    }

    // 连接
    Button {
        id: openBtn
        anchors.top: stopBitCbb.bottom
        text: "连接"
        onClicked: {
            if (serial.open()) {
                openBtn.enabled = false
                comCbb.enabled = false
                baudRateCbb.enabled = false
                dataBitCbb.enabled = false
                parityCbb.enabled = false
                stopBitCbb.enabled = false
            }
        }
    }

    // 断连
    Button {
        id: closeBtn
        anchors.top: stopBitCbb.bottom
        anchors.left: openBtn.right
        text: "断连"
        onClicked: {
            serial.close()
            openBtn.enabled = true
            comCbb.enabled = true
            baudRateCbb.enabled = true
            dataBitCbb.enabled = true
            parityCbb.enabled = true
            stopBitCbb.enabled = true
        }
    }

    Component.onCompleted: {
        console.log(serial.com,
                    serial.baudRate,
                    serial.dataBit,
                    serial.parity,
                    serial.stopBit)
        console.log(serial.availableList())
    }

    Connections {
        target: serial
        onReadData: (data)=> {
            console.log(data)
        }
    }

    Button {
        id: btn_start
        anchors.top: openBtn.bottom
        text: "启动"
        onClicked: {
            serial.startPlot()
        }
    }

    Button {
        anchors.top: openBtn.bottom
        anchors.left: btn_start.right
        text: "停止"
        onClicked: {
            serial.stopPlot()
        }
    }
}
