import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        id: rect
        anchors.centerIn: parent
        height: text.height
        width: text.width
        color: "yellow"
        Text {
            id: text
            anchors.centerIn: parent
            text: "Text"
            color: "red"
            font {
                family: "Arial"
                pointSize: 50
                bold: true
                italic: true
                underline: true
            }
            style: Text.Outline
            styleColor: "black"
        }

        states: [
            State {
                name: "yellow"
                PropertyChanges {
                    target: rect
                    color: "yellow"
                }
            },
            State {
                name: "green"
                PropertyChanges {
                    target: rect
                    color: "green"
                }
            }
        ]

        Timer {
            interval: colorAnimation.duration
            repeat: true
            running: true
            onTriggered: {
                if (rect.state == "yellow") {
                    rect.state = "green"
                } else {
                    rect.state = "yellow"
                }
            }
        }

        transitions: [
            Transition {
                from: "*"
                to: "*"
                ColorAnimation {
                    id: colorAnimation
                    duration: 500
                }
            }
        ]
    }
}
