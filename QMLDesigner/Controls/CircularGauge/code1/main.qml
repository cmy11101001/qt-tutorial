import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    CircularGauge {
        id: circularGauge
        anchors.fill: parent
        anchors.centerIn: parent
        minimumValue: 0
        maximumValue: 100
        value: 50
        stepSize: 0.1
        tickmarksVisible: true

        // 自定义样式
        style: CircularGaugeStyle {
            id: style

            // 背景
            background: Rectangle {
                radius: outerRadius
                color: "black"
                border.width: 1
                border.color: "LightGray"
                Text {
                    anchors.top: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: parent.radius / 5
                    color: "white"
                    text: "关注:" + control.value
                    font {
                        pointSize: topPadding / 1.5 > 0? topPadding / 1.5: 1
                        bold: true
                    }
                }
            }

            // 大刻度
            tickmark: Rectangle {
                implicitWidth: outerRadius * 0.04
                implicitHeight: outerRadius * 0.08
                antialiasing: true
                color: styleData.value >= 80 ? "red" : "white"
            }

            // 小刻度
            minorTickmark: Rectangle {
                implicitWidth: outerRadius * 0.01
                implicitHeight: outerRadius * 0.03
                antialiasing: true
                color: styleData.value >= 80 ? "red" : "white"
            }

            // 刻度文本
            tickmarkLabel:  Text {
                font.pixelSize: Math.max(6, outerRadius * 0.1)
                text: styleData.value
                antialiasing: true
                color: styleData.value >= 80 ? "red" : "white"
            }

            // 指针
            needle: Rectangle {
                y: outerRadius * 0.15
                implicitWidth: outerRadius * 0.03
                implicitHeight: outerRadius * 0.9
                antialiasing: true
                color: "orangered"
            }

            // 前景
            foreground: Item {
                Rectangle {
                    width: outerRadius * 0.2
                    height: width
                    radius: width / 2
                    color: "orangered"
                    anchors.centerIn: parent
                }
            }

            // 刻度文本到外半径的距离
            labelInset: outerRadius * 0.25

            // 小刻度到外半径的距离
            minorTickmarkInset: outerRadius * 0.1

            // 大刻度到外半径的距离
            tickmarkInset: outerRadius * 0.05

            // 最小刻度角度位置
            minimumValueAngle: -180

            // 最大刻度角度位置
            maximumValueAngle: 90
        }
    }
    // 演示
    Timer {
        interval: 20
        repeat: true
        running: true
        onTriggered: {
            if (circularGauge.value ++ >= circularGauge.maximumValue) {
                circularGauge.value = circularGauge.minimumValue
            }
        }
    }
}
