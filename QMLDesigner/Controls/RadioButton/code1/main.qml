import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("RadioButton")

    Item {
        id: rect1
        width: radio101.width
        RadioButton {
            id: radio101
            text: "Option 1-01"
            indicator: Rectangle {
                width: 20
                height: 20
                border.width: 1
                x: 2
                y: (radio101.height - height) / 2
                color: radio101.checked? "black": "white"
            }
            contentItem: Text {
                leftPadding: radio101.indicator.width
                text: radio101.text
                font.pointSize: 15
                color: "red"
                MouseArea {
                    onClicked: {
                        radio101.checked = radio101.checked? false: true
                    }
                }
            }
        }
        RadioButton {
            id: radio102
            anchors.top: radio101.bottom
            text: "Option 1-02"
        }
        RadioButton {
            id: radio103
            anchors.top: radio102.bottom
            text: "Option 1-03"
        }
    }
    Item {
        id: rect2
        anchors.left: rect1.right
        width: radio201.width
        RadioButton {
            id: radio201
            text: "Option 2-01"
            autoExclusive: false
        }
        RadioButton {
            id: radio202
            anchors.top: radio201.bottom
            text: "Option 2-02"
        }
        RadioButton {
            id: radio203
            anchors.top: radio202.bottom
            text: "Option 2-03"
        }
    }
}
