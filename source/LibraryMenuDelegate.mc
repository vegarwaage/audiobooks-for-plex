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
    private var _bookAuthor;
    private var _progressView;

    function initialize(bookId, bookTitle) {
        ConfirmationDelegate.initialize();
        _bookId = bookId;
        _bookTitle = bookTitle;
        _bookAuthor = "Unknown";
        _progressView = null;
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

            // Extract and store metadata
            _bookTitle = result[:title];
            _bookAuthor = result[:author];

            System.println("Book: " + _bookTitle + " by " + _bookAuthor);

            // Save metadata to storage
            saveMetadataToStorage(result[:title], result[:author], result[:chapters]);

            startDownload(result[:chapters]);
        } else {
            System.println("Metadata load failed: " + result[:error]);
            // Show error to user
            var dialog = new WatchUi.Confirmation(result[:error]);
            WatchUi.pushView(dialog, new ErrorDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function saveMetadataToStorage(title, author, chapters) {
        var app = Application.getApp();
        var storage = app.getStorageManager();

        // Save chapters
        storage.setChapters(_bookId, chapters);

        // Save current book metadata
        var metadata = {
            :title => title,
            :author => author,
            :chapterCount => chapters.size()
        };
        storage.setCurrentBookMetadata(_bookId, metadata);

        System.println("Saved metadata: " + title + " by " + author + " (" + chapters.size() + " chapters)");
    }

    function startDownload(chapters) {
        var app = Application.getApp();
        var downloadManager = app.getDownloadManager();

        // Show progress view
        _progressView = new DownloadProgressView(_bookTitle, chapters.size());
        var progressDelegate = new DownloadProgressDelegate(new Lang.Method(self, :onDownloadCancelled));

        WatchUi.pushView(_progressView, progressDelegate, WatchUi.SLIDE_UP);

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

        if (_progressView != null) {
            _progressView.updateProgress(progress[:chapter], progress[:percent]);
        }
    }

    function onDownloadComplete(result) {
        System.println("Download complete! ContentRefs: " + result[:contentRefs].size());

        // Show completion message briefly
        if (_progressView != null) {
            _progressView.showComplete();
        }

        // Pop progress view
        WatchUi.popView(WatchUi.SLIDE_DOWN);

        launchMusicPlayer(result[:contentRefs]);
    }

    function onDownloadError(result) {
        System.println("Download error: " + result[:error] + " (chapter " + result[:chapter] + ")");

        // Pop progress view
        WatchUi.popView(WatchUi.SLIDE_DOWN);

        // Show error dialog
        var dialog = new WatchUi.Confirmation(result[:error]);
        WatchUi.pushView(dialog, new ErrorDelegate(), WatchUi.SLIDE_UP);
    }

    function onDownloadCancelled() {
        System.println("Download cancelled by user");

        var app = Application.getApp();
        var downloadManager = app.getDownloadManager();
        downloadManager.cancel();

        // Pop progress view
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function launchMusicPlayer(contentRefs) {
        var app = Application.getApp();
        app.playAudiobook(_bookId, _bookTitle, _bookAuthor, contentRefs, 0);
        System.println("Audiobook registered with Music Player");
        System.println("Book: " + _bookTitle + " by " + _bookAuthor);
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
