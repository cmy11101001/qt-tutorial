from PySide6.QtWidgets import *
from PySide6.QtCore import *
from module.plot.observe_graph import observe_graph
import math

# 多个观测图
class multi_observe_graph(QWidget):
    # 信号：鼠标选中(图索引)
    sigMouseGraphClick = Signal(int)
    # 实例化
    # num:图个数
    # w_size:图宽
    # h_size:图高
    def __init__(self, num=1, w_size=300, h_size=300, parent=None):
        super(multi_observe_graph, self).__init__(parent)
        # 创建栅格布局
        layout = QGridLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setHorizontalSpacing(0)
        layout.setVerticalSpacing(0)
        self.setLayout(layout)
        # row_num列数
        row_num = math.sqrt(num)
        if row_num.is_integer():
            row_num = int(row_num)
        else:
            row_num = int(row_num) + 1
        # 包含创建所有的observe_graph
        self.graph = []
        # 图的宽度
        self.w_size = w_size
        # 图的高度
        self.h_size = h_size
        # 当前鼠标移动处graph
        self.move_graph = 0
        # 当前鼠标点击graph
        self.mouse_graph = 0
        # 列图个数
        self.graph_row_num = row_num
        for index in range(num):
            self.graph.append(observe_graph(self.w_size, self.h_size))
            self.graph[index].installEventFilter(self)
        # 默认显示所有图
        self.show_all_graph()
        # 默认选中第一个图
        self.graph[0].widget.setStyleSheet('QWidget#plot_widget{border: 2px solid red}')
    
    # 事件过滤器
    def eventFilter(self, obj, event):
        for index, graph in enumerate(self.graph):
            if obj == graph:
                self.move_graph = index
        return False

    # 鼠标点击事件
    def mousePressEvent(self, event):
        self.mouse_graph = self.move_graph
        for index in range(self.graph.__len__()):
            if index == self.mouse_graph:
                self.graph[index].widget.setStyleSheet('QWidget#plot_widget{border: 2px solid red}')
                self.sigMouseGraphClick.emit(self.mouse_graph)
            else:
                self.graph[index].widget.setStyleSheet('')

    # 获取当前选择第几个图
    def get_mouse_graph_index(self) -> int:
        return self.mouse_graph

    # 显示单个图
    # index:从左往右，从上往下数第index个
    def show_one_graph(self) -> None:
        # 清除layout内容
        for i in range(self.layout().count()):
            self.layout().removeWidget(self.graph[i])
            self.graph[i].hide()
        # 只添加一个图
        self.layout().addWidget(self.graph[self.mouse_graph], 0, 0)
        self.graph[self.mouse_graph].setMinimumSize(0,0)
        self.graph[self.mouse_graph].setMaximumSize(16777215, 16777215)
        self.graph[self.mouse_graph].show()

    # 显示多个图
    def show_all_graph(self) -> None:
        # 清除layout内容
        for i in range(self.layout().count()):
            self.layout().removeWidget(self.graph[i])
        # 添加所有图
        for index in range(self.graph.__len__()):
            self.graph[index].show()
            self.graph[index].setFixedSize(self.w_size, self.h_size)
            self.layout().addWidget(self.graph[index], index/self.graph_row_num, index%self.graph_row_num)