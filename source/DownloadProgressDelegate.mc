// ABOUTME: Input delegate for download progress view
// ABOUTME: Allows Back button to cancel download

using Toybox.WatchUi;
using Toybox.System;

class DownloadProgressDelegate extends WatchUi.BehaviorDelegate {

    private var _cancelCallback;

    function initialize(cancelCallback) {
        BehaviorDelegate.initialize();
        _cancelCallback = cancelCallback;
    }

    function onBack() {
        System.println("Back pressed - cancelling download");

        if (_cancelCallback != null) {
            _cancelCallback.invoke();
        }

        return true;
    }

    function onMenu() {
        // Ignore menu during download
        return true;
    }
}
