// ABOUTME: Main application entry point for AudiobooksForPlex
// ABOUTME: Extends Application.AppBase to provide initial view

using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;

class AudiobooksForPlexApp extends Application.AppBase {

    private var _plexService;
    private var _storageManager;

    function initialize() {
        AppBase.initialize();
        _plexService = new PlexLibraryService();
        _storageManager = new StorageManager();
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

    function getPlexService() {
        return _plexService;
    }

    function getStorageManager() {
        return _storageManager;
    }
}

function getApp() {
    return Application.getApp();
}
