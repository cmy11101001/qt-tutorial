import sys
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtQml import *

if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    url = QUrl("./main.qml")
    engine.objectCreated.connect(lambda obj, objUrl: 
                                 sys.exit(-1) 
                                 if not obj and url == objUrl 
                                 else None)
    engine.load(url)
    sys.exit(app.exec())
