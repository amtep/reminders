TARGET = harbour-reminders

QT -= gui
QT -= core

qml.files = qml
desktop.files = harbour-reminders.desktop
icon.files = harbour-reminders.png
OTHER_FILES = rpm/$$TARGET.spec

isEmpty(PREFIX):PREFIX=/opt/sdk

qml.path = $$PREFIX/share/$$TARGET
desktop.path = $$PREFIX/share/applications
icon.path = $$PREFIX/share/icons/hicolor/86x86/apps

INSTALLS += qml desktop icon

# Is there no other way to stop qmake from trying to compile $TARGET ?
QMAKE_LINK = true
