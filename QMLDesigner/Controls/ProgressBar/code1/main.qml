import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ProgressBar {
        id: progressBar
        width: 300
        height: 20
        anchors.centerIn: parent
        from: 0
        to: 100
        value: 50
        indeterminate: checkBox.checked     // 显示进度过程动画，不显示具体进度
        clip: true
        background: Rectangle {
            color: "yellow"
            border.width: 1
        }
        contentItem: Item {
            // 利用from、to、value绘制进度
            Rectangle {
                id: rect
                width: parent.width / 20
                height: parent.height - 10
                y: 5
                color: "red"
                property real indeterminateX: 0
                x: progressBar.indeterminate? indeterminateX
                   : parent.width
                   / (progressBar.to - progressBar.from)
                   * (progressBar.value - progressBar.from)
                   - width / 2
                Timer {
                    interval: 10
                    repeat: true
                    running: progressBar.indeterminate
                    onTriggered: {
                        rect.indeterminateX += progressBar.width / 100
                        if (rect.indeterminateX >= (progressBar.width - rect.width)) {
                            rect.indeterminateX = 0
                        }
                    }
                }
            }
        }
    }

    CheckBox {
        id: checkBox
        anchors.bottom: progressBar.top
        anchors.left: progressBar.left
    }

    TextInput {
        id: textInput
        anchors.bottom: progressBar.top
        anchors.left: checkBox.right
        font.pointSize: 30
        onEditingFinished: {
            progressBar.value = text
        }
    }

    Component.onCompleted: {
        textInput.text = progressBar.value
    }
}
