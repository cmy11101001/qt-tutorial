import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Calendar")

    Calendar {
        id: the_calendar
        anchors.fill: parent
        style: CalendarStyle {
            // 顶部导航栏代理
            navigationBar: Rectangle {
                implicitHeight: 50
                // 低端黑线
                Rectangle {
                    width: parent.width
                    height: 2
                    anchors.bottom: parent.bottom
                    color: "black"
                }
                // 年份减少
                Rectangle {
                    id: subYear
                    width: parent.width * 0.15
                    height: parent.height * 0.8
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "<<"
                        font.bold: true
                        font.pointSize: 15
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.color = "red"
                            }
                            onExited: {
                                parent.color = "black"
                            }
                            onClicked: {
                                control.showPreviousYear()
                            }
                        }
                    }
                }
                // 年份
                Label {
                    id: year
                    anchors.left: subYear.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: control.visibleYear+"年"
                    font.bold: true
                    font.pointSize: 15
                }
                // 年份增加
                Rectangle {
                    id: addYear
                    width: parent.width * 0.15
                    height: parent.height * 0.8
                    anchors.left: year.right
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: ">>"
                        font.bold: true
                        font.pointSize: 15
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.color = "red"
                            }
                            onExited: {
                                parent.color = "black"
                            }
                            onClicked: {
                                control.showNextYear()
                            }
                        }
                    }
                }
                // 月份增加
                Rectangle {
                    id: addMonth
                    width: parent.width * 0.15
                    height: parent.height * 0.8
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    Text {
                        anchors.centerIn: parent
                        text: ">"
                        font.bold: true
                        font.pointSize: 15
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.color = "red"
                            }
                            onExited: {
                                parent.color = "black"
                            }
                            onClicked: {
                                control.showNextMonth()
                            }
                        }
                    }
                }
                // 月份
                Label {
                    id: month
                    anchors.right: addMonth.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: (control.visibleMonth+1)+"月"
                    font.bold: true
                    font.pointSize: 15
                }
                // 月份减少
                Rectangle {
                    id: subMonth
                    width: parent.width * 0.15
                    height: parent.height * 0.8
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: month.left
                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        font.bold: true
                        font.pointSize: 15
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.color = "red"
                            }
                            onExited: {
                                parent.color = "black"
                            }
                            onClicked: {
                                control.showPreviousMonth()
                            }
                        }
                    }
                }
            }
            // 星期几代理
            dayOfWeekDelegate: Rectangle {
                implicitHeight: 40
                Label {
                    anchors.centerIn: parent
                    text: control.__locale.dayName(styleData.dayOfWeek, control.dayOfWeekFormat)
                    font.bold: true
                    font.pixelSize: 15
                }
            }
            // 日期代理
            dayDelegate: Rectangle {
                Label {
                    id: label
                    anchors.centerIn: parent
                    text: styleData.date.getDate()
                    font.pointSize: 13
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        parent.color = "black"
                        label.color = "white"
                    }
                    onExited: {
                        label.color = "black"
                        parent.color = "white"
                    }
                }
            }
        }
    }
}
