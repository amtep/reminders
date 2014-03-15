import QtQuick 2.0
import Sailfish.Silica 1.0

// This just encapsulates some logic for displaying due dates

Item {
    property date dueDate

    // casting to a date-typed property instead of using Date() directly
    // to make sure we are comparing QDate objects and not QDateTime
    property date today: new Date()
    property int days: today - dueDate

    // qsTr will look up the right plural form to use
    property string text: days > 1 ? qsTr("%n day(s) ago", "", days)
          : days == 0 ? qsTr("today")
          : qsTr("in %n day(s)", "", days)
}
