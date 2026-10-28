#include <iostream>

#include "app-list-filter-model.h"
#include "app-list-model.h"
#include "launch-history.h"

#include "file-desktop/parser.h"

AppListFilterModel::AppListFilterModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setSortRole(FDRName);
    setFilterRole(FDRName);
    setFilterCaseSensitivity(Qt::CaseSensitivity::CaseInsensitive);

    // When a launch is recorded the Recent list (membership and order)
    // changes: refresh the filter and the recency sort.
    connect(LaunchHistory::instance(), &LaunchHistory::changed,
            this, [this]() {
        invalidateFilter();   // update which apps count as "recent"
        resort();             // re-order by recency (plain sort() is a no-op in 5.6)
    });
}

void AppListFilterModel::setFilterMode(int mode)
{
    if (m_filterMode == mode)
        return;
    m_filterMode = mode;
    invalidateFilter();
    // Recent mode is ordered by recency, every other mode by name. Re-sort on
    // every switch so both stay correct (plain sort() is a no-op in Qt 5.6 when
    // the sort indicator is already (0, Ascending) — see resort()).
    resort();
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
    if (m_filterMode == AppListFilterModel::Recent)
        return LaunchHistory::instance()->indexOf(
                   src->data(src->index(row, 0, parent), FDRPath).toString()) >= 0;

    return true;
}

bool AppListFilterModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_filterMode == Recent) {
        // Sort by recency: lower index in the launch history = more recent.
        QAbstractItemModel *src = sourceModel();
        if (src) {
            const QString lp = src->data(left, FDRPath).toString();
            const QString rp = src->data(right, FDRPath).toString();
            const int li = LaunchHistory::instance()->indexOf(lp);
            const int ri = LaunchHistory::instance()->indexOf(rp);
            if (li >= 0 && ri >= 0)
                return li < ri;
            if (li >= 0)
                return true;
            if (ri >= 0)
                return false;
        }
        return false;
    }

    // Default: by name (sortRole = FDRName).
    return QSortFilterProxyModel::lessThan(left, right);
}

void AppListFilterModel::sortModel()
{
    resort();
}

void AppListFilterModel::resort()
{
    if (!sourceModel())
        return;
    // QSortFilterProxyModel::sort(column, order) is a NO-OP when the
    // (column, order) pair is unchanged, so a plain sort(0, Ascending) after
    // the model is already in that state does nothing. This 5.6 build has no
    // setSortIndicator, so the only lever is the order: sort descending (a
    // different pair -> genuine re-sort), then ascending again. lessThan()
    // already orders Recent mode by recency, so the final Ascending state is
    // correct.
    sort(0, Qt::DescendingOrder);
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
