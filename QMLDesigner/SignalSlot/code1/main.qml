import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Connections {
        target: text_button
        onMySignal: {
            text_button.text += "\n mySignal被Connections触发,param = " + param
        }
    }

    function onSignal(param){
        text_button.text += "\n mySignal被onSignal触发,param = " + param
    }

    Button {
        id: text_button
        signal mySignal(var param)
        font.pointSize: 20
        text: "点击"
        clip: false
        onClicked: {
            text = "触发onClicked信号 "
            clip = true
            mySignal.connect(onSignal)
            mySignal("一键三连")
        }
        onClipChanged: {
            text += "\n Clip属性修改 "
        }
    }
}
