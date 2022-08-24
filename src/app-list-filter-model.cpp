#include <iostream>

#include "app-list-filter-model.h"
#include "app-list-model.h"

#include "file-desktop/parser.h"

AppListFilterModel::AppListFilterModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setSortRole(FDRName);
    setFilterRole(FDRName);
}

void AppListFilterModel::sortModel()
{
    sort(0, Qt::AscendingOrder);
}


void AppListFilterModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    auto *model = qobject_cast<AppListModel *>(sourceModel);
    connect(model, &AppListModel::changed, this, &AppListFilterModel::sortModel);

    QSortFilterProxyModel::setSourceModel(sourceModel);

    sortModel();
}

//void AppListFilterModel::execute(const int appId) {
    /*std::cout << mapToSource(index).row() << " "<< index.row() << std::endl;

    auto *model = qobject_cast<AppListModel *>(QSortFilterProxyModel::sourceModel());

    auto appIdx = mapToSource(index);

    model->execute(appIdx.row());
    */
void AppListFilterModel::execute(const QModelIndex appId) {

    auto *model = qobject_cast<AppListModel *>(QSortFilterProxyModel::sourceModel());

    model->execute(appId.row());
}
