// ABOUTME: Main application entry point for AudiobooksForPlex
// ABOUTME: Extends Application.AppBase to provide initial view

using Toybox.Application;
using Toybox.WatchUi;

class AudiobooksForPlexApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        // App starting - state restoration will come later
    }

    function onStop(state) {
        // App stopping - state saving will come later
    }

    function getInitialView() {
        var view = new MainView();
        var delegate = new MainDelegate();
        return [view, delegate];
    }
}

function getApp() {
    return Application.getApp();
}
