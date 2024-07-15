#include "obsersingle.h"
#include "ui_obsersingle.h"
#pragma execution_character_set("utf-8")

//////////////////////////// 右键菜单acion回调 ////////////////////////////
// 适应窗口大小
void ObserSingle::RescaleActionFun::fun(ObserSingle *form)
{
    // 自适应y轴数据范围，每次 setData 之后都要调用
    form->customPlot->rescaleAxes(true);
    form->customPlot->replot(QCustomPlot::rpQueuedReplot); // 重绘
}

// 十字游标
void ObserSingle::CursorActionFun::fun(ObserSingle *form)
{
    // 显示十字游标
    if(form->cursorShow){
        form->lineY->point1->setCoords(0, 0);
        form->lineY->point2->setCoords(0, 0);
        form->lineX->point1->setCoords(0, 0);
        form->lineX->point2->setCoords(0, 0);
        form->cursorShow = false;
    }else{
        form->cursorShow = true;
    }
    form->customPlot->replot(QCustomPlot::rpQueuedReplot); // 重绘
}

//////////////////////////// ObserSingle ////////////////////////////
ObserSingle::ObserSingle(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::ObserSingle)
    , clickMenu(new QMenu)
    , lineY(nullptr)
    , lineX(nullptr)
    , cursorShow(false)
    , midButtonPress(false)
    , customPlot(new QCustomPlot)
{
    ui->setupUi(this);

    // 创建画布
    QGridLayout *layout = new QGridLayout();
    layout->setContentsMargins(2, 2, 2, 2);
    layout->addWidget(customPlot);
    ui->plotWindow->setLayout(layout);
    // 轴设置
    customPlot->xAxis->setRange(1, 1, Qt::AlignRight);          // 设置轴刻度
    customPlot->xAxis->ticker()->setTickCount(8);               // 设置轴刻度数目
    customPlot->xAxis->setLabel(tr("xAxis"));                       // 设置轴标签
    customPlot->yAxis->setRange(2, 2, Qt::AlignRight);
    customPlot->yAxis->ticker()->setTickCount(5);
    customPlot->yAxis->setLabel(tr("yAxis"));
    // 图例
    customPlot->legend->setVisible(true);                       // 显示
    customPlot->legend->setBrush(QColor(255, 255, 255, 50));   // 灰色透明
    customPlot->legend->setBorderPen(Qt::NoPen);                // 边框隐藏
    customPlot->legend->setWrap(4);                             // 设置4个图例自动换行
    customPlot->legend->setFillOrder(QCPLayoutGrid::foRowsFirst);    // 图例优先排序(foRowsFirst foColumnsFirst) foRowsFirst
//    customPlot->plotLayout()->addElement(0, 0, customPlot->legend);     // 图例位置     0 0
    customPlot->plotLayout()->setRowStretchFactor(0, 0.001);            // 显示比例     0 0.001
    // 设置基本坐标轴（左侧Y轴和下方X轴）可拖动、可缩放、曲线可选、legend可选、设置伸缩比例，使所有图例可见
    customPlot->setInteractions(QCP::iRangeDrag|QCP::iRangeZoom| QCP::iSelectAxes | QCP::iSelectLegend | QCP::iSelectPlottables);
//    customPlot->setInteractions(QCP::iRangeDrag|QCP::iRangeZoom| QCP::iSelectAxes );
    // 设置legend只能选择图例
    customPlot->legend->setSelectableParts(QCPLegend::spItems);
    // 设置图例与曲线同步选中
    QObject::connect(customPlot, SIGNAL(selectionChangedByUser()), this, SLOT(selectionChanged()));

    // 右键action 适应窗口大小
    clickMenuAddAction(tr("适应窗口大小"), ":/reference/image/plot.png", new RescaleActionFun);
    // 右键action 十字游标
    clickMenuAddAction(tr("十字游标"), ":/reference/image/plot.png", new CursorActionFun);
    // 鼠标右键菜单栏
    QObject::connect(customPlot, SIGNAL(mousePress(QMouseEvent*)), this, SLOT(onMousePress(QMouseEvent *)));

    // 提示线
    lineY = new QCPItemStraightLine(customPlot);
    lineY->setLayer("overlay");
    lineY->setPen(QPen(Qt::gray, 1, Qt::DashLine));
    lineY->setClipToAxisRect(true);
    lineY->point1->setCoords(0, 0);
    lineY->point2->setCoords(0, 0);
    lineX = new QCPItemStraightLine(customPlot);
    lineX->setLayer("overlay");
    lineX->setPen(QPen(Qt::gray, 1, Qt::DashLine));
    lineX->setClipToAxisRect(true);
    lineX->point1->setCoords(0, 0);
    lineX->point2->setCoords(0, 0);
    // 鼠标移动
    QObject::connect(customPlot, SIGNAL(mouseMove(QMouseEvent*)), this, SLOT(onMouseMove(QMouseEvent *)));
    // 鼠标释放
    QObject::connect(customPlot, SIGNAL(mouseRelease(QMouseEvent*)), this,  SLOT(onMouseRelease(QMouseEvent *)));

    // 自适应y轴数据范围，每次 setData 之后都要调用
    customPlot->rescaleAxes(true);
    customPlot->replot(QCustomPlot::rpQueuedReplot); // 重绘

//    customPlot->setOpenGl(true);
//    qDebug()<<"opengle="<<customPlot->openGl();
}

