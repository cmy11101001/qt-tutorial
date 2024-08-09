import QtQuick 2.15

ShaderEffect {
    anchors.fill: parent

    mesh: GridMesh {
        resolution: Qt.size(200, 200)
    }

    property real topWidth: open? width: 20
    property real bottomWidth: topWidth
    property real amplitude: 0.1
    property bool open: false
    property variant source: effectSource

    Behavior on bottomWidth {
        SpringAnimation {
            easing.type: Easing.OutElastic;
            velocity: 2000; mass: 0.2;
            spring: 0.2; damping: 0.05
        }
    }

    Behavior on topWidth {
        NumberAnimation { duration: 250 }
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: effectImage;
        hideSource: true
    }

    Image {
        id: effectImage
        anchors.fill: parent
        source: "qrc:/img.png"
        fillMode: Image.Tile
    }

    // 顶点着色器-4个顶点都会执行一次计算
    vertexShader: "
        // 当前顶点坐标
        attribute highp vec4 qt_Vertex;
        // 纹理坐标
        attribute highp vec2 qt_MultiTexCoord0;
        // model-view-projection（模型-视图-投影）矩阵
        uniform highp mat4 qt_Matrix;
        // 共享纹理坐标, 传递给片段着色器
        varying highp vec2 qt_TexCoord0;
        // 传递给片段着色器的变量
        varying lowp float shade;

        //![ QML传递过来的变量
        uniform highp float topWidth;
        uniform highp float bottomWidth;
        uniform highp float width;
        uniform highp float height;
        uniform highp float amplitude;
        //]

        void main() {
            // 把纹理坐标传递给片段着色器
            qt_TexCoord0 = qt_MultiTexCoord0;
            // 定义一个高精度4维向量 shift
            highp vec4 shift = vec4(0.0, 0.0, 0.0, 0.0);
            //1. 定义一个高精度浮点数 swing
            //2. vec4向量可以通过 .x .y .z .w 或 .r .g .b .a 或 [0] [1] [2] [3]
            //   等多种方式来获取第一、二、三、四维的数据
            highp float swing = (topWidth - bottomWidth) * (qt_Vertex.y / height);
            shift.x = qt_Vertex.x * (width - topWidth + swing) / width;
            shade = sin(21.9911486 * qt_Vertex.x / width);
            shift.y = amplitude * (width - topWidth + swing) * shade;
            //1. gl_Position是顶点最终位置
            //2. 输出顶点最终位置 = 模型-视图-投影矩阵 * (当前顶点坐标 - 以上重新计算的x, y轴纹理坐标位置)
            gl_Position = qt_Matrix * (qt_Vertex - shift);
            // 传递
            shade = 0.2 * (2.0 - shade ) * ((width - topWidth + swing) / width);
        }"

    // 片段着色器-纹理源所有像素都会执行一次计算
    fragmentShader: "
        // 准备渲染的纹理源, 也就是我们要渲染的QML视图
        uniform sampler2D source;
        // 共享纹理坐标, 从顶点着色器传递过来
        varying highp vec2 qt_TexCoord0;
        // 从顶点着色器传递过来的变量
        varying lowp float shade;
        void main() {
            // 使用纹理坐标qt_TexCoord0从纹理源source提取出纹理片段颜色color
            highp vec4 color = texture2D(source, qt_TexCoord0);
            // 重新计算纹理片段颜色
            color.rgb *= 1.0 - shade;
            // 设置纹理片段的颜色, 决定最终屏幕上每个像素的颜色
            gl_FragColor = color;
        }"
}
