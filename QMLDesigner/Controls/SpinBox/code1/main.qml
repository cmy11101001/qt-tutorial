import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("SpinBox")

    SpinBox {
        id: spinBox
        anchors.centerIn: parent
        from: 0
        to: 100
        value: 50
        stepSize: 20
        editable: true
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 100
            border.width: 1
        }
        contentItem: Rectangle {
            TextInput {
                anchors.centerIn: parent
                text: spinBox.value
                font.pointSize: 30
                readOnly: !spinBox.editable
            }
        }
        down {
            indicator: Rectangle {
                implicitWidth: spinBox.background.width / 4
                implicitHeight: spinBox.background.height
                border.width: 1
                color: enabled?
                        spinBox.down.pressed? "gray": "white":
                        "lightGray"
                Text {
                    anchors.centerIn: parent
                    font.pointSize: 30
                    text: "-"
                }
            }
        }
        up {
            indicator: Rectangle {
                implicitWidth: spinBox.background.width / 4
                implicitHeight: spinBox.background.height
                x: spinBox.background.width - width
                border.width: 1
                color: enabled?
                        spinBox.up.pressed? "gray": "white":
                        "lightGray"
                Text {
                    anchors.centerIn: parent
                    font.pointSize: 30
                    text: "+"
                }
            }
        }
    }
}
