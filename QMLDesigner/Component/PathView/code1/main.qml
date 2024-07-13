import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "black"

    PathView {
        id: pathView
        anchors.fill: parent
        model: ListModel {
            ListElement { content: "PathView"; color: "red" }
            ListElement { content: "放假当宅宅"; color: "green"  }
            ListElement { content: "关注"; color: "yellow"  }
            ListElement { content: "点赞"; color: "blue" }
            ListElement { content: "投币"; color: "coral"  }
            ListElement { content: "收藏"; color: "blueviolet"  }
        }
        delegate: Rectangle {
            width: pathView.width * 0.5
            height: pathView.height * 0.5
            color: model.color
            opacity: PathView.itemOpacity
            z: PathView.itemZ
            Text {
                anchors.centerIn: parent
                font.pointSize: 30
                text: model.content
            }
        }

        path: Path {
            startX: pathView.width / 2
            startY: pathView.height / 3 * 2
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemZ"
                value: 10
            }

            PathCubic {
                x: pathView.width / 2
                y: pathView.height / 3
                control1X: pathView.width
                control1Y: y
                control2X: pathView.width
                control2Y: pathView.height / 3 * 2
            }
            PathAttribute {
                name: "itemOpacity"
                value: 0
            }
            PathAttribute {
                name: "itemZ"
                value: 0
            }

            PathCubic {
                x: pathView.width / 2
                y: pathView.height / 3 * 2
                control1X: 0
                control1Y: y
                control2X: 0
                control2Y: pathView.height / 3
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1
            }
            PathAttribute {
                name: "itemZ"
                value: 10
            }
        }
    }
}
