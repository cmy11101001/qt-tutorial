import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ToggleButton {
        style: ToggleButtonStyle {
            checkedDropShadowColor: "yellow"
            checkedGradient: Gradient {
                GradientStop { position: 0.0; color: "green" }
                GradientStop { position: 0.33; color: "yellow" }
                GradientStop { position: 0.66; color: "yellow" }
                GradientStop { position: 1.0; color: "green" }
            }

            uncheckedDropShadowColor: "blue"
            uncheckedGradient: Gradient {
                GradientStop { position: 0.0; color: "red" }
                GradientStop { position: 0.33; color: "yellow" }
                GradientStop { position: 0.66; color: "yellow" }
                GradientStop { position: 1.0; color: "red" }
            }

            inactiveGradient: Gradient {
                GradientStop { position: 0.0; color: "black" }
                GradientStop { position: 0.33; color: "blue" }
                GradientStop { position: 0.66; color: "blue" }
                GradientStop { position: 1.0; color: "black" }
            }
        }
        text: checked? "选中": "未选中"
    }
}
