import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick3D 1.15
import QtQuick3D.Helpers 1.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("quick3D")
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
            clearColor: "white"
        }

        // 网格
        AxisHelper {
            enableAxisLines: true
            enableXYGrid: true
            enableXZGrid: true
            enableYZGrid: true
            gridColor: "black"
            gridOpacity: 0.1
        }

        // 摄像机
        Node {
            id: cameraNode
            PerspectiveCamera {
                id: camera
                // 相机在3D场景上的位置，等于 position.x position.y position.z
                x: 0
                y: 0
                z: 1500
                // 相机旋转角度（以x、y、z轴为中心旋转）
                eulerRotation.x: 0
                eulerRotation.y: 0
                eulerRotation.z: 0
                // 相机最近可视距离
                clipNear : 0
                // 相机最远可视距离
                clipFar : 3000
                // 相机可视角度
                fieldOfView : 60
                fieldOfViewOrientation: Camera.Horizontal
            }
        }

        // 光源
        DirectionalLight {
            x: 0
            y: 0
            z: 0
            ambientColor: Qt.rgba(1.0, 1.0, 1.0, 1.0)
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
//            pivot: Qt.vector3d(50, 0, 0)
            //组件旋转
            eulerRotation.x: 0
            eulerRotation.y: 0
            eulerRotation.z: 0
            // 缩放
            scale.x: 1
            scale.y: 1
            scale.z: 1

            // 红色模型
            Model {
                id: redModel
                x: 50
                y: 50
                z: 50
                // 可以被选中
                pickable: true
                // 网格文件模型的几何形状
                source: "#Cube"
                // 材质
                DefaultMaterial {
                    id: material_red_material
                    // 纹理
                    diffuseMap: Texture {
                        sourceItem: Rectangle {
                            width: 500
                            height: 500
                            color: "red"
                            Text {
                                anchors.centerIn: parent
                                antialiasing: true
                                text: "红色模型"
                                font.bold: true
                                font.pointSize: 50
                            }
                        }
                    }
                }
                materials: [
                    material_red_material
                ]
            }

            // 蓝色模型
            Model {
                id: blueModel
                x: 160
                y: 50
                z: 50
                // 可以被选中
                pickable: true
                // 网格文件模型的几何形状
                source: "#Sphere"
                // 材质
                DefaultMaterial {
                    id: material_blue_material
                    // 纹理
                    diffuseMap: Texture {
                        sourceItem: Rectangle {
                            width: 500
                            height: 500
                            color: "blue"
                            Text {
                                anchors.centerIn: parent
                                antialiasing: true
                                text: "蓝色模型"
                                font.bold: true
                                font.pointSize: 50
                            }
                        }
                    }
                }
                materials: [
                    material_blue_material
                ]
            }
            // 文本
            Node {
                x: 100
                y: 120
                z: 100
                Text {
                    antialiasing: true
                    id: printText
                    anchors.centerIn: parent
                    text: "点击模型试试"
                    font.bold: true
                    font.pointSize: 25
                }
            }
        }

        // 获取鼠标点击处的Model
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true
            property int middleCx: 0
            property int middleCy: 0
            property int rightCx: 0
            property int rightCy: 0
            property bool middlePress: false
            property bool rightPress: false
            onEntered: {
                cursorShape = Qt.OpenHandCursor
            }
            onExited: {
                cursorShape = Qt.ArrowCursor
            }
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    // 获取(x, y)鼠标点击处的PickResult
                    var result = view3D.pick(mouse.x, mouse.y)
                    if (result.objectHit) {
                        // 获取该鼠标位置处的Model
                        var pickedModel = result.objectHit
                        if (redModel === pickedModel) {
                            printText.text = "点击红色模型"
                        } else if (blueModel === pickedModel) {
                            printText.text = "点击蓝色模型"
                        }
                        console.log(pickedModel)
                    } else {
                        printText.text = "点击模型试试"
                    }
                }
            }
            onPressed: {
                if (mouse.button === Qt.MiddleButton) {
                    cursorShape = Qt.CrossCursor
                    middleCx = mouse.x
                    middleCy = mouse.y
                    middlePress = true
                } else if (mouse.button === Qt.RightButton) {
                    cursorShape = Qt.ClosedHandCursor
                    rightCx = mouse.x
                    rightCy = mouse.y
                    rightPress = true
                } else if (mouse.button === Qt.LeftButton) {
                    cursorShape = Qt.PointingHandCursor
                }
            }
            onPositionChanged: {
                if (middlePress) {
                    let intervalX = mouse.x-middleCx
                    let intervalY = mouse.y-middleCy
                    cameraNode.eulerRotation.x = cameraNode.eulerRotation.x-intervalY
                    cameraNode.eulerRotation.y = cameraNode.eulerRotation.y-intervalX
                    middleCx = mouse.x
                    middleCy = mouse.y
                }
                if (rightPress) {
                    let intervalX = mouse.x - rightCx
                    let intervalY = mouse.y - rightCy
                    camera.x = camera.x - (0.000027 * intervalX * camera.z * camera.fieldOfView * (640 / view3D.width))
                    camera.y = camera.y + (0.000027 * intervalY * camera.z * camera.fieldOfView * (480 / view3D.height))
                    rightCx = mouse.x
                    rightCy = mouse.y
                }
            }
            onReleased: {
                cursorShape = Qt.OpenHandCursor
                if (mouse.button === Qt.MiddleButton) {
                    middlePress = false
                } else if (mouse.button === Qt.RightButton) {
                    rightPress = false
                }
            }
            onWheel: {
                if(wheel.angleDelta.y>0)
                    camera.z = camera.z * 1.1
                else
                    camera.z = camera.z * 0.9
            }
        }
    }
}
