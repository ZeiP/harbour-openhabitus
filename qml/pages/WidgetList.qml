import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel { id: widgetList }

    property string widgetPageName;

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    getWidgetsFromSitemap();
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Scroll to top")
                onClicked: view.scrollToTop()
            }
        }

        width: parent.width;
        height: parent.height

        SilicaListView {
            id: view

            header: PageHeader {
                title: widgetPageName
            }

            ViewPlaceholder {
                enabled: widgetList.count == 0
                text: qsTr("No widgets")
            }

            width: parent.width
            height: parent.height
            model: widgetList
            delegate: ListItem {
                id: listItem
                width: ListView.view.width
                contentHeight: Theme.itemSizeSmall
                ListView.onRemove: animateRemoval(listItem)
                menu: contextMenu

                function setValue(value) {
                    remorseAction(qsTr("Setting value to %1").arg(value), function() {
                        var item = view.model.get(index);
                        setWidgetValue(item.link, value, messageNotification);
                    })
                }

                function toggle() {
                    remorseAction(qsTr("Toggling the state"), function() {
                        var item = view.model.get(index);
                        toggleWidget(item.link, item.widgetState, messageNotification);
                    })
                }

                Label {
                    id: label
                    text: name
                }
                Label {
                    anchors.top: label.bottom
                    anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeSmall
                    text: widgetState
                }

                Component {
                    id: contextMenu
                    ContextMenu {
                        Repeater {
                            model: mappings
                            MenuItem {
                                text: label
                                onClicked: setValue(command)
                            }
                        }
                    }
                }

            }
            Component.onCompleted: {
                getWidgetsFromSitemap();
            }
        }
    }

    function getWidgetsFromSitemap() {
        request("rest/sitemaps", "get", "", function(doc) {
            var sitemapUrl = JSON.parse(doc.responseText)[0].homepage.link;
            console.log(sitemapUrl);
            widgetList.clear();
            request(sitemapUrl, "get", "", function(doc) {
                var json = JSON.parse(doc.responseText);
                widgetPageName = json.title;
                var e = json.widgets;
                widgetList.clear();
                for(var i = 0; i < e.length; i++) {
                    var tl = e[i];

                    // Only handle switches for now.
                    if (tl.type != "Switch") {
                        continue;
                    }

                    var item = {}
                    item.name = tl.label;
                    item.type = tl.type;
                    item.link = tl.item.link;
                    item.widgetState = tl.item.state;
                    item.mappings = tl.mappings;
    //                console.log(JSON.stringify(item.mappings));
                    if (item.mappings.length == 0) {
                        if (item.widgetState == "ON") {
                            item.mappings = [ {label: "OFF", command: "OFF"} ];
                        }
                        else {
                            item.mappings = [ {label: "ON", command: "ON"} ];
                        }
                    }

                    widgetList.append(item);
                }
            });
        });
    }

    function setWidgetValue(link, state) {
//        requestPut(link + "/state", "put", state, function(doc) {
        requestPut(link, "post", state, function(doc) {
            console.log(doc.status);
            var m = messageNotification.createObject(null);
            if (doc.status === 200 || doc.status === 202) {
                m.body = qsTr("Widget status successfully set to %1.").arg(state);
                m.summary = qsTr("Widget status toggled")
            }
            else {
                m.body = qsTr("Widget status not set to %1.").arg(state);
                m.summary = qsTr("Widget status toggle fail")
            }
            m.previewSummary = m.summary
            m.previewBody = m.body
            m.publish()
            getWidgetsFromSitemap()
        }, messageNotification);
    }

}
