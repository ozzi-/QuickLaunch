#ifndef FILE_DESKTOP
#define FILE_DESKTOP

#include <qstring.h>
#include <qvariant.h>
#include <sailfishapp.h>

namespace FileDesktop {
    enum RoleEnum{
        FDRPath = 1
    };


    class FileDesktopListModel {
    public:
        QString path;
        QString command;
        QString image;
        explicit FileDesktopListModel();
        explicit FileDesktopListModel(QString path);
        QVariant getRole(RoleEnum role);
        void execute();
    };
}


#endif // FILE_DESKTOP
