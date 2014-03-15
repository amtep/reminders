import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Dialog {
    id: itempage

    property Item delegate

    onAccepted: db.markItemDone(delegate.index)

    Connections {
        target: delegate
        ListView.onRemove: itempage.close()
    }

    SilicaFlickable {
        anchors.fill: parent

        // The PullDownMenu doesn't work if contentHeight is left implicit.
        // It also doesn't work if contentHeight ends up equal to the
        // page height, so add some padding.
        contentHeight: column.y + column.height

        PullDownMenu {
            id: pullmenu
            MenuItem {
                text: qsTr("Delete", "menu")
                onClicked: deleteAnimation.restart()
                SequentialAnimation {
                    id: deleteAnimation
                    FadeAnimation {
                        target: itempage
                        to: 0
                    }
                    ScriptAction {
                        script: {
                            mainpage.showAndDeleteItem(delegate.index)
                            pageStack.pop(null, true)
                        }
                    }
                }
            }
            MenuItem {
                text: qsTr("Edit", "menu")
                onClicked: pageStack.push(DetailPage, { delegate: delegate })
            }
        }

        Column {
            id: column

            width: parent.width
            spacing: theme.paddingMedium

            DialogHeader {
                title: qsTr("Reminder")
                acceptText: qsTr("Done")
            }
            Label {
                id: titleLabel

                text: delegate.title
                font.pixelSize: Theme.fontSizeLarge
            }
            Label {
                text: qsTr("Due: ") + duecalc.text

                DueCalc { id: duecalc; dueDate: delegate.dueDate }
            }
            Label {
                id: descLabel
                width: parent.width

                text: delegate.description
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                text: qsTr("History")
            }
            ColumnView {
                model: db.historyModel(delegate.index)
                delegate: Label {
                    text: model.doneDate
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
