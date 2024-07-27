import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Gauge {
        id: gauge
        anchors.centerIn: parent
        minimumValue: 0
        maximumValue: 100
        value: 50
        // 刻度方向
        orientation: Qt.Vertical
        height: 400
        tickmarkAlignment: Qt.AlignLeft
        // 一个大刻度数值间隔
        tickmarkStepSize: 20
        // 小刻度个数
        minorTickmarkCount: 4
        // 刻度字体
        font {
            bold: true
            pointSize: 20
        }
        // 刻度数值格式
        formatValue: function(value) {
            return value.toFixed(1);
        }
        // 自定义样式
        style: GaugeStyle {
            // 背景
            background: Rectangle {
                radius: 10
                color: "black"
            }
            // 前景
            foreground: Rectangle {
                color: "transparent"
                radius: 10
                border.width: 2
            }
            // 数值
            valueBar: Rectangle {
                color: control.value > 80? "red": "white"
                implicitWidth: 30
                radius: 10
            }
            // 小刻度
            minorTickmark: Item {
                implicitWidth: 10
                implicitHeight: 2

                Rectangle {
                    color: styleData.value > 80? "red": "#cccccc"
                    anchors.fill: parent
                    anchors.leftMargin: 2
                    anchors.rightMargin: 4
                }
            }
            // 大刻度
            tickmark: Item {
                implicitWidth: 18
                implicitHeight: 2

                Rectangle {
                    color: styleData.value > 80? "red": "#c8c8c8"
                    anchors.fill: parent
                    anchors.leftMargin: 3
                    anchors.rightMargin: 3
                }
            }
            // 数值
            tickmarkLabel: Text {
                text: styleData.value + '°'
                font.bold: true
                font.pointSize: 20
            }
        }
    }

    // 动画演示
    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        PropertyAnimation {
            target: gauge
            property: "value"
            to: 100
            easing.type: Easing.InQuint
            duration: 2000
        }
        PropertyAnimation {
            target: gauge
            property: "value"
            to: 0
            easing.type: Easing.InQuint
            duration: 2000
        }
    }
}
