# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# Version
VERSION = 0.7.5
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# The name of your application
TARGET = harbour-quick-launch

CONFIG += sailfishapp

SOURCES += \
    src/app-list-filter-model.cpp \
    src/app-list-model.cpp \
    src/file-desktop/file-desktop.cpp \
    src/file-desktop/parser.cpp \
    src/quick-launcher.cpp

DISTFILES += qml/QuickLauncher.qml \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-quick-launch.changes.in \
    rpm/harbour-quick-launch.changes.run.in \
    rpm/harbour-quick-launch.spec \
    rpm/harbour-quick-launch.yaml \
    translations/*.ts \
    harbour-quick-launch.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-quick-launch-de.ts

HEADERS += src/app-list-model.h \
    src/app-list-filter-model.h \
    src/file-desktop/file-desktop.h \
    src/file-desktop/parser.h

RESOURCES += \
    resources.qrc
