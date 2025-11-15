// ABOUTME: Menu2-based UI for browsing audiobook library
// ABOUTME: Shows alphabetical list of books with title and author

using Toybox.WatchUi;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;

class LibraryBrowserMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Audiobooks"});

        // Add refresh action at top
        addItem(new WatchUi.MenuItem(
            "Refresh Library",
            "Update from Plex",
            :refresh,
            {}
        ));

        // Check for current downloaded book
        loadCurrentBook();

        loadBooks();
    }

    function loadCurrentBook() {
        var app = Application.getApp();
        var storage = app.getStorageManager();
        var metadata = storage.getCurrentBookMetadata();

        // Show current book if metadata exists in storage (persists across restarts)
        if (metadata != null) {
            var title = metadata.get(:title);
            var author = metadata.get(:author);

            if (title != null && author != null) {
                System.println("Current book found: " + title);

                // Add with play symbol prefix
                addItem(new WatchUi.MenuItem(
                    "▶ " + title,
                    author,
                    :current_book,  // Special identifier
                    {}
                ));
            } else {
                System.println("WARNING: Incomplete metadata for current book");
            }
        }
    }

    function loadBooks() {
        var app = Application.getApp();
        var storage = app.getStorageManager();

        // Get all book IDs
        var bookIds = storage.getAllBookIds();

        if (bookIds.size() == 0) {
            // No books cached yet
            addItem(new WatchUi.MenuItem(
                "No books",
                "Pull to refresh",
                :no_books,
                {}
            ));
            return;
        }

        // Add book items
        for (var i = 0; i < bookIds.size(); i++) {
            var bookId = bookIds[i];
            var bookData = storage.getBook(bookId);

            if (bookData != null) {
                var label = bookData[:title];
                var sublabel = bookData[:author];

                addItem(new WatchUi.MenuItem(
                    label,
                    sublabel,
                    bookId,  // Use bookId as item ID
                    {}
                ));
            }
        }

        System.println("Menu loaded with " + bookIds.size() + " books");
    }
}
