// ABOUTME: Detects audio format from file container/extension
// ABOUTME: Maps container strings to format constants for validation

using Toybox.System;

module AudioFormatDetector {

    // Format constants (for API 3.0.0 compatibility)
    // Note: At API 3.0.0, encoding may be auto-detected from container
    const FORMAT_MP3 = 0;
    const FORMAT_M4A = 1;
    const FORMAT_WAV = 2;
    const FORMAT_UNKNOWN = -1;

    function getAudioFormat(container) {
        if (container == null) {
            return FORMAT_UNKNOWN;
        }

        // MP3
        if (container.equals("mp3")) {
            return FORMAT_MP3;
        }

        // M4A, M4B (audiobook), MP4
        if (container.equals("m4a") || container.equals("m4b") || container.equals("mp4")) {
            return FORMAT_M4A;
        }

        // WAV
        if (container.equals("wav")) {
            return FORMAT_WAV;
        }

        // Unsupported format
        return FORMAT_UNKNOWN;
    }

    function isFormatSupported(container) {
        return getAudioFormat(container) != FORMAT_UNKNOWN;
    }

    function getFormatName(format) {
        if (format == FORMAT_MP3) {
            return "MP3";
        } else if (format == FORMAT_M4A) {
            return "M4A";
        } else if (format == FORMAT_WAV) {
            return "WAV";
        }
        return "Unknown";
    }
}
