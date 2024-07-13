import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    BusyIndicator {
        id: busyIndicator
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            onClicked: {
                busyIndicator.running = busyIndicator.running? false: true
            }
        }

        background: Rectangle {
            id: backgroundRect
            color: "transparent"
        }

        contentItem: Item {
            Rectangle {
                anchors.centerIn: parent
                width: parent.width < parent.height? parent.width / 4 * 3: parent.height / 4 * 3
                height: width
                color: backgroundRect.color
                radius: height / 2
                border.width: height / 12
            }

            Canvas {
                id: canvas
                anchors.centerIn: parent
                width: parent.width < parent.height? parent.width / 4 * 3: parent.height / 4 * 3
                height: width
                property real angle: 0
                onPaint: {
                    rotate()
                }
                function rotate() {
                    var ctx = getContext('2d')
                    ctx.clearRect(0, 0, canvas.width, canvas.height)
                    ctx.beginPath()
                    ctx.arc(width/2, height/2, height/2-height/12/2, canvas.angle, canvas.angle + Math.PI * 2 / 12, false)
                    ctx.lineWidth = height / 12
                    ctx.strokeStyle = "red"
                    ctx.stroke()
                    requestAnimationFrame(rotate)
                }
                Timer {
                    repeat: true
                    interval: 25
                    onTriggered: {
                        canvas.angle += Math.PI * 2 / 24
                    }
                    running: busyIndicator.running
                }
            }
        }
    }
}
