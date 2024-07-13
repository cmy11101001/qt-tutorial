import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        anchors.fill: parent
        color: "black"
        Rectangle {
            id: rect1
            width: 128
            height: 96
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            color: "white"
            Text {
                anchors.centerIn: parent
                text: qsTr("rect1")
            }
            MouseArea {
                anchors.fill: parent
                drag.target: rect1
            }
        }

        Rectangle {
            id: rect2
            anchors.left: rect1.right
            anchors.verticalCenter: rect1.verticalCenter
            anchors.leftMargin: 10
            width: 128
            height: 96
            color: "red"
            Text {
                anchors.centerIn: parent
                text: qsTr("rect2")
            }
        }
    }
}
