import QtQuick 2.15

Rectangle {
    id: rect
    // 本视图名称
    property string name: "Drag"
    // 目标DropArea
    required property DropArea parentDropArea
    // 拿起信号
    signal takeUp(var item)
    // 双击连线
    signal linkLine(var item)

    implicitWidth: 50
    implicitHeight: 50
    // 只有支持相同keys的DropArea才能拖进去
    Drag.keys: ["组1"]

    // 当前是否正在拖动绑定鼠标区域当前是否正在拖动
    Drag.active: mouseArea1.drag.active

    // 进入DropArea的判定位置
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    MouseArea {
        id: mouseArea1
        anchors.fill: parent
        drag.target: rect
        onPressed: {
            // 拿起
            if (rect.parent == parentDropArea) {
                rect.takeUp(rect)
            }
//            console.log("拿起")
//            console.log(rect.Drag.target)
        }
        onReleased: {
            // 放下
//            console.log("放下")
//            console.log(rect.Drag.target)
            // 切换parent
            if (rect.Drag.target !== null && rect.Drag.target !== rect.parent) {
                // 将rect.parent(rect.x, rect.y)映射到rect.Drag.target中
                var mappedPoint = rect.parent.mapToItem(rect.Drag.target, rect.x, rect.y)
                rect.parent = rect.Drag.target
                rect.x = mappedPoint.x
                rect.y = mappedPoint.y
            }
            // 判断parent是否是目标parent
            if (rect.parent != rect.parentDropArea) {
                // 自毁
                rect.destroy()
            }
            // 判断坐标是否移出parent
            var xRang = rect.x + rect.Drag.hotSpot.x
            var yRang = rect.y + rect.Drag.hotSpot.y
            if (xRang < 0 || yRang < 0
                    || xRang > rect.parent.width
                    || yRang > rect.parent.height) {
                // 自毁
                rect.destroy()
            }
        }
        onDoubleClicked: {
            if (rect.parent == parentDropArea) {
                rect.linkLine(rect)
            }
        }
    }
}
