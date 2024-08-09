import QtQuick 2.12

Rectangle {
    id: root
    // 边框颜色
    property color posborderColor: "#08a1ef"
    // 拖拽小圆圈填充颜色
    property color posColor: "white"
    // 被控视图
    property var control: parent
    // 拖拽小圆圈大小
    readonly property int posRadius: 6

    color: "transparent"
    border.color: "transparent"
    width: parent.width
    height: parent.height

    // 边框颜色
    Rectangle {
        border.color: posborderColor
        anchors.fill: parent
        anchors.margins: -2
        border.width: 2
        color: "transparent"
        radius: posRadius
    }

    // top
    Rectangle {
        border.color: posborderColor
        border.width:  1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: - width / 2
        }
    }

    // bottom
    Rectangle {
        border.color: posborderColor
        border.width: 1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: - width / 2
        }
    }

    // left
    Rectangle {
        border.color: posborderColor
        border.width:  1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: - width / 2
        }
    }

    // right
    Rectangle {
        border.color: posborderColor
        border.width: 1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: - width / 2
        }
    }

    // topleft
    Rectangle {
        border.color: posborderColor
        border.width: 1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            left: parent.left
            verticalCenter: parent.top
            leftMargin: - width / 2
        }
    }

    // bottomleft
    Rectangle {
        border.color: posborderColor
        border.width: 1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            left: parent.left
            verticalCenter: parent.bottom
            leftMargin: - width / 2
        }
    }

    // topright
    Rectangle {
        border.color: posborderColor
        border.width: 1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            right: parent.right
            verticalCenter: parent.top
            rightMargin: - width / 2
        }
    }

    // bottomright
    Rectangle {
        border.color: posborderColor
        border.width: 1
        color: posColor
        width: posRadius * 2
        height: width
        radius: width / 2
        anchors {
            right: parent.right
            verticalCenter: parent.bottom
            rightMargin: - width / 2
        }
    }

    // 左边拖动大小
    DragItem {
        id: leftdragsize
        y: root.border.width
        height: root.height - border.width * 2
        mouseStyle: Qt.SizeHorCursor
        onDragPos: (pos)=>{
            if (pos.x < root.control.width) {
                root.control.x += pos.x
            }
            if (root.control.width - pos.x > 0) {
                root.control.width -= pos.x
            }
        }
    }

    // 右边拖动大小
    DragItem {
        id: rightdragsize
        x: parent.width - width
        y: root.border.width
        height: root.height - border.width * 2
        mouseStyle: Qt.SizeHorCursor
        onDragPos: (pos)=>{
            if (root.control.width + pos.x > 0) {
                root.control.width += pos.x
            }
        }
    }

    // 顶边拖动大小
    DragItem {
        id: topdragsize
        x: root.border.width
        width: root.width - border.width * 2
        mouseStyle: Qt.SizeVerCursor
        onDragPos: (pos)=>{
            if (pos.y < root.control.height) {
                root.control.y += pos.y
            }
            if (root.control.height - pos.y > 0) {
                root.control.height -= pos.y
            }
        }
    }

    // 底边拖动大小
    DragItem {
        id: bottomdragsize
        x: root.border.width
        y: parent.height - height
        width: root.width - border.width * 2
        mouseStyle: Qt.SizeVerCursor
        onDragPos: (pos)=>{
            if (root.control.height + pos.y > 0) {
                root.control.height += pos.y
            }
        }
    }

    // 左上角拖动大小 - 左上角坐标为 0,0
    DragItem {
        id: lefttopdragsize
        mouseStyle: Qt.SizeFDiagCursor
        onDragPos: (pos)=>{
            if (pos.x < root.control.width) {
                root.control.x += pos.x
            }
            if (pos.y < root.control.height) {
                root.control.y += pos.y
            }
            if (root.control.width - pos.x > 0) {
                root.control.width -= pos.x
            }
            if (root.control.height - pos.y > 0) {
                root.control.height -= pos.y
            }
        }
    }

    // 左下角拖动大小
    DragItem {
        id: leftbottomdragsize
        y: parent.height - height
        mouseStyle: Qt.SizeBDiagCursor
        onDragPos: (pos)=>{
            if (pos.x < root.control.width) {
                root.control.x += pos.x
            }
            if (root.control.width - pos.x > 0) {
                root.control.width -= pos.x
            }
            if (root.control.height + pos.y > 0) {
                root.control.height += pos.y
            }
        }
    }

    // 右上角拖动大小
    DragItem {
        id: righttopdragsize
        x: parent.width - width
        mouseStyle: Qt.SizeBDiagCursor
        onDragPos: (pos)=>{
            if (pos.y < root.control.height) {
                root.control.y += pos.y
            }
            if (root.control.height - pos.y > 0) {
                root.control.height -= pos.y
            }
            if (root.control.width + pos.x > 0) {
                root.control.width += pos.x
            }
        }
    }

    // 右下角拖动大小
    DragItem {
        id: rightbottomdragsize
        x: parent.width - width
        y: parent.height - height
        mouseStyle: Qt.SizeFDiagCursor
        onDragPos: (pos)=>{
            if (root.control.width + pos.x > 0) {
                root.control.width += pos.x
            }
            if (root.control.height + pos.y > 0) {
                root.control.height += pos.y
            }
        }
    }
}
