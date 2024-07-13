import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("TabBar")
    TabBar {
        id: tabBar
        width: parent.width
        background: Rectangle {
            color: "pink"
        }
        TabButton {
            id: tabButton
            text: "放假"
            background: Rectangle {
                color: tabButton.checked? "yellow": "transparent"
            }
            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: tabButton.text
                font.pointSize: 20
                color: "red"
            }
        }
        TabButton {
            text: "当"
        }
        TabButton {
            text: "宅宅"
        }
    }

    StackLayout {
        anchors.top: tabBar.bottom
        width: parent.width
        height: parent.height - tabBar.height
        currentIndex: tabBar.currentIndex
        Rectangle {
            color: "red"
        }
        Rectangle {
            color: "green"
        }
        Rectangle {
            color: "blue"
        }
    }
}
