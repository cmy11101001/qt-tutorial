import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    Text {
        id: window_text
        font.pointSize: 30
        text: qsTr("rectangle text")
    }

    Button {
        x: 20
        y: 100
        text: qsTr("button")
        onClicked: {
            window_text.text += " -> 一键三连"
        }
    }
}
