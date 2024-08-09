#include "cmytablemodel.h"

CmyTableModel::CmyTableModel(QObject *parent)
    : QAbstractTableModel{parent}
{

}

QStringList CmyTableModel::getHeader() const
{
    return headerList;
}

void CmyTableModel::setHeader(const QStringList &strList)
{
    headerList = strList;
    emit headerChanged();
}

QJsonArray CmyTableModel::getParams() const
{
    return params;
}

void CmyTableModel::setParams(const QJsonArray &jsonArr)
{
    params = jsonArr;
    loadData(params);
    emit paramsChanged();
}

QVariant CmyTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(role == Qt::DisplayRole){
        if(orientation == Qt::Horizontal){
            return headerList.value(section, QString::number(section));
        }else if(orientation == Qt::Vertical){
            return QString::number(section);
        }
    }
    return QVariant();
}

bool CmyTableModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role)
{
    if (value != headerData(section, orientation, role)) {
        if(orientation == Qt::Horizontal && role == Qt::DisplayRole){
            headerList[section] = value.toString();
            emit headerDataChanged(orientation, section, section);
            return true;
        }
    }
    return false;
}

int CmyTableModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return paramVector.count();
}

int CmyTableModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return headerList.count();
}

QVariant CmyTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    switch (role) {
        case Qt::DisplayRole:
            return paramVector.at(index.row()).at(index.column());
        default:
            break;
    }

    return QVariant();
}

bool CmyTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (value.isValid() && index.isValid() && (data(index, role) != value)) {
        if(Qt::DisplayRole == role){
            paramVector[index.row()][index.column()] = value;
            emit dataChanged(index, index, QVector<int>() << role);
            return true;
        }
    }
    return false;
}

QHash<int, QByteArray> CmyTableModel::roleNames() const
{
    return {
        {Qt::DisplayRole, "value"},
    };
}

void CmyTableModel::loadData(const QJsonArray &data)
{
    QVector<QVector<QVariant>> newData;
    QJsonArray::const_iterator iter;
    for(iter=data.begin(); iter!=data.end(); ++iter){
        QVector<QVariant> newRow;
        const QJsonObject itemRow=(*iter).toObject();
        for (int i = 0; i < headerList.size(); ++i) {
            QString name = headerList.at(i);
            newRow.append(itemRow.value(name));
        }
        newData.append(newRow);
    }

    emit beginResetModel();
    paramVector = newData;
    emit endResetModel();
}
