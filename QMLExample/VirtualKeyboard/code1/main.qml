import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.VirtualKeyboard.Settings 2.1
import QtQuick.VirtualKeyboard 2.1

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    TextInput {
        id: textInput
        anchors.centerIn: parent
        text: "123456"
        font.pointSize: 30
    }

    Button {
        anchors.right: textInput.left
        anchors.top: textInput.top
    }

    InputPanel {
        id: inputPanel
        x: (window.width - width) * 0.5
        y: parent.height
        width: window.width * 0.8
        visible: true
        states: State {
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height-inputPanel.height
            }
        }
        transitions: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Component.onCompleted:
        {
            VirtualKeyboardSettings.wordCandidateList.alwaysVisible = true
            VirtualKeyboardSettings.activeLocales = ["en_US","zh_CN"]   // 英语、中文(若不设置,则语言就有很多种)
        }
    }
}
