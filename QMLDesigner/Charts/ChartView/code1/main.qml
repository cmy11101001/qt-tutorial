import QtQuick 2.15
import QtQuick.Window 2.15
import QtCharts 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ChartView")

    ChartView {
        id: chartView
        anchors.fill: parent
        // 标题
        title: "数据观测"
        titleColor: "white"
        titleFont: Qt.font({pointSize: 20, bold: true})

        // 主题
        theme: ChartView.ChartThemeDark

        // 抗锯齿
        antialiasing: true

        // 图例
        legend {
            visible: true
            alignment: Qt.AlignRight
            markerShape: Legend.MarkerShapeFromSeries
        }

        // 十字光标与参数显示
        property bool crossShow: true
        // 滚轮缩放轴选择
        property bool xAxisSelect: true
        // 视图是否可以拖动
        property bool isDrag: false
        // 鼠标拖动视图 坐标缓存
        property int xCache: 0
        property int yCache: 0
        // 曲线列表
        property var seriesList: []
        // 曲线最大个数限制
        property int xNum: 100
        // 是否启用自适应
        property bool adaptive: true
        // 自适应x轴最小位置
        property real xMin: 0
        // 自适应x轴最大位置
        property real xMax: 0
        // 自适应y轴最小位置
        property real yMin: 0
        // 自适应y轴最大位置
        property real yMax: 0

        // x坐标范围
        ValueAxis {
            id: xAxis
            min: 0
            max: 10
            tickCount: 11
            minorTickCount: 0
            titleText: "x轴"
            titleFont: Qt.font({pointSize: 15, bold: true})
        }

        // y坐标范围
        ValueAxis {
            id: yAxis
            min: -5
            max: 5
            tickCount: 7
            minorTickCount: 0
            titleText: "y轴"
            titleFont: Qt.font({pointSize: 15, bold: true})
        }

        // 折线图主图
        LineSeries {
            id: mainSeries
            axisX: xAxis
            axisY: yAxis
            width: 1
            opacity: 0.5
            visible: false
        }

        // 右键菜单
        Menu {
            id: rightClickMenu
            title: "右键菜单"
            MenuItem {
                text: "适应窗口大小"
                onTriggered: {
                    chartView.zoomReset()
                    xAxis.min = chartView.xMin
                    xAxis.max = chartView.xMax
                    yAxis.min = chartView.yMin
                    yAxis.max = chartView.yMax
                    chartView.zoomReset()
                }
            }
            MenuItem {
                text: "滚轮缩放x轴"
                onTriggered: {
                    chartView.xAxisSelect = true
                }
            }
            MenuItem {
                text: "滚轮缩放y轴"
                onTriggered: {
                    chartView.xAxisSelect = false
                }
            }
            MenuItem {
                text: "十字光标"
                onTriggered: {
                    chartView.crossShow = !chartView.crossShow
                }
            }
            MenuItem {
                text: "观测自适应"
                onTriggered: {
                    chartView.adaptive = !chartView.adaptive
                }
            }
        }
        // 绘线区鼠标区域
        MouseArea {
            id: mouse
            width: parent.plotArea.width
            height: parent.plotArea.height
            x: parent.plotArea.x
            y: parent.plotArea.y
            hoverEnabled: true
            // 激活右键点击
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            // 鼠标点击
            onClicked: {
                if (mouse.button === Qt.MiddleButton) {
                    // 演示 切换演示定时器状态->记得删除
                    timer.running = !timer.running
                }
                if (mouse.button === Qt.RightButton) {
                    // 右键弹出菜单
                    rightClickMenu.popup(mouseX + chartView.plotArea.x,
                                         mouseY + chartView.plotArea.y)
                }
            }
            // 鼠标按下
            onPressed: {
                if (mouse.button === Qt.LeftButton) {
                    // 左键移动视图
                    chartView.isDrag = true
                    chartView.xCache = mouseX
                    chartView.yCache = mouseY
                }
            }
            // 鼠标释放
            onReleased: {
                if (mouse.button === Qt.LeftButton) {
                    // 左键移动视图
                    chartView.isDrag = false
                }
            }
            // 鼠标进入
            onEntered: {
                if (chartView.crossShow) {
                    toolTip.visible = true
                    crossLine.visible = true
                }
            }
            // 鼠标移动
            onPositionChanged: {
                // 鼠标按下，拖动视图
                if (chartView.isDrag) {
                    // 移动视图
                    var xRange = mouseX - chartView.xCache
                    var yRange = mouseY - chartView.yCache
                    chartView.scrollLeft(xRange)
                    chartView.scrollUp(yRange)
                    // 重新缓存鼠标位置
                    chartView.xCache = mouseX
                    chartView.yCache = mouseY
                }
                // 捕获曲线在十字光标y轴交叉位置数值
                var plotValue = chartView.mapToValue(
                            Qt.point(mouseX + chartView.plotArea.x,
                                     mouseY + chartView.plotArea.y),
                            mainSeries)
                // 十字光标位置
                if (chartView.crossShow) {
                    // 获取ChartView内所有Series
                    var showText = ""
                    for (var i=0; i<chartView.seriesList.length; i++) {
                        // 数据名称：（x坐标，y坐标）
                        var point = chartView.seriesList[i].at(plotValue.x
                                        - chartView.seriesList[i].at(0).x)
                        showText += "\n" + chartView.seriesList[i].name + ": "
                                + "(" + point.x.toFixed(0) +
                                ", " + point.y.toFixed(1) + ")"
                    }
                    // 提示信息位置
                    toolTip.x = mouseX + chartView.plotArea.x + 1
                    toolTip.y = mouseY + chartView.plotArea.y - toolTip.height - 1
                    // plotValue是鼠标位置处的数值
                    toolTip.text = showText + "\n一键三连"
                    // 十字线条位置
                    crossLine.xx = mouseX + chartView.plotArea.x
                    crossLine.yy = mouseY + chartView.plotArea.y
                }
            }
            // 鼠标离开
            onExited: {
                toolTip.visible = false
                crossLine.visible = false
            }
            // 鼠标滚轮
            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    if (chartView.xAxisSelect) {
                        // 放大x轴
                        chartView.zoomIn(Qt.rect(x + width/10, y,
                                                 width - width/10*2, height))
                    } else {
                        // 放大y轴
                        chartView.zoomIn(Qt.rect(x, y + height/10,
                                                 width, height - height/10*2))
                    }
                } else {
                    if (chartView.xAxisSelect) {
                        // 缩小x轴
                        chartView.zoomIn(Qt.rect(x - width/10, y,
                                                 width + width/10*2, height))
                    } else {
                        // 缩小y轴
                        chartView.zoomIn(Qt.rect(x, y - height/10,
                                                 width, height + height/10*2))
                    }
                }
            }
        }

        // 鼠标位置显示曲线信息
        ToolTip {
            id: toolTip
            delay: 1
            background: Rectangle {
                opacity: 0
            }
            contentItem: Text {
                font.bold: true
                font.pointSize: 15
                text: toolTip.text
                color: "white"
            }
        }

        // 画十字线条
        Canvas{
            id: crossLine
            anchors.fill: parent
            property double xx: 0
            property double yy: 0
            onPaint: {
                crossLine.draw()
            }
            function draw() {
                if (xx+yy>0) {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, parent.width, parent.height)
                    ctx.strokeStyle = "white"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.moveTo(xx, chartView.plotArea.y)
                    ctx.lineTo(xx, chartView.plotArea.height + chartView.plotArea.y)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(chartView.plotArea.x, yy)
                    ctx.lineTo(chartView.plotArea.x + chartView.plotArea.width, yy)
                    ctx.stroke()
                }
                requestAnimationFrame(draw);
            }
        }

        // 添加数据
        function appendData(name, value) {
            for (var i=0; i<chartView.seriesList.length; i++) {
                if (chartView.seriesList[i].name === name){
                    // 从最后位置插入
                    var xEnd = chartView.seriesList[i]
                                    .at(chartView.seriesList[i].count-1).x
                    chartView.seriesList[i].append(xEnd+1, value)
                    // 超出最大个数限制, 删除第一个
                    if (chartView.seriesList[i].count > chartView.xNum) {
                        chartView.seriesList[i].remove(0)
                    }
                    var xStart = chartView.seriesList[i].at(0).x
                    // 自适应坐标更新, x最小位置是xStart, x最大位置是xEnd, y值是value
                    if (xStart > chartView.xMin) {
                        chartView.xMin = xStart
                        if (adaptive) xAxis.min = xStart
                    }
                    if (xEnd > chartView.xMax) {
                        chartView.xMax = xEnd
                        if (adaptive) xAxis.max = xEnd
                    }
                    if (value < chartView.yMin) {
                        chartView.yMin = value
                        if (adaptive) yAxis.min = value
                    }
                    if (value > chartView.yMax) {
                        chartView.yMax = value
                        if (adaptive) yAxis.max = value
                    }
                }
            }
        }

        // 组件加载完成
        Component.onCompleted: {
            // 演示
            var series1 = chartView.createSeries(
                        ChartView.SeriesTypeLine, "观测曲线1", xAxis, yAxis)
            series1.opacity = 0.5
            seriesList.push(series1)
            var series2 = chartView.createSeries(
                        ChartView.SeriesTypeLine, "观测曲线2", xAxis, yAxis)
            series2.opacity = 0.5
            seriesList.push(series2)
            for (var i=0; i<11; i++) {
                series1.append(i, (Math.random()-0.5)*10)
                series2.append(i, (Math.random()-0.5)*10)
            }
        }

        // 演示
        Timer {
            id: timer
            running: true
            repeat: true
            interval: 50
            onTriggered: {
                chartView.appendData("观测曲线1", (Math.random()-0.5)*10)
                chartView.appendData("观测曲线2", (Math.random()-0.5)*10)
            }
        }
    }
}
