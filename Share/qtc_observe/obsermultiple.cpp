#include "obsermultiple.h"
#include "ui_obsermultiple.h"
#include <QFile>
#include <QMessageBox>
#include <QRandomGenerator>
#pragma execution_character_set("utf-8")

struct LEVEL_NAME{
    const char *level1_name;        // 第一级展开名
    const char *level2_name;        // 第二级展开名
    const char *level3_name;        // 第三级展开名
    const char *icon;               // 图像路径
};

static struct LEVEL_NAME level_name[] = {
    {"第一级通道1", "第二级通道1", "通道1", ":/reference/image/plot.png"},
    {"第一级通道1", "第二级通道1", "通道2", ":/reference/image/plot.png"},
    {"第一级通道1", "第二级通道2", "通道3", ":/reference/image/plot.png"},
    {"第一级通道2", "第二级通道1", "通道4", ":/reference/image/plot.png"},
    {"第一级通道2", "第二级通道2", "通道5", ":/reference/image/plot.png"},
};

ObserMultiple::ObserMultiple(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::ObserMultiple)
    , multiPlotLayout(new QGridLayout)
    , obserShow(nullptr)
    , plotTimer(new QTimer)
{
    ui->setupUi(this);

    /** 界面位置比例 */
    QList<int> sizeList;
    sizeList.append(200);
    sizeList.append(500);
    ui->splitter->setSizes(sizeList);
    sizeList.clear();
    sizeList.append(100);
    sizeList.append(500);
    ui->splitter_2->setSizes(sizeList);

    /** 初始化通道选择 */
    init_tw_plot();

    /** 限制输入 */
    ui->le_maxNum->setValidator(new QIntValidator(1, 100000, this));

    /** w_multiPlot layout */
    multiPlotLayout->setContentsMargins(0, 0, 0, 0);
    ui->w_multiPlot->setLayout(multiPlotLayout);
    QObject::connect(ui->tw_select, SIGNAL(itemDoubleClicked(QTreeWidgetItem *, int)), this, SLOT(_on_itemDoubleClicked(QTreeWidgetItem *, int)));
    QObject::connect(ui->tw_select, SIGNAL(itemChanged(QTreeWidgetItem *, int)), this, SLOT(_on_itemChanged(QTreeWidgetItem *, int)));

    /** 默认创建4个ObserSingle */
    obserShow = addCanvas();                                // 默认选中第一个
    obserShow->setStyleSheet("border: 2px solid red");
    addCanvas();
    addCanvas();
    addCanvas();

    dataMaxLen = ui->le_maxNum->text().toUInt();
    /** 界面刷新定时器 */
    QObject::connect(plotTimer, SIGNAL(timeout()), this, SLOT(_on_plotTimer_timeout()));
}

ObserMultiple::~ObserMultiple()
{
    if(plotTimer){
        plotTimer->deleteLater();
    }

    delete ui;
}

/** 添加画布 */
ObserSingle *ObserMultiple::addCanvas(void)
{
    ObserSingle *obser = new ObserSingle();
    obser->customPlot->installEventFilter(this);
    obserList.append(obser);
    ResetLayou();

    // 初始化通道选择列表
    QMap<QTreeWidgetItem *, Qt::CheckState> itemStateMap;
    QList<QTreeWidgetItem *> itemKeys = level3StrMap.keys();
    for(int i=0; i<itemKeys.size(); i++){
        itemStateMap.insert(itemKeys.at(i), Qt::Unchecked);
    }
    checkStateMap.insert(obser, itemStateMap);

    if(ui->pb_run->text() == tr("停止")){
        on_pb_run_clicked();
    }

    return obser;
}

/** 减少画布 */
void ObserMultiple::removeCanvas(void)
{
    if(obserList.size() > 1){
        ObserSingle *obser = obserList.at(obserList.size()-1);
        obser->customPlot->removeEventFilter(this);
        obserList.removeLast();
        checkStateMap.remove(obser);
        if(obser == obserShow){
            obserShow = nullptr;
        }
        delete obser;
        ResetLayou();
    }
}

/** 给曲线添加一组数据 */
void ObserMultiple::addData(const QString name, double x, double y)
{
    QTreeWidgetItem *item = level3ItemMap[name];
    dataMap[item].insert(x, y);
    if(dataMap[item].size() > dataMaxLen){
        dataMap[item].remove(dataMap[item].begin().key());
    }
}

