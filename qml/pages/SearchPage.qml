import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.lipstick 0.1

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString

    // ------------------------------------------------------------------
    // Focus + keyboard — the mechanism that reliably works on SFOS.
    //
    // On Sailfish OS the keyboard is a separate app (com.jolla.keyboard);
    // the platform shows it whenever a text input holds *active* focus.
    // The lever is forceActiveFocus(), but it silently no-ops until the
    // window is active/visible — a single early call misses.
    //
    // (The regression this replaces branched on the STATIC `focus` property,
    // which is always true, so it only ever did a focus off/on toggle and
    // never actually grabbed active focus — the keyboard showed up nowhere.)
    //
    // So we retry on a short bounded interval and check activeFocus each tick
    // (the approach that worked in v1.3.0). Triggers:
    //   * page activates    -> onStatusChanged (app opened, back from About)
    //   * app re-activates  -> Qt.application.active (returned from a launched
    //     app; the page is still PageStatus.Active so onStatusChanged does not
    //     fire). Qt.application.active is the authoritative SFOS signal —
    //     Silica's own ApplicationWindow binds applicationActive to it.
    Timer {
        id: focusRetry
        interval: 150
        repeat: true
        running: false
        property int count: 0
        onTriggered: {
            grabFocus()
            // Stop once the field really has active focus, or after ~3 s.
            if (searchField.activeFocus || count >= 20)
                stop()
            count++
        }
    }

    function grabFocus(){
        if (searchField.activeFocus) {
            // Already focused but the input panel is hidden (e.g. right after
            // a launch) — the off/on toggle (Messages "Reset keyboard state"
            // idiom) makes the panel reappear.
            searchField.focus = false
            searchField.focus = true
        } else {
            searchField.forceActiveFocus()
        }
    }

    function startFocusRetries(){
        focusRetry.count = 0
        focusRetry.restart()
    }

    onStatusChanged: {
        if (status === PageStatus.Active)
            startFocusRetries()
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active && searchPage.status === PageStatus.Active)
                startFocusRetries()
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
            Row {
                id: typeFilter

                width: parent.width
                height: Theme.itemSizeLarge

                Rectangle {
                    id: segAll
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    color: filterModel.filterMode === 0 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("All")
                        color: filterModel.filterMode === 0 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea { anchors.fill: parent; onClicked: { filterModel.filterMode = 0 } }
                }
                Rectangle {
                    id: segNative
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    color: filterModel.filterMode === 1 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Native")
                        color: filterModel.filterMode === 1 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea { anchors.fill: parent; onClicked: { filterModel.filterMode = 1 } }
                }
                Rectangle {
                    id: segAndroid
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    color: filterModel.filterMode === 2 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Android")
                        color: filterModel.filterMode === 2 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea { anchors.fill: parent; onClicked: { filterModel.filterMode = 2 } }
                }
                Rectangle {
                    id: segRecent
                    width: typeFilter.width / 4
                    height: typeFilter.height
                    color: filterModel.filterMode === 3 ? Theme.highlightColor : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Recent")
                        color: filterModel.filterMode === 3 ? "white" : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    MouseArea { anchors.fill: parent; onClicked: { filterModel.filterMode = 3 } }
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

