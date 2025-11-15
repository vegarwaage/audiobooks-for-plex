// ABOUTME: Main view showing placeholder text before library loads
// ABOUTME: Will be replaced with Menu2 library browser in later tasks

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Time;

class MainView extends WatchUi.View {

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
            // For now just log, Menu2 UI will use these in next task
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

            // Cache books to storage
            cacheBooks(result[:books]);

            // Print first book as sample
            if (result[:books].size() > 0) {
                var book = result[:books][0];
                System.println("First book: " + book[:title] + " by " + book[:author]);
            }
        } else {
            System.println("ERROR: " + result[:error]);
        }

        WatchUi.requestUpdate();
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

        // Draw placeholder text
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

    function onHide() {
        // View is hidden
    }
}
