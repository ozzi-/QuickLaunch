#include "app-list-model.h"

#include <QStandardPaths>
#include<QDirIterator>
#include "utils/enum-check.h"

AppListModel::AppListModel(QObject *parent) :
    QAbstractListModel(parent)
{

    QStringList data = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);

    //QDirIterator* listDir;
    for (const auto& path : data) {

        QDirIterator listDir(path, {"*.desktop"});
        while (listDir.hasNext()){
            QString path = listDir.next();
            backing << FileDesktopListModel(path);
            // Use this: https://github.com/albertlauncher/plugins/blob/b4cac28be7b265027b00279baba14086d97c4d07/applications/src/extension.cpp to parse the files .Desktop
        }
    }
}

QHash<int, QByteArray> AppListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FDRPath] = "`path";
    return roles;
}

QVariant AppListModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    auto elem = backing[index.row()];
    if (role>RoleEnum::FDRPath){
        return elem.getRole(static_cast<RoleEnum>(role));
    }
    return QVariant();
}

void AppListModel::activate(const int i) {
    if(i < 0 || i >= backing.size()) {
        return;
    }
    /*QString value = backing[i];

    // Remove the value from the old location.
    beginRemoveRows(QModelIndex(), i, i);
    backing.erase(backing.begin() + i);
    endRemoveRows();

    // Add it to the top.
    beginInsertRows(QModelIndex(), 0, 0);
    backing.insert(0, value);
    endInsertRows();*/
}
