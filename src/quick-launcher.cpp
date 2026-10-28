#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QCoreApplication>
#include <QQuickView>
#include <QGuiApplication>
#include <sailfishapp.h>
#include <iostream>

#include "app-list-model.h"
#include "app-list-filter-model.h"
#include "file-desktop/file-desktop.h"
#include "launch-history.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/QuickLauncher.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QCoreApplication::setApplicationVersion(APP_VERSION);

    qmlRegisterType<AppListModel>("es.jaumesingla", 1, 0, "AppListModel");
    // qmlRegisterType<FileDesktop::FileDesktopListModel>("es.jaumesingla", 1, 0, "FileDesktopModel");
    qmlRegisterType<AppListFilterModel>("es.jaumesingla", 1, 0, "AppListFilterModel");

    qmlRegisterSingletonType<LaunchHistory>("es.jaumesingla",
                                                       1,
                                                       0,
                                                       "LaunchHistory",
                                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                Q_UNUSED(engine)
                Q_UNUSED(scriptEngine)
                return LaunchHistory::instance();
            });

    qmlRegisterSingletonType<AppListModel>("es.jaumesingla",
                                                       1,
                                                       0,
                                                       "appDb",
                                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {

                Q_UNUSED(engine)
                Q_UNUSED(scriptEngine)

                auto db = new AppListModel;

                return db;
            });

    // return SailfishApp::main(argc, argv);
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());



    // Start the application.
    v->setSource(SailfishApp::pathTo("qml/QuickLauncher.qml"));
    v->show();


    return app->exec();
}
