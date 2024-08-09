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
        id: topDrag
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
        id: bottomDrag
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
        id: leftDrag
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
        id: rightDrag
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
        id: topleftDrag
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
        id: bottomleftDrag
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
        id: toprightDrag
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
        id: bottomrightDrag
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
        x: -width * 0.5
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
        x: parent.width - width * 0.5
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
        y: -height * 0.5
        width: root.width - border.width * 2
        height: topDrag.height
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
        y: parent.height - height * 0.5
        width: root.width - border.width * 2
        height: bottomDrag.height
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
        x: -width * 0.5
        y: -height * 0.5
        width: topleftDrag.width
        height: topleftDrag.height
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
        x: -width * 0.5
        y: parent.height - height * 0.5
        width: bottomleftDrag.width
        height: bottomleftDrag.height
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
        x: parent.width - width * 0.5
        y: -height * 0.5
        width: toprightDrag.width
        height: toprightDrag.height
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
        x: parent.width - width * 0.5
        y: parent.height - height * 0.5
        width: bottomrightDrag.width
        height: bottomrightDrag.height
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
