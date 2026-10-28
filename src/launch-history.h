#ifndef LAUNCHHISTORY_H
#define LAUNCHHISTORY_H

#include <QObject>
#include <QStringList>

/**
 * Bounded, persisted record of the apps launched through QuickLaunch.
 *
 * Storage : ~/.local/share/harbour-quick-launch/recent.json
 * Format  : a JSON array of desktop-file paths, newest first:
 *           ["/usr/share/applications/a.desktop", ".../b.desktop", ...]
 *
 * The list is bounded to MAX_ENTRIES entries and entries whose .desktop file
 * no longer exists are dropped on load, so the file can never grow
 * unboundedly (no storage leak) and the in-memory list stays tiny.
 */
class LaunchHistory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList paths READ paths NOTIFY changed)

public:
    static const int MAX_ENTRIES = 100;

    explicit LaunchHistory(QObject *parent = nullptr);

    // App-lifetime singleton shared by QML (recordLaunch) and the filter
    // model (recency lookups).
    static LaunchHistory *instance();

    // Desktop-file paths, newest first.
    QStringList paths() const;

    // Position of a path in the list, or -1 if not present.
    // Lower index = more recently launched.
    int indexOf(const QString &path) const;

    // Record a launch: move the app to the front, drop duplicates,
    // trim to MAX_ENTRIES, persist, notify.
    Q_INVOKABLE void recordLaunch(const QString &path);


signals:
    void changed();

private:
    void load();
    void save() const;

    QStringList m_paths; // newest first, bounded by MAX_ENTRIES
};

#endif // LAUNCHHISTORY_H
