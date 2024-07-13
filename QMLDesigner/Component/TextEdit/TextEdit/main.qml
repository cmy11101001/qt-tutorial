import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        anchors.centerIn: parent
        width: textEdit.width
        height: textEdit.height
        color: "yellow"
        TextEdit {
            id: textEdit
            anchors.centerIn: parent
            text: "TextEdit"
            color: "red"
            font{
                pointSize: 30
                bold: true
            }
            selectByMouse: true
            selectionColor: "blue"
            cursorDelegate: Canvas {
                width: 4
                onPaint: {
                    var ctx = getContext('2d')
                    ctx.setLineDash([2, 2, 2])
                    ctx.lineWidth = 4
                    ctx.strokeStyle = "#444fff"
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(0, height)
                    ctx.stroke();
                }
            }
        }
    }
}
