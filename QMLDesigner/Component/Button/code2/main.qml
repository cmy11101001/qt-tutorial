import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("按钮")
    color: "gray"
    // 按钮完整视图
    Rectangle {
        id: root
        anchors.centerIn: parent
        implicitWidth: 100
        implicitHeight: 60
        property alias text: btn.text
        property alias font: btn.font
        signal clicked()
        color: "transparent"
        // 按钮位置
        Button {
            id: btn
            width: parent.width - 8.0
            height: parent.height - 8.0
            x: 0
            y: 0
            text: "按钮"
            // 按钮位移动画时间
            property real durationTime: 50
            // 按钮阴影位置距离
            property real effectOffset: 8.0
            layer.enabled: true
            layer.effect: DropShadow {
                // 阴影效果
                transparentBorder: true
                horizontalOffset: btn.effectOffset
                verticalOffset: btn.effectOffset
                color: Qt.rgba(0, 0, 0, 1)
            }

            // 按钮属性动画
            Behavior on x {
                NumberAnimation {
                    duration: btn.durationTime
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: btn.durationTime
                }
            }
            Behavior on effectOffset {
                NumberAnimation {
                    duration: btn.durationTime
                }
            }

            // 按钮按下
            onPressed: {
                btn.x = 8
                btn.y = 8
                effectOffset = 0
            }

            // 按钮释放
            onReleased: {
                btn.x = 0
                btn.y = 0
                effectOffset = 8
            }

            // 按钮内部视图
            contentItem: Rectangle{
                color: "transparent"
                Text {
                    id: btnText
                    anchors.centerIn: parent
                    text: btn.text
                    font.bold: true
                    font.pointSize: 15
                    color: "black"
                }
            }

            // 按钮背景视图
            background: Rectangle {
                color: "white"
                radius: 30

                // 下划线
                Rectangle {
                    id: lineRect
                    width: 0
                    height: 3
                    color: "black"
                    y: parent.height * 0.8
                    anchors.horizontalCenter: parent.horizontalCenter
                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                // 按钮鼠标区域
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.clicked()
                    }
                    // 按下, 按钮往右下移动
                    onPressed: {
                        btn.x = 8
                        btn.y = 8
                        btn.effectOffset = 0
                    }
                    // 释放, 按钮往左上移动
                    onReleased: {
                        btn.x = 0
                        btn.y = 0
                        btn.effectOffset = 8
                    }
                    // 鼠标进入, 下划线展开
                    onEntered: {
                        lineRect.width = lineRect.parent.width * 0.5
                    }
                    // 鼠标推出, 下划线收缩
                    onExited: {
                        lineRect.width = 0
                    }
                }
            }
        }
    }
}
