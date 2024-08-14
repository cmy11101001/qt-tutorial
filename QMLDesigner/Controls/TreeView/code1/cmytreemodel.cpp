#include "cmytreemodel.h"
#include <QStandardItem>
#include <QDebug>

CmyTreeModel::CmyTreeModel()
{
    this->setHorizontalHeaderLabels(QStringList()<<QString("树形控件"));
    QStandardItem *item1 = new QStandardItem(tr("列1"));
    QStandardItem *item21 = new QStandardItem(tr("列21"));
    QStandardItem *item22 = new QStandardItem(tr("列22"));
    QStandardItem *item23 = new QStandardItem(tr("列23"));
    item1->appendRow(item21);
    item1->appendRow(item22);
    item1->appendRow(item23);
    this->appendRow(item1);

    item1 = new QStandardItem(tr("列1"));
    item21 = new QStandardItem(tr("列21"));
    item22 = new QStandardItem(tr("列22"));
    item23 = new QStandardItem(tr("列23"));
    item1->appendRow(item21);
    item1->appendRow(item22);
    item1->appendRow(item23);
    this->appendRow(item1);
}
