import QtQuick 2.0
import Sailfish.Silica 1.0

import es.jaumesingla 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    // Page edge margin. Theme.horizontalPageMargin is what Silica prescribes,
    // but on this phone it renders close to the edge — enforce a comfortable
    // minimum (user-reported across 1.5.0-3/5: bump 24 → 28 → 40).
    readonly property real pageMargin: Math.max(Theme.horizontalPageMargin, 40)

    // Only components verified to exist in this Silica (see HANDOFF.md
    // white-screen rule): PageHeader, Label, Switch, SilicaFlickable.
    // Everything else is core QtQuick (Row/Column/Rectangle/Text/MouseArea).
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

            // ------------------------------------------------------------
            // Close after launching
            // ------------------------------------------------------------
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

            // ------------------------------------------------------------
            // Recent history — Reset
            // ------------------------------------------------------------
            Row {
                id: historyRow
                width: parent.width
                height: Theme.itemSizeLarge * 1.6
                focus: false

                Column {
                    id: historyLabels
                    x: page.pageMargin
                    width: parent.width - x - resetButton.width
                            - page.pageMargin - Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall

                    Label {
                        width: parent.width
                        elide: Text.ElideRight
                        text: qsTr("Recent history")
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: qsTr("Apps shown in the \"Recent\" filter. Resetting removes the whole list.")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                // "Reset" text button — core QtQuick only (no SilicaButton
                // on this phone, white-screen rule).
                Rectangle {
                    id: resetButton
                    x: parent.width - width - page.pageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: resetText.width + 2 * Theme.paddingMedium
                    height: Theme.itemSizeMedium * 0.9
                    radius: height / 2
                    color: Theme.highlightColor

                    Text {
                        id: resetText
                        anchors.centerIn: parent
                        text: qsTr("Reset")
                        color: "white"
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    MouseArea {
                        anchors.fill: parent
                        focus: false
                        onClicked: {
                            LaunchHistory.clear()
                            // Visual feedback: the "Recent" filter list
                            // updates via LaunchHistory::changed.
                        }
                    }
                }
            }

            // ------------------------------------------------------------
            // Show filter bar (All / Native / Android / Recent)
            // ------------------------------------------------------------
            Row {
                id: filterBarRow
                width: parent.width
                height: Theme.itemSizeLarge * 1.6
                focus: false

                Column {
                    id: filterBarLabels
                    x: page.pageMargin
                    width: parent.width - x - filterToggle.width
                            - page.pageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall

                    Label {
                        width: parent.width
                        elide: Text.ElideRight
                        text: qsTr("Show filter bar")
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: qsTr("Show the All / Native / Android / Recent bar below the search field.")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Switch {
                    id: filterToggle
                    x: parent.width - width - page.pageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    checked: QuickLaunchSettings.showFilterBar
                    onCheckedChanged: QuickLaunchSettings.showFilterBar = checked
                }

                MouseArea {
                    anchors.fill: parent
                    focus: false
                    onClicked: filterToggle.checked = !filterToggle.checked
                }
            }
        }
    }
}
