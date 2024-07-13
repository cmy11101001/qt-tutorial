import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("MenuBar&ToolBar")
    // 菜单栏
    MenuBar {
        id: menuBar
        contentWidth: parent.width
        // 绘制菜单栏背景
        background: Rectangle {
            color: "lightGray"
            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "black"
            }
        }
        // 菜单选项代理
        delegate: MenuBarItem {
            // 绘制菜单选项背景
            background: Rectangle {
                color: highlighted? "black": "gray"
                border.width: 1
            }
            // 绘制菜单选项内容
            contentItem: Text {
                font.pointSize: 15
                color: "white"
                text: menu.title
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

        Menu {
            id: menu
            title: "菜单1"
            // 绘制每个选项视图
            delegate: MenuItem {
                id: menuItem
                // 绘制选项展开箭头
                arrow: Canvas  {
                    x: parent.width - width
                    implicitWidth: 40
                    implicitHeight: 40
                    visible: menuItem.subMenu
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.moveTo(12, 12)
                        ctx.lineTo(width - 12, height / 2)
                        ctx.lineTo(12, height - 12)
                        ctx.closePath()
                        ctx.fill()
                    }
                }
                // 绘制选项指示器
                indicator: Rectangle {
                    width: 24       // 14 + 10
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"
                    Rectangle {
                        width: 14
                        height: 14
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        visible: menuItem.checked
                        color: "black"
                        radius: 7
                    }
                }
                // 绘制选项内容视图
                contentItem: Text {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: 15
                    opacity: enabled ? 1.0 : 0.3
                    color: menuItem.highlighted ? "white" : "black"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                // 绘制选项背景视图
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    opacity: enabled ? 1 : 0.3
                    color: menuItem.highlighted ? "gray" : "transparent"
                }
            }
            Action {
                text: "选项1"
                checkable: true
                checked: true
            }
            MenuSeparator {}
            Action {
                text: "选项2"
            }
            Menu{
                title: "选项3"
                Action{ text: "选项4" }
                Action{ text: "选项5" }
            }
        }

        Menu {
            title: "About"
            Action {
                text: "选项1"
                checkable: true
            }
        }
    }
    // 工具栏
    ToolBar {
        anchors.top: menuBar.bottom
        width: parent.width

        Row {
            ToolButton {
               text: "关注"
               contentItem: Rectangle {
                   color: "transparent"
                   border.width: 1
                   Text {
                       anchors.centerIn: parent
                       text: parent.parent.text
                   }
               }
               padding: 0
            }
            ToolButton {
               text: "点赞"
            }
        }
    }
}
