import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.lipstick 0.1

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString

    // ------------------------------------------------------------------
    // Focus + keyboard — reliable across open, minimize/reopen, and returning
    // from a launched app.
    //
    // SFOS shows the keyboard whenever the field holds *active* focus. Two
    // things break it (both seen on this phone):
    //   (1) forceActiveFocus() before the window is active/visible is a no-op;
    //   (2) on re-activation the fullscreen transition dismisses the keyboard
    //       *after* the grab — the "keyboard closes right away" bug.
    //
    // Fix (mirrors Jolla's own PinInput / password field):
    //   * grab on a short DELAY so the transition settles first, then retry a
    //     few times until activeFocus really holds;
    //   * re-grab the moment the field *loses* active focus while we're still
    //     on the page with the app in the foreground (defeats the dismiss);
    //   * drive it from page-active and app-active. Qt.application.active is
    //     the authoritative SFOS signal (Silica binds applicationActive to it).
    //
    // Only safe Qt 5.6 Timer APIs are used (interval/running/start/stop/
    // restart/onTriggered) — no stopped/elapsed/progress.
    Timer {
        id: focusRetry
        interval: 120
        repeat: true
        running: false
        property int count: 0
        onTriggered: {
            grabFocus()
            if (!searchField.activeFocus)
                LaunchHistory.dbg("retry#" + count + " still no focus")
            // Stop once the field really has active focus, or after ~3 s.
            if (searchField.activeFocus || count >= 25)
                stop()
            count++
        }
    }

    // Let the re-activation fullscreen transition settle before grabbing.
    Timer {
        id: focusDelay
        interval: 250
        running: false
        onTriggered: {
            LaunchHistory.dbg("delay done -> startFocusRetries")
            startFocusRetries()
        }
    }

    function grabFocus(){
        // forceActiveFocus() is the reliable lever (a focus off/on toggle is
        // not — that was the "keyboard never shows" regression). Re-mark focus
        // too, the way Jolla's PinInput does, so a hidden keyboard returns.
        searchField.focus = true
        searchField.forceActiveFocus()
    }

    function startFocusRetries(){
        focusRetry.count = 0
        focusRetry.restart()
    }

    function requestKeyboard(){
        focusDelay.restart()
    }

    // Page became active (app opened, back from About).
    onStatusChanged: {
        if (status === PageStatus.Active) {
            LaunchHistory.dbg("page active")
            requestKeyboard()
        }
    }

    // App re-activated (returned from a launched app / minimize + reopen).
    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active && searchPage.status === PageStatus.Active) {
                LaunchHistory.dbg("app active")
                requestKeyboard()
            }
        }
    }

    // THE fix for "keyboard closes right away on reopen" AND for the filter-
    // tap flicker: if the field loses active focus while we're on the page with
    // the app in the foreground, grab it back SYNCHRONOUSLY. A delayed re-grab
    // is exactly what made the keyboard visibly close and re-open on filter
    // taps — the field was "unfocused" for the whole delay.
    Connections {
        target: searchField
        onActiveFocusChanged: {
            if (!searchField.activeFocus
                && searchPage.status === PageStatus.Active
                && Qt.application.active) {
                LaunchHistory.dbg("watcher: focus LOST -> immediate re-grab")
                grabFocus()
                startFocusRetries()
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                const pageOnStack = pageStack.find(function (p) {
                    return p === searchPage
                })
                pageStack.pop(pageOnStack, PageStackAction.Immediate)
                __silica_applicationwindow_instance.activate()
                startFocusRetries()
            }
        }

    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About Quick Launch")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        Column {
            id: headerContainer

            width: searchPage.width
            focus: false   // never a focus-parking spot (see filter cluster below)

            SearchField {
                id: searchField
                width: parent.width
                focus: true

               onTextChanged: {
                   if (!searchField.activeFocus){
                       searchField.forceActiveFocus()
                   }

                   filterModel.setFilterFixedString(text)
               }
            }

            // App-type filter (All / Native / Android / Recent). Built from
            // core QtQuick (Row/Rectangle/Text/MouseArea) + Theme only — NO
            // Silica control types, because this Silica build has no
            // SilicaSegmentedControl / SilicaButton (using one caused a white
            // screen at load).
            //
            // KEYBOARD (the flicker fix): in Qt Quick EVERY item is
            // focus: true by default, and a mouse press parks the active focus
            // on the pressed item or its nearest focusable ancestor. One
            // focusable item anywhere in the press path was enough to steal
            // the focus from searchField and close the keyboard. So EVERY item
            // in this cluster is focus: false, and each tap also re-asserts the
            // field's active focus immediately (belt and braces; the
            // focus-loss watcher does the same synchronously if anything
            // ever takes it anyway). All core QtQuick 2.0 — Qt 5.6 safe.
            Row {
                id: typeFilter

                width: parent.width
                height: Theme.itemSizeLarge
                focus: false

                Rectangle {
                    id: segAll
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    focus: false
                    color: filterModel.filterMode === 0 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        focus: false
                        text: qsTr("All")
                        color: filterModel.filterMode === 0 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea {
                        anchors.fill: parent
                        focus: false
                        onPressed: {
                            LaunchHistory.dbg("segAll press")
                            grabFocus()
                        }
                        onClicked: {
                            LaunchHistory.dbg("segAll click")
                            filterModel.filterMode = 0
                            grabFocus()
                        }
                    }
                }
                Rectangle {
                    id: segNative
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    focus: false
                    color: filterModel.filterMode === 1 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        focus: false
                        text: qsTr("Native")
                        color: filterModel.filterMode === 1 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea {
                        anchors.fill: parent
                        focus: false
                        onPressed: {
                            LaunchHistory.dbg("segNative press")
                            grabFocus()
                        }
                        onClicked: {
                            LaunchHistory.dbg("segNative click")
                            filterModel.filterMode = 1
                            grabFocus()
                        }
                    }
                }
                Rectangle {
                    id: segAndroid
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    focus: false
                    color: filterModel.filterMode === 2 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        focus: false
                        text: qsTr("Android")
                        color: filterModel.filterMode === 2 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea {
                        anchors.fill: parent
                        focus: false
                        onPressed: {
                            LaunchHistory.dbg("segAndroid press")
                            grabFocus()
                        }
                        onClicked: {
                            LaunchHistory.dbg("segAndroid click")
                            filterModel.filterMode = 2
                            grabFocus()
                        }
                    }
                }
                Rectangle {
                    id: segRecent
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    focus: false
                    color: filterModel.filterMode === 3 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        focus: false
                        text: qsTr("Recent")
                        color: filterModel.filterMode === 3 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea {
                        anchors.fill: parent
                        focus: false
                        onPressed: {
                            LaunchHistory.dbg("segRecent press")
                            grabFocus()
                        }
                        onClicked: {
                            LaunchHistory.dbg("segRecent click")
                            filterModel.filterMode = 3
                            grabFocus()
                        }
                    }
                }
            }
        }

        SilicaListView {
            id: view

            anchors.fill: parent

            model: AppListFilterModel {
                id: filterModel

                sourceModel: AppListModel{
                    id: appDb
                }
            }

            currentIndex: -1

            header: Item {
                id: header
                width: headerContainer.width
                height: headerContainer.height
                focus: false   // never a focus-parking spot
                Component.onCompleted: headerContainer.parent = header
            }

            delegate: ListItem {
                id: delegate

                width: parent.width
                contentHeight: Theme.itemSizeLarge

                onClicked: function (){
                    // Remember this app for the "Recent" view (persisted,
                    // bounded to 100 entries in C++).
                    LaunchHistory.recordLaunch(path)
                    launcher.launchApplication()
                    // Reset to the original state: empty search, full list.
                    // Focus + keyboard are re-grabbed automatically when the
                    // user comes back (Qt.application.active -> startFocusRetries()).
                    searchField.text = ""
                    __silica_applicationwindow_instance.deactivate()
                }

                LauncherItem {
                    id: launcher
                    filePath: path
                }

                Row {
                    width: parent.width - 2 * x
                    x: Theme.horizontalPageMargin
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: appIcon

                        height: parent.height - 2 * Theme.paddingSmall
                        width: parent.height - 2 * Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter

                        source: icon
                    }
                    Item {
                        id: spacer

                        width:Theme.paddingMedium
                        height:1

                    }
                    Column{
                        id: data

                        width: parent.width - appIcon.width

                        anchors.verticalCenter: appIcon.verticalCenter

                        Label{
                            id: text
                            width: parent.width
                            elide: Text.ElideRight
                            text: name
                            color: pressed ? Theme.secondaryHighlightColor:Theme.highlightColor
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Label{
                            text: command
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

            // Empty-state hint: nothing launched through QuickLaunch yet.
            Label {
                anchors.centerIn: parent
                visible: filterModel.filterMode === 3 && filterModel.count === 0
                text: qsTr("No apps launched yet.\nStart a few and they will show up here.")
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }

}

