import QtQuick 2.15
import QtQuick.Window 2.15

Window{
    id: window
    // 存放分割视图
    property alias splitItew: item;
    // 原窗口
    property var originalWindow

    // 存放分割视图
    Item{
        id: item;
        anchors.fill: parent;
    }

    // 窗口关闭，把视图返还给原窗口
    Connections {
        target: window
        // 窗口关闭
        onClosing: {
            if (originalWindow !== undefined) {
                if (item.children.length > 0) {
                    item.children[0].parent = originalWindow.rectItem
                }
            }
        }
    }
}
