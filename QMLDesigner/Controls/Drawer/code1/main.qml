import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Drawer")

    Drawer {
        id: drawer
        width: parent.width / 4
        height: parent.height

        // 从屏幕左边滑出来
        edge: Qt.LeftEdge
        // 可以从屏幕边缘拉出来
        interactive: true
        // 设置模态
        modal: true
        // 模态背景变暗
        dim: true
        // 内部视图不能超出抽屉视图边界显示
        clip: true
        // 关闭策略
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        // 绘制抽屉背景视图
        background: Rectangle{
            anchors.fill: parent
            opacity: 0
        }
        // 绘制抽屉内部视图
        Rectangle {
            width: parent.width+30
            height: parent.height
            x: -30
            radius: 30
            opacity: 1
            Text {
                anchors.centerIn: parent
                text: "关注\n宅宅"
                font.pointSize: 30
                verticalAlignment: Text.AlignTop
            }
        }
    }

    Button {
        id: button
        x: drawer.width * drawer.position
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("打开")
        onClicked: {
            drawer.open()
        }
    }

}
