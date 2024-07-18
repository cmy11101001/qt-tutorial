import QtQuick 2.15
import QtQuick.Window 2.15
import QtCharts 2.15
import QtQuick.Controls 2.15

Window {
    width: 1080
    height: 720
    visible: true
    title: qsTr("放假当宅宅")

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
        property int xNum: 50
        // 显示帧率
        property int frame: 30
        // 是否启用自适应
        property bool adaptive: true
        // 自适应x轴最小位置
        property real xMin: 0
        // 自适应x轴最大位置
        property real xMax: 0
        // 滚动视图
        property bool rollView: true

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
            delegate: MenuItem {
                id: menuItem
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    opacity: 1
                    color: menuItem.highlighted ? "gray" : "transparent"
                }
                contentItem: Text {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: 15
                    opacity: 1
                    color: menuItem.highlighted ? "white" : "black"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
            Action {
                text: "适应窗口大小"
                onTriggered: {
                    chartView.zoomReset()
                    xAxis.min = chartView.xMin
                    xAxis.max = chartView.xMax
                    // 遍历所有曲线，拿到每组曲线y轴最新100组数据最小值跟最大值
                    var yMin = 0
                    var yMax = 0
                    for (var i=0; i<chartView.seriesList.length; i++) {
                        var num = chartView.seriesList[i].count>100?
                                    100: chartView.seriesList[i].count
                        var startCount = chartView.seriesList[i].count>num?
                                    chartView.seriesList[i].count-num: 0
                        for (var j=0; j<num; j++) {
                            if (i==0 && j==0) {
                                yMin = chartView.seriesList[i].at(startCount+j).y
                                yMax = yMin+0.1
                            } else {
                                if (yMin > chartView.seriesList[i].at(startCount+j).y) {
                                    yMin = chartView.seriesList[i].at(startCount+j).y
                                } else if (yMax < chartView.seriesList[i].at(startCount+j).y) {
                                    yMax = chartView.seriesList[i].at(startCount+j).y
                                }
                            }
                        }
                    }
                    yAxis.min = yMin
                    yAxis.max = yMax
                    // 曲线适应视图大小
                    chartView.zoomReset()
                }
            }
            Action {
                text: "滚轮缩放x轴"
                onTriggered: {
                    chartView.xAxisSelect = true
                }
            }
            Action {
                text: "滚轮缩放y轴"
                onTriggered: {
                    chartView.xAxisSelect = false
                }
            }
            Action {
                text: "十字光标"
                onTriggered: {
                    chartView.crossShow = !chartView.crossShow
                }
                checkable: true
                Component.onCompleted: {
                    checked = chartView.crossShow
                }
            }
            Action {
                text: "滚动视图"
                onTriggered: {
                    chartView.rollView = !chartView.rollView
                }
                checkable: true
                Component.onCompleted: {
                    checked = chartView.rollView
                }
            }
            Action {
                text: "观测自适应"
                onTriggered: {
                    chartView.adaptive = !chartView.adaptive
                }
                checkable: true
                Component.onCompleted: {
                    checked = chartView.adaptive
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

        // 创建曲线
        function createPlot(name) {
            var series = chartView.createSeries(
                        ChartView.SeriesTypeLine, name, xAxis, yAxis)
            series.opacity = 0.5
            seriesList.push(series)
        }

        // 删除曲线
        function removePlot(name) {
            for (var i=0; i<chartView.seriesList.length; i++) {
                if (chartView.seriesList[i].name === name){
                    chartView.removeSeries(chartView.seriesList[i])
                    chartView.seriesList.splice(i, 1)
                    break
                }
            }
        }

        // 清空曲线
        function removeAllPlot() {
            chartView.removeAllSeries()
            chartView.seriesList.splice(0, chartView.seriesList.length);
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
                        // 曲线所有数据x坐标前移, 但是会影响性能
                        if (!chartView.rollView) {
                            for (var j=0; j<chartView.seriesList[i].count; j++) {
                                chartView.seriesList[i].replace(chartView.seriesList[i].at(j).x,
                                                                chartView.seriesList[i].at(j).y,
                                                                chartView.seriesList[i].at(j).x-1,
                                                                chartView.seriesList[i].at(j).y)
                            }
                        }
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
                }
            }
        }

        // 组件加载完成
        Component.onCompleted: {
            // 演示
            chartView.createPlot("曲线1")
            chartView.createPlot("曲线2")
            chartView.createPlot("曲线3")
            chartView.createPlot("曲线4")
            // 删除曲线
            chartView.removePlot("曲线4")
        }

        // 演示
        Timer {
            id: timer
            running: true
            repeat: true
            interval: Math.round(1000 / chartView.frame)
            onTriggered: {
                chartView.appendData("曲线1", (Math.random()-0.5)*5 + 6.6)
                chartView.appendData("曲线2", (Math.random()-0.5)*5 + 3.3)
                chartView.appendData("曲线3", (Math.random()-0.5)*5)
            }
        }
    }
}
