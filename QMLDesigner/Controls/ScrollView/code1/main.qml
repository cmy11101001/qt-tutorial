import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ScrollView {
        id: scrollView
        width: 200
        height: 200
        anchors.centerIn: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
        background: Rectangle {
            color: "yellow"
        }
        TextEdit {
            id: textEdit
            anchors.centerIn: parent
            text: "ScrollView + TextEdit"
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

    function scrollViewAddText(text) {
        // 给TextEdit添加文本
        textEdit.text += text
        // 调整视图到scrollView底部
        scrollView.ScrollBar.vertical.position =
                scrollView.contentHeight>scrollView.height?
                (scrollView.contentHeight - scrollView.height)
                 / scrollView.contentHeight: 0
    }

    Button {
        anchors.left: scrollView.right
        anchors.top: scrollView.top
        text: "添加文本"
        onClicked: {
            scrollViewAddText("\n一键三连")
        }
    }
}
