import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Dialog {
        id: dialog
        anchors.centerIn: Overlay.overlay
        title: "这里是标题"
        standardButtons: Dialog.Ok | Dialog.Cancel // 设置标准按钮组合
        // 头视图
        header: Text {
            text: dialog.title
            font.pointSize: 15
            font.bold: true
            padding: 10
            Rectangle {
                implicitWidth: parent.width
                implicitHeight: 2
                anchors.bottom: parent.bottom
                color: "green"
            }
        }
        // 尾视图
        footer: Text {
            text: "这里有小尾巴"
            font.pointSize: 10
            padding: 10
            Rectangle {
                implicitWidth: parent.width
                implicitHeight: 1
                anchors.top: parent.top
                color: "green"
            }
        }
        // 背景视图
        background: Rectangle {
            opacity: 0.3
            border.width: 1
        }
        // 内容视图
        Rectangle {
            implicitHeight: 200
            implicitWidth: 300
            color: "red"
            Text {
                anchors.centerIn: parent
                text: "这里是内容"
                font.pointSize: 30
            }
            Button {
                id: cancel
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                text: "Cancel"
                font.pointSize: 20
                Rectangle {
                    width: 1
                    height: parent.height
                    anchors.left: parent.left
                }
                onClicked: {
                    dialog.rejected()
                    dialog.close()
                }
            }
            Button {
                id: ok
                anchors.bottom: parent.bottom
                anchors.right: cancel.left
                text: "Ok"
                font.pointSize: 20
                onClicked: {
                    dialog.accepted()
                    dialog.close()
                }
            }
        }
        // 模态
        modal: true

        onAccepted: {
            logText.text = "点击了Ok"
        }
        onRejected: {
            logText.text = "点击了Cancel"
        }
    }

    // 添加一个按钮来打开对话框
    Button {
        id: button
        text: "打开对话框"
        anchors.centerIn: parent
        onClicked: {
            dialog.open() // 打开对话框
        }
    }
    // 演示用
    Text {
        id: logText
        anchors.top: button.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        topPadding: 10
        text: "点击结果"
        font.pointSize: 20
    }
}
