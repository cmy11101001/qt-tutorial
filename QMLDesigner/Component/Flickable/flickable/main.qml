import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        width: 200
        height: 200
        color: "red"
        anchors.centerIn: parent
        clip: true
        Flickable {
            id: flickable
            anchors.fill: parent
//            Rectangle {
//                id: content
//                width: 400
//                height: 400
//                color: "yellow"
//                opacity: 0.5
//            }
            Image {
                id: content
                source: "qrc:/image.png"
            }
            contentWidth: content.width
            contentHeight: content.height
            rebound: Transition {
                NumberAnimation {
                    properties: "x, y"
                    duration: 500
                    easing.type: Easing.OutBounce
                }
            }
            ScrollBar.vertical: ScrollBar {
                background: Rectangle {
                    color: "#ffffff"
                }
                interactive: true
            }
            ScrollBar.horizontal: ScrollBar {
                background: Rectangle {
                    color: "#ffffff"
                }
                interactive: true
            }
            MouseArea {
                anchors.fill: parent
                onWheel: {
                    var delta = wheel.angleDelta.y / 120;
                    if (delta > 0) {
                       // 放大
                       content.scale *= 1.1;
                    } else {
                       // 缩小
                       content.scale /= 1.1;
                    }
                }
            }
        }
    }
}
