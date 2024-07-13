import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        id: rect
        width: 50
        height: 50
        color: "red"
    }

    SequentialAnimation {
        running: true
        ParallelAnimation {
            ColorAnimation {
                target: rect
                property: "color"
                from: "red"
                to: "blue"
                duration: 500
            }

            NumberAnimation {
                target: rect
                property: "x"
                from: 0
                to: 200
                duration: 500
            }
        }

        PropertyAction {
            target: rect
            property: "x"
            value: 0
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction {
            script: myScript()
        }

        PropertyAnimation {
            target: rect
            property: "width"
            from: 50
            to: 200
            duration: 500
        }
    }

    Text {
        id: text
        anchors.top: rect.bottom
        font.pointSize: 30
        text: "点赞+关注"
    }

    function myScript() {
        text.text = "执行ScriptAction"
    }
}
