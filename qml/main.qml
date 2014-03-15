import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow
{
    id: app
    initialPage: Component { MainPage { id: mainpage } }
    cover: Qt.resolvedUrl("CoverPage.qml")
    _defaultPageOrientations: Orientation.Portrait | Orientation.Landscape

    Component {
        id: db
        ReminderDB { }
    }
}
