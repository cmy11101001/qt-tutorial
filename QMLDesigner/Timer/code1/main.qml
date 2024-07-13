import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Rectangle {
        id: myRectangle
        anchors.fill: parent
        color: "#ff0000"
        Switch {
            anchors.centerIn: parent
            text: "启动定时器"
            checked: false
            onCheckedChanged: {
                if (checked){
                    myTimer.start()
                    text = "停止定时器"
                } else {
                    myTimer.stop()
                    text = "启动定时器"
                }
            }
        }
    }

    Timer {
        id: myTimer
        interval: 500
        repeat: true
        running: false
        onTriggered: {
            myRectangle.color =
                    (myRectangle.color == "#ff0000")
                    ? "#0000ff" : "#ff0000"
        }
    }
}
