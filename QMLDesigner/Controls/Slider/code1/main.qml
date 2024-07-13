import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    Slider {
        id: slider
        from: 0
        to: 100
        value: 50
        handle: Rectangle {
            implicitWidth: 30
            implicitHeight: 30
            border.width: 1
            x: slider.leftPadding
               + slider.visualPosition
               * (slider.availableWidth - width)
            y: slider.height / 2 - height / 2
            Text {
                anchors.centerIn: parent
                font.pointSize: 15
                text: slider.value.toFixed(0)
            }
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            border.width: 1
            Rectangle {
                width: parent.width - slider.leftPadding
                       - slider.rightPadding
                height: 10
                radius: 5
                anchors.centerIn: parent
                color: "black"
            }
            Rectangle {
                x: slider.leftPadding
                width: slider.visualPosition * parent.width
                       - x - slider.rightPadding
                height: 10
                radius: 5
                anchors.verticalCenter: parent.verticalCenter
                color: "red"
            }
        }
    }
}
