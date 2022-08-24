import QtQuick 2.0
import Sailfish.Silica 1.0

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString

    onStatusChanged: {
        if (status === PageStatus.Active){
            searchField.forceActiveFocus()
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

            PageHeader {
                title: "Applications"
            }

            SearchField {
                id: searchField
                width: parent.width

               onTextChanged: filterModel.setFilterFixedString(text)
               // onFocusChanged: console.log(event)
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

                onClicked: filterModel.execute(appId)

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
                            text: "packageName"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }
        }
    }

}

