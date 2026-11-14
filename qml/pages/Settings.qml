import QtQuick 2.0
import Sailfish.Silica 1.0

import es.jaumesingla 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    // Only components verified to exist in this Silica (see HANDOFF.md
    // white-screen rule): PageHeader, Label, Switch, SilicaFlickable.
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: 0

            PageHeader {
                title: qsTr("Settings")
            }

            Row {
                id: closeRow
                width: parent.width
                height: Theme.itemSizeLarge * 1.6
                focus: false

                Column {
                    id: closeLabels
                    width: parent.width - toggleSwitch.width
                            - 3 * Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall

                    Label {
                        width: parent.width
                        elide: Text.ElideRight
                        text: qsTr("Close after launching")
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: qsTr("Quit QuickLaunch instead of minimizing it after an app has been launched.")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Switch {
                    id: toggleSwitch
                    x: parent.width - width - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    checked: QuickLaunchSettings.closeAfterLaunch
                    onCheckedChanged: QuickLaunchSettings.closeAfterLaunch = checked
                }
            }
        }
    }
}
