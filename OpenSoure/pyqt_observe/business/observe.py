from PySide6.QtWidgets import *
from PySide6.QtCore import *
from PySide6.QtGui import *
from ui.ui_observe import Ui_observe
from module.plot.multi_observe_graph import multi_observe_graph
import random

# 观测界面
class observe(QWidget, Ui_observe):
    # 观测运行(True | False)
    sig_observe_run = Signal(bool)
    # 实例化
    def __init__(self, graph_num = 1, plot_ch=[], x_num=20000, parent=None):
        super(observe, self).__init__(parent)
        self.setupUi(self)
        # 观测图
        layout = QGridLayout()
        self.w_observe.setLayout(layout)
        self.observe_graph = multi_observe_graph(graph_num)
        self.w_observe.layout().addWidget(self.observe_graph)
        self.observe_graph.sigMouseGraphClick.connect(self.onMouseGraphClick)
        # 默认显示所有
        self.observe_graph.show_all_graph()
        self.__show_one_str = self.tr('show one')
        self.__show_all_str = self.tr('show all')
        self.pb_show_one.setText(self.__show_one_str)
        # 显示唯一/显示所有按钮
        self.pb_show_one.clicked.connect(self.on_pb_show_one)
        # 通道选择树状图
        self.plot_ch = plot_ch
        # 曲线名称(通道组+通道名)
        self.ch_name = []
        # 创建树状图界面
        self.init_tw_plot(self.plot_ch)
        # 曲线图选择[[], [], [], ...]
        self.graph_select = []
        # 初始化曲线通道选择
        self.init_graph_select(self.graph_select)
        # 通道选择触发信号
        self.tw_plot.itemChanged.connect(self.on_tw_plot_itemChanged)
        # 清除曲线按钮
        self.pb_clear.clicked.connect(self.on_pb_clear)
        # 创建所有数据缓存队列[x, y]
        self.data = [[], []]
        # 初始化所有曲线缓存队列
        self.init_data(self.data)
        # 初始化启动按钮
        self.__observe_start = self.tr('start')
        self.__observe_stop = self.tr('stop')
        self.pb_observe.setText(self.__observe_start)
        self.pb_observe.clicked.connect(self.on_pb_observe)
        # 观测刷新定时器
        self.observe_timer = QTimer(self)
        self.observe_timer.timeout.connect(self.observe_timer_timeout)
        # 横轴数据量
        v = QIntValidator(0, 1000000, self)
        self.le_x_num.setValidator(v)
        self.x_num = x_num
        self.le_x_num.setText('%s'%(self.x_num))
        self.le_x_num.editingFinished.connect(self.on_le_editingFinished)
        # 帧数
        v = QDoubleValidator(0.0, 60.0, 1, self)
        v.setNotation(QDoubleValidator.StandardNotation)
        self.le_frame.setValidator(v)
        self.frame = 10
        self.le_frame.setText('%s'%(self.frame))
        self.le_frame.editingFinished.connect(self.on_le_editingFinished)




        # 测试定时器(删)
        self.test_time = QTimer(self)
        self.test_time.timeout.connect(self.test_time_timeout)

    # 初始化所有曲线缓存队列
    def init_data(self, data:list) -> None:
        for index in range(self.ch_name.__len__()):
            data[0].append([])
            data[1].append([])

    # 清除曲线按钮
    def on_pb_clear(self) -> None:
        # 选择全部清空
        for ch0_index in range(self.tw_plot.topLevelItemCount()):
            item0 = self.tw_plot.topLevelItem(ch0_index)
            for ch1_index in range(item0.childCount()):
                item1 = item0.child(ch1_index)
                item1.setCheckState(0, Qt.Unchecked)
        # 曲线全部删除
        for graph_index, graph_select in enumerate(self.graph_select):
            for ch_index, name in enumerate(self.ch_name):
                if graph_select[ch_index] == True:
                    self.observe_graph.graph[graph_index].delete_plot_line(name)
                    graph_select[ch_index] = False

    # 显示唯一/显示所有按钮
    def on_pb_show_one(self) -> None:
        if self.sender().text() == self.__show_one_str:
            self.observe_graph.show_one_graph()
            self.sender().setText(self.__show_all_str)
        else:
            self.observe_graph.show_all_graph()
            self.sender().setText(self.__show_one_str)

    # 初始化通道选择树状图
    def init_tw_plot(self, plot_ch:list) -> None:
        self.tw_plot.clear()
        # 获取第一层第二层观测名称
        ch_list_0 = plot_ch[0]
        ch_list_1 = plot_ch[1]
        # 第一层树状图
        for ch in ch_list_0:
            item = QTreeWidgetItem()
            item.setText(0, ch)
            self.tw_plot.addTopLevelItem(item)
        #第二层树状图
        index = 0       # 通道名称索引
        for i, ch_list in enumerate(ch_list_1):
            for ch in ch_list:
                # 获取第一层的item
                item0 = self.tw_plot.topLevelItem(i)
                item = QTreeWidgetItem()
                item.setText(0, ch)
                item.setCheckState(0, Qt.Unchecked)
                item0.addChild(item)
                ch_name = '%s(%s)'%(ch_list_0[i], ch)
                self.ch_name.append(ch_name)

    # 初始化曲线通道选择
    def init_graph_select(self, graph_select:list) -> None:
        for graph_index in range(self.observe_graph.graph.__len__()):
            select = []
            for ch_index in range(self.ch_name.__len__()):
                select.append(False)
            graph_select.append(select)

    # 通道选择触发信号
    def on_tw_plot_itemChanged(self, item:QTreeWidgetItem, column:int) -> None:
        # 获取树状图名称：第一层(第二层)
        ch_name = '%s(%s)'%(item.parent().text(column), item.text(column))
        # 通道选择状态
        checkState = item.checkState(column)
        # 当前选择第几个图
        select_graph = self.observe_graph.get_mouse_graph_index()
        # 索引对应曲线名称 self.ch_name 的下标
        index = 0
        for i, name in enumerate(self.ch_name):
            if ch_name == name:
                index = i
                break
        # 创建或删除曲线
        if checkState == Qt.CheckState.Checked:
            self.observe_graph.graph[select_graph].delete_plot_line(self.ch_name[index])
            self.observe_graph.graph[select_graph].create_plot_line(self.ch_name[index])
            self.observe_graph.graph[select_graph].set_plot_line_data(self.ch_name[index], self.data[0][index], self.data[1][index])
            self.graph_select[select_graph][index] = True
        else:
            self.observe_graph.graph[select_graph].delete_plot_line(self.ch_name[index])
            self.graph_select[select_graph][index] = False

    # 鼠标选中图
    # index:当前图索引
    def onMouseGraphClick(self, index:int):
        # 刷新 tw_plot 所有选择状态
        i = 0
        for ch0_index in range(self.tw_plot.topLevelItemCount()):
            item0 = self.tw_plot.topLevelItem(ch0_index)
            for ch1_index in range(item0.childCount()):
                item1 = item0.child(ch1_index)
                if self.graph_select[index][i] == True:
                    item1.setCheckState(0, Qt.Checked)
                else:
                    item1.setCheckState(0, Qt.Unchecked)
                i += 1

    # 给单曲线添加一个数据
    def append_one_plot_data(self, index:int, data) -> None:
        if self.data[0][index].__len__() <= self.x_num:    # 限制最大显示数据量
            self.data[0][index].append(self.data[0][index].__len__())
        else:
            num = self.data[0][index].__len__() - self.x_num
            if num > 1:
                del self.data[0][index][self.data[0][index].__len__()-num+1:self.data[0][index].__len__()]
                del self.data[1][index][0:num]
            else:
                self.data[1][index].pop(0)
        self.data[1][index].append(data)

    # 给所有曲线添加一个数据
    def append_all_plot_data(self, data:list) -> None:
        for index in range(data.__len__()):
            self.append_one_plot_data(index, data[index])

    # 启动/停止观测
    def on_pb_observe(self) -> None:
        if self.pb_observe.text() == self.__observe_start:
            # 启动
            self.pb_observe.setText(self.__observe_stop)
            if not self.observe_timer.isActive():
                self.observe_timer.start(1000/self.frame)
            # 测试数据定时器(删)
            if not self.test_time.isActive():
                self.test_time.start(1)
            # 发出启动观测信号
            self.sig_observe_run.emit(True)
        else:
            # 停止
            self.pb_observe.setText(self.__observe_start)
            if self.observe_timer.isActive():
                self.observe_timer.stop()
            # 测试数据定时器(删)
            if self.test_time.isActive():
                self.test_time.stop()
            # 发出停止观测信号
            self.sig_observe_run.emit(False)

    # 观测刷新定时器
    def observe_timer_timeout(self) -> None:
        # 刷新曲线显示
        for graph_index, graph_select in enumerate(self.graph_select):
            for index in range(graph_select.__len__()):
                if graph_select[index] == True:
                    self.observe_graph.graph[graph_index].set_plot_line_data(self.ch_name[index], self.data[0][index], self.data[1][index])

    # lineedit编辑完成
    def on_le_editingFinished(self) -> None:
        if self.sender().objectName() == 'le_x_num':
            self.x_num = int(self.sender().text())
            self.le_x_num.setText('%s'%(self.x_num))
        elif self.sender().objectName() == 'le_frame':
            self.frame = float(self.sender().text())
            if self.observe_timer.isActive():
                self.observe_timer.start(1000/self.frame)




    # 测试定时器(删)
    def test_time_timeout(self) -> None:
        data = []
        for index in range(self.ch_name.__len__()):
            data.append(random.randint(-1000, 1000))
        self.append_all_plot_data(data)
