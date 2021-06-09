#ifndef APP_LIST_MODEL
#define APP_LIST_MODEL

#include <QAbstractListModel>
#include "file-desktop/file-desktop.h"

using namespace FileDesktop;

class AppListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum AppListRole {
        NameRole = Qt::UserRole + 1,
    };

    explicit AppListModel(QObject *parent = 0);

    virtual int rowCount(const QModelIndex&) const { return backing.size(); }
    virtual QVariant data(const QModelIndex &index, int role) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void execute(const int i);
    Q_INVOKABLE void filter(const QString search);

private:
    QVector<FileDesktopListModel> backing;
    QVector<FileDesktopListModel> db;
};

#endif // APP_LIST_MODEL
