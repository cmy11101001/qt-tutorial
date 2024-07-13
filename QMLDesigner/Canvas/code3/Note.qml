import QtQuick 2.15

Item {
    id: item
    // 轨道序号
    required property var number
    Rectangle {
        anchors.fill: parent
        radius: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#0004bd" }
        }
    }
}
