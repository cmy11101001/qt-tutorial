import numpy as np

# 通用算法
class algorithm(object):
    def __init__(self):
        super().__init__()

    # 搜索数组array最接近value数值下标
    @staticmethod
    def getnearpos(array:list, value:float) -> int:
        idx = (np.abs(array-value)).argmin()
        return idx
