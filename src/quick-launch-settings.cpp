#include "quick-launch-settings.h"

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
