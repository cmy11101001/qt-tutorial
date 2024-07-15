import os
import os.path

# 业务逻辑ui与py文件所在目录
main_path = ['ui', 'business', 'module', 'ui\\module']
ui_path = [main_path]
# 列出目录下的所有UI文件
def listUiFile(dir):
	list = []
	files = os.listdir(dir)
	for filename in files:
		if os.path.splitext(filename)[1] == '.ui':
			list.append(filename)
	return list
# 列出目录下的所有py文件
def listPyFile(dir):
	list = []
	files = os.listdir(dir)
	for filename in files:
		if os.path.splitext(filename)[1] == '.py':
			list.append(filename)
	return list

# 主程序
if __name__ == "__main__":
    for dir_path in ui_path:                        # 遍历所有业务逻辑
        cmd_file = str()                            # 指令，包含所有ui与py文件路径与文件名
        cmd_ts = str()                              # 指令，输出翻译文件路径与文件名
        for dir in dir_path:                        # 遍历业务逻辑包含的py与ui文件              
            list = listUiFile(dir)                  # 遍历ui文件
            if list.__len__() != 0:
                cmd_ts = dir+'\\zh_CN.ts'           # 输出翻译文件存放在ui文件目录
            for item in list:
                cmd_file += (' '+dir+'\\'+item)
            list = listPyFile(dir)                  # 遍历py文件
            for item in list:
                cmd_file += (' '+dir+'\\'+item)
        if cmd_file.__len__() == 0:                 # 如果指令没有任何文件名就continue
            continue
        cmd = 'pyside6-lupdate.exe {cmd_file} -ts {cmd_ts}'.format(cmd_file=cmd_file, cmd_ts=cmd_ts)
        os.system(cmd)