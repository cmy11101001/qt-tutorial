import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import CmyTableModel 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Param Table")

    id: paramTable
    // 参数表头
    property var header: ["group", "idx", "param", "type", "value"]
    // 参数表
    property var params: [
        {"group": "A", "idx": 1, "param": "x1", "type": "float", "value": 32.11},
        {"group": "A", "idx": 2, "param": "x2", "type": "float", "value": 32.11},
        {"group": "A", "idx": 3, "param": "x3", "type": "float", "value": 32.11},
        {"group": "A", "idx": 4, "param": "x4", "type": "float", "value": 32.11},
        {"group": "A", "idx": 5, "param": "x5", "type": "float", "value": 32.11},
        {"group": "A", "idx": 6, "param": "x6", "type": "float", "value": 32.11},
        {"group": "A", "idx": 7, "param": "x7", "type": "float", "value": 32.11},
        {"group": "A", "idx": 8, "param": "x8", "type": "float", "value": 32.11},
        {"group": "A", "idx": 9, "param": "y1", "type": "int", "value": 23}
    ]
    // 列表头
    property int colHeaderWidth: 30
    // 行表头
    property int rowHeaderHeight: 50
    // 列宽
    property variant colWidths: [100, 100, 100, 100, 150]

    // 左上角
    Rectangle {
        id: tag
        anchors.top: parent.top
        anchors.left: parent.left
        width: paramTable.colHeaderWidth
        height: paramTable.rowHeaderHeight
        color: "yellow"
    }

    // 行表头
    Item {
        id: rowHeader
        height: paramTable.rowHeaderHeight
        width: parent.width

        anchors.top: parent.top
        anchors.left: tag.right

        //暂存鼠标拖动的位置
        property int posXTemp: 0
        /*!
        MouseArea{
            anchors.fill: parent
            onPressed: rowHeader.posXTemp = mouseX
            onPositionChanged: {
                if(tableView.contentX + (rowHeader.posXTemp - mouseX)>0){
                    tableView.contentX += (rowHeader.posXTemp - mouseX)
                }else{
                    tableView.contentX = 0
                }
                rowHeader.posXTemp = mouseX
            }
        }
        */
        Row {
            id: row
            anchors.fill: parent
            leftPadding: -tableView.contentX
            clip: true
            spacing: 0

            Repeater {
                model: tableView.columns>0? tableView.columns: 0

                Rectangle {
                    id: item
                    width: paramTable.colWidths[index] + tableView.columnSpacing
                    height: rowHeader.height
                    color: "purple"
                    clip: true

                    Text {
                        anchors.centerIn: parent
                        text: tableModel.headerData(index, Qt.Horizontal)
                        font {
                            pointSize: 25
                            bold: true
                        }
                    }
                    Rectangle{
                        width: 1
                        height: parent.height
                        anchors.right: parent.right
                        color: "black"
                        opacity: 0.5
                    }
                    MouseArea{
                        width: 4
                        height: parent.height
                        anchors.right: parent.right
                        cursorShape: Qt.SplitHCursor
                        onPressed: rowHeader.posXTemp = mouseX
                        onPositionChanged: {
                            if((item.width - (rowHeader.posXTemp-mouseX)) > 10){
                                item.width -= (rowHeader.posXTemp-mouseX)
                            }else{
                                item.width = 10
                            }
                            rowHeader.posXTemp = mouseX
                            paramTable.colWidths[index] = (item.width - tableView.columnSpacing)
                            // 更新布局
                            tableView.forceLayout()
                        }
                    }
                }
            }
        }
    }

    //列表头
    Column {
        id: colHeader
        anchors.top: tag.bottom
        topPadding: -tableView.contentY
        clip: true
        spacing: 1
        Repeater {
            model: tableView.rows>0? tableView.rows: 0
            Rectangle {
                width: paramTable.colHeaderWidth
                height: tableView.rowHeightProvider(index)
                color: "green"
                Text {
                    anchors.centerIn: parent
                    text: tableModel.headerData(index, Qt.Vertical)
                    font {
                        pointSize: 25
                        bold: true
                    }
                }
            }
        }
    }

    // 参数表
    TableView {
        id: tableView
        height: paramTable.height - rowHeader.height
        width: paramTable.width - tag.width
        anchors.top: rowHeader.bottom
        anchors.left: colHeader.right
        columnSpacing: 1
        rowSpacing: 1
        clip: true
        focus: true
        boundsBehavior: Flickable.StopAtBounds
        // 返回模型中每行的高度
        rowHeightProvider: function (row) {
            return 50
        }
        // 返回模型中每列的宽度
        columnWidthProvider: function (column) {
            return paramTable.colWidths[column]
        }
        ScrollBar.vertical: ScrollBar {}
        ScrollBar.horizontal: ScrollBar {}

        model: CmyTableModel {
            id: tableModel
            header: paramTable.header
            params: paramTable.params
        }

        // 参数表单元格
        delegate: Rectangle{
            color: (model.row%2)? "orange": Qt.darker("orange")
            implicitHeight: 50
            implicitWidth: model.column < 4? 100: 150
            clip: true
            TextInput{
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                selectByMouse: true
                selectedTextColor: "black"
                selectionColor: "white"
                visible: model < 4? false: true
                text: value
                focus: true
                onEditingFinished: {
                    model.value = text
                }
                font {
                    pointSize: 20
                    bold: true
                }
            }
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: model.column < 4? true: false
                text: value
                font {
                    pointSize: 20
                    bold: true
                }
            }
        }
    }
}
