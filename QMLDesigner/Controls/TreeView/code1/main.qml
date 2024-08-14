import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 1.4
import QtQml.Models 2.12
import CmyTreeModel 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("TreeView")
    color: "yellow"

    TreeView {
        id: treeView
        anchors.fill: parent
        // 头是否显示
        headerVisible: false
        // 选择模式
        selectionMode: SelectionMode.NoSelection
        // 背景颜色交替
        alternatingRowColors: true
        // 背景是否显示
        backgroundVisible: false
        // 自定义模型数据
        CmyTreeModel {
            id: cmyTreeModel
        }
        model: cmyTreeModel
        selection: ItemSelectionModel {
            model: cmyTreeModel
        }
        // 单项个代理
        itemDelegate: Rectangle {
            color: "transparent"
            CheckBox {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                activeFocusOnPress: true
                text: styleData.value
                // 没有子节点，显示CheckBox
                visible: !styleData.hasChildren
                onCheckedStateChanged: {
                    switch (checkedState) {
                    case Qt.Checked:
                       console.log(qsTr("复选框:选中"), styleData.value)
                       break
                    case Qt.PartiallyChecked:
                       console.log(qsTr("复选框:半选"), styleData.value)
                       break
                    default:
                       console.log(qsTr("复选框:不选"), styleData.value)
                       break
                    }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: styleData.value
                // 有子节点，显示Text
                visible: styleData.hasChildren
            }
        }
        // 行背景代理
        rowDelegate: Rectangle {
            height: 50
            border.width: 1
            color: "transparent"
        }
        // 列
        TableViewColumn {
            horizontalAlignment: Qt.AlignLeft;
            width: treeView.width - 2
            title: "树型组件"
            role: "display"
        }
        // 点击切换展开列表
        onDoubleClicked: (index)=>{
            console.log(index)
            if (isExpanded(index)) {
                collapse(index)
            } else {
                expand(index)
            }
        }
    }
}
