// ABOUTME: Input delegate for library browser menu
// ABOUTME: Handles book selection and menu navigation

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application;
using Toybox.Time;
using Toybox.Lang;

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

        // TODO: In later phases, show download confirmation
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

class ErrorDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        // Dismiss error dialog
        return true;
    }
}
