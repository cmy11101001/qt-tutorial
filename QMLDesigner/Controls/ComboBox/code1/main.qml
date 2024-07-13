import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ComboBox")

    ComboBox {
        id: comboBox
        // 列表项数据模型
        model: ListModel {
            ListElement { name: "点赞"; color: "black"}
            ListElement { name: "关注"; color: "red" }
            ListElement { name: "投币"; color: "blue" }
        }
        // 显示文本对应的数据模型属性
        textRole: "name"
        // 选项改变
        onCurrentTextChanged: {
            logText.text = currentText
        }
        // ComboBox内容视图
        contentItem: Text {
            font.pointSize: 30
            text: comboBox.displayText
            color: "green"
            leftPadding: 10
        }
        // ComboBox背景视图
        background: Rectangle {
            color: "yellow"
            border.width: 1
        }
        // 选项视图代理
        delegate: ItemDelegate {
            width: comboBox.width
            height: comboBox.height
            // 选项内容视图
            contentItem: Text {
                text: name
                font.pointSize: 30
                color: model.color
                verticalAlignment: Text.AlignVCenter
            }
            // 选项背景视图
            background: Rectangle {
                color: comboBox.highlightedIndex === index? "yellow": "transparent"
            }
        }
        // 指示器
        indicator: Rectangle {
            x: comboBox.width - width
            y: 0
            width: 50
            height: comboBox.height
            color: "transparent"
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext('2d')
                    ctx.beginPath()
                    ctx.moveTo(10, 10)
                    ctx.lineTo(40, 10)
                    ctx.lineTo(25, height-10)
                    ctx.closePath()
                    ctx.fillStyle = "blue"
                    ctx.fill()
                    ctx.strokeStyle = "black"
                    ctx.lineWidth = 2
                    ctx.stroke()
                }
            }
        }
    }

    // 演示
    Text {
        id: logText
        anchors.left: comboBox.right
        anchors.leftMargin: 20
        font.pointSize: 30
    }
}
