import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        id: root
        width: 480; height: 240
        color: '#1e1e1e'

        // 绘制纹理->剧幕
        CurtainEffect {
            id: curtain
            anchors.fill: parent
        }

        // 切换剧幕
        MouseArea {
            anchors.fill: parent
            onClicked: curtain.open = !curtain.open
        }
    }
}
