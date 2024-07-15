# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'observe.ui'
##
## Created by: Qt User Interface Compiler version 6.4.0
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QApplication, QFrame, QGridLayout, QHBoxLayout,
    QHeaderView, QLineEdit, QPushButton, QSizePolicy,
    QSpacerItem, QSplitter, QTreeWidget, QTreeWidgetItem,
    QVBoxLayout, QWidget)

class Ui_observe(object):
    def setupUi(self, observe):
        if not observe.objectName():
            observe.setObjectName(u"observe")
        observe.resize(741, 574)
        self.gridLayout = QGridLayout(observe)
        self.gridLayout.setObjectName(u"gridLayout")
        self.splitter_2 = QSplitter(observe)
        self.splitter_2.setObjectName(u"splitter_2")
        self.splitter_2.setOrientation(Qt.Horizontal)
        self.widget = QWidget(self.splitter_2)
        self.widget.setObjectName(u"widget")
        self.horizontalLayout_4 = QHBoxLayout(self.widget)
        self.horizontalLayout_4.setObjectName(u"horizontalLayout_4")
        self.horizontalLayout_4.setContentsMargins(0, 0, 0, 0)
        self.splitter = QSplitter(self.widget)
        self.splitter.setObjectName(u"splitter")
        self.splitter.setOrientation(Qt.Vertical)
        self.splitter.setHandleWidth(5)
        self.widget1 = QWidget(self.splitter)
        self.widget1.setObjectName(u"widget1")
        self.verticalLayout = QVBoxLayout(self.widget1)
        self.verticalLayout.setObjectName(u"verticalLayout")
        self.verticalLayout.setContentsMargins(0, 0, 0, 0)
        self.horizontalLayout = QHBoxLayout()
        self.horizontalLayout.setObjectName(u"horizontalLayout")
        self.pb_clear = QPushButton(self.widget1)
        self.pb_clear.setObjectName(u"pb_clear")

        self.horizontalLayout.addWidget(self.pb_clear)

        self.pb_show_one = QPushButton(self.widget1)
        self.pb_show_one.setObjectName(u"pb_show_one")

        self.horizontalLayout.addWidget(self.pb_show_one)

        self.horizontalSpacer = QSpacerItem(40, 20, QSizePolicy.Expanding, QSizePolicy.Minimum)

        self.horizontalLayout.addItem(self.horizontalSpacer)


        self.verticalLayout.addLayout(self.horizontalLayout)

        self.horizontalLayout_2 = QHBoxLayout()
        self.horizontalLayout_2.setObjectName(u"horizontalLayout_2")
        self.le_x_num = QLineEdit(self.widget1)
        self.le_x_num.setObjectName(u"le_x_num")

        self.horizontalLayout_2.addWidget(self.le_x_num)

        self.le_frame = QLineEdit(self.widget1)
        self.le_frame.setObjectName(u"le_frame")

        self.horizontalLayout_2.addWidget(self.le_frame)

        self.horizontalSpacer_2 = QSpacerItem(40, 20, QSizePolicy.Expanding, QSizePolicy.Minimum)

        self.horizontalLayout_2.addItem(self.horizontalSpacer_2)


        self.verticalLayout.addLayout(self.horizontalLayout_2)

        self.horizontalLayout_3 = QHBoxLayout()
        self.horizontalLayout_3.setObjectName(u"horizontalLayout_3")
        self.pb_observe = QPushButton(self.widget1)
        self.pb_observe.setObjectName(u"pb_observe")

        self.horizontalLayout_3.addWidget(self.pb_observe)

        self.horizontalSpacer_3 = QSpacerItem(40, 20, QSizePolicy.Expanding, QSizePolicy.Minimum)

        self.horizontalLayout_3.addItem(self.horizontalSpacer_3)


        self.verticalLayout.addLayout(self.horizontalLayout_3)

        self.verticalSpacer = QSpacerItem(20, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)

        self.verticalLayout.addItem(self.verticalSpacer)

        self.splitter.addWidget(self.widget1)
        self.tw_plot = QTreeWidget(self.splitter)
        self.tw_plot.setObjectName(u"tw_plot")
        self.tw_plot.setMinimumSize(QSize(200, 0))
        self.splitter.addWidget(self.tw_plot)

        self.horizontalLayout_4.addWidget(self.splitter)

        self.line = QFrame(self.widget)
        self.line.setObjectName(u"line")
        self.line.setFrameShape(QFrame.VLine)
        self.line.setFrameShadow(QFrame.Sunken)

        self.horizontalLayout_4.addWidget(self.line)

        self.splitter_2.addWidget(self.widget)
        self.w_observe = QWidget(self.splitter_2)
        self.w_observe.setObjectName(u"w_observe")
        self.splitter_2.addWidget(self.w_observe)

        self.gridLayout.addWidget(self.splitter_2, 0, 0, 1, 1)


        self.retranslateUi(observe)

        QMetaObject.connectSlotsByName(observe)
    # setupUi

    def retranslateUi(self, observe):
        observe.setWindowTitle(QCoreApplication.translate("observe", u"observe", None))
        self.pb_clear.setText(QCoreApplication.translate("observe", u"clear", None))
        self.pb_show_one.setText(QCoreApplication.translate("observe", u"show one", None))
        self.le_x_num.setPlaceholderText(QCoreApplication.translate("observe", u"horizontal axis num", None))
        self.le_frame.setPlaceholderText(QCoreApplication.translate("observe", u"frame", None))
        self.pb_observe.setText(QCoreApplication.translate("observe", u"start", None))
        ___qtreewidgetitem = self.tw_plot.headerItem()
        ___qtreewidgetitem.setText(0, QCoreApplication.translate("observe", u"channel", None));
    # retranslateUi

