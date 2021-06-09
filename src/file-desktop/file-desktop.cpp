
#include "./file-desktop.h"

#include <QProcess>
#include <QDebug>
#include <iostream>

namespace FileDesktop {
    FileDesktopListModel::FileDesktopListModel(){
        path="";
        command="";
        image="";
    }
    FileDesktopListModel::FileDesktopListModel(QString __path){
        path=__path;
        command = "";
        image = "";
    }

    QVariant FileDesktopListModel::getRole(RoleEnum role) const {
        QString data = "";
        switch(role){
            case FDRPath:
                data = path;
            break;
            case FDRName:
                data = name;
            break;
            case FDRIcon:
                data = image;
            break;
            default:
                data = "-- No identified --";
        }
        return QVariant(data);
    }

    void FileDesktopListModel::execute() const {
        // call here:
        // startDetached(const QString &program, const QStringList &arguments, const QString &workingDirectory = QString(), qint64 *pid = nullptr)
        QProcess::startDetached(command);
    }

    bool FileDesktopListModel::match(const QString search) const{
        //std::cout << name.data_ptr() << " vs " << search.data_ptr() << "=" << name.contains(search) << std::endl;
        return name.toLower().contains(search);
    }
}
