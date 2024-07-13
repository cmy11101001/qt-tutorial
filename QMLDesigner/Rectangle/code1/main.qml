import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Rectangle Example")

    Rectangle {
        width: 100
        height: 100
        x: 0
        y: 0
        color: "yellow"
        border.color : "black"
        border.width : 5
        clip: true

        Rectangle {
            width: 200
            height: 300
            x: 10
            y: 10
            color : "blue"
            opacity: 1
            radius : 100
            antialiasing : true
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#000000" }
                GradientStop { position: 1.0; color: "#ffffff" }
            }
            border.color : "red"
            border.width : 5
        }
    }
}
