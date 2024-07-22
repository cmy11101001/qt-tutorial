import QtQuick 2.15

DropArea {
    id: dropArea
    // 默认颜色
    property alias color: dropRectangle.color
    property color dropColor: "grey"

    implicitWidth: parent.width
    implicitHeight: parent.height * 0.8
    keys: ["组1", "组2"]

    Rectangle {
        id: dropRectangle
        anchors.fill: parent
        color: "yellow"
    }

    // 当拖动进入 DropArea
    onEntered: (drag) => {
//        console.log("拖进来:" + drag.source.name)
    }

    // 当位置发生改变
    onPositionChanged: (drag) => {
//        console.log("正在移动:", drag.source.name, "(", drag.source.x, ",", drag.source.y, ")")
    }

    states: [
        State {
            when: dropArea.containsDrag
            PropertyChanges {
                target: dropRectangle
                color: dropColor
            }
        }
    ]
}
