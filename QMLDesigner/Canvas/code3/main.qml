import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import "game.js" as Game

Window {
    width: 480
    height: 640
    minimumWidth: 480
    maximumWidth: 480
    minimumHeight: 640
    maximumHeight: 640
    visible: true
    title: qsTr("Canvas Game")

    Canvas {
        id: canvas
        anchors.fill: parent
        // 得分
        property int score: 0
        // 准度宽松系数
        property int loose: 200

        onPaint: {
            var ctx = getContext('2d')
            // 绘制背景
            drawBackground(ctx)
            // 界面刷新
            draw(ctx)
        }

        function drawBackground(ctx) {
            ctx.setLineDash([1, 5, 1, 1, 5])
            ctx.lineWidth = 2
            ctx.strokeStyle = "#e1ad0f"
            ctx.lineCap = "round"

            // 画边框
            ctx.beginPath()
            ctx.moveTo(180, 0)
            ctx.lineTo(0, 640)
            ctx.stroke();

            ctx.beginPath()
            ctx.moveTo(300, 0)
            ctx.lineTo(480, 640)
            ctx.stroke()

            // 音符线
            ctx.setLineDash([3])
            ctx.beginPath()
            ctx.moveTo(18, 576)
            ctx.lineTo(462, 576)
            ctx.stroke()

            // 画轨道
            ctx.setLineDash([1, 4, 5])
            ctx.beginPath()
            ctx.moveTo(200, 0)
            ctx.lineTo(80, 640)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(220, 0)
            ctx.lineTo(160, 640)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(240, 0)
            ctx.lineTo(240, 640)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(260, 0)
            ctx.lineTo(320, 640)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(280, 0)
            ctx.lineTo(400, 640)
            ctx.stroke()
        }

        // 分数显示
        Text{
            anchors.centerIn: parent
            font{
                pointSize: 40
                bold: true
            }
            text: canvas.score
        }

        // 界面刷新
        function draw(ctx) {
            Game.process(ctx)
            // 平滑动画效果
            requestAnimationFrame(draw);
        }

        // 生成音符
        Timer {
            interval: 200
            repeat: true
            running: true
            onTriggered: {
                // 计算在第几条轨道上生成
                var randomNumber = Math.floor(Math.random() * 6.99)
                Game.generatedNote(canvas, randomNumber)
            }
        }

        // 音符越界
        Timer {
            interval: 20
            repeat: true
            running: true
            onTriggered: {
                Game.noteOver(canvas)
            }
        }

        // 按键触发
        focus: true
        Keys.onPressed: {
            Game.pressedKeys(canvas, event.key)
        }
    }
}
