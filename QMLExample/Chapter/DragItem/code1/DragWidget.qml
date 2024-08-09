import QtQuick 2.12

Item {
    id: root
    x: 0
    y: 0
    width: parent.width
    height: parent.height
    // 被控视图
    property var control: parent
    MouseArea {
        anchors.fill: control
        onClicked: {
            parent.focus = true
        }
    }

    // 支持鼠标拖拽
    DragItem {
        id: dragwidget
        mouseStyle: Qt.SizeAllCursor
        control: root.control
        anchors.fill: parent
        hoverenabled: false
        visible: control.focus
        onDragPos: {
            control.x += pos.x
            control.y += pos.y
        }
    }

    // 支持大小拖拽
    DragSizeItem {
        control: root.control
        anchors.fill: parent
        visible: control.focus
    }
}
