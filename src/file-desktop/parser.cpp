// parser of .desktop files, extracted from:
// https://github.com/albertlauncher/plugins


#include <QString>
#include <QFile>
#include <iostream>
#include <QTranslator>
#include <QDebug>

#include "parser.h"


#define DEBG std::cerr
#define INFO std::cerr
#define WARN std::cerr
#define CRIT std::cerr

// ToDo: Add it later into the configuration
bool useGenericName = false;
bool useNonLocalizedName = false;
bool useKeywords = false;
QLocale loc;

namespace FileDesktop{
    using namespace std;
/******************************************************************************/
QString fieldCodesExpanded(const QString & exec, const QString & name, const QString & icon, const QString & de_path) {
    /*
     * https://specifications.freedesktop.org/desktop-entry-spec/1.5/ar01s07.html
     *
     * Code	Description
     * %% : '%'
     * %f : A single file name (including the path), even if multiple files are selected. The system reading the desktop entry should recognize that the program in question cannot handle multiple file arguments, and it should should probably spawn and execute multiple copies of a program for each selected file if the program is not able to handle additional file arguments. If files are not on the local file system (i.e. are on HTTP or FTP locations), the files will be copied to the local file system and %f will be expanded to point at the temporary file. Used for programs that do not understand the URL syntax.
     * %F : A list of files. Use for apps that can open several local files at once. Each file is passed as a separate argument to the executable program.
     * %u : A single URL. Local files may either be passed as file: URLs or as file path.
     * %U : A list of URLs. Each URL is passed as a separate argument to the executable program. Local files may either be passed as file: URLs or as file path.
     * %i : The Icon key of the desktop entry expanded as two arguments, first --icon and then the value of the Icon key. Should not expand to any arguments if the Icon key is empty or missing.
     * %c : The translated name of the application as listed in the appropriate Name key in the desktop entry.
     * %k : The location of the desktop file as either a URI (if for example gotten from the vfolder system) or a local filename or empty if no location is known.
     * Deprecated: %v %m %d %D %n %N
     */
    QString commandLine;
    for (auto it = exec.cbegin(); it != exec.end(); ++it) {
        if (*it == '%'){
            ++it;
            if (it == exec.end()) {
                break;
            } else if (*it=='%') {
                commandLine.push_back("%");
            } else if (*it=='f') {  // Unhandled atm
            } else if (*it=='F') {  // Unhandled atm
            } else if (*it=='u') {  // Unhandled atm
            } else if (*it=='U') {  // Unhandled atm
            } else if (*it=='i' && !icon.isNull()) {
                commandLine.push_back(QString("--icon %1").arg(icon));
            } else if (*it=='c') {
                commandLine.push_back(name);
            } else if (*it=='k') {
                commandLine.push_back(de_path);
            } else if (*it=='v' || *it=='m' || *it=='d' || *it=='D' || *it=='n' || *it=='N') { /*Skipping deprecated field codes*/
            } else {
                qWarning() << "Ignoring invalid field code: " << *it;
            }
        } else
            commandLine.push_back(*it);
    }
    return commandLine;
}
/******************************************************************************/
QString xdgStringEscape(const QString & unescaped) {
    /*
     * The escape sequences \s, \n, \t, \r, and \\ are supported for values of
     * type string and localestring, meaning ASCII space, newline, tab, carriage
     * return, and backslash, respectively.
     *
     * http://standards.freedesktop.org/desktop-entry-spec/latest/ar01s03.html
     */
    QString result;
    QString::const_iterator it = unescaped.begin();
    while (it != unescaped.end()) {
        if (*it == '\\'){
            ++it;
            if (it == unescaped.end())
                break;
            else if (*it=='s')
                result.append(' ');
            else if (*it=='n')
                result.append('\n');
            else if (*it=='t')
                result.append('\t');
            else if (*it=='r')
                result.append('\r');
            else if (*it=='\\')
                result.append('\\');
        }
        else
            result.append(*it);
        ++it;
    }
    return result;
}

QString getLocalizedKey(const QString &key, const map<QString,QString> &entries, const QLocale &loc) {
    map<QString,QString>::const_iterator it;
    if ( (it = entries.find(QString("%1[%2]").arg(key, loc.name()))) != entries.end()
         || (it = entries.find(QString("%1[%2]").arg(key, loc.name().left(2)))) != entries.end()
         || (it = entries.find(key)) != entries.end())
        return it->second;
    return QString();
}

