import QtQuick.Window 2.12
import QtQuick 2.12
import QtQuick.Controls 1.4

Window {
    id: window
    width: 1200
    height: 720
    visible: true

    Item {
        id: item
        anchors.fill: parent
        // 演示数据
        property var modelData: [
            {
                time: qsTr("2020.01.03"),
                msg:qsTr("放假当宅宅"),
                level:qsTr("信息")
            },
            {
                time: qsTr("2020.01.04"),
                msg:qsTr("点赞"),
                level:qsTr("调试")
            },
            {
                time: qsTr("2020.02.04"),
                msg:qsTr("关注"),
                level:qsTr("告警")
            },
            {
                time: qsTr("2021.02.04"),
                msg:qsTr("投币"),
                level:qsTr("错误")
            }
        ]

        // 自定义表头
        clip: true
        Rectangle {
            id: headerRect
            width: parent.width
            height: 30
            color: "transparent"
            anchors.bottom: tableView.top
            //暂存鼠标拖动的位置
            property int posXTemp: 0
            // 时间
            Rectangle {
                id: myViewTime
                height: parent.height
                implicitWidth: 100
                anchors.left: parent.left
                color: Qt.rgba(255, 255, 255, 0.5)
                Text {
                    text: viewTime.title
                    font.pointSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                }
                MouseArea{
                    width: 4
                    height: parent.height
                    anchors.right: parent.right
                    cursorShape: Qt.SplitHCursor
                    onPressed: headerRect.posXTemp = mouseX
                    onPositionChanged: {
                        if((myViewTime.width - (headerRect.posXTemp-mouseX)) > 10){
                            myViewTime.width -= (headerRect.posXTemp-mouseX)
                        }else{
                            myViewTime.width = 10
                        }
                    }
                }
            }
            // 级别
            Rectangle {
                id: myViewLevel
                anchors.left: myViewTime.right
                height: parent.height
                implicitWidth: 100
                color: Qt.rgba(255, 255, 255, 0.5)
                ComboBox {
                    anchors.fill: parent
                    model: ListModel {
                        id: levelListModel
                        ListElement { text: "全部" }
                        ListElement { text: "信息" }
                        ListElement { text: "调试" }
                        ListElement { text: "调试" }
                        ListElement { text: "错误" }
                    }
                    onCurrentIndexChanged: {
                        // 删除tableView.model所有数据，重新加载跟currentText一致的数据
                        listModel.clear()
                        if (currentIndex == -1) {
                            return
                        }
                        if (currentIndex == 0) {
                            for (let i=0; i<10; i++) {
                                listModel.append(item.modelData)
                            }
                        } else {
                            for (let i=0; i<10; i++) {
                                listModel.append(item.modelData[currentIndex-1])
                            }
                        }
                    }
                }
                Rectangle {
                    anchors.left: parent.left
                    height: parent.height
                    width: 1
                    color: "black"
                }
                MouseArea{
                    width: 4
                    height: parent.height
                    anchors.right: parent.right
                    cursorShape: Qt.SplitHCursor
                    onPressed: headerRect.posXTemp = mouseX
                    onPositionChanged: {
                        if((myViewLevel.width - (headerRect.posXTemp-mouseX)) > 10){
                            myViewLevel.width -= (headerRect.posXTemp-mouseX)
                        }else{
                            myViewLevel.width = 10
                        }
                    }
                }
            }
            // 消息
            Rectangle {
                id: myViewMsg
                anchors.left: myViewLevel.right
                height: parent.height
                width: tableView.width - myViewLevel.width - myViewTime.width
                color: Qt.rgba(255, 255, 255, 0.5)
                Text {
                    text: msgLevel.title
                    font.pointSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                }
                Rectangle {
                    anchors.left: parent.left
                    height: parent.height
                    width: 1
                    color: "black"
                }
            }
        }

        TableView {
            id: tableView
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
            anchors.top: headerRect.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            // 行颜色交替
            alternatingRowColors: true
            // 是否填充背景视图
            backgroundVisible: false
            // 选择模式
            selectionMode: SelectionMode.MultiSelection
            // 是否显示表头
            headerVisible: false
            /*!
            // 头(无法处理直接CmyComboBox点击，需要重写整个TableView的鼠标区域)
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
                CmyComboBox {
                    anchors.fill: parent
                    visible: styleData.column === 1? true: false
                    contentPadding: 5
                    contentFontSize: 15
                    radiusEnable: false
                    Component.onCompleted: {
                        this.model.clear()
                        this.model.append({ name: qsTr("全部"), color: "red"})
                        this.model.append({ name: qsTr("信息"), color: "red"})
                        this.model.append({ name: qsTr("调试"), color: "red"})
                        this.model.append({ name: qsTr("告警"), color: "red"})
                        this.model.append({ name: qsTr("错误"), color: "red"})
                        this.currentIndex = 0
                    }
                }
            }
            */

            // 尾
            contentFooter: Rectangle {
                width: parent.width
                height: 20
                color: "transparent"
                border.width: 1
                Text {
                    text: "这里有小尾巴"
                    font.pointSize: 10
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                }
            }

            // 行内容
            Component {
                id: itemDelegate
                Rectangle {
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: styleData.selected? "white": "black"
                        text: styleData.value
                        font.pointSize: 12
                        font.bold: true
                        elide: styleData.elideMode
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.fill: parent
                        // 右线
                        Rectangle {
                            height: parent.height
                            width: 1
                            color: "black"
                            anchors.right: parent.right
                        }
                        // 下线
                        Rectangle {
                            height: 1
                            width: parent.width
                            color: "black"
                            anchors.bottom: parent.bottom
                        }
                        visible: styleData.column === 0 || styleData.column === 1? true: false
                    }
                    TextEdit {
                        anchors.centerIn: parent
                        selectionColor: styleData.selected? Qt.rgba(255, 255, 255, 0.2): Qt.rgba(0, 0, 0, 0.2)
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
                        visible: styleData.column === 2? true: false
                    }
                }
            }

            // 表格列条目
            TableViewColumn {
                id: viewTime
                role: "time"
                title: "时间"
                width: myViewTime.width
                elideMode: Text.ElideRight
                delegate: itemDelegate
            }
            TableViewColumn {
                id: viewLevel
                role: "level"
                title: "级别"
                width: myViewLevel.width
                delegate: itemDelegate
            }
            TableViewColumn {
                id: msgLevel
                role: "msg"
                title: "消息"
        //        width: tableView.width - viewTime.width - viewLevel.width - 2 // -2 就刚好宽度匹配
                width: myViewMsg.width
                delegate: itemDelegate
            }

            // 内容
            model: ListModel {
                id: listModel
            }

            // 内容行代理
            rowDelegate: Rectangle{
                id:rowRectangle
                color: styleData.selected? Qt.rgba(0, 0, 0, 0.5)
                                         : (styleData.alternate? Qt.rgba(255, 255, 255, 0.5)
                                                               : "#7fdfdfdf")
                height: 30
                focus: true
            }
        }
    }
}