ObserSingle::~ObserSingle()
{
    ui->plotWindow->layout()->deleteLater();
    QList<QString> keyList = actionFunMap.keys();
    for(int i=0; i<keyList.size(); i++){
        if(actionFunMap[keyList[i]]){
            delete actionFunMap[keyList[i]];
        }
    }
    QList<QAction *> actionList = actionMap.keys();
    for(int i=0; i<actionList.size(); i++){
        if(actionList.at(i)){
            delete actionList.at(i);
        }
    }
    if(clickMenu){
        clickMenu->deleteLater();
    }
    if(customPlot){
        customPlot->deleteLater();
    }
    delete ui;
}

/** 鼠标移动 */
void ObserSingle::onMouseMove(QMouseEvent *event)
{
    if(midButtonPress){
        // posPress 与 QCursor::pos() 比较
        QPoint pos = QCursor::pos();
        int xLen = pos.x() - posPress.x();
        int yLen = pos.y() - posPress.y();
        if(qAbs(xLen) - qAbs(yLen) > 0){
            // 拉伸x轴
            if(xLen > 0){
                double xSize = customPlot->xAxis->range().upper - customPlot->xAxis->range().lower;
                customPlot->xAxis->setRangeLower(customPlot->xAxis->range().lower + xSize/20);
                customPlot->xAxis->setRangeUpper(customPlot->xAxis->range().upper - xSize/20);
            }else{
                double xSize = customPlot->xAxis->range().upper - customPlot->xAxis->range().lower;
                customPlot->xAxis->setRangeLower(customPlot->xAxis->range().lower - xSize/20);
                customPlot->xAxis->setRangeUpper(customPlot->xAxis->range().upper + xSize/20);
            }
        }else{
            // 拉伸y轴
            if(yLen > 0){
                double ySize = customPlot->yAxis->range().upper - customPlot->yAxis->range().lower;
                customPlot->yAxis->setRangeLower(customPlot->yAxis->range().lower - ySize/20);
                customPlot->yAxis->setRangeUpper(customPlot->yAxis->range().upper + ySize/20);
            }else{
                double ySize = customPlot->yAxis->range().upper - customPlot->yAxis->range().lower;
                customPlot->yAxis->setRangeLower(customPlot->yAxis->range().lower + ySize/20);
                customPlot->yAxis->setRangeUpper(customPlot->yAxis->range().upper - ySize/20);
            }
        }
        posPress = pos;
        customPlot->replot(QCustomPlot::rpQueuedReplot);
    }else{
        // 当前鼠标位置（像素坐标）
        int x_pos = event->pos().x();
        int y_pos = event->pos().y();
        // 像素坐标转成实际的x,y轴的坐标
        float x_val = customPlot->xAxis->pixelToCoord(x_pos);
        float y_val = customPlot->yAxis->pixelToCoord(y_pos);
        if(cursorShow){
            lineY->point1->setCoords(x_val, customPlot->yAxis->range().lower);
            lineY->point2->setCoords(x_val, customPlot->yAxis->range().upper);
            lineX->point1->setCoords(customPlot->xAxis->range().lower, y_val);
            lineX->point2->setCoords(customPlot->xAxis->range().upper, y_val);
            customPlot->replot(QCustomPlot::rpQueuedReplot);
        }
        QToolTip::hideText();
        QToolTip::showText(event->globalPos(),
                           QString("x:%1 y:%2").arg(x_val).arg(y_val),
                           this, rect());
    }
}

/** 图例与曲线同步选中 */
void ObserSingle::selectionChanged()
{
    // make top and bottom axes be selected synchronously, and handle axis and tick labels as one selectable object:
    if (customPlot->xAxis->selectedParts().testFlag(QCPAxis::spAxis) || customPlot->xAxis->selectedParts().testFlag(QCPAxis::spTickLabels) ||
        customPlot->xAxis2->selectedParts().testFlag(QCPAxis::spAxis) || customPlot->xAxis2->selectedParts().testFlag(QCPAxis::spTickLabels))
    {
        customPlot->xAxis2->setSelectedParts(QCPAxis::spAxis|QCPAxis::spTickLabels);
        customPlot->xAxis->setSelectedParts(QCPAxis::spAxis|QCPAxis::spTickLabels);
    }
    // make left and right axes be selected synchronously, and handle axis and tick labels as one selectable object:
    if (customPlot->yAxis->selectedParts().testFlag(QCPAxis::spAxis) || customPlot->yAxis->selectedParts().testFlag(QCPAxis::spTickLabels) ||
        customPlot->yAxis2->selectedParts().testFlag(QCPAxis::spAxis) || customPlot->yAxis2->selectedParts().testFlag(QCPAxis::spTickLabels))
    {
        customPlot->yAxis2->setSelectedParts(QCPAxis::spAxis|QCPAxis::spTickLabels);
        customPlot->yAxis->setSelectedParts(QCPAxis::spAxis|QCPAxis::spTickLabels);
    }

    // 将图形的选择与相应图例项的选择同步
    for (int i=0; i<customPlot->graphCount(); ++i)
    {
        QCPGraph *graph = customPlot->graph(i);
        QCPPlottableLegendItem *item = customPlot->legend->itemWithPlottable(graph);
        if (item->selected() || graph->selected())
        {
            item->setSelected(true);
            // 注意：这句需要Qcustomplot2.0系列版本
            graph->setSelection(QCPDataSelection(graph->data()->dataRange()));
            // 这句1.0系列版本即可
            // graph->setSelected(true);
        }
    }
}

