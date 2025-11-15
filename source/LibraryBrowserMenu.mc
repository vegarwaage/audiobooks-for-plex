// ABOUTME: Menu2-based UI for browsing audiobook library
// ABOUTME: Shows alphabetical list of books with title and author

using Toybox.WatchUi;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;

class LibraryBrowserMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Audiobooks"});

        loadBooks();
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
