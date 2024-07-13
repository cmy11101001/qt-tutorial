import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Flickable {
        id: flick
        width: 300; height: 200;
        contentWidth: edit.paintedWidth
        contentHeight: edit.paintedHeight
        clip: true
        TextEdit {
            id: edit
            width: flick.width
            focus: true
            wrapMode: TextEdit.Wrap
            selectByMouse: true
        }
        // 添加垂直滚动条
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            background: Rectangle {
                color: "#ffffff"
            }
            interactive: true
            policy: ScrollBar.AlwaysOn
        }
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
        }
    }
    Button {
        anchors.left: flick.right
        text: "添加文本"
        onClicked: {
            // 给TextEdit添加文本
            edit.text += "\n放假当宅宅\n点赞\n关注\n投币\n收藏"
            // 调整视图到flick底部
            flick.contentY = flick.contentHeight>flick.height?
                        flick.contentHeight - flick.height: 0
        }
    }
}
