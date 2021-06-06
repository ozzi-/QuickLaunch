
#include "./file-desktop.h"
#include "./parser.h"

#include <QProcess>

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
        auto hash = parseFile(path);
        extractData(path, hash, *this);
    }

    QVariant FileDesktopListModel::getRole(RoleEnum role) {
        QString data = "";
        switch(role){
            case FDRPath:
                data = path;
            break;
            default:
                data = "-- No identified --";
        }
        return QVariant(data);
    }

    void FileDesktopListModel::execute(){
        // call here:
        // startDetached(const QString &program, const QStringList &arguments, const QString &workingDirectory = QString(), qint64 *pid = nullptr)
        QProcess::startDetached(command);
    }
}
