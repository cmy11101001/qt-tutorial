import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Animation")

    Rectangle {
        id: rect
        width: 50
        height: 50
        color: "red"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                rect.color = "yellow"
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 1000
            }
        }
    }

//    ColorAnimation {
//        id: colorAnimation
//        target: rect
//        property: "color"
//        from: "red"
//        to: "yellow"
//        duration: 500
//        running: true
//    }

//    Component.onCompleted: {
//        colorAnimation.start()
//    }
}
