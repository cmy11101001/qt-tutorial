import QtQuick.Window 2.12
import QtQuick 2.12
import QtQuick.Particles 2.12
import QtQuick.Controls 2.12

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("粒子系统")

    // 粒子系统
    ParticleSystem {
        id: particleSystem
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
            border.color: "black"
            color: "transparent"
        }
        // 是否在生命周期结束时自动淡出
        fade: true
    }

    // 发射器
    Emitter {
        id: emitter
        anchors.fill: parent
        system: particleSystem
        // 发射器的形状
        shape: MaskShape {
            // 该图像不透明度非0的区域被视为形状内部
            source: "qrc:/../emitter.png"
        }
        // 粒子起始加速度
        acceleration: PointDirection {
            // x y 是指方向上的分量
            // xVariation yVariation 是指分量上的误差范围
            x: 0
            y: 0
            xVariation: 0;
            yVariation: 0;
        }
        // 每秒发射多少粒子
        emitRate: 20000
        // 粒子最大发射量
        maximumEmitted: 4000
        // 粒子群
        group: "实例化"
        // 粒子生命周期(毫秒)
        lifeSpan: 200
        // 生命周期误差区间(毫秒)
        lifeSpanVariation: 0
        // 粒子发射方向
        velocity: CumulativeDirection {
            AngleDirection {
                angleVariation: 360
                magnitudeVariation: 80
            }
            PointDirection {
                y: 20
            }
        }
        // 使能
        enabled: true
    }
}
