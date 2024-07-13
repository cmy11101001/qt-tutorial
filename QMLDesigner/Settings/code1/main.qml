import QtQuick 2.15
import QtQuick.Window 2.15
import Qt.labs.settings 1.1
import QtQuick.Controls 2.15

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "#ff0000"

    Settings {
        fileName: "./setting.ini"
        property alias color: window.color
        property alias window_width: window.width
        property alias window_heigh: window.height
    }

    Button{
        text: "切换颜色"
        onClicked: {
            window.color = window.color == "#ff0000"?
                        "#00ff00":
                        "#ff0000"
        }
    }
}
