import sys
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtQml import *

class Backend(QObject):
    message = pyqtSignal(str)
    @pyqtSlot(str)
    def receive(self, msg:str) -> None:
        self.message.emit(msg)
        
def GetBackend(engine:QQmlEngine, scriptEngine:QJSEngine) -> QObject:
    backend = Backend()
    return backend

if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    url = QUrl("./main.qml")
    engine.objectCreated.connect(lambda obj, objUrl: 
                                 sys.exit(-1) 
                                 if not obj and url == objUrl 
                                 else None)
    qmlRegisterSingletonType(Backend, "My.Backend", 1, 0, "Backend", GetBackend)
    backend = Backend()
    engine.rootContext().setContextProperty("Backend2", backend)
    engine.load(url)
    sys.exit(app.exec())
