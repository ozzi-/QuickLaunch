
#ifndef FILE_DESKTOP_PARSER
#define FILE_DESKTOP_PARSER

#include<qstring.h>
#include <map>

#include "file-desktop.h"

namespace FileDesktop {
    using DesktopHash = std::map<QString,std::map<QString,QString>>;

    DesktopHash parseFile(QString path);
    bool extractData(QString path, DesktopHash sectionMap, FileDesktopListModel& outModel);
}

#endif
