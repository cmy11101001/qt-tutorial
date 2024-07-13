import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    property StackView stackView
    Rectangle {
        anchors.fill: parent
        color: "blue"
        Text {
            anchors.centerIn: parent
            text: "视图3"
            font.pointSize: 30
        }

        Button {
            font.pointSize: 20
            text: "回退视图2"
            onClicked: {
                stackView.pop()
            }
        }

        Button {
            anchors.right: parent.right
            font.pointSize: 20
            text: "回退首页"
            onClicked: {
                stackView.pop(null)
            }
        }
    }
}
