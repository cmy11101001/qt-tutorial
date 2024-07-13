import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Button {
        text: "发消息"
        onClicked: {
            if (!popup.opened) {
                popup.close()
            }
            popup.open()
        }
    }

    Popup {
        id: popup
        x: parent.width / 2 - width / 2
        y: parent.height / 5
        // 弹窗模态
        modal: false
        // 触发弹窗关闭方式
        closePolicy: Popup.NoAutoClose
        // 弹窗背景视图
        background: Rectangle {
            color: "transparent"
            Rectangle {
                height: 2
                width: parent.width
                y: 0
                color: "green"
            }
            Rectangle {
                height: 2
                width: parent.width
                y: parent.height - height
                color: "green"
            }
        }
        // 弹窗内容视图
        Text {
            text: "放假当宅宅！！！"
            font.pointSize: 30
        }
        // open过渡
        enter: Transition {
            SequentialAnimation {
                NumberAnimation {
                   property: "opacity"
                   from: 0.0
                   to: 1.0
                   duration: 400
                }
                PauseAnimation {
                    duration: 500
                }
                ParallelAnimation{
                    NumberAnimation {
                       property: "y"
                       to: 0.0
                       duration: 400
                    }
                    NumberAnimation {
                       property: "opacity"
                       from: 1.0
                       to: 0.0
                       duration: 400
                    }
                }
                PropertyAction {
                    target: popup
                    property: "y"
                    value: popup.parent.height / 5
                }
                ScriptAction {
                    script: popup.close()
                }
            }
        }
        // close过渡
        exit: Transition {
            PropertyAction {
                target: popup
                property: "y"
                value: popup.parent.height / 5
            }
        }
    }
}
