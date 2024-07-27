import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick3D 1.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    View3D {
        id: view3D
        anchors.fill: parent
        renderMode: View3D.Overlay
        // 渲染场景
        environment: sceneEnvironment
        SceneEnvironment {
            id: sceneEnvironment
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
            backgroundMode: SceneEnvironment.Color
            clearColor: "black"
        }

        // 摄像机
        PerspectiveCamera {
            // 相机在3D场景上的位置，等于 position.x position.y position.z
            x: 0
            y: 0
            z: 600
            // 相机旋转角度（以x、y、z轴为中心旋转）
            eulerRotation.x: 0
            eulerRotation.y: 0
            eulerRotation.z: 0
            // 相机最近可视距离
            clipNear : 0
            // 相机最远可视距离
            clipFar : 1200
            // 相机可视角度
            fieldOfView : 30
            fieldOfViewOrientation: Camera.Horizontal
        }

        // 光源
        DirectionalLight {
            x: 0
            y: 180
            z: 0
            // 光照距离
            brightness: 500
            // 光源旋转
            eulerRotation.x: 0
            eulerRotation.y: 0
            eulerRotation.z: 0
        }

        // 3D场景中的基本组件
        Node {
            // 放在3D场景原点处
            x: 0
            y: 0
            z: 0
            // 组件旋转的支点
            pivot: Qt.vector3d(50, 0, 0)
            //组件旋转
            eulerRotation.x: 45
            eulerRotation.y: 45
            // 缩放
            scale.x: 1
            scale.y: 1
            scale.z: 1

            Model {
                x: 0
                y: 0
                z: 0
                // 可以被选中
                pickable: true
                // 网格文件模型的几何形状
                source: "#Cube"
                // 材质
                DefaultMaterial {
                    id: material_001_material
                    // 纹理
                    diffuseMap: Texture {
                        sourceItem: Rectangle {
                            id: rect
                            width: 100
                            height: 100
                            color: "red"
                            Text {
                                anchors.centerIn: parent
                                text: "放假当宅宅"
                                font.bold: true
                                font.pointSize: 15
                            }
                        }
                    }
                }
                materials: [
                    material_001_material
                ]
            }

            Item {
                Rectangle {
                    x: 200
                    y: 200
                    width: 50
                    height: 50
                    radius: 25
                    color: "yellow"
                }
            }
        }

        // 获取鼠标点击处的Model
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 获取(x, y)鼠标点击处的PickResult
                var result = view3D.pick(mouse.x, mouse.y);
                if (result.objectHit) {
                    // 获取该鼠标位置处的Model
                    var pickedModel = result.objectHit;
                    console.log(pickedModel)
                }
            }
        }
    }
}
