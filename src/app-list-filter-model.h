#ifndef APPLISTFILTERMODEL_H
#define APPLISTFILTERMODEL_H

#include <QSortFilterProxyModel>
#include "file-desktop/file-desktop.h"

class AppListFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)

public:
    enum FilterMode {
        All = 0,      // show everything
        Native = 1,   // show only non-Android (native Sailfish) apps
        Android = 2,  // show only Android apps
        Recent = 3    // only apps launched through QuickLaunch, newest first
    };

public slots:
    Q_INVOKABLE void sortModel();

public:
    explicit AppListFilterModel(QObject *parent = nullptr);
    void setSourceModel(QAbstractItemModel *sourceModel) override;

    Q_INVOKABLE void execute(const QModelIndex i);
    //Q_INVOKABLE void execute(const int i);

    int filterMode() const { return m_filterMode; }
    void setFilterMode(int mode);

signals:
    void filterModeChanged();

protected:
    bool filterAcceptsRow(int row, const QModelIndex &parent) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

private:
    int m_filterMode = All;
};

#endif // APPLISTFILTERMODEL_H
