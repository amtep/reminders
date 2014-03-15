import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

// This item shows a reminder in the reminder list
ListItem {
    id: reminderitem

    property alias text: remindertext.text
    property alias dueDate: duecalc.dueDate

    contentHeight: remindertext.height + duetext.height

    DueCalc { id: duecalc }

    Label {
        id: remindertext

        anchors.top: parent.top
        height: contentHeight
        width: reminderitem.width

        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        maximumLineCount: 2
    }

    Label {
        id: duetext

        anchors.top: remindertext.bottom
        height: contentHeight
        width: reminderitem.width

        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeSmall
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignRight
        opacity: 0.8

        text: duecalc.text
    }

    OpacityRampEffect {
        sourceItem: remindertext
        slope: 0.8
        offset: 0
        direction: OpacityRamp.LeftToRight
    }
}
