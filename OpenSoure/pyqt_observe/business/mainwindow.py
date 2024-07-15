from PySide6.QtWidgets import *
from PySide6.QtCore import *
from PySide6.QtGui import *
from ui.ui_mainwindow import Ui_MainWindow
from business.observe import observe
import resource.qrc_res

class MainWindow(QMainWindow, Ui_MainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)
        self.setupUi(self)

        # 加载翻译文件
        trans = QTranslator()
        trans.load('ui/zh_CN')
        QApplication.instance().installTranslator(trans)

        # 加载皮肤
        with open('resource\\style\\green.qss', 'r') as f:
            qssStyle = f.read()
            self.setStyleSheet(qssStyle)
            
        # 项目标题
        self.setWindowTitle(self.tr('放假当宅宅'))
        
        plot_ch = [['x', 'y', 'z'],
                [['x_ch1', 'x_ch2', 'x_ch3'],
                ['y_ch1', 'y_ch2', 'y_ch3' , 'y_ch4'],
                ['z_ch1', 'z_ch2']]]
                
        self.obserWidget = observe(3, plot_ch, 20000, self)
        self.setCentralWidget(self.obserWidget)
        self.obserWidget.show()


    # 主窗口关闭事件
    def closeEvent(self, event:QCloseEvent):
        self.deleteLater()
