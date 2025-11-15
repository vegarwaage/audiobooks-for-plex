// ABOUTME: Input delegate for main view
// ABOUTME: Handles button presses and navigation events

using Toybox.WatchUi;
using Toybox.System;

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        System.println("Select pressed");
        return true;
    }

    function onBack() {
        System.println("Back pressed - exiting app");
        return false; // Exit app
    }

    function onMenu() {
        System.println("Menu pressed");
        return true;
    }
}
