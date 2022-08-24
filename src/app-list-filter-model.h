#ifndef APPLISTFILTERMODEL_H
#define APPLISTFILTERMODEL_H

#include <QSortFilterProxyModel>

class AppListFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
public slots:
    Q_INVOKABLE void sortModel();

public:
    explicit AppListFilterModel(QObject *parent = nullptr);
    void setSourceModel(QAbstractItemModel *sourceModel) override;

    Q_INVOKABLE void execute(const QModelIndex i);
    //Q_INVOKABLE void execute(const int i);
};

#endif // APPLISTFILTERMODEL_H
