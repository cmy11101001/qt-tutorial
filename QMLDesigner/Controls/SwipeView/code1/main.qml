import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    SwipeView {
        id: view
        anchors.fill: parent
        currentIndex: pageIndicator.currentIndex

        // 添加页面
        Rectangle {
            color: "red"
            Text {
                anchors.centerIn: parent
                font.pointSize: 30
                color: "white"
                text: "点赞"
            }
        }
        Rectangle {
            color: "green"
            Text {
                anchors.centerIn: parent
                font.pointSize: 30
                color: "white"
                text: "关注"
            }
        }
        Rectangle {
            color: "blue"
            Text {
                anchors.centerIn: parent
                font.pointSize: 30
                color: "white"
                text: "放假当宅宅"
            }
        }
    }

    PageIndicator {
        id: pageIndicator
        count: view.count
        currentIndex: view.currentIndex
        anchors.bottom: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        interactive: true
        delegate: Rectangle {
            width: 40
            height: 40
            color: pressed? "pink": index===pageIndicator.currentIndex? "white": "black"
        }
    }
}
