import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    Rectangle {                                                                                         // 2
        width: textInput.width
        height: textInput.height
        anchors.centerIn: parent
        color: "yellow"
        border.color: "black"
        Text {                                                                                          // 3
            id: getTextLength
            visible: false
            text: textInput.text
            font.pointSize: textInput.font.pointSize
        }
        TextInput {                                                                                     // 1
            id: textInput
            anchors.centerIn: parent
            width: text.length < 1?                                                                     // 3
                       100:
                       echoMode == TextInput.Password?
                           getTextLength.width * 2:
                           getTextLength.width
            font{                                                                                       // 1
                pointSize: 30
                bold: true
            }
            validator: RegExpValidator {                                                                // 4
                regExp: /^\d+$/
            }
            echoMode: TextInput.Password                                                                // 10
            cursorVisible: true                                                                         // 5
            cursorDelegate: Rectangle{                                                                  // 6
                id: rect
                width: 4
                color: "red"
                states: [                                                                               // 7
                    State {
                        name: "red"
                        PropertyChanges {
                            target: rect
                            color: "red"
                        }
                    },
                    State {
                        name: "transparent"
                        PropertyChanges {
                            target: rect
                            color: "transparent"
                        }
                    }
                ]
                transitions: [                                                                          // 8
                    Transition {
                        from: "*"
                        to: "*"
                        ColorAnimation {
                            id: colorAnimation
                            duration: 250
                        }
                    }
                ]
                Timer {                                                                                 // 9
                    interval: colorAnimation.duration
                    repeat: true
                    running: true
                    onTriggered: {
                        rect.state = rect.state == "red" ? "transparent" : "red"
                    }
                }
            }
        }
    }
}
