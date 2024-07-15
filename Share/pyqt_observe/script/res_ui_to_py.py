import os
import os.path

# qrc文件所在目录
qrc_path = ['resource']
# 列出目录下所有的qrc文件
def listQrcFile(dir):
	list = []
	files = os.listdir(dir)
	for filename in files:
		if os.path.splitext(filename)[1] == '.qrc':
			list.append(filename)
	return list
# 把扩展名为.qrc的文件改成扩展名为.py的文件
def transQrcPyFile(filename):
	return 'qrc_' + os.path.splitext(filename)[0] + '.py'
# 调用系统命令把UI文件转换成Python文件
def qrc_to_py():
	for dir in qrc_path:
		list = listQrcFile(dir)
		for qrcfile in list:
			pyfile = transQrcPyFile(qrcfile)
			cmd = 'pyside6-rcc.exe -o {pyfile} {qrcfile}'.format(pyfile=dir+'\\'+pyfile, qrcfile=dir+'\\'+qrcfile)
			os.system(cmd)

# UI文件所在的路径
ui_path = ['ui']
# 列出目录下的所有UI文件
def listUiFile(dir):
	list = []
	files = os.listdir(dir)
	for filename in files:
		if os.path.splitext(filename)[1] == '.ui':
			list.append(filename)
	return list
# 把扩展名为.ui的文件改成扩展名为.py的文件
def transUiPyFile(filename):
	return 'ui_' + os.path.splitext(filename)[0] + '.py'
# 调用系统命令把UI文件转换成Python文件
def ui_to_py():
	for dir in ui_path:
		list = listUiFile(dir)
		for uifile in list:
			pyfile = transUiPyFile(uifile)
			cmd = 'pyside6-uic.exe -o {pyfile} {uifile}'.format(pyfile=dir+'\\'+pyfile, uifile=dir+'\\'+uifile)
			os.system(cmd)

# 主程序
if __name__ == "__main__":
	qrc_to_py()				# qrc转py
	ui_to_py()				# ui转py