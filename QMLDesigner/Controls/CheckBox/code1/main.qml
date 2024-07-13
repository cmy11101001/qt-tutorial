import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    CheckBox {
        id: checkBox
        font.pointSize: 30
        text: "放假当宅宅"
        tristate: true
        onCheckStateChanged: {
            switch (checkState) {
            case Qt.Checked:
                logText.text = text+":\nChecked"
                break
            case Qt.PartiallyChecked:
                logText.text = text+":\nPartiallyChecked"
                break
            default:
                logText.text = text+":\nUnChecked"
                break
            }
        }
        background: Rectangle {
            color: "blue"
            width: checkBox.implicitWidth
        }
        contentItem: Text {
            text: checkBox.text
            color: "yellow"
            font.pixelSize: 30
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: checkBox.indicator.width
        }
        indicator: Rectangle {
            color: "transparent"
            width: image.width
            height: checkBox.height
            Image {
                id: image
                anchors.centerIn: parent
                height: checkBox.height
                source: checkBox.getCheckState()
                fillMode: Image.PreserveAspectFit
            }
        }
        function getCheckState() {
            switch (checkBox.checkState) {
            case Qt.Checked:
                return "qrc:/Checked.png"
            case Qt.PartiallyChecked:
                return "qrc:/PartiallyChecked.png"
            default:
                return "qrc:/UnChecked.png"
            }
        }
    }

    Rectangle {
        anchors.top: checkBox.bottom
        width: logText.width
        height: logText.height
        color: "yellow"
        Text {
            id: logText
            font.pointSize: 30
            text: "点赞+关注"
        }
    }
}
