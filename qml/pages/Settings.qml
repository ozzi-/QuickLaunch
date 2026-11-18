import QtQuick 2.0
import Sailfish.Silica 1.0

import es.jaumesingla 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    // Page edge margin. Theme.horizontalPageMargin is what Silica prescribes,
    // but on this phone it renders close to the edge — enforce a comfortable
    // minimum (user-reported, 1.5.0-3/4).
    readonly property real pageMargin: Math.max(Theme.horizontalPageMargin, 28)

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
                    x: page.pageMargin
                    width: parent.width - x - toggleSwitch.width
                            - page.pageMargin
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
                    x: parent.width - width - page.pageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    checked: QuickLaunchSettings.closeAfterLaunch
                    onCheckedChanged: QuickLaunchSettings.closeAfterLaunch = checked
                }

                // Whole row is the tap target (this Silica has no
                // SilicaSwitchRow — see HANDOFF.md white-screen rule).
                // Declared last, so it sits on top and also covers the
                // Switch itself; tapping anywhere on the row toggles.
                MouseArea {
                    anchors.fill: parent
                    focus: false
                    onClicked: toggleSwitch.checked = !toggleSwitch.checked
                }
            }
        }
    }
}
