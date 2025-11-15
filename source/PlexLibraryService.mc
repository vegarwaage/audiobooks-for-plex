// ABOUTME: Handles all Plex server communication via HTTP API
// ABOUTME: Provides methods for library browsing, metadata fetching

using Toybox.Communications;
using Toybox.System;
using Toybox.Application.Properties;
using Toybox.Lang;

class PlexLibraryService {

    private var _serverUrl;
    private var _authToken;
    private var _libraryName;
    private var _librarySectionId;
    private var _booksCallback;
    private var _sectionsCallback;
    private var _metadataCallback;

    function initialize() {
        loadConfiguration();
    }

    // --- Configuration ---

    function loadConfiguration() {
        _serverUrl = Properties.getValue("serverUrl");
        _authToken = Properties.getValue("authToken");
        _libraryName = Properties.getValue("libraryName");

        // Validate configuration
        if (_serverUrl == null || _serverUrl.equals("")) {
            _serverUrl = "http://localhost:32400";
        }
        if (_libraryName == null || _libraryName.equals("")) {
            _libraryName = "Audiobooks";
        }

        System.println("Plex config loaded:");
        System.println("  Server: " + _serverUrl);
        System.println("  Library: " + _libraryName);
        System.println("  Token: " + (_authToken != null ? "***SET***" : "MISSING"));

        _librarySectionId = null; // Will be fetched
    }

    function hasValidConfiguration() {
        return _authToken != null && !_authToken.equals("");
    }

    // --- Library Section Discovery ---

    function findLibrarySection() {
        if (!hasValidConfiguration()) {
            if (_sectionsCallback != null) {
                _sectionsCallback.invoke({
                    :success => false,
                    :error => "No auth token configured"
                });
                _sectionsCallback = null;
            }
            if (_booksCallback != null) {
                _booksCallback.invoke({
                    :success => false,
                    :error => "No auth token configured"
                });
                _booksCallback = null;
            }
            return;
        }

        var url = _serverUrl + "/library/sections";
        var params = {
            "X-Plex-Token" => _authToken
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Accept" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onLibrarySectionsReceived)
        );
    }

    function onLibrarySectionsReceived(responseCode as Lang.Number, data as Lang.Dictionary or Null) as Void {
        System.println("Library sections response: " + responseCode);

        if (responseCode == 200) {
            // Parse response to find matching library
            var sectionId = parseLibrarySectionId(data);

            if (sectionId != null) {
                _librarySectionId = sectionId;
                System.println("Found library section ID: " + sectionId);

                // If this was called from fetchAllBooks, continue with fetchBooksFromSection
                // Otherwise just return success
                if (_booksCallback != null) {
                    fetchBooksFromSection();
                } else if (_sectionsCallback != null) {
                    _sectionsCallback.invoke({
                        :success => true,
                        :sectionId => sectionId
                    });
                    _sectionsCallback = null;
                }
            } else {
                // Invoke BOTH callbacks with error
                if (_booksCallback != null) {
                    _booksCallback.invoke({
                        :success => false,
                        :error => "Library '" + _libraryName + "' not found"
                    });
                    _booksCallback = null;
                }
                if (_sectionsCallback != null) {
                    _sectionsCallback.invoke({
                        :success => false,
                        :error => "Library '" + _libraryName + "' not found"
                    });
                    _sectionsCallback = null;
                }
            }
        } else {
            // Invoke BOTH callbacks with HTTP error
            if (_booksCallback != null) {
                _booksCallback.invoke({
                    :success => false,
                    :error => "HTTP " + responseCode
                });
                _booksCallback = null;
            }
            if (_sectionsCallback != null) {
                _sectionsCallback.invoke({
                    :success => false,
                    :error => "HTTP " + responseCode
                });
                _sectionsCallback = null;
            }
        }
    }

    function parseLibrarySectionId(data) {
        // Parse JSON to find library section matching _libraryName
        // Plex API returns: MediaContainer.Directory[].{key, title}

        if (data == null) {
            return null;
        }

        var mediaContainer = data.get("MediaContainer");
        if (mediaContainer == null) {
            return null;
        }

        var directories = mediaContainer.get("Directory");
        if (directories == null) {
            return null;
        }

        // Find matching library by title
        for (var i = 0; i < directories.size(); i++) {
            var dir = directories[i];
            var title = dir.get("title");

            if (title != null && title.equals(_libraryName)) {
                var key = dir.get("key");
                if (key != null) {
                    return key;
                }
            }
        }

        return null;
    }

