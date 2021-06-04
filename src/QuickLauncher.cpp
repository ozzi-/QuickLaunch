#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <iostream>

#include "app-list-model.h"


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

    qmlRegisterType<AppListModel>("es.jaumesingla", 1, 0, "AppListModel");

    // return SailfishApp::main(argc, argv);
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());

    // Start the application.
    v->setSource(SailfishApp::pathTo("qml/QuickLauncher.qml"));
    v->show();


    return app->exec();
}
