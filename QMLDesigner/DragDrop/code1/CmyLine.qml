import QtQuick 2.15
import QtQuick.Shapes 1.15

Shape {
    anchors.fill: parent
    property var itemStart: null
    property var itemEnd: null

    // 画线
    ShapePath {
        strokeColor: "white"
        strokeWidth: 2

        startX: itemStart === null? 0: itemStart.x + itemStart.width / 2
        startY: itemStart === null? 0: itemStart.y + itemStart.height / 2
        PathLine {
            x: itemEnd === null? 0: itemEnd.x + itemEnd.width / 2
            y: itemEnd === null? 0: itemEnd.y + itemEnd.height / 2
        }
    }

    // 画方向
    ShapePath {
        id: arrow
        strokeColor: "white"
        property int xStart: itemStart === null || itemEnd === null? 0: itemStart.x + itemStart.width * 0.5
        property int yStart: itemStart === null || itemEnd === null? 0: itemStart.y + itemStart.height * 0.5
        property int xEnd: itemStart === null || itemEnd === null? 0: itemEnd.x + itemEnd.width * 0.5
        property int yEnd: itemStart === null || itemEnd === null? 0: itemEnd.y + itemEnd.height * 0.5
        property int xRange: xEnd - xStart
        property int yRange: yEnd - yStart
        property int len: 10
        // 斜率
        property real m: (xStart !== xEnd)? (yEnd - yStart) / (xEnd - xStart): 0
        // 垂直斜率
        property real m_prime: (m !== 0)? -1/m: len
        // 计算R
        property real k: m_prime !== 0? len / Math.sqrt(1 + m_prime * m_prime): len
        startX: xStart + xRange * 0.55
        startY: yStart + yRange * 0.55
        PathLine {
            x: arrow.xStart + arrow.xRange * 0.50 + arrow.k
            y: arrow.yStart + arrow.yRange * 0.50 + arrow.k * arrow.m_prime
        }
        PathLine {
            x: arrow.xStart + arrow.xRange * 0.50 - arrow.k
            y: arrow.yStart + arrow.yRange * 0.50 - arrow.k * arrow.m_prime
        }
    }

    // 始视图没了，连线删除
    onItemStartChanged: {
        if (itemStart == null) {
            destroy()
        }
    }

    // 末视图没了，连线删除
    onItemEndChanged: {
        if (itemEnd == null) {
            destroy()
        }
    }
}
