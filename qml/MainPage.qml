import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    function showAndDeleteItem(index) {
        // This is needed both for UI (the user should see the remorse item)
        // and to make sure the delegate exists.
        view.positionViewAtIndex(index, ListView.Contain)
        // Set currentIndex in order to find the corresponding currentItem.
        view.currentIndex = index
        view.currentItem.deleteItem()
    }

    SilicaListView {
        id: view

        anchors.fill: parent
        model: db.model

        ViewPlaceholder {
            //: Placeholder text when app is empty
            //: Doubles as a tutorial
            text: qsTr("Pull down to create a repeating reminder")
            enabled: view.count == 0
        }

        delegate: ReminderListItem {
            id: reminderitem

            onClicked: pageStack.push(itempage, { delegate: reminderitem })

            function deleteItem() {
                //: Remorse item text
                remorseAction(qsTr("Deleting", "remorse"), function() {
                    db.deleteReminder(model.index)
                })
            }
        }

        PullDownMenu {
            MenuItem {
                text: db.filterDueDate
                    ? qsTr("Show All", "menu")
                    : qsTr("Show Today", "menu")
                onClicked: db.filterDueDate = !db.filterDueDate
            }
            MenuItem {
                //: Menu item to create an editing page for a new note
                text: qsTr("New Item", "menu")
                onClicked: pageStack.push(detailpage, { isNew: true })
            }
        }
    }

    Component {
        id: itempage
        ItemPage { }
    }

    Component {
        id: detailpage
        DetailPage { }
    }
}
