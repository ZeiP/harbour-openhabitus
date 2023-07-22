import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: settingspage

    SilicaFlickable {
        anchors.fill: parent
        Column {
            anchors.fill: parent
            DialogHeader {
                acceptText: qsTr("Save")
            }
            TextField {
                id: baseUrlField
                width: parent.width
                label: qsTr("OpenHAB base URL")
                placeholderText: qsTr("OpenHAB base URL")
                text: settings.base_url
                focus: true
                inputMethodHints: Qt.ImhUrlCharactersOnly

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: focus = false
            }
            TextSwitch {
                id: noRemorse
                checked: settings.no_remorse
                text: qsTr("Don't use remorse when sending commands")
                description: qsTr("If selected, no remorse timer will be used when commands are sent")
            }
            TextSwitch {
                id: noSuccessNotifications
                checked: settings.no_success_notifications
                text: qsTr("Don't issue success notifications")
                description: qsTr("If selected, notifications aren't issued when a value is set")
            }
        }
        VerticalScrollDecorator {}
    }
    onDone: {
        if (result == DialogResult.Accepted) {
            settings.base_url = baseUrlField.text
            settings.no_remorse = noRemorse.checked
            settings.no_success_notifications = noSuccessNotifications.checked
        }
    }
}
