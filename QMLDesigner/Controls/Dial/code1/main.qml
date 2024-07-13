import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Dial {
        anchors.fill: parent
        id: dial
        // 设置旋钮的范围
        from: 0
        to: 100
        // 设置旋钮的初始值
        value: 50
        // 设置旋钮的步长
        stepSize: 0.1
        // 监听旋钮值变化的信号
        onValueChanged: {
            label.text = value.toFixed(1); // 更新标签文本为旋钮的值
        }

        // 计算弧度
        property real angleInRadian: (dial.angle * Math.PI) / 180
        // 背景视图以中心为原点(0, 0)来计算，(0, radius)是初始坐标
        property real coeff: 30
        // 计算旋转后的坐标
        property real angleX: - (backgroundRect.radius - coeff) * Math.sin(angleInRadian)
        property real angleY: (backgroundRect.radius - coeff) * Math.cos(angleInRadian)

        // 绘制手柄
        handle: Rectangle {
            radius: 0
            width: dial.coeff
            height: dial.coeff
            color: "transparent"
            border.width: 1
            x: parent.width / 2 - parent.angleX - (width / 2)
            y: parent.height / 2 - parent.angleY - (height / 2)
            rotation: dial.angle
        }

        // 绘制背景
        background: Rectangle {
            id: backgroundRect
            radius: (dial.width > dial.height)? (dial.height / 2): (dial.width / 2)
            width: radius * 2
            height: radius * 2
            anchors.centerIn: dial
            color: "transparent"
            border.width: 1
            Canvas {
                anchors.fill: parent
                onPaint: {
                    draw()
                }
                function draw() {
                    var ctx = getContext("2d")
                    // 绘制背景
                    ctx.clearRect(0, 0, width, height)
                    // 背景动态与角度绑定
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2,
                            backgroundRect.radius - dial.coeff,
                            (-140 - 90) * Math.PI / 180,
                            (dial.angle - 90) * Math.PI / 180, false);
                    ctx.stroke();
                    requestAnimationFrame(draw)
                }
            }
        }

        // 中心位置显示数值
        Label {
            id: label
            text: "0"
            font.bold: true
            font.pixelSize: 30
            anchors.centerIn: parent
        }
    }
}
