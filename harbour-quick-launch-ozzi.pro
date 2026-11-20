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
VERSION = 1.7.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# The name of your application
# (renamed for the Chum/OBS publication — the original name is taken by
# the upstream v1.0 package there; see obs/README.md)
TARGET = harbour-quick-launch-ozzi

CONFIG += sailfishapp
QT += core-private

SOURCES += \
    src/app-list-filter-model.cpp \
    src/app-list-model.cpp \
    src/file-desktop/file-desktop.cpp \
    src/file-desktop/parser.cpp \
    src/launch-history.cpp \
    src/quick-launch-settings.cpp \
    src/quick-launcher.cpp

DISTFILES += qml/QuickLauncher.qml \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/LaunchPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/Settings.qml \
    rpm/QuickLauncher.changes.in \
    rpm/QuickLauncher.changes.run.in \
    rpm/harbour-quick-launch-ozzi.spec \
    translations/harbour-quick-launch-ozzi.ts \
    translations/harbour-quick-launch-ozzi-de.ts \
    harbour-quick-launch-ozzi.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-quick-launch-ozzi-de.ts

HEADERS += src/app-list-model.h \
    src/app-list-filter-model.h \
    src/file-desktop/file-desktop.h \
    src/file-desktop/parser.h \
    src/launch-history.h \
    src/quick-launch-settings.h

RESOURCES += \
    resources.qrc
