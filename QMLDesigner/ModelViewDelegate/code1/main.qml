import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    ListView {
        id: myListView
        width: 150
        height: parent.height
        model: ListModel {
            ListElement { content: "ListView"}
            ListElement { content: "放假当宅宅"}
            ListElement { content: "一键三连"}
        }
        delegate: Rectangle {
            width: 150
            height: 50
            color: index % 2 === 0 ? "#30ffaf" : "#f6ff08"
            Text {
                anchors.centerIn: parent
                text: content;
                font{
                    pointSize: 20
                    bold: true
                }
            }
        }
    }

    Column {
        id: myColumn
        width: 150
        height: parent.height
        anchors.left: myListView.right
        anchors.leftMargin: 2
        Repeater {
            model: ["Column", "放假当宅宅", "一键三连"]
            delegate: Rectangle {
                width: 150
                height: 50
                color: index % 2 === 0 ? "#30ffaf" : "#f6ff08"
                Text {
                    anchors.centerIn: parent
                    text: modelData;
                    font{
                        pointSize: 20
                        bold: true
                    }
                }
            }
        }
    }

    GridView {
        id: myGridView
        width: 300
        height: parent.height
        anchors.left: myColumn.right
        anchors.leftMargin: 2
        cellWidth: 150
        cellHeight: 50
        model: ListModel {
            ListElement { content: "GridView"}
            ListElement { content: "放假当宅宅"}
            ListElement { content: "一键三连"}
        }
        delegate: Rectangle {
            width: 150
            height: 50
            color: index % 2 === 0 ? "#30ffaf" : "#f6ff08"
            Text {
                anchors.centerIn: parent
                text: content;
                font{
                    pointSize: 20
                    bold: true
                }
            }
        }
    }
}
