import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("缩放旋转")

    Rectangle {
        width: 300
        height: 300

        //写在最前面,焦点吸收器
        MouseArea {
            anchors.fill: parent
            onClicked: {
                focus = true
            }
        }

        Rectangle {
            id: rectangle
            x: 30
            y: 30
            width: 100
            height: 100
            color: "gray"
            smooth: true
            antialiasing: true
            // 单击获取焦点
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    parent.focus = true
                }
            }
            // 支持旋转
            RotateCursor {
                visible: parent.focus
            }
            // 支持拖拽缩放
            DragWidget {
                visible: parent.focus
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                clip: true
                Text {
                    text: "宅宅"
                    font.bold: true
                    font.pointSize: 20
                    anchors.centerIn: parent
                }
            }
        }

    }
}
