import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: root
    // 被控视图
    property var control: parent
    readonly property int recSize: 12
    width: recSize
    height: recSize
    color: "#00FFFF"
    radius: width / 2
    // 旋转视图位置在被控视图上方
    anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        topMargin: -20
    }
    // 旋转视图到被控视图之间画一条线
    Rectangle {
        id: rotateline
        color: root.color
        width: 2
        height: 10
        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: -2
        }
    }

    // 进入视图时光标位置视图
    Image {
        id: rotateCursor
        source: "./rotate.svg"
        width: sourceSize.width * 0.6
        height: sourceSize.height * 0.6
        visible: rotateArea.containsMouse | rotateArea.pressed
        x: rotateArea.mouseX - width  / 2
        y: rotateArea.mouseY - height / 2
    }

    MouseArea {
        id: rotateArea
        anchors.centerIn: parent
        width: parent.width * 2
        height: parent.height * 2
        hoverEnabled: true
        property int pressX: 0
        // 鼠标位置是否在当前鼠标区域内
        onContainsMouseChanged: {
            if(containsMouse) {
                // 隐藏光标, 此时rotateCursor显示
                cursorShape = Qt.BlankCursor
            } else {
                cursorShape = Qt.ArrowCursor
            }
        }

        onPressedChanged: {
            // 鼠标在视图内部
            if (containsPress) {
                pressX = mouseX
            }
        }

        // 鼠标按下移动时旋转视图
        onPositionChanged: {
            if (pressed) {
                cursorShape = Qt.BlankCursor
                let t = control.rotation + (mouseX - pressX) * 0.2
                t = t % 360
                control.rotation = Math.floor(t)
            }
        }
    }

    ToolTip {
        id: toolTop
        x: rotateArea.mouseX + 20
        y: rotateArea.mouseY
        visible: rotateArea.pressed
        contentItem: Text {
            text: parseInt(control.rotation) + "°"
        }
    }
}


