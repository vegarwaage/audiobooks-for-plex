// ABOUTME: Custom view showing download progress during chapter downloads
// ABOUTME: Displays book title, chapter X/Y, progress bar, percentage

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class DownloadProgressView extends WatchUi.View {

    private var _bookTitle;
    private var _currentChapter;
    private var _totalChapters;
    private var _percent;
    private var _isComplete;

    function initialize(bookTitle, totalChapters) {
        View.initialize();
        _bookTitle = bookTitle;
        _currentChapter = 0;
        _totalChapters = totalChapters;
        _percent = 0;
        _isComplete = false;
    }

    function updateProgress(currentChapter, percent) {
        _currentChapter = currentChapter;
        _percent = percent;
        _isComplete = false;
        WatchUi.requestUpdate();
    }

    function showComplete() {
        _isComplete = true;
        WatchUi.requestUpdate();
    }

    function onLayout(dc) {
        // No layout needed
    }

    function onShow() {
        // View displayed
    }

    function onUpdate(dc) {
        // Clear screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        if (_isComplete) {
            // Show completion message
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                height / 2,
                Graphics.FONT_LARGE,
                "Download\nComplete!",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            // Show progress
            drawProgressUI(dc, width, height);
        }
    }

    function drawProgressUI(dc, width, height) {
        // Draw title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height * 0.2,
            Graphics.FONT_SMALL,
            "Downloading",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw book title (truncated if needed)
        dc.drawText(
            width / 2,
            height * 0.35,
            Graphics.FONT_MEDIUM,
            truncateString(_bookTitle, 20),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw chapter count
        dc.drawText(
            width / 2,
            height * 0.5,
            Graphics.FONT_SMALL,
            "Chapter " + _currentChapter + "/" + _totalChapters,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw progress bar
        drawProgressBar(dc, width, height);

        // Draw percentage
        dc.drawText(
            width / 2,
            height * 0.75,
            Graphics.FONT_MEDIUM,
            _percent + "%",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawProgressBar(dc, width, height) {
        var barWidth = width * 0.8;
        var barHeight = 10;
        var barX = (width - barWidth) / 2;
        var barY = height * 0.6;

        // Draw background (empty bar)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barWidth, barHeight);

        // Draw filled portion
        var fillWidth = (barWidth * _percent) / 100;
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, fillWidth, barHeight);

        // Draw border
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(barX, barY, barWidth, barHeight);
    }

    function truncateString(str, maxLen) {
        if (str.length() <= maxLen) {
            return str;
        }
        return str.substring(0, maxLen - 3) + "...";
    }

    function onHide() {
        // View hidden
    }
}
