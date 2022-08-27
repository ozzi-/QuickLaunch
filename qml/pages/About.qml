import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("About")
            }
            Image {
                id: logo
                source: "qrc:///icons/logo"
                smooth: true
                height: parent.width / 2
                width: parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.7
            }
            Label {
                x : Theme.horizontalPageMargin
                width: parent.width - 2*x

                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.secondaryHighlightColor

                text: "QuickLauncher"
            }

            Label {
                x : Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: Qt.application.version
            }

            Item {
               height: Theme.paddingMedium
               width: 1
           }

           Label {
               x : Theme.horizontalPageMargin
               width: parent.width - 2*x
               wrapMode: Text.WordWrap
               font.pixelSize: Theme.fontSizeSmall

               text: qsTr("QuickLauncher is an application search and launcher")
           }

           SectionHeader{
               text: qsTr("Sources")
           }

           BackgroundItem{
               width: parent.width
               height: Theme.itemSizeMedium
               Row{
                   x : Theme.horizontalPageMargin
                   width: parent.width - 2*x
                   height: parent.height
                   spacing:Theme.paddingMedium

                   Image {
                       width: parent.height
                       height: width
                       fillMode: Image.PreserveAspectFit
                       anchors.verticalCenter: parent.verticalCenter
                       source: "qrc:///icons/git"
                   }

                   Label{
                       width: parent.width - parent.height - parent.spacing
                       anchors.verticalCenter: parent.verticalCenter
                       wrapMode: Text.WrapAnywhere
                       font.pixelSize: Theme.fontSizeSmall

                       text: "https://gitlab.com/dracks/quicklaunchslx/"
                       color: parent.parent.pressed ? Theme.highlightColor : Theme.primaryColor

                   }
               }
               onClicked: Qt.openUrlExternally("https://gitlab.com/dracks/quicklaunchslx/")
           }
        }
    }
}
