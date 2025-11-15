// ABOUTME: Input delegate for library browser menu
// ABOUTME: Handles book selection and menu navigation

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application;
using Toybox.Time;
using Toybox.Lang;
using Toybox.Media;
using AudioFormatDetector;

class LibraryMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var itemId = item.getId();

        if (itemId == :refresh) {
            System.println("Refreshing library from Plex...");
            refreshLibrary();
            return;
        }

        System.println("Selected: " + item.getLabel());
        System.println("Book ID: " + itemId);

        // Show download confirmation
        showDownloadConfirmation(itemId, item.getLabel());
    }

    function showDownloadConfirmation(bookId, bookTitle) {
        var message = "Download:\n" + bookTitle + "?";
        var confirmation = new WatchUi.Confirmation(message);

        WatchUi.pushView(
            confirmation,
            new DownloadConfirmationDelegate(bookId, bookTitle),
            WatchUi.SLIDE_UP
        );
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
        // Called when menu is dismissed
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function refreshLibrary() {
        var app = Application.getApp();
        var plexService = app.getPlexService();

        plexService.fetchAllBooks(new Lang.Method(self, :onBooksRefreshed));
    }

    function onBooksRefreshed(result) {
        if (result[:success]) {
            System.println("Library refreshed: " + result[:books].size() + " books");

            cacheBooks(result[:books]);

            // Reload menu
            WatchUi.popView(WatchUi.SLIDE_DOWN);

            var menu = new LibraryBrowserMenu();
            var delegate = new LibraryMenuDelegate();
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
        } else {
            System.println("Refresh failed: " + result[:error]);

            // Show error toast (stays on current menu)
            showError(result[:error]);
        }
    }

    function showError(errorMessage) {
        // Create simple confirmation showing error
        var dialog = new WatchUi.Confirmation(errorMessage);
        WatchUi.pushView(
            dialog,
            new ErrorDelegate(),
            WatchUi.SLIDE_UP
        );
    }

    function cacheBooks(books) {
        var app = Application.getApp();
        var storage = app.getStorageManager();

        var bookIds = [];
        for (var i = 0; i < books.size(); i++) {
            var book = books[i];
            var bookId = book[:id].toString();

            bookIds.add(bookId);

            var bookData = {
                :title => book[:title],
                :author => book[:author],
                :duration => book[:duration]
            };
            storage.setBook(bookId, bookData);
        }

        storage.setAllBookIds(bookIds);

        var now = Time.now().value();
        storage.setLibrarySyncTime(now);

        System.println("Cached " + bookIds.size() + " books");
    }
}

// Confirmation delegate for download dialog
class DownloadConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    private var _bookId;
    private var _bookTitle;

    function initialize(bookId, bookTitle) {
        ConfirmationDelegate.initialize();
        _bookId = bookId;
        _bookTitle = bookTitle;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            System.println("Download confirmed for: " + _bookTitle);
            startMetadataFetch();
        } else {
            System.println("Download cancelled");
        }

        return true;
    }

    function startMetadataFetch() {
        var app = Application.getApp();
        var plexService = app.getPlexService();

        System.println("Fetching metadata for book: " + _bookId);
        plexService.fetchAudiobookMetadata(_bookId, new Lang.Method(self, :onMetadataLoaded));
    }

    function onMetadataLoaded(result) {
        if (result[:success]) {
            System.println("Metadata loaded: " + result[:chapters].size() + " chapters");
            startDownload(result[:chapters]);
        } else {
            System.println("Metadata load failed: " + result[:error]);
            // TODO: Show error to user
        }
    }

    function startDownload(chapters) {
        var app = Application.getApp();
        var downloadManager = app.getDownloadManager();

        downloadManager.downloadAudiobook(
            _bookId,
            chapters,
            new Lang.Method(self, :onDownloadProgress),
            new Lang.Method(self, :onDownloadComplete),
            new Lang.Method(self, :onDownloadError)
        );
    }

    function onDownloadProgress(progress) {
        System.println("Download progress: Chapter " + progress[:chapter] + "/" + progress[:total] + " (" + progress[:percent] + "%)");
        // TODO: Show progress UI
    }

    function onDownloadComplete(result) {
        System.println("Download complete! ContentRefs: " + result[:contentRefs].size());
        launchMusicPlayer(result[:contentRefs]);
    }

    function onDownloadError(result) {
        System.println("Download error: " + result[:error] + " (chapter " + result[:chapter] + ")");
        // TODO: Show error to user
    }

    function launchMusicPlayer(contentRefs) {
        var app = Application.getApp();
        app.playAudiobook(_bookId, _bookTitle, "Unknown Author", contentRefs, 0);
        System.println("Audiobook registered with Music Player");
    }
}

class ErrorDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        // Dismiss error dialog
        return true;
    }
}
