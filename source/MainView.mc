// ABOUTME: Main view showing placeholder text before library loads
// ABOUTME: Will be replaced with Menu2 library browser in later tasks

using Toybox.WatchUi;
using Toybox.Graphics;

class MainView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        // No layout needed for placeholder
    }

    function onShow() {
        // View is displayed
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
