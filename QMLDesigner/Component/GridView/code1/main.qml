import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("GridView")

    ListModel {
        id: model
        ListElement { color: "red"; url: "MyCompnent1.qml" }
        ListElement { color: "yellow"; url: "MyCompnent2.qml" }
        ListElement { color: "green"; url: "MyCompnent3.qml" }
        ListElement { color: "red"; url: "MyCompnent1.qml" }
        ListElement { color: "yellow"; url: "MyCompnent2.qml" }
        ListElement { color: "green"; url: "MyCompnent3.qml" }
        ListElement { color: "red"; url: "MyCompnent1.qml" }
        ListElement { color: "yellow"; url: "MyCompnent2.qml" }
        ListElement { color: "green"; url: "MyCompnent3.qml" }
    }

    Component {
        id: delegate
        Item {
            width: gridView.cellWidth - 20
            height: gridView.cellHeight - 20
            Component.onCompleted: createQml(this, model.url, model.color)
        }
    }

    function createQml(parent, url, color) {
        var myComponent = Qt.createComponent(url)
        if (myComponent.status === Component.Ready) {
            myComponent.createObject(parent, {
                color: color
            });
        }
    }

    GridView {
        id: gridView
        anchors.fill: parent
        model: model
        delegate: delegate
        cellWidth: height / 2
        cellHeight: height / 2
        flow: GridView.FlowTopToBottom
    }
}
