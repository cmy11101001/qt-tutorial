import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Tumbler {
        id: tumbler
        anchors.centerIn: parent
        // 只显示3个视图
        visibleItemCount: 3
        // 绘制背景视图
        background: Rectangle {
            border.width: 1
            radius: 10
        }
        // 模型
        model: ListModel {
            ListElement { value: "视图1" }
            ListElement { value: "视图2" }
            ListElement { value: "视图3" }
            ListElement { value: "视图4" }
            ListElement { value: "视图5" }
        }
        // 代理
        delegate: Rectangle {
            width: 100
            height: 50
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: value
                font.bold: true
                font.pointSize: 15
                color: tumbler.currentItem === this.parent? "red": "black"
                Rectangle {
                    y: parent.height + 5
                    color: "green"
                    width: parent.width
                    height: 2
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    color = "gray"
                    opacity: 0.5
                }
                onExited: {
                    color = "transparent"
                    opacity: 1
                }
            }
        }
        // 是否循环
        wrap: true
        // 视图加载完成时
        Component.onCompleted: {
            tumbler.currentIndex = 1
            tumbler.currentIndex = 0
        }
    }
}
