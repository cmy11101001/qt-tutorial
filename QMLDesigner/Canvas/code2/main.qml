import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Canvas {
        anchors.fill: parent
        Image {
            id: myImage
            source: "qrc:/image.png"
            visible: false
            smooth: true                                                                // 启用平滑以改善缩放时的图像质量
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.translate(320, 240);                                                    // 3
            ctx.rotate(Math.PI / 2);                                                    // 4
            ctx.beginPath();                                                            // 5 设置裁剪路径
            ctx.rect(0, 0, 100, 100);                                                   // 5 创建一个100x100的矩形作为裁剪区域
            ctx.clip();                                                                 // 5 应用裁剪
            ctx.drawImage(myImage, 0, 0, myImage.width * 0.2, myImage.height * 0.2);    // 2
        }
    }
}
