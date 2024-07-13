import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("RangeSlider")

    RangeSlider {
        id: rangeSlider
        from: 0
        to: 100
        first {
            value: 10
            handle: Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                border.width: 1
                x: rangeSlider.leftPadding
                   + rangeSlider.first.visualPosition
                   * (rangeSlider.availableWidth - width)
                y: rangeSlider.height / 2 - height / 2
                Text {
                    anchors.centerIn: parent
                    font.pointSize: 15
                    text: rangeSlider.first.value.toFixed(0)
                }
            }
        }
        second {
            value: 90
            handle: Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                border.width: 1
                x: rangeSlider.leftPadding
                   + rangeSlider.second.visualPosition
                   * (rangeSlider.availableWidth - width)
                y: rangeSlider.height / 2 - height / 2
                Text {
                    anchors.centerIn: parent
                    font.pointSize: 15
                    text: rangeSlider.second.value.toFixed(0)
                }
            }
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            border.width: 1
            Rectangle {
                width: parent.width - rangeSlider.leftPadding
                       - rangeSlider.rightPadding
                height: 10
                radius: 5
                anchors.centerIn: parent
                color: "black"
            }
            Rectangle {
                x: rangeSlider.first.visualPosition * parent.width
                   + rangeSlider.leftPadding
                width: rangeSlider.second.visualPosition * parent.width
                       - x - rangeSlider.rightPadding
                height: 10
                anchors.verticalCenter: parent.verticalCenter
                color: "red"
            }
        }
    }
}