    DesktopHash parseFile(QString path){
        DEBG << "Indexing desktop file:" << path.data_ptr();

        DesktopHash sectionMap;

        /*
         * Get the data from the desktop file
         */

        // Read the file into a map
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly| QIODevice::Text))
            return sectionMap;
        QTextStream stream(&file);
        QString currentGroup;
        for (QString line=stream.readLine(); !line.isNull(); line=stream.readLine()) {
            line = line.trimmed();
            if (line.startsWith('#') || line.isEmpty())
                continue;
            if (line.startsWith("[")){
                currentGroup = line.mid(1,line.size()-2).trimmed();
                continue;
            }
            sectionMap[currentGroup].emplace(line.section('=', 0,0).trimmed(),
                                             line.section('=', 1, -1).trimmed());
        }
        file.close();
        return sectionMap;
    }

    bool extractData(QString path, DesktopHash sectionMap, FileDesktopListModel& outModel){
        map<QString,map<QString,QString>>::iterator sectionIterator;

        // Skip if there is no "Desktop Entry" section
        if ((sectionIterator = sectionMap.find("Desktop Entry")) == sectionMap.end())
            return false;

        map<QString,QString> const &entryMap = sectionIterator->second;
        map<QString,QString>::const_iterator entryIterator;

        // Skip, if type is not found or not application
        if ((entryIterator = entryMap.find("Type")) == entryMap.end() ||
                entryIterator->second != "Application")
            return false;

        // Skip, if this desktop entry must not be shown
        if ((entryIterator = entryMap.find("NoDisplay")) != entryMap.end()
                && entryIterator->second == "true")
            return false;
/*
        if (!ignoreShowInKeys) {
            // Skip if the current desktop environment is specified in "NotShowIn"
            if ((entryIterator = entryMap.find("NotShowIn")) != entryMap.end())
                for (const QString &str : entryIterator->second.split(';',QString::SkipEmptyParts))
                    if (xdg_current_desktop.contains(str))
                        continue;

            // Skip if the current desktop environment is not specified in "OnlyShowIn"
            if ((entryIterator = entryMap.find("OnlyShowIn")) != entryMap.end()) {
                bool found = false;
                for (const QString &str : entryIterator->second.split(';',QString::SkipEmptyParts))
                    if (xdg_current_desktop.contains(str)){
                        found = true;
                        break;
                    }
                if (!found)
                    return sectionMap;
            }
        }
*/
        // bool term;
        QString name;
        QString nonLocalizedName;
        QString genericName;
        QString comment;
        QString icon;
        QString exec;
        QString workingDir;
        QStringList keywords;
        QStringList actionIdentifiers;

        // Try to get the localized name, skip if empty
        name = xdgStringEscape(getLocalizedKey("Name", entryMap, loc));
        if (name.isNull())
            return false;

        // Try to get the exec key, skip if not existant
        if ((entryIterator = entryMap.find("Exec")) != entryMap.end())
            exec = xdgStringEscape(entryIterator->second);
        else
            return false;

        // Try to get the localized icon, skip if empty
        icon = xdgStringEscape(getLocalizedKey("Icon", entryMap, loc));

        // Check if this is a terminal app
        /*term = (entryIterator = entryMap.find("Terminal")) != entryMap.end()
                && entryIterator->second=="true";*/

        // Try to get the localized genericName
        genericName = xdgStringEscape(getLocalizedKey("GenericName", entryMap, loc));

        // Try to get the non-localized name
        if ((entryIterator = entryMap.find("Name")) != entryMap.end())
            nonLocalizedName = xdgStringEscape(entryIterator->second);

        // Try to get the localized comment
        comment = xdgStringEscape(getLocalizedKey("Comment", entryMap, loc));

        // Try to get the keywords
        keywords = xdgStringEscape(getLocalizedKey("Keywords", entryMap, loc)).split(';',QString::SkipEmptyParts);

        // Try to get the workindir
        if ((entryIterator = entryMap.find("Path")) != entryMap.end())
            workingDir = xdgStringEscape(entryIterator->second);

        // Try to get the keywords
        if ((entryIterator = entryMap.find("Actions")) != entryMap.end())
            actionIdentifiers = xdgStringEscape(entryIterator->second).split(';',QString::SkipEmptyParts);

//            // Try to get the mimetypes
//            if ((valueIterator = entryMap.find("MimeType")) != entryMap.end())
//                keywords = xdgStringEscape(valueIterator->second).split(';',QString::SkipEmptyParts);


        /*
         * Build the item
         */

        // Field code expandesd commandline
        QString commandLine = fieldCodesExpanded(exec, name, icon, path);

        // Icon path
        QString icon_path = icon; //XDG::IconLookup::iconPath({icon, "application-x-executable", "exec"});
        if (icon_path.isNull())
            icon_path = ":application-x-executable";



        // Description
        QString subtext;
        if (!comment.isEmpty())
            subtext = comment;
        else if(useGenericName && !genericName.isEmpty())
            subtext = genericName;
        else if(useNonLocalizedName && !nonLocalizedName.isEmpty())
            subtext = nonLocalizedName;
        else
            subtext = commandLine;
        /*
        // Set index strings
        vector<QString> indexStrings;
        indexStrings.emplace_back(name, UINT_MAX);

        QStringList excludes = {
            "java ",
            "ruby ",
            "python ",
            "perl ",
            "bash ",
            "sh ",
            "dbus-send ",
            "/"
        };
        if (none_of(excludes.begin(), excludes.end(), [&exec](const QString &str){ return exec.startsWith(str); }))
            indexStrings.emplace_back(exec.section(QChar(QChar::Space), 0, 0, QString::SectionSkipEmpty), UINT_MAX);

        if (useKeywords)
            for (auto & kw : keywords)
                indexStrings.emplace_back(kw, UINT_MAX/2);

        if (useGenericName && !genericName.isEmpty())
            indexStrings.emplace_back(genericName, UINT_MAX/2);

        if (useNonLocalizedName && !nonLocalizedName.isEmpty())
            indexStrings.emplace_back(nonLocalizedName, UINT_MAX/2);

        //*/

        if (!icon_path.startsWith(QLatin1Char('/')))
                icon_path.prepend(QStringLiteral("image://theme/"));

        outModel.command = commandLine;
        outModel.image = icon_path;
        outModel.name = name;

        return true;
    }
}