/** 启停 */
void ObserMultiple::run(bool b)
{
    if(b){
        if(ui->pb_run->text() == tr("启动")){
            on_pb_run_clicked();
        }
    }else{
        if(ui->pb_run->text() == tr("停止")){
            on_pb_run_clicked();
        }
    }
}

/** 选中画布 */
bool ObserMultiple::eventFilter(QObject *object, QEvent *event)
{
    if(event->type() == QEvent::MouseButtonPress){
        for(int i=0; i<obserList.size(); i++){
            if(obserList.at(i)->customPlot == object){
                obserShow = obserList.at(i);
                obserList.at(i)->setStyleSheet("border: 2px solid red");
                // 切换通道选择器
                SelectReset();
            }else{
                obserList.at(i)->setStyleSheet("");
            }
        }
    }

    return false;
}

/** 显示当前选中画布的通道选择器 */
void ObserMultiple::SelectReset(void)
{
    QMap<QTreeWidgetItem *, Qt::CheckState> itemStateMap = checkStateMap[obserShow];
    QList<QTreeWidgetItem *> keysList = itemStateMap.keys();
    for(int i=0; i<keysList.size(); i++){
        keysList.at(i)->setCheckState(0, itemStateMap[keysList.at(i)]);
    }
}

/** 根据obserList重置布局 */
void ObserMultiple::ResetLayou(void)
{
    if(obserList.size()>0){
        double sqrt_size = sqrt(obserList.size());
        int col = 0;
        int colLen = floor(sqrt_size);
        if(colLen == sqrt_size){
            colLen -= 1;
        }
        int line = 0;
        if(multiPlotLayout){
            delete multiPlotLayout;
        }
        multiPlotLayout = new QGridLayout();
        multiPlotLayout->setContentsMargins(0, 0, 0, 0);
        ui->w_multiPlot->setLayout(multiPlotLayout);
        for(int i=0; i<obserList.size(); i++){
            multiPlotLayout->addWidget(obserList.at(i), line, col);
            obserList.at(i)->show();
            col++;
            if(col > colLen){
                col = 0;
                line ++;
            }
        }
    }
}

/** 显示一个 */
void ObserMultiple::OneLayou(void)
{
    if(obserShow){
        for(int i=0; i<obserList.size(); i++){
            if(obserList.at(i) == obserShow){
                obserList.at(i)->show();
            }else{
                obserList.at(i)->hide();
                ui->w_multiPlot->layout()->removeWidget(obserList.at(i));
                obserList.at(i)->customPlot->replot(QCustomPlot::rpQueuedReplot);
            }
        }
    }
}

/** 界面刷新定时器 */
void ObserMultiple::_on_plotTimer_timeout()
{
//    QMap<double, double> x_y_dataMap;
//    QVector<double> x, y;
//    QMap<QTreeWidgetItem *, Qt::CheckState> checkMap;
    QList<QTreeWidgetItem *> checkList;
    QTreeWidgetItem *item;
    on_pb_injectionData_clicked();  // 调用注入测试数据按钮 删
    for(int i=0; i<obserList.size(); i++){
        // 只刷新选择的通道
//        checkMap = checkStateMap[obserList.at(i)];
        checkList = checkStateMap[obserList.at(i)].keys();
        for(int j=0; j<checkList.size(); j++){
            item = checkList.at(j);
            if(checkStateMap[obserList.at(i)][item] == Qt::Checked){
//                x_y_dataMap = dataMap[item];
//                x = x_y_dataMap.keys().toVector();
//                y = x_y_dataMap.values().toVector();
//                obserList.at(i)->DrawCurve(level3StrMap[item], x, y);
                obserList.at(i)->drawCurve(level3StrMap[item], dataMap[item].keys().toVector(), dataMap[item].values().toVector());
            }
        }

        // 画布刷新
        obserList.at(i)->customPlot->replot(QCustomPlot::rpQueuedReplot);
        obserList.at(i)->replot();
    }
}

void ObserMultiple::on_pb_addCanvas_clicked()
{
    addCanvas();
}

void ObserMultiple::on_pb_removeCanvas_clicked()
{
    removeCanvas();
}

