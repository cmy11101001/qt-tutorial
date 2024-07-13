import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    property StackView stackView
    Rectangle {
        anchors.fill: parent
        color: "red"
        Text {
            anchors.centerIn: parent
            text: "视图1"
            font.pointSize: 30
        }

        Button {
            anchors.right: parent.right
            font.pointSize: 20
            text: "进入视图2"
            onClicked: {
                stackView.push("qrc:/MyView02.qml", {stackView: stackView})
            }
        }
    }
}
