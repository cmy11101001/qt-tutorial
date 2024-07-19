import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Particles 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ParticleSystem")

    // 按钮
    Button {
        id: btn
        anchors.centerIn: parent
        text: "按钮"
        clip: true
        // 绘制按钮背景视图
        background: Rectangle {
            property list<Gradient> myGradient: [
                Gradient {
                    GradientStop { position: 1.0; color: "violet" }
                    GradientStop { position: 0.0; color: "blue" }
                },
                Gradient {
                    GradientStop { position: 0.0; color: "violet" }
                    GradientStop { position: 1.0; color: "blue" }
                },
                Gradient {
                    GradientStop { position: 0.0; color: "yellow" }
                    GradientStop { position: 1.0; color: "orange" }
                }
            ]
            gradient: myGradient[1]
            border.width: 1
            border.color: "white"
            radius: 20
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.gradient = parent.myGradient[0]
                }
                onExited: {
                    parent.gradient = parent.myGradient[1]
                }
                onPressed: {
                    parent.gradient = parent.myGradient[2]
                }
                onReleased: {
                    parent.gradient = parent.myGradient[1]
                    sequentialAnimation.running = true
                    emitter.enabled = true
                }
            }
        }
        // 绘制按钮内容视图
        contentItem: Rectangle {
            implicitWidth: 200
            implicitHeight: 100
            color: "transparent"
            Text {
                anchors.centerIn: parent
                font.bold: true
                font.pointSize: 30
                text: btn.text
                color: "white"
            }
        }

        // 粒子系统
        ParticleSystem {
            id: particleSystem
            z: rectShade.z + 1
        }

        // 粒子画笔
        ItemParticle  {
            id: itemParticle
            system: particleSystem
            // 粒子组
            groups: "实例化"
            // 粒子视图
            delegate: Rectangle {
                width: itemParticle.parent.width > itemParticle.parent.height?
                           itemParticle.parent.height * 0.02:
                           itemParticle.parent.width * 0.02
                height: width
                radius: height / 2
                border.width: radius * 0.8
                border.color: "white"
                color: "transparent"
            }
            // 是否在生命周期结束时自动淡出
            fade: true
        }

        // 发射器
        Emitter {
            id: emitter
            width: 1
            height: parent.height
            anchors.left: parent.left
            system: particleSystem
            // 粒子起始加速度
            acceleration: PointDirection {
                // x y 是指方向上的分量
                // xVariation yVariation 是指分量上的误差范围
                x: 100
                y: 0
                xVariation: 0;
                yVariation: 0;
            }
            // 每秒发射多少粒子
            emitRate: 2000 //60
            // 粒子最大发射量
            maximumEmitted: 2000 //60
            // 粒子群
            group: "实例化"
            // 粒子生命周期(毫秒)
            lifeSpan: 200
            // 生命周期误差区间(毫秒)
            lifeSpanVariation: 0
            // 粒子发射方向
            velocity: PointDirection {
                id: pointDirection
                // x y 是指方向上的分量
                // xVariation yVariation 是指分量上的误差范围
                x: 1000 / emitter.lifeSpan * emitter.parent.width;
                y: 0;
                xVariation: 0;
                yVariation: 0;
            }
            // 使能
            enabled: false
        }

        // 粒子控制
        Turbulence {
            width: btn.width - rectShade.width
            height: parent.height
            anchors.left: rectShade.right
            system: particleSystem
            // 粒子进入控制范围就开始乱窜
            strength: 1000;
        }

        // 按钮遮罩
        Rectangle {
            id: rectShade
            width: parent.width
            height: parent.height
            anchors.left: parent.left
            color: "white"
            z: parent.z + 1
        }

        // 动画
        SequentialAnimation {
            id: sequentialAnimation
            ParallelAnimation {
                NumberAnimation {
                    target: rectShade
                    property: "width"
                    from: btn.width
                    to: 0
                    duration: 1000
                    easing.type: Easing.InOutExpo
                }
                NumberAnimation {
                    target: pointDirection
                    property: "x"
                    from: 1000 / emitter.lifeSpan * emitter.parent.width
                    to: 0
                    duration: 1000
                    easing.type: Easing.InOutExpo
                }
            }
            ScriptAction {
                script: emitter.enabled = false
            }
            running: true
        }

        // 加载完成
        Component.onCompleted: {
            emitter.enabled = true
        }
    }
}
