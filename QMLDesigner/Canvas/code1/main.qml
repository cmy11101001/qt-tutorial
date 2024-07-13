import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    Canvas {
        id: myCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")

            ctx.beginPath()
            ctx.rect(50, 50, 100, 100)                                              // 左上角坐标(50, 50)，长100，宽100
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(200, 100, 50, 0*Math.PI, 1*Math.PI)                             // 圆中心坐标(200, 100)，半径50，绘制弧度从0到PI
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(250, 100)                                                    // 直线起点(250, 100)
            ctx.lineTo(420, 100)                                                    // 直线终点(350, 100)
            ctx.stroke()

            ctx.fillStyle = "red";
            ctx.font = "italic 30px Arial"
            ctx.fillText("Hello World", 250, 90)                                    // 文本左下角(250, 90)

            ctx.beginPath()
            ctx.ellipse(420, 50, 200, 100)                                          // 左上角坐标(420, 50)，宽200，高100
            ctx.stroke()

            ctx.fillStyle = "red";
            ctx.fillRect(50, 200, 100, 100)                                         // 左上角坐标(50, 200)，长100，宽100

            ctx.beginPath()
            ctx.moveTo(150, 250)
            ctx.quadraticCurveTo(250, 150, 250, 250)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(450, 245)
            ctx.lineTo(500, 245)
            ctx.lineTo(500, 225)
            ctx.lineTo(525, 250)
            ctx.lineTo(500, 275)
            ctx.lineTo(500, 255)
            ctx.lineTo(450, 255)
            ctx.closePath()
            ctx.fillStyle = "yellow"
            ctx.fill()
            ctx.strokeStyle = "black"
            ctx.lineWidth = 2
            ctx.stroke()
        }
    }
}
