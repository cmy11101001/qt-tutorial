import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    Switch {
        id: mySwitch
        anchors.centerIn: parent
        text: "点赞"
        background: Rectangle {
            border.width: 1
        }
        contentItem: Text {
            leftPadding: mySwitch.indicator.width
            text: mySwitch.text
            font.pointSize: 15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        indicator: Rectangle {
            implicitWidth: 60
            implicitHeight: 20
            radius: 5
            x: mySwitch.leftPadding
            y: mySwitch.height / 2 - height / 2
            color: "lightGray"
            Rectangle {
                width: 20
                height: 20
                radius: 5
                x: mySwitch.checked? 0: parent.width - width
                y: parent.height / 2 - height / 2
                color: mySwitch.checked? "gray": "green"
                Behavior on x {
                    NumberAnimation {
                        duration: 100
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
        }
    }
}
