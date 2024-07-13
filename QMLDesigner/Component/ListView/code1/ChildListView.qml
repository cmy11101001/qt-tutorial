import QtQuick 2.15

Rectangle {
    width: listView.width
    height: listView.height + rectIcon.height
    color: "white"
    property int iconSize: 50
    property int viewSize: 200
    property var title
    property var childModel

    Rectangle {
        id: rectIcon
        width: iconSize
        height: iconSize
        border.color: "white"
        color: "red"
    }
    Rectangle {
        id: rect
        width: viewSize
        height: iconSize
        anchors.left: rectIcon.right
        border.color: "white"
        color: "black"
        Text {
            anchors.centerIn: parent
            color: "white"
            text: title
            font{
                pointSize: 20
                bold: true
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                listView.height = listRect.height == 0? (listView.count * 50): 0
                listRect.height = listRect.height == 0? listView.height: 0
            }
        }
    }
    Rectangle {
        id: listRect
        height: listView.height
        width: listView.width
        anchors.left: rectIcon.right
        anchors.top: rect.bottom
        color: "blue"
        ListView {
            id: listView
            width: viewSize
            height: count * (viewSize / 4)
            clip: true
            model: childModel
            delegate: Rectangle {
                width: listView.width
                height: (viewSize / 4)
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
}
