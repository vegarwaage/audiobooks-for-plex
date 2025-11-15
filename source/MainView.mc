// ABOUTME: Main view showing placeholder text before library loads
// ABOUTME: Will be replaced with Menu2 library browser in later tasks

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Time;
using Toybox.System;

class MainView extends WatchUi.View {
    private var _errorMessage = null;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        // No layout needed for placeholder
    }

    function onShow() {
        // Try loading from cache first
        var cachedBooks = loadCachedBooks();

        if (cachedBooks != null && cachedBooks.size() > 0) {
            System.println("Using cached books");
            showLibraryMenu();
        } else {
            System.println("No cache, fetching from Plex...");

            // Fetch from Plex
            var app = Application.getApp();
            var plexService = app.getPlexService();
            plexService.fetchAllBooks(new Lang.Method(self, :onBooksLoaded));
        }
    }

    function onBooksLoaded(result) {
        if (result[:success]) {
            System.println("SUCCESS: Loaded " + result[:books].size() + " books");

            // Clear error message
            _errorMessage = null;

            // Cache books to storage
            cacheBooks(result[:books]);

            // Show library browser menu
            showLibraryMenu();
        } else {
            System.println("ERROR: " + result[:error]);

            // Set error message
            _errorMessage = result[:error];

            // Still try to show menu with cached data
            var cachedBooks = loadCachedBooks();
            if (cachedBooks != null && cachedBooks.size() > 0) {
                System.println("Using cached books despite error");
                showLibraryMenu();
            }
        }

        WatchUi.requestUpdate();
    }

    function showLibraryMenu() {
        var menu = new LibraryBrowserMenu();
        var delegate = new LibraryMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
    }

    function cacheBooks(books) {
        var app = Application.getApp();
        var storage = app.getStorageManager();

        // Save book IDs list
        var bookIds = [];
        for (var i = 0; i < books.size(); i++) {
            var book = books[i];
            var bookId = book[:id].toString();

            bookIds.add(bookId);

            // Save individual book metadata
            var bookData = {
                :title => book[:title],
                :author => book[:author],
                :duration => book[:duration]
            };
            storage.setBook(bookId, bookData);
        }

        storage.setAllBookIds(bookIds);

        // Save sync timestamp
        var now = Time.now().value();
        storage.setLibrarySyncTime(now);

        System.println("Cached " + bookIds.size() + " books to storage");
    }

    function loadCachedBooks() {
        var app = Application.getApp();
        var storage = app.getStorageManager();

        var bookIds = storage.getAllBookIds();

        if (bookIds.size() == 0) {
            System.println("No cached books found");
            return null;
        }

        var books = [];
        for (var i = 0; i < bookIds.size(); i++) {
            var bookId = bookIds[i];
            var bookData = storage.getBook(bookId);

            if (bookData != null) {
                books.add({
                    :id => bookId,
                    :title => bookData[:title],
                    :author => bookData[:author],
                    :duration => bookData[:duration]
                });
            }
        }

        System.println("Loaded " + books.size() + " cached books");
        return books;
    }

    function onUpdate(dc) {
        // Clear screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_errorMessage != null) {
            // Show error message
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_SMALL,
                _errorMessage,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 0.7,
                Graphics.FONT_XTINY,
                "Using cached books",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            // Show loading message
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_MEDIUM,
                "Audiobooks for Plex",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 0.7,
                Graphics.FONT_SMALL,
                "Loading...",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }

    function onHide() {
        // View is hidden
    }
}