    // --- Fetch All Books (Alphabetical) ---

    function fetchAllBooks(callback) {
        _booksCallback = callback;

        if (_librarySectionId == null) {
            // Need to find library section first
            findLibrarySection();
            return;
        }

        fetchBooksFromSection();
    }

    function fetchBooksFromSection() {
        var url = _serverUrl + "/library/sections/" + _librarySectionId + "/all";
        var params = {
            "X-Plex-Token" => _authToken,
            "type" => "9",  // Type 9 = Albums (audiobooks in music library)
            "sort" => "titleSort:asc"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Accept" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onBooksReceived)
        );
    }

    function onBooksReceived(responseCode as Lang.Number, data as Lang.Dictionary or Null) as Void {
        System.println("Books response: " + responseCode);

        if (responseCode == 200) {
            var books = parseBooks(data);
            if (_booksCallback != null) {
                _booksCallback.invoke({
                    :success => true,
                    :books => books
                });
                _booksCallback = null;
            }
        } else {
            if (_booksCallback != null) {
                _booksCallback.invoke({
                    :success => false,
                    :error => "HTTP " + responseCode
                });
                _booksCallback = null;
            }
        }
    }

    function parseBooks(data) {
        // Parse JSON to extract book metadata
        // Plex API returns: MediaContainer.Metadata[].{ratingKey, title, parentTitle (author)}

        var books = [];

        if (data == null) {
            return books;
        }

        var mediaContainer = data.get("MediaContainer");
        if (mediaContainer == null) {
            return books;
        }

        var metadata = mediaContainer.get("Metadata");
        if (metadata == null) {
            return books;
        }

        // Extract book info
        for (var i = 0; i < metadata.size(); i++) {
            var item = metadata[i];

            var book = {
                :id => item.get("ratingKey"),
                :title => item.get("title"),
                :author => item.get("parentTitle"),  // Artist/Author
                :duration => item.get("duration")     // milliseconds
            };

            books.add(book);
        }

        System.println("Parsed " + books.size() + " books");
        return books;
    }

    // --- Fetch Audiobook Metadata (Chapters) ---

    function fetchAudiobookMetadata(ratingKey, callback) {
        _metadataCallback = callback;

        var url = _serverUrl + "/library/metadata/" + ratingKey;
        var params = {
            "X-Plex-Token" => _authToken
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Accept" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onMetadataReceived)
        );
    }

    function onMetadataReceived(responseCode as Lang.Number, data as Lang.Dictionary or Null) as Void {
        System.println("Metadata response: " + responseCode);

        if (_metadataCallback == null) {
            System.println("WARNING: No metadata callback set");
            return;
        }

        if (responseCode == 200) {
            var chapters = parseChapters(data);
            _metadataCallback.invoke({
                :success => true,
                :chapters => chapters
            });
        } else {
            _metadataCallback.invoke({
                :success => false,
                :error => "HTTP " + responseCode
            });
        }

        _metadataCallback = null;
    }

    function parseChapters(data) {
        // Parse JSON to extract chapter/part information
        // Plex API: MediaContainer.Metadata[0].Media[0].Part[]
        // Each Part has: key (URL path), duration, container (format)

        var chapters = [];

        if (data == null) {
            return chapters;
        }

        var mediaContainer = data.get("MediaContainer");
        if (mediaContainer == null) {
            return chapters;
        }

        var metadata = mediaContainer.get("Metadata");
        if (metadata == null || metadata.size() == 0) {
            return chapters;
        }

        var item = metadata[0];
        var mediaArray = item.get("Media");
        if (mediaArray == null || mediaArray.size() == 0) {
            return chapters;
        }

        var media = mediaArray[0];
        var parts = media.get("Part");
        if (parts == null) {
            return chapters;
        }

        // Extract chapter info from parts
        for (var i = 0; i < parts.size(); i++) {
            var part = parts[i];

            var chapter = {
                :key => part.get("key"),              // URL path
                :duration => part.get("duration"),     // milliseconds
                :container => part.get("container"),   // mp3, m4a, m4b, etc.
                :size => part.get("size")              // bytes
            };

            chapters.add(chapter);
        }

        System.println("Parsed " + chapters.size() + " chapters");
        return chapters;
    }
}
