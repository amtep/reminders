import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Dialog {
    id: detailpage

    property bool isNew
    property Item delegate   // not used if isNew

    property alias title: titlefield.text
    property alias description: descfield.text
    property alias dueDate: datefield.date

    onAccepted: {
        var item = {
            "title": title,
            "description": description,
            "dueDate": dueDate,
            "logic": logicfield.currentItem.logic,
            "logicValue": logicfield.currentItem.logicValue
        }
        if (isNew)
            db.newReminder(item)
        else
            db.editReminder(delegate.index, item)
    }

    Component.onCompleted: {
        if (!isNew) {
            var item = db.model.get(delegate.index)
            title = item.title
            description = item.description
            dueDate = item.dueDate
            logicfield.setLogic(item.logic, item.logicValue)
        }
    }

    Connections {
        target: delegate
        ListView.onRemove: itempage.close()
    }

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: column

            property int afterDays: 4
            property int weekDay
            property int monthDay

            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                title: qsTr("Details")
            }
            TextField {
                id: titlefield
                placeholderText: qsTr("Reminder", "title")
                label: qsTr("Title")
                font.pixelSize: Theme.fontSizeLarge
            }
            ComboBox {
                id: logicfield

                //: This is the label for a combobox that continues
                //: with values like "daily", "after X days", "on weekday"
                label: qsTr("Return", "logic")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("every day", "logic")
                        property string logic: "recur"
                        property int logicValue: 1
                    }
                    MenuItem {
                        text: qsTr("after %n days", "logic", logicValue)
                        property string logic: "recur"
                        property int logicValue: column.afterDays
                    }
                    MenuItem {
                        text: qsTr("every week", "logic")
                        property string logic: "weekly"
                        property int logicValue: column.weekDay
                    }
                    MenuItem {
                        text: qsTr("every month", "logic")
                        property string logic: "monthly"
                        property int logicValue: column.monthDay
                    }
                }

                function setLogic(logic, value) {
                    if (logic == "recur" && value == 1) {
                        currentIndex = 0
                    } else if (logic == "recur") {
                        afterDays = value
                        currentIndex = 1
                    } else if (logic == "weekly") {
                        weekDay = value
                        currentIndex = 2
                    } else if (logic == "monthly") {
                        monthDay = value
                        currentIndex = 3
                    }
                }
            }
            Item {
                id: logicvalueselector
                visible: logicfield.currentIndex > 0

                TextField {
                    visible: logicfield.currentIndex == 1
                    label: qsTr("days", "label")
                    validator: IntValidator { bottom: 1 }
                    onTextChanged: {
                        if (acceptableInput)
                            afterDays = parseInt(text, 10)
                    }
                }
                ComboBox {
                    visible: logicfield.currentIndex == 2
                    menu: ContextMenu {
                        MenuItem { text: qsTr("on Sunday") }
                        MenuItem { text: qsTr("on Monday") }
                        MenuItem { text: qsTr("on Tuesday") }
                        MenuItem { text: qsTr("on Wednesday") }
                        MenuItem { text: qsTr("on Thursday") }
                        MenuItem { text: qsTr("on Friday") }
                        MenuItem { text: qsTr("on Saturday") }
                    }
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0)
                            weekDay = currentIndex
                    }
                }
                ComboBox {
                    visible: logicfield.currentIndex == 3
                    menu: ContextMenu {
                        MenuItem { text: qsTr("on the 1st") }
                        MenuItem { text: qsTr("on the 2nd") }
                        MenuItem { text: qsTr("on the 3rd") }
                        MenuItem { text: qsTr("on the 4th") }
                        MenuItem { text: qsTr("on the 5th") }
                        MenuItem { text: qsTr("on the 6th") }
                        MenuItem { text: qsTr("on the 7th") }
                        MenuItem { text: qsTr("on the 8th") }
                        MenuItem { text: qsTr("on the 9th") }
                        MenuItem { text: qsTr("on the 10th") }
                        MenuItem { text: qsTr("on the 11th") }
                        MenuItem { text: qsTr("on the 12th") }
                        MenuItem { text: qsTr("on the 13th") }
                        MenuItem { text: qsTr("on the 14th") }
                        MenuItem { text: qsTr("on the 15th") }
                        MenuItem { text: qsTr("on the 16th") }
                        MenuItem { text: qsTr("on the 17th") }
                        MenuItem { text: qsTr("on the 18th") }
                        MenuItem { text: qsTr("on the 19th") }
                        MenuItem { text: qsTr("on the 20th") }
                        MenuItem { text: qsTr("on the 21st") }
                        MenuItem { text: qsTr("on the 22nd") }
                        MenuItem { text: qsTr("on the 23rd") }
                        MenuItem { text: qsTr("on the 24th") }
                        MenuItem { text: qsTr("on the 25th") }
                        MenuItem { text: qsTr("on the 26th") }
                        MenuItem { text: qsTr("on the 27th") }
                        MenuItem { text: qsTr("on the 28th") }
                        MenuItem { text: qsTr("on the 29th") }
                        MenuItem { text: qsTr("on the 30th") }
                        MenuItem { text: qsTr("on the 31st") }
                    }
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0)
                            monthDay = currentIndex + 1
                    }
                }
            }
            TextArea {
                id: descfield
                placeholderText: qsTr("Further description", "placeholder")
                font.pixelSize: Theme.fontSizeMedium
            }
            Item {
                Label { text: qsTr("Next due date:") }
                DatePicker { id: datefield }
            }
        }
        VerticalScrollDecorator {}
    }
}
