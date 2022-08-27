#ifndef FILE_DESKTOP
#define FILE_DESKTOP

#include <qstring.h>
#include <qvariant.h>
#include <sailfishapp.h>

namespace FileDesktop {
    enum RoleEnum{
        FDRPath = 1,
        FDRName = 2,
        FDRIcon = 3,
        FDRId = 4,
        FDRCommand = 5,
    };

    // Q_ENUM(RoleEnum);


    class FileDesktopListModel {
    public:
        QString path;
        QString command;
        QString name;
        QString image;
        QString appType;
        int appId;
        explicit FileDesktopListModel();
        explicit FileDesktopListModel(QString path);
        QVariant getRole(const RoleEnum role) const;
        Q_INVOKABLE void execute() const;
        bool match(const QString search) const;
    };
}


#endif // FILE_DESKTOP
