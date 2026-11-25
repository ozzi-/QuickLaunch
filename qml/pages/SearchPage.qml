import QtQuick 2.0
import QtQuick.Window 2.0
import Sailfish.Silica 1.0
import org.nemomobile.lipstick 0.1

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString

    // True right after a filter tap: the focus loss that follows is
    // USER-INTENDED (the keyboard is meant to close and STAY closed) — the
    // watcher must not re-grab. Consumed by the watcher; reset on every
    // page/app (re)activation so it can never leak into a later session.
    property bool suppressRegrab: false

    // ------------------------------------------------------------------
    // Focus + keyboard — VERIFIED ON THE PHONE (dbg.log traces, 1.4.0-4):
    //
    //  * SFOS shows the keyboard while the field holds *active* focus.
    //  * On re-activation the fullscreen transition dismisses the keyboard
    //    ~0.9–2.9 s AFTER app-active, clearing active focus again.
    //  * CRITICAL (measured): a re-grab of active focus that arrives
    //    IMMEDIATELY after such a loss is SILENTLY SWALLOWED by Ibis —
    //    activeFocus is restored (zero failed retries in the traces) but the
    //    keyboard stays hidden. A re-grab DELAYED ~250 ms (Ibis's hide has
    //    settled) is what actually brings the keyboard back. => NEVER
    //    re-grab synchronously; always go through the delayed path.
    //  * Tapping a filter steals the focus ~12 ms after the click (something
    //    above the focus:false cluster). Per user decision the keyboard then
    //    closes and STAYS closed (no flicker) => suppressRegrab.
    //  * Qt.application.active is the authoritative SFOS activation signal
    //    (Silica binds applicationActive to it).
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
        onTriggered: startFocusRetries()
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

    // Tile -> fullscreen reopen fix (2026-11):
    //
    // When the app sits in the home-screen tile for a while, it reopens with
    // the field STILL HOLDING activeFocus while the keyboard is hidden (Ibis
    // dismissed it in the background). None of the usual triggers fire in
    // that state: Qt.application.active already was true (no activeChanged),
    // the page is already Active (no statusChanged), and no focus LOSS
    // happens (no watcher fire). So nothing asks for the keyboard.
    //
    // The one reliable signal for the tile -> fullscreen transition is the
    // WINDOW GEOMETRY changing from small (tile) to large (fullscreen).
    // When we detect that, the keyboard is hidden while focus is held — the
    // state the plain grabFocus() cannot fix. Cure = the only phone-verified
    // path: drop the focus (keyboard hidden either way) and re-grab DELAYED
    // ~250 ms, so Ibis sees a fresh acquisition instead of an immediate
    // (swallowed) re-grab.
    function refreshKeyboard(){
        if (!searchField.activeFocus)
            return   // focus already lost -> the watcher/normal path handles it
        searchField.activeFocus = false
        focusDelay.restart()
    }

    // Window size tracking: distinguishes tile<->fullscreen transitions
    // (small <-> large) from in-foreground events like rotation (large ->
    // large), which must not disturb the keyboard.
    property real lastWinArea: 0
    function isFullArea(w, h){
        return w * h >= (Screen.width * Screen.height) / 2
    }
    Connections {
        target: window
        onGeometryChanged: {
            const nowLarge = isFullArea(window.width, window.height)
            const wasSmall = lastWinArea > 0
                             && lastWinArea < (Screen.width * Screen.height) / 2
            lastWinArea = window.width * window.height
            if (nowLarge && wasSmall && searchPage.status === PageStatus.Active)
                refreshKeyboard()
        }
    }

    // Page became active (app opened, back from About). Fresh start: the
    // keyboard is wanted, so allow re-grabs (clear any stale suppression).
    onStatusChanged: {
        if (status === PageStatus.Active) {
            suppressRegrab = false
            requestKeyboard()
        }
    }

    // App re-activated (returned from a launched app / minimize + reopen).
    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active && searchPage.status === PageStatus.Active) {
                suppressRegrab = false
                requestKeyboard()
            }
        }
    }

    // If the field loses active focus while on-page with the app in the
    // foreground, re-grab it — but ONLY via the proven DELAYED path (Ibis
    // swallows an immediate re-grab; ~250 ms later it lands). This is what
    // brings the keyboard back after the minimize/reopen transition dismiss.
    // A focus loss right after a filter tap is user-intended (the keyboard
    // closes by design) and is consumed via suppressRegrab.
    Connections {
        target: searchField
        onActiveFocusChanged: {
            if (!searchField.activeFocus
                && searchPage.status === PageStatus.Active
                && Qt.application.active) {
                if (suppressRegrab)
                    suppressRegrab = false
                else
                    requestKeyboard()
            }
        }
    }

    // Hiding the filter bar (Settings) must also reset the search UI:
    // otherwise the list stays silently filtered (e.g. "Android" or a
    // leftover search text) with no bar left to change it back.
    Connections {
        target: QuickLaunchSettings
        onShowFilterBarChanged: {
            if (!QuickLaunchSettings.showFilterBar) {
                filterModel.filterMode = 0
                searchField.text = ""
            }
        }
    }

    // ------------------------------------------------------------------
    // "Close after launch" — PAGE-LEVEL close sequence.
    //
    // In v1.5/v1.6 these timers lived inside the list delegate. Launching
    // an app records it in the Recent history, which does a full model
    // reset — and item views recycle delegates on resets, so a close timer
    // living in the clicked delegate can be destroyed mid-flight and the
    // app never quits (the reported "launching an Android app leaves
    // QuickLaunch open" failure). At page level the sequence is immune to
    // delegate recycling and to any model churn.
    //
    // FAST PATH: quit as soon as lipstick has DISPATCHED the launch —
    // LauncherItem::launchWithArguments() sets isLaunching=true right
    // after the ContentAction trigger (sailfishos/lipstick
    // src/components/launcheritem.cpp), so once it is true our exit can
    // no longer abort the target app.
    //
    // HARD GUARANTEE: no matter what happens (launch error, property
    // missing, delegate gone), the 3 s cap below quits the app.
    property var closeTarget: null

    Timer {
        id: closeWait
        interval: 200
        repeat: true
        running: false
        property int ticks: 0
        onTriggered: {
            ticks++
            var launching = false
            try {
                if (closeTarget)
                    launching = closeTarget.isLaunching
            } catch (err) {
                launching = false   // launcher object gone — the cap still quits
            }
            if (ticks === 1 || launching === true || ticks >= 15)
                QuickLaunchSettings.dbgLog("closeWait tick " + ticks
                                            + " isLaunching=" + String(launching))
            if (launching === true) {
                stop()
                closeQuit.start()
            } else if (ticks >= 15) {
                // Hard cap (3 s after the click): quit no matter what.
                stop()
                closeQuit.start()
            }
        }
    }

    Timer {
        id: closeQuit
        interval: 300
        running: false
        onTriggered: {
            QuickLaunchSettings.dbgLog("closeQuit -> Qt.quit()")
            Qt.quit()
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
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
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
            // KEYBOARD: in Qt Quick EVERY item is focus: true by default, and
            // a press parks the active focus on the pressed item or its nearest
            // focusable ancestor, so every item in this cluster is focus:
            // false (all core QtQuick 2.0 — Qt 5.6 safe). Tapping a filter
            // still steals the focus (~12 ms after the click) and closes the
            // keyboard — that is the DESIRED behavior (no flicker); the
            // suppressRegrab flag keeps the watcher from re-grabbing it.
            Row {
                id: typeFilter

                // Settings -> "Show filter bar" (default on). Invisible
                // children are skipped by the enclosing Column layout, so
                // the list simply starts higher when hidden.
                visible: QuickLaunchSettings.showFilterBar

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
                        onClicked: {
                            filterModel.filterMode = 0
                            suppressRegrab = true   // keyboard closes by design
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
                        onClicked: {
                            filterModel.filterMode = 1
                            suppressRegrab = true   // keyboard closes by design
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
                        onClicked: {
                            filterModel.filterMode = 2
                            suppressRegrab = true   // keyboard closes by design
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
                        onClicked: {
                            filterModel.filterMode = 3
                            suppressRegrab = true   // keyboard closes by design
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

                    // Close-after-launch: hand the page-level sequence this
                    // row's launcher, then request the launch. try/catch:
                    // a dispatch error must never stop the close sequence —
                    // the setting means "close after I clicked".
                    closeTarget = launcher
                    try {
                        launcher.launchApplication()
                    } catch (err) {
                        QuickLaunchSettings.dbgLog("launchApplication(" + path
                                                    + ") threw: " + err.toString())
                    }

                    if (QuickLaunchSettings.closeAfterLaunch) {
                        // Do NOT reset the UI (search text / list state):
                        // the app is about to quit, and the reset's model
                        // churn races the close sequence.
                        QuickLaunchSettings.dbgLog("close-sequence start: " + path)
                        closeWait.ticks = 0
                        closeWait.restart()
                    } else {
                        // Reset to the original state: empty search, full list.
                        searchField.text = ""
                        __silica_applicationwindow_instance.deactivate()
                        // (Focus + keyboard are re-grabbed automatically when
                        //  the user comes back.)
                    }
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

