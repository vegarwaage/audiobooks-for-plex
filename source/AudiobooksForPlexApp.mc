// ABOUTME: Main application entry point for AudiobooksForPlex
// ABOUTME: Extends AudioContentProviderApp to integrate with Music Player

using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Media;

class AudiobooksForPlexApp extends Application.AudioContentProviderApp {

    private var _plexService;
    private var _storageManager;
    private var _downloadManager;
    private var _currentContentDelegate;

    function initialize() {
        AudioContentProviderApp.initialize();
        _plexService = new PlexLibraryService();
        _storageManager = new StorageManager();

        // Initialize download manager with Plex config
        var serverUrl = Properties.getValue("serverUrl");
        var authToken = Properties.getValue("authToken");
        _downloadManager = new DownloadManager(serverUrl, authToken);
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

    function playAudiobook(bookId, bookTitle, author, contentRefs, startChapter) {
        System.println("Playing audiobook: " + bookTitle);

        // Create and store ContentDelegate
        // The Music Player will retrieve this via the app's getContentDelegate() method
        _currentContentDelegate = new AudiobookContentDelegate(
            bookId,
            bookTitle,
            author,
            contentRefs,
            startChapter
        );

        System.println("ContentDelegate created - audiobook ready for Music Player");
        System.println("Note: Open native Music Player app to start playback");
    }

    // Override AudioContentProviderApp method to provide delegate to Music Player
    function getContentDelegate(args) {
        System.println("Music Player requesting ContentDelegate");

        if (_currentContentDelegate == null) {
            System.println("WARNING: No audiobook loaded");
        }

        return _currentContentDelegate;
    }

    function getCurrentContentDelegate() {
        return _currentContentDelegate;
    }

    function getPlexService() {
        return _plexService;
    }

    function getStorageManager() {
        return _storageManager;
    }

    function getDownloadManager() {
        return _downloadManager;
    }
}

function getApp() {
    return Application.getApp();
}
