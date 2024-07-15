from PySide6.QtCore import *

# 单例
setting = QSettings('config/setting.ini',QSettings.IniFormat)
# 初始化
init = setting.value( "/common/init" )
if init == None:
    # 初始化
    setting.setValue("/common/init", True)
    # 项目
    setting.setValue("/common/project", 0)