void ObserMultiple::on_pb_showSingle_clicked()
{
    if(ui->pb_showSingle->text() == tr("唯一")){
        ui->pb_showSingle->setText(tr("混合"));
        OneLayou();
    }else{
        ui->pb_showSingle->setText(tr("唯一"));
        ResetLayou();
    }
}

/** 插入一条level name */
void ObserMultiple::InsertLevelName(struct LEVEL_NAME *levelName)
{
    //    qDebug() << levelName->level1_name;
    QTreeWidgetItem *item;
    bool create = false;
    QList<QString>::Iterator it;
    // 判断第一级是否已创建
    create = false;
    it = select1List.begin();
    for(; it!=select1List.end(); ++it){
        if(!QString::compare(*it, QString(levelName->level1_name))){
            // 第一级已创建
            create = true;
        }
    }
    if(create){
        // 第一级已创建，判断第二级是否已创建，没有则创建第二级
        create = false;
        it = select2List.begin();
        for(; it!=select2List.end(); ++it){
            if(!QString::compare(*it, QString(levelName->level2_name))){
                // 第二级已创建
                create = true;
            }
        }
        if(!create){
            // 创建第二级，添加到select2List与level2ItemMap/level2StrMap
            item = new QTreeWidgetItem();
            item->setText(0, levelName->level2_name);
            level1ItemMap[levelName->level1_name]->addChild(item);
            select2List << levelName->level2_name;
            level2ItemMap.insert(levelName->level2_name, item);
            level2StrMap.insert(item, levelName->level2_name);
        }
    }else{
        // 创建第一级，添加到select1List与level1ItemMap/level1StrMap
        item = new QTreeWidgetItem();
        item->setText(0, levelName->level1_name);   // 0列
        ui->tw_select->addTopLevelItem(item);
        select1List << levelName->level1_name;
        level1ItemMap.insert(levelName->level1_name, item);
        level1StrMap.insert(item, levelName->level1_name);
        // 创建第二级，添加到select2List与level2ItemMap/level2StrMap
        item = new QTreeWidgetItem();
        item->setText(0, levelName->level2_name);
        level1ItemMap[levelName->level1_name]->addChild(item);
        select2List << levelName->level2_name;
        level2ItemMap.insert(levelName->level2_name, item);
        level2StrMap.insert(item, levelName->level2_name);
    }

    // 创建第三级，并且添加到select3List/level3StrMap
    item = new QTreeWidgetItem();
    item->setText(0, levelName->level3_name);
    item->setCheckState(0, Qt::Unchecked);
    level2ItemMap[levelName->level2_name]->addChild(item);
    select3List << levelName->level3_name;
    level3ItemMap.insert(levelName->level3_name, item);
    level3StrMap.insert(item, levelName->level3_name);

    // 创建icon
    if(levelName->icon){
        QIcon icon;
        icon.addPixmap(QPixmap(levelName->icon));
        level3ItemMap[levelName->level3_name]->setIcon(0, icon);        // 0列
    }

    // 展开
    ui->tw_select->expandAll();
}

/** 初始化通道选择 */
void ObserMultiple::init_tw_plot(void)
{
    ui->tw_select->clear();
    ui->tw_select->setColumnCount(1);
    QStringList list;
    list << tr("选择观测通道");
    ui->tw_select->setHeaderLabels(list);
    int name_size = sizeof(level_name) / sizeof(struct LEVEL_NAME);
    for(int i=0; i<name_size; i++){
        InsertLevelName(&level_name[i]);
    }

    // 初始化颜色列表
    colorList.append(QColor(0xff, 0x00, 0x00));
    colorList.append(QColor(0xf6, 0x00, 0xff));
    colorList.append(QColor(0x18, 0x00, 0xff));
    colorList.append(QColor(0x00, 0xff, 0xe4));
    colorList.append(QColor(0x00, 0xff, 0x12));
    colorList.append(QColor(0xf6, 0xff, 0x00));
    colorList.append(QColor(0xff, 0xa2, 0x00));

    // 初始化通道数据, 空数据
    QMap<double, double> x_y_dataMap;
    QList<QTreeWidgetItem *> keysList = level3StrMap.keys();
    for(int i=0; i<keysList.size(); i++){
        dataMap.insert(keysList.at(i), x_y_dataMap);
    }
}

