import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Shapes 1.15

Window {
    width: 480
    height: 480
    visible: true
    title: qsTr("Shape")

    Shape {
        anchors.fill: parent
        asynchronous: true
//        rotation: 45

        // 按钮1-默认状态
        ShapePath {
            fillColor: "black"
            strokeColor: "red"
            strokeWidth: 2
            PathMove { x: 0; y: height * 0.5 }
            PathLine { x: width * 0.4; y: height * 0.5 }
            PathArc { x: width * 0.5; y: height * 0.4; radiusX: width * 0.1; radiusY: height * 0.1 }
            PathLine { x: width * 0.5; y: 0 }
            PathArc { x: 0; y: height * 0.5; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
        }
        // 按钮1-点击状态
        Shape {
            anchors.fill: parent
            containsMode: Shape.FillContains
            opacity: tap1Handler.pressed ? 1 : 0
            TapHandler { id: tap1Handler }

            ShapePath {
                fillColor: "blue"
                strokeColor: "green"
                strokeWidth: 2
                PathMove { x: 0; y: height * 0.5 }
                PathLine { x: width * 0.4; y: height * 0.5 }
                PathArc { x: width * 0.5; y: height * 0.4; radiusX: width * 0.1; radiusY: height * 0.1 }
                PathLine { x: width * 0.5; y: 0 }
                PathArc { x: 0; y: height * 0.5; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
            }
        }

        // 按钮2-默认状态
        ShapePath {
            fillColor: "black"
            strokeColor: "red"
            strokeWidth: 2
            PathMove { x: width * 0.5; y: 0 }
            PathLine { x: width * 0.5; y: height * 0.4 }
            PathArc { x: width * 0.6; y: height * 0.5; radiusX: width * 0.1; radiusY: height * 0.1 }
            PathLine { x: width; y: height * 0.5 }
            PathArc { x: width * 0.5; y: 0; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
        }
        // 按钮2-点击状态
        Shape {
            anchors.fill: parent
            containsMode: Shape.FillContains
            opacity: tap2Handler.pressed ? 1 : 0
            TapHandler { id: tap2Handler }

            ShapePath {
                fillColor: "blue"
                strokeColor: "green"
                strokeWidth: 2
                PathMove { x: width * 0.5; y: 0 }
                PathLine { x: width * 0.5; y: height * 0.4 }
                PathArc { x: width * 0.6; y: height * 0.5; radiusX: width * 0.1; radiusY: height * 0.1 }
                PathLine { x: width; y: height * 0.5 }
                PathArc { x: width * 0.5; y: 0; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
            }
        }

        // 按钮3-默认状态
        ShapePath {
            fillColor: "black"
            strokeColor: "red"
            strokeWidth: 2
            PathMove { x: width; y: height * 0.5 }
            PathLine { x: width * 0.6; y: height * 0.5 }
            PathArc { x: width * 0.5; y: height * 0.6; radiusX: width * 0.1; radiusY: height * 0.1 }
            PathLine { x: width * 0.5; y: height }
            PathArc { x: width; y: height * 0.5; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
        }
        // 按钮3-点击状态
        Shape {
            anchors.fill: parent
            containsMode: Shape.FillContains
            opacity: tap3Handler.pressed ? 1 : 0
            TapHandler { id: tap3Handler }

            ShapePath {
                fillColor: "blue"
                strokeColor: "green"
                strokeWidth: 2
                PathMove { x: width; y: height * 0.5 }
                PathLine { x: width * 0.6; y: height * 0.5 }
                PathArc { x: width * 0.5; y: height * 0.6; radiusX: width * 0.1; radiusY: height * 0.1 }
                PathLine { x: width * 0.5; y: height }
                PathArc { x: width; y: height * 0.5; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
            }
        }

        // 按钮4-默认状态
        ShapePath {
            fillColor: "black"
            strokeColor: "red"
            strokeWidth: 2
            PathMove { x: width * 0.5; y: height }
            PathLine { x: width * 0.5; y: height * 0.6 }
            PathArc { x: width * 0.4; y: height * 0.5; radiusX: width * 0.1; radiusY: height * 0.1 }
            PathLine { x: 0; y: height * 0.5 }
            PathArc { x: width * 0.5; y: height; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
        }
        // 按钮4-点击状态
        Shape {
            anchors.fill: parent
            containsMode: Shape.FillContains
            opacity: tap4Handler.pressed ? 1 : 0
            TapHandler { id: tap4Handler }

            ShapePath {
                fillColor: "blue"
                strokeColor: "green"
                strokeWidth: 2
                PathMove { x: width * 0.5; y: height }
                PathLine { x: width * 0.5; y: height * 0.6 }
                PathArc { x: width * 0.4; y: height * 0.5; radiusX: width * 0.1; radiusY: height * 0.1 }
                PathLine { x: 0; y: height * 0.5 }
                PathArc { x: width * 0.5; y: height; radiusX: width * 0.5; radiusY: height * 0.5; direction: PathArc.Counterclockwise }
            }
        }

        // 按钮5-默认状态
        ShapePath {
            fillColor: "black"
            strokeColor: "red"
            strokeWidth: 2
            PathMove { x: width * 0.5; y: height * 0.4 }
            PathArc { x: width * 0.5; y: height * 0.6;
                radiusX: width * 0.1; radiusY: height * 0.1;
                direction: PathArc.Counterclockwise}
            PathArc { x: width * 0.5; y: height * 0.4;
                radiusX: width * 0.1; radiusY: height * 0.1;
                direction: PathArc.Counterclockwise}
        }
        // 按钮5-点击状态
        Shape {
            anchors.fill: parent
            containsMode: Shape.FillContains
            opacity: tap5Handler.pressed ? 1 : 0
            TapHandler { id: tap5Handler }

            ShapePath {
                fillColor: "blue"
                strokeColor: "green"
                strokeWidth: 2
                PathMove { x: width * 0.5; y: height * 0.4 }
                PathArc { x: width * 0.5; y: height * 0.6;
                    radiusX: width * 0.1; radiusY: height * 0.1;
                    direction: PathArc.Counterclockwise}
                PathArc { x: width * 0.5; y: height * 0.4;
                    radiusX: width * 0.1; radiusY: height * 0.1;
                    direction: PathArc.Counterclockwise}
            }
        }
    }
}
