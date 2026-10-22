#include <iostream>

#include "app-list-filter-model.h"
#include "app-list-model.h"

#include "file-desktop/parser.h"

AppListFilterModel::AppListFilterModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setSortRole(FDRName);
    setFilterRole(FDRName);
    setFilterCaseSensitivity(Qt::CaseSensitivity::CaseInsensitive);
}

void AppListFilterModel::setFilterMode(int mode)
{
    if (m_filterMode == mode)
        return;
    m_filterMode = mode;
    invalidateFilter();
    emit filterModeChanged();
}

bool AppListFilterModel::filterAcceptsRow(int row, const QModelIndex &parent) const
{
    // Keep the existing name filter, then apply the app-type filter on top.
    if (!QSortFilterProxyModel::filterAcceptsRow(row, parent))
        return false;

    if (m_filterMode == AppListFilterModel::All)
        return true;

    QAbstractItemModel *src = sourceModel();
    if (!src)
        return true;

    const QString appType = src->data(src->index(row, 0, parent),
                                      FileDesktop::FDRAppType).toString();

    if (m_filterMode == AppListFilterModel::Native)
        return appType != QLatin1String("android");   // everything not Android = native
    if (m_filterMode == AppListFilterModel::Android)
        return appType == QLatin1String("android");

    return true;
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
