// ABOUTME: ContentDelegate providing audiobook chapters to Music Player
// ABOUTME: Handles playback events and chapter navigation

using Toybox.Media;
using Toybox.System;
using Toybox.Lang;

class AudiobookContentDelegate extends Media.ContentDelegate {

    private var _bookId;
    private var _bookTitle;
    private var _author;
    private var _contentRefs;
    private var _currentChapter;

    function initialize(bookId, bookTitle, author, contentRefs, startChapter) {
        ContentDelegate.initialize();

        _bookId = bookId;
        _bookTitle = bookTitle;
        _author = author;
        _contentRefs = contentRefs;
        _currentChapter = startChapter != null ? startChapter : 0;

        System.println("ContentDelegate initialized:");
        System.println("  Book: " + _bookTitle + " by " + _author);
        System.println("  Chapters: " + _contentRefs.size());
        System.println("  Start chapter: " + _currentChapter);
    }

    // Provide content to Music Player
    function getContent() {
        System.println("getContent() called - providing " + _contentRefs.size() + " chapters");

        // Create ContentIterator with no args - it gets refs from delegate
        var iterator = new Media.ContentIterator();

        return iterator;
    }

    // Handle playback events
    function onSong(contentRefId, songEvent, playbackPosition) {
        System.println("Song event: " + songEventToString(songEvent) + " @ " + playbackPosition + "s");

        if (songEvent == Media.SONG_EVENT_START) {
            handlePlaybackStarted(playbackPosition);
        } else if (songEvent == Media.SONG_EVENT_PAUSE) {
            handlePlaybackPaused(playbackPosition);
        } else if (songEvent == Media.SONG_EVENT_COMPLETE) {
            handlePlaybackComplete(playbackPosition);
        } else if (songEvent == Media.SONG_EVENT_SKIP_NEXT) {
            handleSkipNext();
        } else if (songEvent == Media.SONG_EVENT_SKIP_PREVIOUS) {
            handleSkipPrevious();
        }
    }

    // Playback started
    private function handlePlaybackStarted(position) {
        System.println("Playback started at chapter " + _currentChapter);
        // TODO Phase 3: Start position tracking timer
    }

    // Playback paused
    private function handlePlaybackPaused(position) {
        System.println("Playback paused at position: " + position + "s");
        // TODO Phase 3: Save position locally (position is in seconds)
    }

    // Playback completed
    private function handlePlaybackComplete(position) {
        System.println("Playback complete");
        // TODO Phase 3: Save position, maybe auto-advance
    }

    // Skip to next chapter
    private function handleSkipNext() {
        if (_currentChapter < _contentRefs.size() - 1) {
            _currentChapter++;
            System.println("Skipped to chapter " + _currentChapter);
        } else {
            System.println("Already at last chapter");
        }
    }

    // Skip to previous chapter
    private function handleSkipPrevious() {
        if (_currentChapter > 0) {
            _currentChapter--;
            System.println("Skipped to chapter " + _currentChapter);
        } else {
            System.println("Already at first chapter");
        }
    }

    // Helper to convert event to string for logging
    private function songEventToString(event) {
        if (event == Media.SONG_EVENT_START) { return "START"; }
        else if (event == Media.SONG_EVENT_PAUSE) { return "PAUSE"; }
        else if (event == Media.SONG_EVENT_RESUME) { return "RESUME"; }
        else if (event == Media.SONG_EVENT_COMPLETE) { return "COMPLETE"; }
        else if (event == Media.SONG_EVENT_STOP) { return "STOP"; }
        else if (event == Media.SONG_EVENT_SKIP_NEXT) { return "SKIP_NEXT"; }
        else if (event == Media.SONG_EVENT_SKIP_PREVIOUS) { return "SKIP_PREVIOUS"; }
        else if (event == Media.SONG_EVENT_SKIP_FORWARD) { return "SKIP_FORWARD"; }
        else if (event == Media.SONG_EVENT_SKIP_BACKWARD) { return "SKIP_BACKWARD"; }
        else if (event == Media.SONG_EVENT_PLAYBACK_NOTIFY) { return "PLAYBACK_NOTIFY"; }
        return "UNKNOWN";
    }

    // Getters
    function getBookId() {
        return _bookId;
    }

    function getCurrentChapter() {
        return _currentChapter;
    }
}
