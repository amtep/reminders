import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

CoverBackground {

    CoverPlaceholder {
        //: Coverpage text when db is empty
        text: qsTr("Reminders", "cover")
        icon.source: "file:///usr/share/icons/hicolor/86x86/apps/harbour-reminders.png"
        visible: !db || db.model.count == 0
    }

    GridView {
        id: coverview

        anchors.fill: parent
        anchors.margins: Theme.paddingLarge
        visible: db && db.model.count > 0
        clip: true

        model: db.model
        interactive: false

        delegate: Label {
            width: coverview.width
            height: coverview.height

            font.pixelSize: Theme.fontSizeMedium

            text: model.title
        }

        function goPrevious() {
            if (currentIndex + 1 < model.count)
                currentIndex += 1
            else
                currentIndex = 0
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: coverview.goPrevious()
        }
        CoverAction {
            iconSource: "image://theme/icon-l-check"
            onTriggered: db.markItemDone(coverview.currentIndex)
        }
    }
}
