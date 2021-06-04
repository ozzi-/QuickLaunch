#ifndef DEMOMODEL_H
#define DEMOMODEL_H

#include <QAbstractListModel>

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

    Q_INVOKABLE void activate(const int i);

private:
    QVector<QString> backing;
};

#endif // DEMOMODEL_H
