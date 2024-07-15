import sys
from PySide6.QtWidgets import *
from module.setting.setting import setting
from business.mainwindow import MainWindow

if __name__ == '__main__':
    app = QApplication(sys.argv)
    project = int(setting.value("/common/project"))
    win = MainWindow()
    win.show()
    sys.exit(app.exec())
