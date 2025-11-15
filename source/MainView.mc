// ABOUTME: Main view showing placeholder text before library loads
// ABOUTME: Will be replaced with Menu2 library browser in later tasks

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Lang;

class MainView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        // No layout needed for placeholder
    }

    function onShow() {
        // Test Plex connection when view shows
        var app = Application.getApp();
        var plexService = app.getPlexService();

        plexService.fetchAllBooks(new Lang.Method(self, :onBooksLoaded));
    }

    function onBooksLoaded(result) {
        if (result[:success]) {
            System.println("SUCCESS: Loaded " + result[:books].size() + " books");

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
