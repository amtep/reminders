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
                onClicked: pageStack.push(detailpage, { delegate: delegate })
            }
        }

        DialogHeader {
            id: header
            title: qsTr("Done")
        }

        Column {
            id: column

            anchors.top: header.bottom
            width: parent.width
            spacing: Theme.paddingMedium

            Label {
                id: titleLabel

                text: db.model.get(delegate.index).title
                font.pixelSize: Theme.fontSizeLarge
            }
            Label {
                text: qsTr("Due: ") + duecalc.text

                DueCalc {
                    id: duecalc
                    dueDate: db.model.get(delegate.index).dueDate
                }
            }
            Label {
                id: descLabel
                width: parent.width

                text: db.model.get(delegate.index).description
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                id: historylabel
                text: qsTr("History")
            }
            ColumnView {
                model: db.historyModel(delegate.index)
                itemHeight: historylabel.height
                delegate: Label {
                    text: model.doneDate
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        VerticalScrollDecorator {}
    }

    Component {
        id: detailpage
        DetailPage { }
    }
}
