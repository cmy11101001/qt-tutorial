import QtQuick 2.12

Item {
    id: root

    signal dragPos(point pos)
    signal clicked(real x, real y)
    signal doubleClicked(real x, real y)
    // 鼠标位置是否在当前鼠标区域内
    property alias containsMouse: mouseArea.containsMouse
    // 鼠标位置在鼠标区域内的样式
    property int mouseStyle: Qt.ArrowCursor
    // 鼠标悬停使能
    property bool hoverenabled: true
    // 被控视图
    property var control: parent
    implicitWidth: 6
    implicitHeight: 6

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: hoverenabled
        property point pressPoint: Qt.point(0, 0)
        onPressed: {
            pressPoint = Qt.point(mouseX, mouseY)
        }
        // 拖拽移动
        onPositionChanged: {
            if (drag && pressed && control) {
                let radian = control.rotation * (Math.PI / 180)
                let rotateX = Math.cos(radian) * (mouseX - pressPoint.x) - Math.sin(radian) * (mouseY - pressPoint.y)
                let rotateY = Math.cos(radian) * (mouseY - pressPoint.y) + Math.sin(radian) * (mouseX - pressPoint.x)
                dragPos(Qt.point(rotateX, rotateY))
            }
        }
        // 鼠标位置是否在当前鼠标区域内
        onContainsMouseChanged: {
            if (containsMouse) {
                cursorShape = mouseStyle
            } else {
                cursorShape = Qt.ArrowCursor
            }
        }
        onClicked: {
            root.clicked(mouseX, mouseY)
        }
        onDoubleClicked: {
            root.doubleClicked(mouseX, mouseY)
        }
    }
}
