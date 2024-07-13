import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("DelayButton")

    DelayButton {
        id: delayButton
        x: 10
        y: 10
        delay: 1000
        text: "一键三连"
        onActivated: {
            logText.text = "已三连"
        }

        onPressed: {
            logText.text = ""
        }

        // 内容视图
        contentItem: Text {
            text: delayButton.text
            anchors.centerIn: delayButton
            font.pointSize: 30
        }

        // 背景视图
        background: Rectangle {
            color: "transparent"
            Canvas {
                anchors.fill: parent
                onPaint: {
                    draw()
                }
                // 动画平滑
                function draw() {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    drawRect(ctx)
                    ctx.stroke()
                    requestAnimationFrame(draw)
                }
                // 画边框
                function drawRect(ctx) {
                    if (delayButton.progress < 0.25) {
                        ctx.lineTo(width * (delayButton.progress / 0.25), 0)
                        return
                    } else {
                        ctx.lineTo(width, 0)
                    }
                    if (delayButton.progress < 0.5) {
                        ctx.lineTo(width, height * ((delayButton.progress - 0.25) / 0.25))
                        return
                    } else {
                        ctx.lineTo(width, height)
                    }
                    if (delayButton.progress < 0.75) {
                        ctx.lineTo(width * (1 - (delayButton.progress - 0.5) / 0.25), height)
                    } else {
                        ctx.lineTo(0, height)
                        ctx.lineTo(0, height * (1 - (delayButton.progress - 0.75) / 0.25))
                    }
                }
            }
        }
    }

    // 演示
    Text {
        id: logText
        anchors.left: delayButton.right
        anchors.verticalCenter: delayButton.verticalCenter
        leftPadding: 20
        font.pointSize: 30
    }
}
