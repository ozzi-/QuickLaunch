#ifndef QUICK_LAUNCH_SETTINGS_H
#define QUICK_LAUNCH_SETTINGS_H

#include <QObject>
#include <QSettings>

/**
 * @brief Persisted app settings (QSettings — QtCore, always available).
 *
 * Singleton exposed to QML as QuickLaunchSettings (es.jaumesingla 1.0).
 */
class QuickLaunchSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool closeAfterLaunch READ closeAfterLaunch
               WRITE setCloseAfterLaunch NOTIFY closeAfterLaunchChanged)

public:
    static QuickLaunchSettings *instance();

    bool closeAfterLaunch() const;
    void setCloseAfterLaunch(bool closeAfterLaunch);

signals:
    void closeAfterLaunchChanged();

private:
    explicit QuickLaunchSettings();
    QSettings *m_settings;
};

#endif // QUICK_LAUNCH_SETTINGS_H
