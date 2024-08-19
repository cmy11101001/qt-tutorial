import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("SplitWindow")
    property alias rectItem: rectItem

    // 分割窗口
    SplitWindow {
        id: splitWindow
        width: window.width
        height: window.height
        visible: false
        originalWindow: window
    }

    // 存放分割视图
    Item {
        id: rectItem
        anchors.fill: parent
        // 分割视图
        Rectangle {
            id: rect
            color: "red"
            anchors.fill: parent
            Text {
                anchors.centerIn: parent
                text: "窗口"
            }
        }
    }

    // 触发视图分割
    Button {
        text: "分割窗口"
        onClicked: {
            splitWindow.show()
            rect.parent = splitWindow.splitItew
        }
    }
}
