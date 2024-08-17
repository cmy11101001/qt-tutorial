import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    // 这里的colors就是addImageProvider第一个参数
    // index就是requestPixmap中的id
    Column {
        id: column
        Repeater {
            model: 8
            Image {
                source: "image://colors/"+index
            }
        }
    }

    Image {
        id: image
        anchors.top: column.top
        anchors.left: column.right
        cache: false
        source: "image://UpdateImage"
    }
    Connections {
        target: UpdateImage
        onUpdatePixmap: {
            image.source = ""
            image.source = "image://UpdateImage"
        }
    }
}