/** 右键菜单 */
void ObserSingle::onMousePress(QMouseEvent *event)
{
    if(event->button() == Qt::RightButton){
        clickMenu->exec(QCursor::pos());
    }else if(event->button() == Qt::MiddleButton){
        midButtonPress = true;
        posPress = QCursor::pos();
    }
}

/** 鼠标释放 */
void ObserSingle::onMouseRelease(QMouseEvent *event)
{
    if(event->button() == Qt::MiddleButton){
        midButtonPress = false;
    }
}

/** 右键菜单action点击 */
void ObserSingle::_on_action_create_triggered(void)
{
    QAction *action = static_cast<QAction *>(this->sender());

    if(actionMap.contains(action)){
        if(actionFunMap.contains(actionMap[action])){
            actionFunMap[actionMap[action]]->fun(this);
        }
    }
}

/** 创建右键菜单action */
void ObserSingle::clickMenuAddAction(QString name, QString icon, MenuActionFun *fun)
{
    QAction *action = new QAction(QIcon(icon), name, this);
    actionMap.insert(action, name);
    QObject::connect(action, SIGNAL(triggered()), this, SLOT(_on_action_create_triggered()));
    clickMenu->addAction(action);
    actionFunMap.insert(name, fun);
}

/** 绘制曲线 */
void ObserSingle::drawCurve(const QString name, const QVector<double> x, const QVector<double> y, QPen pen)
{
    if(curveMap.contains(name)){
        curveMap[name]->setData(x, y, true);
    }else{
        QCPGraph *graph = customPlot->addGraph();
        graph->setAntialiased(false);               // 关闭抗锯齿可加快绘制速度
        graph->setAntialiasedFill(false);
        graph->setAntialiasedScatters(false);
        graph->setPen(pen);
        graph->setName(name);
        graph->setData(x, y, true);
        curveMap.insert(name, graph);
    }
    customPlot->replot(QCustomPlot::rpQueuedReplot); // 重绘
}

/** 清除曲线 */
void ObserSingle::clearCurve(const QString name)
{
    if(curveMap.contains(name)){
        QVector<double> x, y;
        // 删除所有曲线
//        customPlot->clearGraphs();
        QCPGraph *graph;
        // 移除map曲线
        curveMap.remove(name);
        QList<QString> nameList = curveMap.keys();
        // 重新绘画所有曲线
        QList<QString> nameListSave;
        QList<QVector<double>> xList;
        QList<QVector<double>> yList;
        QList<QPen> penList;
        for(int i=0; i<nameList.size(); i++){
            graph = curveMap[nameList[i]];
            curveMap.remove(nameList[i]);
            // 保存曲线数据
            x.clear();
            y.clear();
            for(int data_i=0; data_i<graph->data()->size(); data_i++){
                x.append(graph->data()->at(data_i)->key);
                y.append(graph->data()->at(data_i)->value);
            }
            // 保存曲线颜色
            QColor color = graph->pen().color();
            // 重画曲线
//            DrawCurve(nameList[i], x, y, QPen(color));
//            DrawCurve(nameList[i], x, y);
            nameListSave.append(nameList[i]);
            xList.append(x);
            yList.append(y);
            penList.append(QPen(color));
        }
        customPlot->clearGraphs();
        for(int i=0; i<nameListSave.size(); i++){
            drawCurve(nameListSave[i], xList[i], yList[i], penList[i]);
        }

    }
    customPlot->replot(QCustomPlot::rpQueuedReplot); // 重绘
}

/** 自适应屏幕 */
void ObserSingle::replot(void)
{
    customPlot->rescaleAxes(true);
}

/** 设置运行状态 */
void ObserSingle::setRunStatus(bool b)
{
    if(b){
        customPlot->setInteractions(QCP::iRangeDrag|QCP::iRangeZoom| QCP::iSelectAxes );
        // 将图形的选择与相应图例项的选择同步取消
        for (int i=0; i<customPlot->graphCount(); ++i)
        {
            QCPGraph *graph = customPlot->graph(i);
            QCPPlottableLegendItem *item = customPlot->legend->itemWithPlottable(graph);
            if (item->selected() || graph->selected())
            {
                item->setSelected(false);
                QCPDataSelection select;
                graph->setSelection(select);
            }
        }
    }else{
        customPlot->setInteractions(QCP::iRangeDrag|QCP::iRangeZoom| QCP::iSelectAxes | QCP::iSelectLegend | QCP::iSelectPlottables);
    }
}
