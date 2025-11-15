// ABOUTME: Input delegate for library browser menu
// ABOUTME: Handles book selection and menu navigation

using Toybox.WatchUi;
using Toybox.System;

class LibraryMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var itemId = item.getId();

        System.println("Selected: " + item.getLabel());
        System.println("Book ID: " + itemId);

        // TODO: In later phases, show download confirmation
        // For now, just log selection
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
        // Called when menu is dismissed
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
