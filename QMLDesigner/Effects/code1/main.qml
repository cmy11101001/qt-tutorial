import QtQuick 2.15
import QtQuick.Window 2.15
import QtQml.Models 2.1

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ShaderEffect")

    Rectangle {
        id: rect1
        anchors.fill: parent
        visible: false
        Text {
            anchors.centerIn: parent
            font.pixelSize: 100
            color: "blue"
            text: "放假当宅宅"
        }
    }

    ShaderEffectSource {
        id: theSource
        sourceItem: rect1
    }

    ShaderEffect {
        anchors.centerIn: parent
        anchors.fill: parent
        property variant source: theSource
        property variant delta: Qt.size(0.5 / width, 0.5 / height)
        fragmentShader: "qrc:/shaders/outline.frag"
    }
}
