.qmake.conf添加
INCLUDEPATH += $$PWD/../QtAV-depends-windows-x86+x64/include
LIBS += -L$$PWD/../QtAV-depends-windows-x86+x64/lib/x64

QtAV/libQtAV/Headers/QtAV/FilterContext.h添加
#include <QPainter>
#include <QPainterPath>

QtAV/libQmlAV/Sources/SGVideoNode.cpp添加
#include <QSGMaterial>

使用Mingw64 release构建代码
继续编译，有错误就查一下，改改就好了

把QtAV-depends-windows-x86+x64的bin下的x64所有dll复制到build-QtAV-Desktop_Qt_5_15_2_MinGW_64_bit-Release的bin文件下
重新构建代码

执行sdk_install.bat安装QtAV

自己的程序使用，把QtAV-depends-windows-x86+x64的bin下的x64所有dll复制到自己的程序输出路径里面