import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    property StackView stackView
    Rectangle {
        anchors.fill: parent
        color: "yellow"
        Text {
            anchors.centerIn: parent
            text: "视图2"
            font.pointSize: 30
        }

        Button {
            font.pointSize: 20
            text: "回退视图1"
            onClicked: {
                stackView.pop()
            }
        }

        Button {
            anchors.right: parent.right
            font.pointSize: 20
            text: "进入视图3"
            onClicked: {
                stackView.push("qrc:/MyView03.qml", {stackView: stackView})
            }
        }
    }
}
