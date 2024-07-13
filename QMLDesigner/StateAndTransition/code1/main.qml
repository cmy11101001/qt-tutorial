import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        id :rect1
        width: 100
        height: 100
        color: "red"
        anchors.left: parent.left
        anchors.top: parent.top
        Text {
            anchors.centerIn: parent
            font.pointSize: 20
            text: qsTr("rect1")
        }
        property int myNum: 1
        states: [
            State {
                name: "state 1"
                when: rect1.myNum === 1
                changes: [
                    PropertyChanges {
                        target: rect1
                        color: "red"
                    }
                ]
            },
            State {
                name: "state 2"
                when: rect1.myNum === 2
                changes: [
                    PropertyChanges {
                        target: rect1
                        color: "blue"
                    }
                ]
            }
        ]
        MouseArea {
            anchors.fill: parent
            onEntered: {
                rect1.myNum = 2
            }
            onExited: {
                rect1.myNum = 1
            }
        }
    }

    Rectangle{
        id :rect2
        width: 100
        height: 100
        color: "red"
        anchors.left: rect1.right
        anchors.leftMargin: 10
        anchors.top: rect1.top
        Text {
            anchors.centerIn: parent
            font.pointSize: 20
            text: qsTr("rect2")
        }
        state: "state 1"
        states: [
            State {
                name: "state 1"
                PropertyChanges {
                    target: rect2
                    color: "red"
                }
            },
            State {
                name: "state 2"
                PropertyChanges {
                    target: rect2
                    color: "blue"
                }
            }
        ]
        MouseArea {
            anchors.fill: parent
            onEntered: {
                rect2.state = "state 2"
            }
            onExited: {
                rect2.state = "state 1"
            }
        }

        transitions: [
            Transition {
                from: "state 1"
                to: "state 2"
                ColorAnimation {
                    property: "color"
                    duration: 300
                }
            },
            Transition {
                from: "state 2"
                to: "state 1"
                ColorAnimation {
                    property: "color"
                    duration: 500
                }
            }
        ]
    }
}
