import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("ListView")

    Rectangle {
        height: listView.height
        width: listView.width
        color: "blue"
        clip: true
        ListView {
            id: listView
            width: 250
            height: window.height
            model: ListModel {
                ListElement {
                    name: "第一组"
                    subListElement:[
                        ListElement {content: "ListView"},
                        ListElement {content: "放假当宅宅"},
                        ListElement {content: "点赞" }
                    ]
                }
                ListElement {
                    name: "第二组"
                    subListElement:[
                        ListElement {content: "ListView"},
                        ListElement {content: "放假当宅宅"},
                        ListElement {content: "点赞" },
                        ListElement {content: "投币"}
                    ]
                }
                ListElement {
                    name: "第三组"
                    subListElement:[
                        ListElement {content: "ListView"},
                        ListElement {content: "放假当宅宅"},
                        ListElement {content: "点赞" },
                        ListElement {content: "投币"},
                        ListElement {content: "关注"}
                    ]
                }
            }
            delegate: ChildListView {
                title: name
                childModel: subListElement
            }
            ScrollBar.vertical: ScrollBar {
                background: Rectangle {
                    color: "#ffffff"
                }
                interactive: true
            }
        }
    }
}
