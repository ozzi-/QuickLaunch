import QtQuick 2.0
import Sailfish.Silica 1.0

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString
    // property Timer delayTimer

    onSearchStringChanged: delayTimer.restart()

    function filterDelayed(){
        /*if (!delayTimer){
            delayTimer = new Timer()
            delayTimer.interval = 3000
            delayTimer.repeat = false
            delayTimer.triggered.connect(function (){
                dModel.filter(searchString)
            })
        }*/

        delayTimer.restart()
    }


    Timer {
        id: delayTimer
        interval: 1000
        repeat: false
        onTriggered: dmodel.filter(searchString)
    }


    function reset() {
            //% "Search results will be shown here"
            // viewPlaceholder.text = qsTrId("orn-searchpage-placeholder-default")
            //% "Type some keywords in the field above"
            // viewPlaceholder.hintText = qsTrId("orn-searchpage-placeholder-default-hint")
            view.headerContainer.searchField.forceActiveFocus()
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            view.headerContainer.searchField.forceActiveFocus()
        }
    }

    Column {
        id: headerContainer

        width: searchPage.width

        PageHeader {
            title: "Applications"
        }

        SearchField {
            id: searchField
            width: parent.width

            Binding {
                target: searchPage
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }

    SilicaListView {
        id: view

        anchors.fill: parent

        model: AppListModel {
            id: dmodel
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }


        header: Item {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }

        delegate: ListItem {

            Image {
                id: appIcon
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.iconSizeLauncher
                height: Theme.iconSizeLauncher
                fillMode: Image.PreserveAspectFit
                source: icon
            }
            Item {
                anchors {
                    left: appIcon.right
                    leftMargin: Theme.paddingMedium
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    // x: appIcon.right

                    text: name

                }
            }

            onClicked: dmodel.execute(index)
        }
    }

}

