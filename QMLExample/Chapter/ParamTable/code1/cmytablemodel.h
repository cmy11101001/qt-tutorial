#ifndef CMYTABLEMODEL_H
#define CMYTABLEMODEL_H

#include <QAbstractTableModel>
#include <QJsonArray>
#include <QJsonObject>

class CmyTableModel : public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList header READ getHeader WRITE setHeader NOTIFY headerChanged)
    Q_PROPERTY(QJsonArray params READ getParams WRITE setParams NOTIFY paramsChanged)

public:
    explicit CmyTableModel(QObject *parent = nullptr);

    QStringList getHeader() const;
    void setHeader(const QStringList &strList);

    QJsonArray getParams() const;
    void setParams(const QJsonArray &jsonArr);

    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;
    bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value,
                       int role = Qt::DisplayRole) override;

    int rowCount(const QModelIndex & = QModelIndex()) const override;
    int columnCount(const QModelIndex & = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::DisplayRole) override;
    QHash<int, QByteArray> roleNames() const override;

private:
    void loadData(const QJsonArray &data);

signals:
    void headerChanged();
    void paramsChanged();

private:
    QJsonArray params;
    QVector<QVector<QVariant>> paramVector;
    QList<QString> headerList;
};

#endif // CMYTABLEMODEL_H
