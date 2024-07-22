import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("DropArea")
    id: window

    property bool onLine: false
    property var startItem
    property var endItem

    // 放置拖拽元素的区域
    CmyDrop {
        id: dropArea
        width: parent.width
        height: parent.height * 0.8
        anchors.bottom: parent.bottom
        color: "black"
        dropColor: "gray"
    }

    // 创建拖拽元素
    function createCmyDrag() {
        var drag = Qt.createQmlObject("
            import QtQuick 2.15
            CmyDrag {
                parentDropArea: dropArea
                width: 200
                height: 50
                border.width: 1
                name: \"放假当宅宅\"
                Text {
                    anchors.centerIn: parent
                    text: parent.name
                    font.pointSize: 20
                }
            }
        "
        , window)
        return drag
    }

    // 创建连线元素
    function createCmyLine() {
        var line = Qt.createQmlObject("
            import QtQuick 2.15
            CmyLine {
            }
        "
        , dropArea)
        return line
    }

    // 添加拖拽元素
    Button {
        id: btn
        text: "创建拖拽元素"
        onClicked: {
            var drag = window.createCmyDrag()
            drag.x = btn.width
            // 单击
            drag.takeUp.connect(window.onTakeUp)
            // 双击
            drag.linkLine.connect(window.onLinkLine)
        }
    }

    // 单击or拿起or连接完成
    function onTakeUp(item) {
        if (window.onLine){
            window.onLine = false
            window.endItem = item
            // 判断startItem是否等于endItem
            if (startItem !== endItem) {
                var line = window.createCmyLine()
                line.itemStart = startItem
                line.itemEnd = endItem
                line.update()
            }
        }
    }

    // 双击连线
    function onLinkLine(item) {
        if (!window.onLine) {
            window.onLine = true
            window.startItem = item
        }
    }
}
