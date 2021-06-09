#include "app-list-model.h"

#include <QStandardPaths>
#include<QDirIterator>
#include <iostream>
#include "utils/enum-check.h"

#include "file-desktop/parser.h"

AppListModel::AppListModel(QObject *parent) :
    QAbstractListModel(parent)
{

    QStringList data = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);

    //QDirIterator* listDir;
    for (const auto& path : data) {

        QDirIterator listDir(path, {"*.desktop"});
        while (listDir.hasNext()){
            QString path = listDir.next();
            auto fd = FileDesktopListModel(path);
            auto hash = parseFile(path);
            extractData(path, hash, fd);
            db << fd;
            // Use this: https://github.com/albertlauncher/plugins/blob/b4cac28be7b265027b00279baba14086d97c4d07/applications/src/extension.cpp to parse the files .Desktop
        }
    }
    this->filter(QString(""));
}

QHash<int, QByteArray> AppListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FDRPath] = "path";
    roles[FDRName] = "name";
    roles[FDRIcon] = "icon";
    return roles;
}

QVariant AppListModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    auto elem = backing[index.row()];
    if (role>=RoleEnum::FDRPath){
        return elem.getRole(static_cast<RoleEnum>(role));
    }
    return QVariant();
}

void AppListModel::execute(const int i) {
    if(i < 0 || i >= backing.size()) {
        return;
    }

    backing[i].execute();
}

void AppListModel::filter(const QString search){
    beginResetModel();
    backing.clear();

    for (const auto& app: db){
        if (app.match(search)){
            backing << app;
        }
    }
    endResetModel();
}
