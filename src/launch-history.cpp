#include "launch-history.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>

static QString storageFile()
{
    // SFOS app data lives in the user's home directory.
    return QDir::homePath()
            + QStringLiteral("/.local/share/harbour-quick-launch/recent.json");
}

LaunchHistory *LaunchHistory::instance()
{
    // Leaked on purpose: the app-lifetime object is shared between the QML
    // singleton and the filter model.
    static LaunchHistory *self = new LaunchHistory;
    return self;
}

LaunchHistory::LaunchHistory(QObject *parent) :
    QObject(parent)
{
    load();
}

QStringList LaunchHistory::paths() const
{
    return m_paths;
}

int LaunchHistory::indexOf(const QString &path) const
{
    return m_paths.indexOf(path);
}

void LaunchHistory::recordLaunch(const QString &path)
{
    if (path.isEmpty())
        return;

    // Most recent first; dedupe.
    m_paths.removeAll(path);
    m_paths.prepend(path);

    // Hard bound: never keep more than MAX_ENTRIES entries.
    while (m_paths.size() > MAX_ENTRIES)
        m_paths.removeLast();

    save();
    emit changed();
}

void LaunchHistory::load()
{
    QFile f(storageFile());
    if (!f.exists() || !f.open(QIODevice::ReadOnly))
        return;

    const QByteArray raw = f.readAll();
    f.close();

    const QJsonDocument doc = QJsonDocument::fromJson(raw);
    if (!doc.isArray())
        return;

    const QJsonArray arr = doc.array();
    for (int i = 0; i < arr.size() && m_paths.size() < MAX_ENTRIES; ++i) {
        const QString p = arr.at(i).toString();
        if (p.isEmpty() || m_paths.contains(p))
            continue;

        // Drop apps that were uninstalled since; otherwise dead paths would
        // accumulate forever.
        if (!QFile::exists(p))
            continue;

        m_paths << p;
    }
}

void LaunchHistory::save() const
{
    const QString target = storageFile();
    QDir().mkpath(QFileInfo(target).absolutePath());

    QJsonArray arr;
    for (int i = 0; i < m_paths.size(); ++i)
        arr.append(m_paths.at(i));

    // Write atomically (temp file + rename) so a killed app can never leave
    // a half-written file behind.
    const QString tmp = target + QStringLiteral(".tmp");
    QFile f(tmp);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return;
    f.write(QJsonDocument(arr).toJson(QJsonDocument::Compact));
    f.close();

    QFile::remove(target);
    QFile::rename(tmp, target);
}
