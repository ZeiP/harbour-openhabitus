import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutpage
    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: mainCol
            spacing: Theme.paddingMedium
            anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
            PageHeader {
                title: qsTr("About")
            }
/*            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../images/ptl.png"
            } */
            Column {
                anchors.left: parent.left; anchors.right: parent.right
                spacing: Theme.paddingSmall
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                    text: qsTr("Openhabitus")
                }
            }
            Label {
                wrapMode: Text.WordWrap
                anchors.left: parent.left; anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Openhabitus is a client application for controlling an OpenHAB-compatible home automation system.")
            }
            Label {
                anchors.left: parent.left; anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("Thanking:") +
"\n" + qsTr("– Jyri-Petteri ”ZeiP” Paloposki (author)")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("GitHub (source codes and issues)")
                onClicked: Qt.openUrlExternally("https://github.com/ZeiP/harbour-openhabitus")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("OpenHAB project")
                onClicked: Qt.openUrlExternally("https://www.openhab.org/")
            }
        }

        VerticalScrollDecorator {}
    }
}
