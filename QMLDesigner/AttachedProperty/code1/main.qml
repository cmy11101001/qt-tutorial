import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "blue"

    Rectangle {
        width: 100;
        height: 100;
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        color: "yellow";
        focus: true;
        Keys.onPressed: {
            switch(event.key) {
                case Qt.Key_Left: x -= 100; break;
                case Qt.Key_Right: x += 100; break;
                case Qt.Key_Up: y -= 100; break;
                case Qt.Key_Down: y += 100; break;
                default: return;
            }
        }
    }
}
