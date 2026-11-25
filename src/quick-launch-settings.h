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
    Q_PROPERTY(bool showFilterBar READ showFilterBar
               WRITE setShowFilterBar NOTIFY showFilterBarChanged)

public:
    static QuickLaunchSettings *instance();

    bool closeAfterLaunch() const;
    void setCloseAfterLaunch(bool closeAfterLaunch);

    // All / Native / Android / Recent filter bar (default: shown).
    bool showFilterBar() const;
    void setShowFilterBar(bool showFilterBar);

    // Diagnostic file logging. The phone suppresses qDebug()/journal for
    // app processes; a plain file under the app data dir (next to the
    // Recent history) is the only reliable sink — same technique that
    // cracked the keyboard bugs. Appends one timestamped line, caps the
    // file so it can never grow unboundedly.
    Q_INVOKABLE void dbgLog(const QString &line);

signals:
    void closeAfterLaunchChanged();
    void showFilterBarChanged();

private:
    explicit QuickLaunchSettings();
    QSettings *m_settings;
};

#endif // QUICK_LAUNCH_SETTINGS_H
