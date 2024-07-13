import QtQuick 2.15
import QtQuick.Window 2.1

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Text {
        id: window_text
        font.pointSize: 30
        text: qsTr("Window text")
    }

    MyCompnent {
        anchors.top: window_text.bottom
    }

}
