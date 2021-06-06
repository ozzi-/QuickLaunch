import QtQuick 2.0
import Sailfish.Silica 1.0

import es.jaumesingla 1.0

Page {
    id: searchPage
    property string searchString

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

        delegate: BackgroundItem {
            Label {
                x: Theme.horizontalPageMargin
                text: path
            }
            onClicked: dmodel.activate(index)
        }
    }

}
