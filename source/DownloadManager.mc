// ABOUTME: Manages sequential download of audiobook chapters
// ABOUTME: Tracks progress, handles errors, stores encrypted audio files

using Toybox.Communications;
using Toybox.Media;
using Toybox.System;
using Toybox.Lang;
using Toybox.PersistedContent;
using AudioFormatDetector;

class DownloadManager {

    private var _serverUrl;
    private var _authToken;
    private var _bookId;
    private var _chapters;
    private var _currentChapterIndex;
    private var _progressCallback;
    private var _completeCallback;
    private var _errorCallback;
    private var _downloadedRefs;

    function initialize(serverUrl, authToken) {
        _serverUrl = serverUrl;
        _authToken = authToken;
        _bookId = null;
        _chapters = null;
        _currentChapterIndex = 0;
        _progressCallback = null;
        _completeCallback = null;
        _errorCallback = null;
        _downloadedRefs = [];
    }

    // Start downloading audiobook chapters
    function downloadAudiobook(bookId, chapters, progressCallback, completeCallback, errorCallback) {
        _bookId = bookId;
        _chapters = chapters;
        _currentChapterIndex = 0;
        _progressCallback = progressCallback;
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;
        _downloadedRefs = [];

        System.println("Starting download: " + chapters.size() + " chapters");

        // Start with first chapter
        downloadNextChapter();
    }

    // Download next chapter in sequence
    private function downloadNextChapter() {
        if (_currentChapterIndex >= _chapters.size()) {
            // All chapters downloaded
            onDownloadComplete();
            return;
        }

        var chapter = _chapters[_currentChapterIndex];
        System.println("Downloading chapter " + (_currentChapterIndex + 1) + "/" + _chapters.size());

        // Report progress
        if (_progressCallback != null) {
            _progressCallback.invoke({
                :chapter => _currentChapterIndex + 1,
                :total => _chapters.size(),
                :percent => (_currentChapterIndex * 100) / _chapters.size()
            });
        }

        // Build download URL
        var url = _serverUrl + chapter[:key];
        var params = {
            "download" => "1",
            "X-Plex-Token" => _authToken
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onChapterDownloaded)
        );
    }

    // Handle chapter download response
    function onChapterDownloaded(responseCode as Lang.Number, data as PersistedContent.Iterator or Lang.String or Lang.Dictionary or Null) as Void {
        System.println("Chapter download response: " + responseCode);

        if (responseCode == 200) {
            // Success - save encrypted audio file
            var chapter = _chapters[_currentChapterIndex];
            var format = AudioFormatDetector.getAudioFormat(chapter[:container]);

            if (format == null) {
                onDownloadError("Unsupported audio format: " + chapter[:container]);
                return;
            }

            // Create ContentRef for this chapter
            // Note: data is encrypted audio, Garmin handles encryption automatically
            var contentRef = new Media.ContentRef(
                data,  // Encrypted audio data
                Media.CONTENT_TYPE_AUDIO
            );

            _downloadedRefs.add(contentRef);

            System.println("Chapter " + (_currentChapterIndex + 1) + " downloaded successfully");

            // Move to next chapter
            _currentChapterIndex++;
            downloadNextChapter();

        } else {
            // Error
            onDownloadError("HTTP " + responseCode + " downloading chapter " + (_currentChapterIndex + 1));
        }
    }

    // All chapters downloaded successfully
    private function onDownloadComplete() {
        System.println("Download complete: " + _downloadedRefs.size() + " chapters");

        // Report 100% progress
        if (_progressCallback != null) {
            _progressCallback.invoke({
                :chapter => _chapters.size(),
                :total => _chapters.size(),
                :percent => 100
            });
        }

        // Invoke complete callback
        if (_completeCallback != null) {
            _completeCallback.invoke({
                :success => true,
                :contentRefs => _downloadedRefs
            });
        }

        // Clear callbacks
        _progressCallback = null;
        _completeCallback = null;
        _errorCallback = null;
    }

    // Download error occurred
    private function onDownloadError(errorMessage) {
        System.println("Download error: " + errorMessage);

        if (_errorCallback != null) {
            _errorCallback.invoke({
                :success => false,
                :error => errorMessage,
                :chapter => _currentChapterIndex + 1
            });
        }

        // Clear callbacks
        _progressCallback = null;
        _completeCallback = null;
        _errorCallback = null;
    }

    // Cancel ongoing download
    function cancel() {
        System.println("Download cancelled");
        _progressCallback = null;
        _completeCallback = null;
        _errorCallback = null;
    }
}
