import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel { id: widgetList }

    property string widgetPageName;

    property string sitemapUrl: "";

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    getWidgetsFromSitemap(sitemapUrl);
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
                hintText: qsTr("Check your settings")
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
                    if (!settings.no_remorse) {
                        remorseAction(qsTr("Setting value to %1").arg(value), function() {
                            var item = view.model.get(index);
                            if (item.link) {
                                setWidgetValue(item.link, value, messageNotification);
                            }
                        })
                    }
                    else {
                        var item = view.model.get(index);
                        if (item.link) {
                            setWidgetValue(item.link, value, messageNotification);
                        }
                    }
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

                onClicked: {
                    var item = view.model.get(index);
                    if (item.targetSitemap) {
                        pageStack.push(Qt.resolvedUrl("WidgetList.qml"), {sitemapUrl: item.targetSitemap})
                    }
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
                getWidgetsFromSitemap(sitemapUrl);
            }
        }
    }

    function getWidgetsFromSitemap(url) {
        if (url == "") {
            if (rootSitemap == "") {
                request("rest/sitemaps", "get", "", function(doc) {
                    rootSitemap = JSON.parse(doc.responseText)[0].homepage.link;
                    getWidgetsFromSitemap(rootSitemap);
                });
                return;
            }
            url = rootSitemap;
        }
        widgetList.clear();
        console.log(url);
        request(url, "get", "", function(doc) {
            var json = JSON.parse(doc.responseText);
            widgetPageName = json.title;
            var e = json.widgets;
            widgetList.clear();
            for(var i = 0; i < e.length; i++) {
                var tl = e[i];

                if ((!tl.item || !tl.item.state) && (!tl.linkedPage || !tl.linkedPage.link)) {
                    console.log("Skipping");
                    continue;
                }

                var item = {}
                item.name = tl.label;
                item.type = tl.type;
                if (tl.item && tl.item.state) {
                    item.widgetState = tl.item.state;

                    // Selection widgets have a display mapping in stateDescription.
                    if (tl.item.stateDescription) {
                        for(var j = 0; j < tl.item.stateDescription.options.length; j++) {
                            if (tl.item.stateDescription.options[j].value == tl.item.state) {
                                item.widgetState = tl.item.stateDescription.options[j].label;
                                break;
                            }
                        }
                    }
                }
                else {
                    item.widgetState = qsTr("Group");
                }
                if (tl.linkedPage && tl.linkedPage.link) {
                    item.targetSitemap = tl.linkedPage.link;
                }

                item.mappings = [];

                if (tl.type == "Switch" || tl.type == "Selection") {
                    item.link = tl.item.link;
                    if (tl.mappings && tl.mappings.length > 0) {
                        item.mappings = tl.mappings;
                    }
                    else if (tl.item.commandDescription && tl.item.commandDescription.commandOptions) {
                        item.mappings = tl.item.commandDescription.commandOptions;
                    }
                    else if (tl.item.state) {
                        if (tl.item.state == "ON") {
                            item.mappings = [ {label: "OFF", command: "OFF"} ];
                        }
                        else {
                            item.mappings = [ {label: "ON", command: "ON"} ];
                        }
                    }
                }
//                console.log(JSON.stringify(item.mappings));

                widgetList.append(item);
            }
        });

    }

    function setWidgetValue(link, state) {
//        requestPut(link + "/state", "put", state, function(doc) {
        requestPut(link, "post", state, function(doc) {
            console.log(doc.status);
            var m = messageNotification.createObject(null);
            if (doc.status === 200 || doc.status === 202) {
                if (!settings.no_success_notifications) {
                    m.body = qsTr("Widget status successfully set to %1.").arg(state);
                    m.summary = qsTr("Widget status set")
                }
            }
            else {
                m.body = qsTr("Widget status not set to %1.").arg(state);
                m.summary = qsTr("Widget status change failed")
            }
            if (m.body) {
                m.previewSummary = m.summary
                m.previewBody = m.body
                m.publish()
            }
            getWidgetsFromSitemap(sitemapUrl)
        }, messageNotification);
    }

}