/** 双击通道选择 */
void ObserMultiple::_on_itemDoubleClicked(QTreeWidgetItem *item, int column)
{
    if(level3StrMap.contains(item)){
//        qDebug() << "双击第三级";
        if(item->checkState(column) == Qt::Unchecked){
            item->setCheckState(column, Qt::Checked);
        }else{
            item->setCheckState(column, Qt::Unchecked);
        }
    }
}

/** 通道选择改变 */
void ObserMultiple::_on_itemChanged(QTreeWidgetItem *item, int column)
{
//    emit sig_logMessage("通道改变"+item->text(column));
    if(level3StrMap.contains(item)){
        if(obserShow){
            if(item->checkState(column) == Qt::Checked){
                QMap<double, double> x_y_dataMap = dataMap[item];
                //            QVector<double> x = x_y_dataMap.keys().toVector();
                //            QVector<double> y = x_y_dataMap.values().toVector();
                //            obserShow->DrawCurve(level3StrMap[item], x, y, QPen(colorList[obserShow->customPlot->graphCount() % colorList.size()]));
                obserShow->drawCurve(level3StrMap[item], x_y_dataMap.keys().toVector(), x_y_dataMap.values().toVector(), QPen(colorList[obserShow->customPlot->graphCount() % colorList.size()]));
                //            obserShow->DrawCurve(level3StrMap[item], x, y);
            }else{
                obserShow->clearCurve(level3StrMap[item]);
            }
            QMap<QTreeWidgetItem *, Qt::CheckState> checkMap = checkStateMap[obserShow];
            checkMap[item] = item->checkState(column);
            checkStateMap[obserShow] = checkMap;
        }
    }
}

/** 横轴数量编辑框回车 */
void ObserMultiple::on_le_maxNum_editingFinished()
{
    if(dataMaxLen == ui->le_maxNum->text().toInt()){
        return ;
    }
    dataMaxLen = ui->le_maxNum->text().toInt();
    QList<QTreeWidgetItem *> itemKeys = dataMap.keys();
    for(int i=0; i<itemKeys.size(); i++){
        dataMap[itemKeys.at(i)].clear();
    }
}

/** 注入数据按钮 */
void ObserMultiple::on_pb_injectionData_clicked()
{
    QList<QString> nameList = level3ItemMap.keys();
    static double x = 0;
    double y;
    x = x+1;
    QTreeWidgetItem *item;
    for(int i=0; i<nameList.size(); i++){
        item = level3ItemMap[nameList.at(i)];
        y = static_cast<double>(QRandomGenerator::global()->bounded(-15, 15));
        dataMap[item].insert(x, y);
        if(dataMap[item].size() > dataMaxLen){
            dataMap[item].remove(dataMap[item].begin().key());
        }
    }
}

/** 运行按钮 */
void ObserMultiple::on_pb_run_clicked()
{
    if(ui->pb_run->text() == tr("启动")){
        ui->pb_run->setText(tr("停止"));
        emit sig_run(true);
        for(int i=0; i<obserList.size(); i++){
            obserList.at(i)->setRunStatus(true);
        }
        if(!plotTimer->isActive()){
            plotTimer->start(50);
        }
    }else{
        ui->pb_run->setText(tr("启动"));
        emit sig_run(false);
        for(int i=0; i<obserList.size(); i++){
            obserList.at(i)->setRunStatus(false);
        }
        if(plotTimer->isActive()){
            plotTimer->stop();
        }
    }
}

/** 选中清除 */
void ObserMultiple::on_pb_clearSingle_clicked()
{
    if(obserShow){
        QMap<QTreeWidgetItem *, Qt::CheckState> selectObser = checkStateMap[obserShow];
        QList<QTreeWidgetItem *> keys = selectObser.keys();
        for(int i=0; i<keys.size(); i++){
            keys.at(i)->setCheckState(0, Qt::Unchecked);
        }
    }
}

