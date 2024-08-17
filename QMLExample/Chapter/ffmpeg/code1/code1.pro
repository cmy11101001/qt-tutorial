QT += quick widgets

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

#添加ffmpeg头文件
INCLUDEPATH += $$PWD/include

#WINDOWS平台
win32 {
    # 输出目录 和 ffmpeg bin同目录
    DESTDIR = $$PWD/bin

    # 编译需要的库
    LIBS += \
        -L$$PWD/lib -lavcodec \
        -L$$PWD/lib -lavdevice \
        -L$$PWD/lib -lavdevice \
        -L$$PWD/lib -lavfilter \
        -L$$PWD/lib -lavformat \
        -L$$PWD/lib -lavutil \
        -L$$PWD/lib -lpostproc \
        -L$$PWD/lib -lswresample \
        -L$$PWD/lib -lswscale
}

HEADERS += \
    ffmpeginclude.h
