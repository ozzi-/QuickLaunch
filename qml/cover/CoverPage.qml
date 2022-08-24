import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    function _activatePage(name, callback) {
            var namelength = name.length
            const pageOnStack = pageStack.find(function(p) {
                return p.toString().substr(0, namelength) === name
            })
            if (pageOnStack) {
                if (callback) {
                    callback(pageOnStack)
                }
                pageStack.pop(pageOnStack, PageStackAction.Immediate)
            } else {
                pageStack.push(Qt.resolvedUrl("../pages/%1.qml".arg(name)), {}, PageStackAction.Immediate)
            }
            __silica_applicationwindow_instance.activate()
        }

    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("QuickLauncher")
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: _activatePage("SearchPage")
        }

    }
}
