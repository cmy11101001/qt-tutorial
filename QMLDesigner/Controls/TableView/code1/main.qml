import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 1.4

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("TableView")

    TableView {
        id: tableView
        anchors.fill: parent
        // 行颜色交替
        alternatingRowColors: true
        // 是否填充背景视图
        backgroundVisible: true

        // 头
        headerDelegate: Rectangle{
            height: 30
            border.width: 1
            color: Qt.rgba(255, 255, 255, 0.5)
            border.color: "black"
            Text {
                text: styleData.value
                font.pointSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                visible: styleData.column === 0 || styleData.column === 2? true: false
            }
            ComboBox {
                anchors.fill: parent
                visible: styleData.column === 1? true: false
            }
        }

        // 尾
        contentFooter: Rectangle {
            width: parent.width
            height: 10
            color: "black"
        }

        // 行内容
        Component {
            id: itemDelegate
            TextEdit {
                anchors.verticalCenter: parent.verticalCenter
                color: styleData.selected? "white": "black"
                readOnly: true
                selectByMouse: true
                text: styleData.value
                font.pointSize: 12
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                Rectangle {
                    height: parent.height
                    width: 1
                    color: "black"
                    anchors.right: parent.right
                }
            }
        }
        TableViewColumn {
            id: viewTime
            role: "time"
            title: "时间"
            width: 100
            elideMode: Text.ElideRight
            delegate: itemDelegate
        }
        TableViewColumn {
            id: viewLevel
            role: "level"
            title: "级别"
            width: 100
            delegate: itemDelegate
        }
        TableViewColumn {
            role: "msg"
            title: "消息"
            width: tableView.width - viewTime.width - viewLevel.width - 2 // -2 就刚好宽度匹配
            delegate: itemDelegate
        }

        // 内容
        model: ListModel {
            id: phoneModel

            ListElement{
                time:qsTr("2020.01.03")
                msg:qsTr("放假当宅宅")
                level:qsTr("信息")
            }
            ListElement{
                time:qsTr("2020.01.04")
                msg:qsTr("点赞")
                level:qsTr("调试")
            }
            ListElement{
                time:qsTr("2020.02.04")
                msg:qsTr("关注")
                level:qsTr("告警")
            }
            ListElement{
                time:qsTr("2021.02.04")
                msg:qsTr("投币")
                level:qsTr("错误")
            }
        }

        rowDelegate: Rectangle{
            id:rowRectangle
            color: styleData.selected? Qt.rgba(0, 0, 0, 0.5)
                                     : (styleData.alternate? Qt.rgba(255, 255, 255, 0.5)
                                                           : "#7fdfdfdf")
            height: 30
       }
    }
}
