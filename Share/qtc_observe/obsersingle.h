#ifndef OBSERSINGLE_H
#define OBSERSINGLE_H

#include <QWidget>
#include <QMap>
#include "qcustomplot.h"

namespace Ui {
class ObserSingle;
}

/** 右键菜单action回调 */
class ObserSingle;
class MenuActionFun
{
public:
    virtual void fun(ObserSingle *form) = 0;
    virtual ~MenuActionFun(){};
};

class ObserSingle : public QWidget
{
    Q_OBJECT

public:
    explicit ObserSingle(QWidget *parent = nullptr);
    ~ObserSingle();

    /** 右键菜单action回调 */
    // 适应窗口大小
    class RescaleActionFun : public MenuActionFun{
    public:
        void fun(ObserSingle *form);
    };
    // 十字游标
    class CursorActionFun : public MenuActionFun{
    public:
        void fun(ObserSingle *form);
    };

    /** 绘制曲线 */
    void drawCurve(const QString name, const QVector<double> x, const QVector<double> y, QPen pen = QPen(Qt::black));
    /** 清除曲线 */
    void clearCurve(const QString name);
    /** 自适应屏幕 */
    void replot(void);
    /** 设置运行状态 */
    void setRunStatus(bool b);

signals:
    /** 输出日志 */
    void sig_logMessage(const QString &msg);

private slots:
    void selectionChanged();                    /** 图例与曲线同步选中 */
    void onMousePress(QMouseEvent *event);      /** 右键菜单 */
    void _on_action_create_triggered(void);     /** 右键菜单action点击 */
    void onMouseMove(QMouseEvent *);            /** 鼠标移动信号 */
    void onMouseRelease(QMouseEvent *);         /** 鼠标释放信号 */

private:
    void clickMenuAddAction(QString name, QString icon, MenuActionFun *fun);        /** 创建右键菜单action */

private:
    Ui::ObserSingle *ui;
    QMenu *clickMenu;
    QMap<QAction *, QString> actionMap;         // 保存action对应的名称
    QMap<QString, MenuActionFun*> actionFunMap; // 右键菜单栏action回调

    QMap<QString, QCPGraph *> curveMap;         // 曲线表
    QCPItemStraightLine *lineY;                 // tooltip的垂直线
    QCPItemStraightLine *lineX;                 // tooltip的水平线
    bool cursorShow;                            // 十字游标
    bool midButtonPress;                        // 鼠标中键按下
    QPoint posPress;                            // 中键鼠标位置

public:
    QCustomPlot *customPlot;
};

#endif // OBSERSINGLE_H
