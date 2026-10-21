import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.lipstick 0.1

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString

    function activateFocus(){
        searchField.selectAll()
        searchField.forceActiveFocus()
    }

    Timer {
        id: timeout
        interval: 1000
        running: false
        onTriggered: activateFocus()
    }

    // On first open the page reports PageStatus.Active before the window is
    // fully visible, so forceActiveFocus() silently fails. Retry on a fixed
    // schedule (checking each tick) until the field really has focus, so the
    // user can type right away.
    property bool focusLocked: false
    Timer {
        id: initialFocus
        property int ticks: 0
        interval: 200
        running: searchPage.status === PageStatus.Active && !searchPage.focusLocked
        repeat: true
        onTriggered: {
            if (searchPage.focusLocked)
                stop()
            searchField.forceActiveFocus()
            if (searchField.activeFocus) {
                searchPage.focusLocked = true
                stop()
            } else {
                ticks++
                if (ticks >= 15) {   // give up after ~3 s; the user can tap the field
                    searchPage.focusLocked = true
                    stop()
                }
            }
        }
    }

    onStatusChanged: {
        console.log(status)
        if (status === PageStatus.Active){
            activateFocus()
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
                activateFocus()
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
                    // filterModel.execute(appId);
                    launcher.launchApplication()
                    // Reset to the original state: empty search, full list
                    searchField.text = ""
                    __silica_applicationwindow_instance.deactivate()
                    timeout.restart()
                    // timeout.start()
                    // activateFocus()
                    // pageStack.push(Qt.resolvedUrl("LaunchPage.qml"), { appIcon: icon, appName: name})
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
        }
    }

}

