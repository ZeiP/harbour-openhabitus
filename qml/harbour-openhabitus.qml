import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "common"

import Nemo.Notifications 1.0

ApplicationWindow {
    id: mainWindow

    initialPage: Component { WidgetList { } }

    Settings {
        id: settings
    }

    Component {
        id: messageNotification
        Notification {}
    }

    function request(url, method, data, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(mxhr) {
            return function() { if(mxhr.readyState === XMLHttpRequest.DONE) { callback(mxhr); } }
        })(xhr);
        // Check that the URL ends in slash.
        if (url.substr(0, 4) != "http") {
            var base_url = settings.base_url
            if (base_url.substr(base_url.length - 1) !== "/") {
                base_url = base_url + "/";
            }
            url = base_url + url;
        }

console.log(url);
        xhr.open(method, url, true);
        xhr.responseType = 'json';
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept", "application/json");
        if(method === "post" || method === "put") {
            xhr.send(data);
        }
        else {
            xhr.send('');
        }
    }

    function requestPut(url, method, data, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(mxhr, messageNotification) {
            return function() { if(mxhr.readyState === XMLHttpRequest.DONE) { callback(mxhr); } }
        })(xhr, messageNotification);
        // Check that the URL ends in slash.
        if (url.substr(0, 4) != "http") {
            var base_url = settings.base_url
            if (base_url.substr(base_url.length - 1) !== "/") {
                base_url = base_url + "/";
            }
            url = base_url + url;
        }

console.log(url);
        xhr.open(method, url, true);
        xhr.setRequestHeader("Content-Type", "text/plain");
        xhr.setRequestHeader("Accept", "application/json");
        if(method === "post" || method === "put") {
            xhr.send(data);
        }
        else {
            xhr.send('');
        }
    }

    Component.onCompleted: {
        var m = messageNotification.createObject(null);
    }
}
