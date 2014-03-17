TARGET = harbour-reminders

QT -= gui
QT -= core

qml.files = qml
desktop.files = $$TARGET.desktop
icon.files = $TARGET.png
OTHER_FILES = rpm/$$TARGET.spec

isEmpty(PREFIX):PREFIX=/opt/sdk

target.path = $$PREFIX/bin
qml.path = $$PREFIX/share/$$TARGET
desktop.path = $$PREFIX/share/applications
icon.path = $$PREFIX/share/icons/hicolor/86x86/apps

INSTALLS += target qml desktop icon
