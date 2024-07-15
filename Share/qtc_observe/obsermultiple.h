#ifndef OBSERMULTIPLE_H
#define OBSERMULTIPLE_H

#include <QWidget>
#include <QList>
#include <QTimer>
#include "obsersingle.h"

namespace Ui {
class ObserMultiple;
}

class ObserMultiple : public QWidget
{
    Q_OBJECT

public:
    explicit ObserMultiple(QWidget *parent = nullptr);
    ~ObserMultiple();

    ObserSingle *addCanvas(void);               /** 添加画布 */
    void removeCanvas(void);                    /** 减少画布(减少当前选中画布) */
    void addData(const QString name, double x, double y);       /** 给name曲线添加一组数据 */
    void run(bool b);                           /** 启停 */

signals:
    /** 输出日志 */
    void sig_logMessage(const QString &msg);
    /** 启停信号 */
    void sig_run(bool b);

protected:
    bool eventFilter(QObject *object, QEvent *event);

private slots:
    void _on_itemDoubleClicked(QTreeWidgetItem *item, int column);
    void _on_itemChanged(QTreeWidgetItem *item, int column);
    void _on_plotTimer_timeout(void);           /** 界面刷新定时器 */
    void on_pb_addCanvas_clicked();             /** 增加画布 */
    void on_pb_removeCanvas_clicked();          /** 减少画布 */
    void on_pb_showSingle_clicked();            /** 显示单个 */

    void on_le_maxNum_editingFinished();

    void on_pb_injectionData_clicked();

    void on_pb_run_clicked();

    void on_pb_clearSingle_clicked();

    void on_pb_clear_clicked();

    void on_pb_contiune_clicked();

    void on_pb_export_clicked();

    void on_pb_import_clicked();

private:
    void ResetLayou(void);                      /** 根据obserList重置布局 */
    void OneLayou(void);                        /** 唯一显示布局 */
    void init_tw_plot(void);                                    /** 根据表level_name初始化tw_plot */
    void InsertLevelName(struct LEVEL_NAME *levelName);         /** 插入一条level name */
    void SelectReset(void);                     /** 显示当前选中画布的通道选择器 */

private:
    Ui::ObserMultiple *ui;
    QGridLayout *multiPlotLayout;                   // 多画布布局
    QList<ObserSingle *> obserList;                 // 多画布容器
    ObserSingle *obserShow;                         // 当前选中画布
    QList<QString> select1List;                     // 第一级列表
    QList<QString> select2List;                     // 第二级列表
    QList<QString> select3List;                     // 第三级列表
    QMap<QString, QTreeWidgetItem *> level1ItemMap; // 第一级的item列表
    QMap<QTreeWidgetItem *, QString> level1StrMap;  // 第一级的item列表
    QMap<QString, QTreeWidgetItem *> level2ItemMap; // 第二级的item列表
    QMap<QTreeWidgetItem *, QString> level2StrMap;  // 第二级的item列表
    QMap<QString, QTreeWidgetItem *> level3ItemMap; // 第三级的item列表
    QMap<QTreeWidgetItem *, QString> level3StrMap;  // 第三级的item列表

    QMap<ObserSingle *, QMap<QTreeWidgetItem *, Qt::CheckState>> checkStateMap;       // 每个画布都有自己的CheckState列表

    QMap<QTreeWidgetItem *, QMap<double, double>> dataMap;      // 观测曲线缓存数据

    QList<QColor> colorList;                        // 颜色列表

    int dataMaxLen;                                 // 曲线最大值
    QTimer *plotTimer;
};

#endif // OBSERMULTIPLE_H
