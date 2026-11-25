#include "quick-launch-settings.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>

QuickLaunchSettings *QuickLaunchSettings::instance()
{
    static QuickLaunchSettings *instance = new QuickLaunchSettings();
    return instance;
}

QuickLaunchSettings::QuickLaunchSettings()
    : QObject(nullptr)
    , m_settings(new QSettings("es.jaumesingla", "harbour-quick-launch"))
{
}

bool QuickLaunchSettings::closeAfterLaunch() const
{
    return m_settings->value("closeAfterLaunch", false).toBool();
}

void QuickLaunchSettings::setCloseAfterLaunch(bool closeAfterLaunch)
{
    if (closeAfterLaunch == m_settings->value("closeAfterLaunch", false).toBool())
        return;
    m_settings->setValue("closeAfterLaunch", closeAfterLaunch);
    m_settings->sync();
    emit closeAfterLaunchChanged();
}

bool QuickLaunchSettings::showFilterBar() const
{
    return m_settings->value("showFilterBar", true).toBool();
}

void QuickLaunchSettings::setShowFilterBar(bool showFilterBar)
{
    if (showFilterBar == m_settings->value("showFilterBar", true).toBool())
        return;
    m_settings->setValue("showFilterBar", showFilterBar);
    m_settings->sync();
    emit showFilterBarChanged();
}

static QString dbgLogFile()
{
    return QDir::homePath()
            + QStringLiteral("/.local/share/harbour-quick-launch/dbg.log");
}

void QuickLaunchSettings::dbgLog(const QString &line)
{
    const QString path = dbgLogFile();
    QDir().mkpath(QFileInfo(path).absolutePath());

    // Keep the file bounded: start over once it gets large.
    QFileInfo info(path);
    if (info.exists() && info.size() > 1024 * 1024)
        QFile::remove(path);

    QFile f(path);
    if (!f.open(QIODevice::Append | QIODevice::Text))
        return;
    QTextStream ts(&f);
    ts << QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss.zzz"))
       << "  " << line << '\n';
    ts.flush();
}
