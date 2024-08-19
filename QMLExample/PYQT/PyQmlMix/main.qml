import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import My.Backend 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Button {
        x:10
        y:10
        width: 100
        height: 50
        text: qsTr("backend")
        onClicked: {
            Backend.receive("Button 1 msg")
        }
    }
    Button {
        x:120
        y:10
        width: 100
        height: 50
        text: qsTr("backend2")
        onClicked: {
            Backend2.receive("Button 2 msg")
        }
    }
    TextArea {
        id: textArea
        x: 10
        y: 70
        font.pointSize: 20
        placeholderText: qsTr("Msg Area")
    }
    Connections {
        target: Backend
        onMessage: (msg)=> {
            textArea.text = msg
        }
    }
    Connections {
        target: Backend2
        onMessage: (msg)=> {
            textArea.text = msg
        }
    }
}
