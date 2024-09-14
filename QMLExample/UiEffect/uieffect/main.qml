import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.10

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "whitesmoke"

    Button {
        clip: false
        Component {
            id: release_effect
            DropShadow {
                // 外阴影效果
                samples: 8
                radius: 8
                spread: 0
//                radius: floor(samples/2)
                transparentBorder: true
                horizontalOffset: 5
                verticalOffset: 5
                color: Qt.rgba(0, 0, 0, 0.5)
            }
        }
        Component {
            id: press_effect
            InnerShadow {
                // 内阴影效果
                samples: 8
                radius: 8
                spread: 0
//                radius: floor(samples/2)
                horizontalOffset: 5
                verticalOffset: 5
                color: Qt.rgba(0, 0, 0, 0.5)
            }
        }

        anchors.centerIn: parent
        width: 100
        height: 60
        layer.enabled: true
        layer.effect: release_effect
        background: Rectangle {
            id: rect
            color: "white"
            radius: 20
        }
        text: "按钮"
        font.bold: true
        font.pointSize: 20
        onPressed: {
            layer.effect = press_effect
        }
        onReleased: {
            layer.effect = release_effect
        }
    }
}
