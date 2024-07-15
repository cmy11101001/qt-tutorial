# import pyqtgraph.examples
from PySide6.QtWidgets import *
from PySide6.QtGui import *
from pyqtgraph import *
import pyqtgraph as pg
import numpy as np
import copy
from module.common.algorithm import algorithm

# 观测图
class observe_graph(QWidget):
    # 实例化
    # name_list:曲线名称列表
    # w_size:图宽
    # h_size:图高
    def __init__(self, w_size=300, h_size=300,name_list=[], parent=None):
        super().__init__(parent)
        # 创建栅格布局
        layout = QGridLayout()
        layout.setContentsMargins(3, 3, 3, 3)
        layout.setHorizontalSpacing(1)
        layout.setVerticalSpacing(1)
        self.setLayout(layout)
        # 创建光标标签
        self.__create_cursor_label()
        # 画图窗口添加
        self.plotWidget = PlotWidget(background='#FFFFFF')
        # 创建一个QWidget包含PlotWidget
        self.widget = QWidget()
        self.widget.setObjectName('plot_widget')
        layout = QGridLayout()
        layout.setContentsMargins(3, 3, 3, 3)
        layout.setHorizontalSpacing(1)
        layout.setVerticalSpacing(1)
        self.widget.setLayout(layout)
        self.widget.layout().addWidget(self.plotWidget, 0, 0)
        # 添加QWidget
        self.layout().addWidget(self.widget, 1, 0)
        # 固定窗口大小
        self.setFixedSize(w_size, h_size)
        # 显示图例
        self.plotWidget.addLegend(frame=False, colCount=3)
        # 曲线创建
        self.plot_list = []
        for index, name in enumerate(name_list):            # 索引线段名
            self.plot_list.append(self.plotWidget.plot(pen=(((index&7)>>2)*199, ((index&3)>>1)*199, (index&1)*199), name=name))
        # 背景网格显示与透明度
        self.plotWidget.showGrid(x=True, y=True, alpha=0.2)
        # 创建交叉线
        self.__create_cross_line()
        # 鼠标移动事件
        self.plotWidget.scene().sigMouseMoved.connect(self.mouseMoved)

    # 鼠标移动
    def mouseMoved(self, evt):
        pos = evt
        if self.plotWidget.sceneBoundingRect().contains(pos):
            # 获取鼠标位置
            mousePoint = self.plotWidget.plotItem.vb.mapSceneToView(pos)
            # 获取所有曲线y轴数据
            str_plot_y = ''
            for plot in self.plot_list:
                if plot.yData is not None:
                    str_plot_y += " ,<font color=black>{name}={y}</font>".format(name=plot.name(), y=plot.yData[algorithm.getnearpos(plot.xData, mousePoint.x())])
            # 右上角x,y轴数据显示
            str_plot_y = "<font color=red>x={:0.1f}</font>, <font color=green>y={:0.1f}</font>".format(mousePoint.x(), mousePoint.y()) + str_plot_y
            self.cursor_label.setText(str_plot_y)
            # 交叉线移动
            self.__vLine.setPos(mousePoint.x())
            self.__hLine.setPos(mousePoint.y())

    # 创建交叉线
    def __create_cross_line(self) -> None:
        # 交叉线
        self.__vLine = pg.InfiniteLine(angle=90, movable=False)
        self.__hLine = pg.InfiniteLine(angle=0, movable=False)
        self.plotWidget.addItem(self.__vLine, ignoreBounds=True)
        self.plotWidget.addItem(self.__hLine, ignoreBounds=True)

    # 创建光标标签
    def __create_cursor_label(self) -> None:
        self.cursor_label = QLabel('')
        # 自动换行
        self.cursor_label.setWordWrap(True)
        self.layout().addWidget(self.cursor_label, 0, 0)

    # 创建曲线
    # name:曲线名称
    def create_plot_line(self, name:str) -> None:
        self.plot_list.append(self.plotWidget.plot(pen=(((self.plot_list.__len__()&7)>>2)*199, ((self.plot_list.__len__()&3)>>1)*199, (self.plot_list.__len__()&1)*199), name=name))

    # 删除曲线
    # name:曲线名称
    def delete_plot_line(self, name:str) -> None:
        # 拷贝所有曲线[name, xData, yData]
        __plot_list = [[], [], []]
        for plot in self.plot_list:
            if name != plot.name():
                __plot_list[0].append(plot.name())
                __plot_list[1].append(copy.deepcopy(plot.xData))
                __plot_list[2].append(copy.deepcopy(plot.yData))
        # 清除所有曲线
        self.plotWidget.clear()
        self.plot_list.clear()
        # 重新创建所有曲线
        for index, name in enumerate(__plot_list[0]):
            self.plot_list.append(self.plotWidget.plot(pen=(((index&7)>>2)*199, ((index&3)>>1)*199, (index&1)*199), name=name))
            if __plot_list[1][index] is not None and __plot_list[2][index] is not None:
                self.plot_list[index].setData(__plot_list[1][index], __plot_list[2][index])
        # 创建交叉线
        self.__create_cross_line()

    # 设置曲线数据
    # name:曲线名称
    # xData:曲线x轴数据
    # yData:曲线y轴数据
    def set_plot_line_data(self, name:str, xData:list, yData:list) -> None:
        for plot in self.plot_list:
            if name == plot.name():
                plot.setData(xData, yData)
            
if __name__ == '__main__':
    # pyqtgraph.examples.run()
    app = QApplication(sys.argv)
    name = ['ob1', 'ob2', 'ob3', 'ob4', 'ob5', 'ob6', 'ob7', 'ob8']
    win = observe_graph(name)
    win.create_plot_line('ob9')
    win.create_plot_line('ob10')
    win.create_plot_line('ob11')
    win.delete_plot_line('ob4')
    win.delete_plot_line('ob5')
    win.set_plot_line_data('ob2', [0, 2, 4, 7], [1, 3, 6, 19])
    win.set_plot_line_data('ob3', [2, 3, 7, 6], [3, 6, 19, 2])
    win.show()
    sys.exit(app.exec())