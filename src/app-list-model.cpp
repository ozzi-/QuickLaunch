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
            auto dataMapped = parseFile(path);
            extractData(path, dataMapped, fd);
            if (fd.name.length()>0){
                fd.appId = db.length()-1;
                db << fd;
            }
            // Use this: https://github.com/albertlauncher/plugins/blob/b4cac28be7b265027b00279baba14086d97c4d07/applications/src/extension.cpp to parse the files .Desktop
        }
    }
}

QHash<int, QByteArray> AppListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FDRPath] = "path";
    roles[FDRName] = "name";
    roles[FDRIcon] = "icon";
    roles[FDRId] = "appId";
    roles[FDRCommand] = "command";
    return roles;
}

QVariant AppListModel::data(const QModelIndex &index, int role) const {
    if(!index.isValid()) {
        return QVariant();
    }
    auto elem = db[index.row()];
    if (role == RoleEnum::FDRId){
        return QVariant(index);
    }
    if (role>=RoleEnum::FDRPath){
        return elem.getRole(static_cast<RoleEnum>(role));
    }
    return QVariant();
}

void AppListModel::execute(const int i) {
    if(i < 0 || i >= db.size()) {
        return;
    }

    db[i].execute();
}
