import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("StackView")

    StackView {
        id: stackView
        anchors.fill: parent
        // 背景视图
        background: Rectangle{
            color: "green"
        }

        // 启动视图
        initialItem: MyView01 {
            stackView: stackView
        }

        // 过渡动画
        pushEnter: Transition {
            from: "*"
            to: "*"
            PropertyAnimation {
                property: "width"
                from: 0
                to: stackView.width
                duration: 500
            }
            PropertyAnimation {
                property: "height"
                from: 0
                to: stackView.height
                duration: 500
            }
        }
    }
}
