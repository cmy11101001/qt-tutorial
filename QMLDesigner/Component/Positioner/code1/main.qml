import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("positioner")

    Rectangle {
        id: rectColumn
        width: parent.width / 2
        height: parent.height / 2
        border.width: 1
        Column {
            anchors.fill: parent
            spacing: 10
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: 50; height: 50
                    border.width: 1
                    color: "yellow"
                    opacity: 0.5
                }
            }
        }
        Text {
            text: qsTr("Column")
            anchors.centerIn: parent
            font.pointSize: 30
        }
    }
    Rectangle {
        id: rectFlow
        width: parent.width / 2
        height: parent.height / 2
        border.width: 1
        anchors.left: rectColumn.right
        Flow {
            anchors.fill: parent
            spacing: 10
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: 50; height: 50
                    border.width: 1
                    color: "yellow"
                    opacity: 0.5
                }
            }
        }
        Text {
            text: qsTr("Flow")
            anchors.centerIn: parent
            font.pointSize: 30
        }
    }
    Rectangle {
        id: rectGrid
        width: parent.width / 2
        height: parent.height / 2
        border.width: 1
        anchors.top: rectColumn.bottom
        Grid {
            anchors.fill: parent
            spacing: 10
            columns: 3 // 设置列数为3
            rows: 2 // 设置行数为2
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: 50; height: 50
                    border.width: 1
                    color: "yellow"
                    opacity: 0.5
                }
            }
        }
        Text {
            text: qsTr("Grid")
            anchors.centerIn: parent
            font.pointSize: 30
        }
    }
    Rectangle {
        id: rectRow
        width: parent.width / 2
        height: parent.height / 2
        border.width: 1
        anchors.left: rectGrid.right
        anchors.top: rectColumn.bottom
        Row {
            anchors.fill: parent
            spacing: 10
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: 50; height: 50
                    border.width: 1
                    color: "yellow"
                    opacity: 0.5
                }
            }
        }
        Text {
            text: qsTr("Row")
            anchors.centerIn: parent
            font.pointSize: 30
        }
    }
}