/** 全部清除 */
void ObserMultiple::on_pb_clear_clicked()
{
    QList<ObserSingle *> singleKeys = checkStateMap.keys();
    QMap<QTreeWidgetItem *, Qt::CheckState> itemMap;
    QList<QTreeWidgetItem *> itemKeys;
    // 清除所有曲线状态表以及曲线
    for(int i=0; i<singleKeys.size(); i++){
        itemMap = checkStateMap[singleKeys.at(i)];
        itemKeys = itemMap.keys();
        for(int j=0; j<itemKeys.size(); j++){
            if(checkStateMap[singleKeys.at(i)][itemKeys.at(j)] == Qt::Checked){
                checkStateMap[singleKeys.at(i)][itemKeys.at(j)] = Qt::Unchecked;
                singleKeys.at(i)->clearCurve(level3StrMap[itemKeys.at(j)]);
            }
        }
    }
    // 清除曲线选择树
    on_pb_clearSingle_clicked();
}

/** 持续缓存 */
void ObserMultiple::on_pb_contiune_clicked()
{
    if(ui->pb_contiune->text() == "持续缓存"){
//        QString fileName = QFileDialog::getOpenFileName(this,tr("文件"), "./", tr("(*.csv)"), 0, QFileDialog::DontUseNativeDialog);
//        if(fileName == ""){
//            return ;
//        }
//        QFile csvFile(fileName);
//        if(!csvFile.open(QIODevice::WriteOnly | QIODevice::Text)){
//            csvFile.close();
//            return;
//        }

        QMessageBox::information(this, tr("提示"), tr("功能预留"));
        return ;

        ui->pb_contiune->setText(tr("结束缓存"));
    }else{
        ui->pb_contiune->setText(tr("持续缓存"));
    }
}

/** 导出数据 */
void ObserMultiple::on_pb_export_clicked()
{
    if(ui->pb_run->text() == tr("停止")){
        on_pb_run_clicked();
    }
    // 创建一个file文件
    QString fileName = QFileDialog::getSaveFileName(this, tr("Save File"), "./file", tr("File(*.csv)"), 0, QFileDialog::DontUseNativeDialog);
    if(fileName == ""){
        return;
    }
    // 打开文件
    QFile csvFile(fileName);
    if(!csvFile.open(QIODevice::WriteOnly | QIODevice::Text)){
        csvFile.close();
        return;
    }
    // 创建数据流
    QTextStream out(&csvFile);

    // 第一行显示通道号
    QList<QTreeWidgetItem *> itemKeys = dataMap.keys();
    for(int i=0; i<itemKeys.size(); i++){
        out << level3StrMap[itemKeys.at(i)]+',';
    }
    out << "\n";
    // 拿到所有通道的所有y轴数据
    QList<QVector<double>> yList;
    for(int i=0; i<itemKeys.size(); i++){
        yList.append(dataMap[itemKeys.at(i)].values().toVector());
    }
    // y轴数据量肯定并不一定相等，取y轴通道最低数据量个数
    int minSize = yList.at(0).size();
    for(int i=0; i<yList.size(); i++){
        if(minSize > yList.at(i).size()){
            minSize = yList.at(i).size();
        }
    }
    // 所有y轴数据存入csv
    for(int i=0; i<minSize; i++){
        for(int j=0; j<yList.size(); j++){
            out << yList.at(j).at(i) << ',';
        }
        out << '\n';
    }

    //含中文字符的要用tr包裹，否则乱码，元素(单元格)之间用逗号分隔，用\n换行
    csvFile.flush();
    csvFile.close();
    QMessageBox::information(this, tr("提示"), tr("数据导出成功"));
}


void ObserMultiple::on_pb_import_clicked()
{
    if(ui->pb_run->text() == tr("停止")){
        on_pb_run_clicked();
    }
    QMessageBox::information(this, tr("提示"), tr("功能预留"));
    return ;

    QString fileName = QFileDialog::getOpenFileName(this,tr("文件"), "./", tr("(*.csv)"), 0, QFileDialog::DontUseNativeDialog);
    QFile csvFile(fileName);
    if(!csvFile.open(QIODevice::ReadOnly | QIODevice::Text)){
        csvFile.close();
        return;
    }
    QTextStream in(&csvFile);
    while(!in.atEnd()){
        QString str = in.readLine();
        str.remove("\n");
        QStringList lst = str.split(",");
        // todo. 处理数据

    }
    csvFile.close();
    QMessageBox::information(this, tr("提示"), tr("数据导入成功"));
}

