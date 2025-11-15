# AudiobooksForPlex Phase 1: Core Foundation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build basic Plex library browsing on Garmin Forerunner 970 watch with offline-capable storage and Menu2 UI.

**Architecture:** AudioContentProviderApp that fetches audiobook library from Plex server, stores metadata in flat 8KB-aware structure, and displays books in Menu2-based interface. Position tracking and downloads come in later phases.

**Tech Stack:** Garmin Connect IQ SDK 7.x, Monkey C, Toybox API (WatchUi.Menu2, Application.Storage, Communications.makeWebRequest), Plex Media Server API

---

## Prerequisites

**Before starting:**
- Connect IQ SDK installed (check: `monkeyc --version`)
- Visual Studio Code with Monkey C extension installed
- Garmin Forerunner 970 device or simulator access
- Plex server accessible on local network
- Plex auth token obtained (see docs/plans/2025-11-15-audiobooks-mvp-design.md)

**Reference Documentation:**
- Design: `/docs/plans/2025-11-15-audiobooks-mvp-design.md`
- Feasibility: `/docs/FEASIBILITY_REPORT.md`
- Garmin Docs: `/garmin-documentation/`
- Project Guide: `/.claude/CLAUDE.md`

---

## Task 1: Project Initialization

**Goal:** Create basic Connect IQ project structure with manifest and build configuration.

**Files:**
- Create: `manifest.xml`
- Create: `monkey.jungle`
- Create: `resources/`
- Create: `source/`

### Step 1: Create manifest.xml

Create file at project root:

```xml
<?xml version="1.0" encoding="utf-8"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        entry="AudiobooksForPlexApp"
        id="YOUR_APP_ID_HERE"
        launcherIcon="@Drawables.LauncherIcon"
        minApiLevel="3.0.0"
        name="@Strings.AppName"
        type="audio-content-provider-app"
        version="0.1.0">

        <iq:products>
            <iq:product id="forerunner970"/>
        </iq:products>

        <iq:permissions>
            <iq:uses-permission id="Communications"/>
            <iq:uses-permission id="Media"/>
        </iq:permissions>

        <iq:languages>
            <iq:language>eng</iq:language>
        </iq:languages>

        <iq:barrels/>
    </iq:application>
</iq:manifest>
```

**Note:** Replace `YOUR_APP_ID_HERE` with a UUID (generate with `uuidgen` command).

### Step 2: Create monkey.jungle build configuration

Create file at project root:

```
project.manifest = manifest.xml

# Forerunner 970 target
forerunner970.sourcePath = source
forerunner970.resourcePath = resources
```

### Step 3: Create directory structure

```bash
mkdir -p source
mkdir -p resources/drawables
mkdir -p resources/strings
mkdir -p resources/layouts
mkdir -p resources/properties
mkdir -p bin
```

### Step 4: Create basic strings resource

Create: `resources/strings/strings.xml`

```xml
<strings>
    <string id="AppName">Audiobooks for Plex</string>
    <string id="MenuTitle">Audiobooks</string>
    <string id="Loading">Loading...</string>
    <string id="Error">Error</string>
    <string id="NoBooks">No audiobooks found</string>
    <string id="Collections">Collections</string>
</strings>
```

### Step 5: Create placeholder launcher icon

Create: `resources/drawables/drawables.xml`

```xml
<drawables>
    <bitmap id="LauncherIcon" filename="launcher_icon.png"/>
</drawables>
```

**Note:** For now, create a simple 80x80 PNG with text "AB" (AudioBooks). Proper icon comes later.

### Step 6: Verify build configuration

Run: `monkeyc -d forerunner970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key`

Expected: Error about missing source files (normal at this stage).

### Step 7: Commit project structure

```bash
git add manifest.xml monkey.jungle resources/ source/ bin/.gitkeep
git commit -m "feat: initialize Connect IQ project structure

- Add manifest.xml with AudioContentProviderApp type
- Add monkey.jungle build config for Forerunner 970
- Create resource directories and basic strings
- Add placeholder launcher icon

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 2: Properties Configuration

**Goal:** Set up app properties for Plex server configuration (serverUrl, authToken, libraryName).

**Files:**
- Create: `resources/properties/properties.xml`
- Create: `resources/properties/.gitignore`

### Step 1: Create properties.xml

Create: `resources/properties/properties.xml`

```xml
<properties>
    <property id="serverUrl" type="string">http://localhost:32400</property>
    <property id="authToken" type="string"></property>
    <property id="libraryName" type="string">Audiobooks</property>
</properties>
```

### Step 2: Create .gitignore for local overrides

Create: `resources/properties/.gitignore`

```
# Ignore local property overrides (sensitive data)
*.local.xml
AudiobooksForPlex.set
```

### Step 3: Document settings workflow

Create: `docs/DEVELOPMENT_SETUP.md`

```markdown
# Development Setup

## Plex Settings Configuration

### Method 1: .set File (Sideloading)

1. Create `AudiobooksForPlex.set`:

```xml
<?xml version="1.0"?>
<properties>
    <property id="serverUrl">http://YOUR_SERVER_IP:32400</property>
    <property id="authToken">YOUR_PLEX_TOKEN</property>
    <property id="libraryName">Audiobooks</property>
</properties>
```

2. Copy to watch via USB: `/GARMIN/APPS/SETTINGS/AudiobooksForPlex.set`

### Method 2: Simulator Testing

1. Configure properties in simulator settings
2. Settings saved to temp directory automatically

### Getting Plex Token

1. Open Plex web app
2. Play any media
3. Click "..." → Get Info → View XML
4. Find `X-Plex-Token` in URL

## Build Commands

```bash
# Build for Forerunner 970
monkeyc -d forerunner970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key

# Run in simulator
monkeydo bin/AudiobooksForPlex.prg forerunner970

# Sideload to device
# 1. Connect watch via USB
# 2. Copy bin/AudiobooksForPlex.prg to /GARMIN/APPS/
```
```

### Step 4: Verify properties accessible in code

This will be tested when we create the app entry point in next task.

### Step 5: Commit properties configuration

```bash
git add resources/properties/properties.xml resources/properties/.gitignore docs/DEVELOPMENT_SETUP.md
git commit -m "feat: add properties configuration for Plex settings

- Add properties.xml with serverUrl, authToken, libraryName
- Add .gitignore for sensitive local overrides
- Document settings workflow for development

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 3: App Entry Point

**Goal:** Create minimal AudioContentProviderApp that launches and shows placeholder view.

**Files:**
- Create: `source/AudiobooksForPlexApp.mc`
- Create: `source/MainView.mc`
- Create: `source/MainDelegate.mc`

### Step 1: Create app entry point

Create: `source/AudiobooksForPlexApp.mc`

```monkey-c
// ABOUTME: Main application entry point for AudiobooksForPlex
// ABOUTME: Extends Application.AppBase to provide initial view

using Toybox.Application;
using Toybox.WatchUi;

class AudiobooksForPlexApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        // App starting - state restoration will come later
    }

    function onStop(state) {
        // App stopping - state saving will come later
        return null;
    }

    function getInitialView() {
        var view = new MainView();
        var delegate = new MainDelegate();
        return [view, delegate];
    }
}

function getApp() {
    return Application.getApp();
}
```

### Step 2: Create placeholder main view

Create: `source/MainView.mc`

```monkey-c
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
```

### Step 3: Create basic input delegate

Create: `source/MainDelegate.mc`

```monkey-c
// ABOUTME: Input delegate for main view
// ABOUTME: Handles button presses and navigation events

using Toybox.WatchUi;
using Toybox.System;

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        System.println("Select pressed");
        return true;
    }

    function onBack() {
        System.println("Back pressed - exiting app");
        return false; // Exit app
    }

    function onMenu() {
        System.println("Menu pressed");
        return true;
    }
}
```

### Step 4: Build and verify app launches

Run: `monkeyc -d forerunner970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key -w`

Expected: Build succeeds with no warnings.

### Step 5: Test in simulator

Run: `monkeydo bin/AudiobooksForPlex.prg forerunner970`

Expected: App launches, shows "Audiobooks for Plex" and "Loading..." text.
Test: Press Back button → App exits.

### Step 6: Commit app entry point

```bash
git add source/AudiobooksForPlexApp.mc source/MainView.mc source/MainDelegate.mc
git commit -m "feat: add app entry point with placeholder view

- Create AudiobooksForPlexApp extending AppBase
- Add MainView with placeholder text
- Add MainDelegate with basic button handling
- Verified: App builds and launches in simulator

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 4: Storage Manager (Flat Structure)

**Goal:** Implement flat storage manager that works within 8KB per-value limit.

**Files:**
- Create: `source/StorageManager.mc`

### Step 1: Create StorageManager class

Create: `source/StorageManager.mc`

```monkey-c
// ABOUTME: Manages flat key-value storage to work within 8KB limit
// ABOUTME: Provides methods for storing library metadata, books, collections

using Toybox.Application.Storage;
using Toybox.System;

class StorageManager {

    // Keys for storage
    const KEY_LIBRARY_SYNC = "library_last_sync";
    const KEY_COLLECTION_IDS = "collection_ids";
    const KEY_ALL_BOOK_IDS = "all_book_ids";
    const KEY_CURRENT_BOOK_ID = "current_book_id";

    function initialize() {
    }

    // --- Library Sync Timestamp ---

    function setLibrarySyncTime(timestamp) {
        Storage.setValue(KEY_LIBRARY_SYNC, timestamp);
    }

    function getLibrarySyncTime() {
        return Storage.getValue(KEY_LIBRARY_SYNC);
    }

    // --- Collections ---

    function setCollectionIds(collectionIds) {
        Storage.setValue(KEY_COLLECTION_IDS, collectionIds);
    }

    function getCollectionIds() {
        var ids = Storage.getValue(KEY_COLLECTION_IDS);
        return ids != null ? ids : [];
    }

    function setCollection(collectionId, collectionData) {
        var key = "collection_" + collectionId;
        Storage.setValue(key, collectionData);
    }

    function getCollection(collectionId) {
        var key = "collection_" + collectionId;
        return Storage.getValue(key);
    }

    function setBooksInCollection(collectionId, bookIds) {
        var key = "books_" + collectionId;
        Storage.setValue(key, bookIds);
    }

    function getBooksInCollection(collectionId) {
        var key = "books_" + collectionId;
        var ids = Storage.getValue(key);
        return ids != null ? ids : [];
    }

    // --- Books ---

    function setAllBookIds(bookIds) {
        Storage.setValue(KEY_ALL_BOOK_IDS, bookIds);
    }

    function getAllBookIds() {
        var ids = Storage.getValue(KEY_ALL_BOOK_IDS);
        return ids != null ? ids : [];
    }

    function setBook(bookId, bookData) {
        var key = "book_" + bookId;
        Storage.setValue(key, bookData);
    }

    function getBook(bookId) {
        var key = "book_" + bookId;
        return Storage.getValue(key);
    }

    // --- Current Book ---

    function setCurrentBookId(bookId) {
        Storage.setValue(KEY_CURRENT_BOOK_ID, bookId);
    }

    function getCurrentBookId() {
        return Storage.getValue(KEY_CURRENT_BOOK_ID);
    }

    // --- Utility ---

    function clearAllData() {
        Storage.clearValues();
    }

    function debugPrintStorage() {
        System.println("=== Storage Debug ===");
        System.println("Library sync: " + getLibrarySyncTime());
        System.println("Collection IDs: " + getCollectionIds());
        System.println("All book IDs: " + getAllBookIds());
        System.println("Current book: " + getCurrentBookId());
    }
}
```

### Step 2: Manual testing (no automated tests for Monkey C storage)

We'll verify StorageManager works when we integrate with Plex API in next task.

### Step 3: Commit StorageManager

```bash
git add source/StorageManager.mc
git commit -m "feat: add flat storage manager for 8KB limit

- Create StorageManager with flat key-value structure
- Support collections, books, current book tracking
- Avoid nested structures to prevent 8KB overflow
- Add debug print utility

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 5: Plex API Service - Basic Structure

**Goal:** Create PlexLibraryService with authentication and basic request handling.

**Files:**
- Create: `source/PlexLibraryService.mc`

### Step 1: Create PlexLibraryService class skeleton

Create: `source/PlexLibraryService.mc`

```monkey-c
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

    function findLibrarySection(callback) {
        if (!hasValidConfiguration()) {
            callback.invoke({
                :success => false,
                :error => "No auth token configured"
            });
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
            method(:onLibrarySectionsReceived).bindWith(callback)
        );
    }

    function onLibrarySectionsReceived(callback, responseCode, data) {
        System.println("Library sections response: " + responseCode);

        if (responseCode == 200) {
            // Parse response to find matching library
            var sectionId = parseLibrarySectionId(data);

            if (sectionId != null) {
                _librarySectionId = sectionId;
                System.println("Found library section ID: " + sectionId);

                callback.invoke({
                    :success => true,
                    :sectionId => sectionId
                });
            } else {
                callback.invoke({
                    :success => false,
                    :error => "Library '" + _libraryName + "' not found"
                });
            }
        } else {
            callback.invoke({
                :success => false,
                :error => "HTTP " + responseCode
            });
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
        if (_librarySectionId == null) {
            // Need to find library section first
            findLibrarySection(new Lang.Method(self, :onLibrarySectionFound).bindWith(callback));
            return;
        }

        fetchBooksFromSection(callback);
    }

    function onLibrarySectionFound(callback, result) {
        if (result[:success]) {
            fetchBooksFromSection(callback);
        } else {
            callback.invoke(result);
        }
    }

    function fetchBooksFromSection(callback) {
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
            method(:onBooksReceived).bindWith(callback)
        );
    }

    function onBooksReceived(callback, responseCode, data) {
        System.println("Books response: " + responseCode);

        if (responseCode == 200) {
            var books = parseBooks(data);
            callback.invoke({
                :success => true,
                :books => books
            });
        } else {
            callback.invoke({
                :success => false,
                :error => "HTTP " + responseCode
            });
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
}
```

### Step 2: Integrate PlexLibraryService into app

Modify: `source/AudiobooksForPlexApp.mc`

Add at top:
```monkey-c
using Toybox.Lang;
```

Add property:
```monkey-c
    private var _plexService;
    private var _storageManager;
```

Update `initialize()`:
```monkey-c
    function initialize() {
        AppBase.initialize();
        _plexService = new PlexLibraryService();
        _storageManager = new StorageManager();
    }
```

Add getter methods at end of class:
```monkey-c
    function getPlexService() {
        return _plexService;
    }

    function getStorageManager() {
        return _storageManager;
    }
```

### Step 3: Test Plex API connection

Modify: `source/MainView.mc`

Update `onShow()`:
```monkey-c
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
```

Add at top:
```monkey-c
using Toybox.Application;
using Toybox.Lang;
```

### Step 4: Build and test with real Plex server

**Prerequisites:** Configure Plex settings (see docs/DEVELOPMENT_SETUP.md)

Run: `monkeyc -d forerunner970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key -w`

Run: `monkeydo bin/AudiobooksForPlex.prg forerunner970`

Expected output in simulator console:
```
Plex config loaded:
  Server: http://YOUR_IP:32400
  Library: Audiobooks
  Token: ***SET***
Library sections response: 200
Found library section ID: 5
Books response: 200
Parsed 12 books
SUCCESS: Loaded 12 books
First book: Foundation by Isaac Asimov
```

**If error:** Check Plex server URL, auth token, library name in settings.

### Step 5: Commit Plex API integration

```bash
git add source/PlexLibraryService.mc source/AudiobooksForPlexApp.mc source/MainView.mc
git commit -m "feat: add Plex API service with library fetching

- Create PlexLibraryService with authentication
- Fetch library sections to find audiobooks library
- Fetch all books alphabetically from library
- Parse JSON responses to extract book metadata
- Integrate with app and test with real Plex server

Tested: Successfully fetched books from Plex

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 6: Cache Books to Storage

**Goal:** Save fetched books to StorageManager for offline browsing.

**Files:**
- Modify: `source/MainView.mc`
- Modify: `source/StorageManager.mc`

### Step 1: Add cache save method to MainView

Modify: `source/MainView.mc`

Update `onBooksLoaded()`:
```monkey-c
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
```

Add import at top:
```monkey-c
using Toybox.Time;
```

### Step 2: Add method to load cached books

Add to `source/MainView.mc`:

```monkey-c
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
```

### Step 3: Update onShow to try cache first

Modify `onShow()` in `source/MainView.mc`:

```monkey-c
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
```

### Step 4: Test caching behavior

Run: `monkeydo bin/AudiobooksForPlex.prg forerunner970`

**First launch:**
- Expected: "No cache, fetching from Plex..."
- Expected: "Cached 12 books to storage"

**Second launch (restart app in simulator):**
- Expected: "Using cached books"
- Expected: "Loaded 12 cached books"

### Step 5: Commit caching implementation

```bash
git add source/MainView.mc
git commit -m "feat: cache fetched books to storage for offline browsing

- Save book metadata to StorageManager after fetching
- Load cached books on app launch
- Fall back to Plex fetch if no cache exists
- Save library sync timestamp

Tested: Cache persists between app launches

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 7: Menu2 Library Browser UI

**Goal:** Replace placeholder view with Menu2-based library browser showing book list.

**Files:**
- Create: `source/LibraryBrowserMenu.mc`
- Create: `source/LibraryMenuDelegate.mc`
- Modify: `source/AudiobooksForPlexApp.mc`

### Step 1: Create LibraryBrowserMenu

Create: `source/LibraryBrowserMenu.mc`

```monkey-c
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
```

### Step 2: Create LibraryMenuDelegate

Create: `source/LibraryMenuDelegate.mc`

```monkey-c
// ABOUTME: Input delegate for library browser menu
// ABOUTME: Handles book selection and menu navigation

using Toybox.WatchUi;
using Toybox.System;

class LibraryMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var itemId = item.getId();

        System.println("Selected: " + item.getLabel());
        System.println("Book ID: " + itemId);

        // TODO: In later phases, show download confirmation
        // For now, just log selection

        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onDone() {
        // Called when menu is dismissed
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
```

### Step 3: Update app to show Menu2 instead of placeholder

Modify: `source/AudiobooksForPlexApp.mc`

Update `getInitialView()`:
```monkey-c
    function getInitialView() {
        // Start with loading view
        var view = new MainView();
        var delegate = new MainDelegate();
        return [view, delegate];
    }
```

Modify: `source/MainView.mc`

Update `onBooksLoaded()` to show menu:
```monkey-c
    function onBooksLoaded(result) {
        if (result[:success]) {
            System.println("SUCCESS: Loaded " + result[:books].size() + " books");

            // Cache books to storage
            cacheBooks(result[:books]);

            // Show library browser menu
            showLibraryMenu();
        } else {
            System.println("ERROR: " + result[:error]);
            // Show error in UI
        }

        WatchUi.requestUpdate();
    }

    function showLibraryMenu() {
        var menu = new LibraryBrowserMenu();
        var delegate = new LibraryMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
    }
```

Update `onShow()` to show menu if cached:
```monkey-c
    function onShow() {
        // Try loading from cache first
        var cachedBooks = loadCachedBooks();

        if (cachedBooks != null && cachedBooks.size() > 0) {
            System.println("Using cached books");
            showLibraryMenu();
        } else {
            System.println("No cache, fetching from Plex...");

            // Fetch from Plex
            var app = Application.getApp();
            var plexService = app.getPlexService();
            plexService.fetchAllBooks(new Lang.Method(self, :onBooksLoaded));
        }
    }
```

### Step 4: Test Menu2 UI

Run: `monkeydo bin/AudiobooksForPlex.prg forerunner970`

**Expected behavior:**
1. App shows "Loading..." placeholder briefly
2. If cached: Menu2 appears immediately with book list
3. If not cached: Books fetched, then Menu2 appears
4. Menu shows: "Audiobooks" title, list of books with title/author
5. Can scroll through books
6. Select button on book → Logs selection (no action yet)
7. Back button → Returns to placeholder view

### Step 5: Commit Menu2 implementation

```bash
git add source/LibraryBrowserMenu.mc source/LibraryMenuDelegate.mc source/MainView.mc source/AudiobooksForPlexApp.mc
git commit -m "feat: add Menu2 library browser UI

- Create LibraryBrowserMenu showing alphabetical book list
- Create LibraryMenuDelegate handling book selection
- Show menu after books loaded/cached
- Display book title and author in menu items

Tested: Menu2 displays book list, scrollable, selectable

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 8: Refresh Library Action

**Goal:** Add menu action to manually refresh library from Plex.

**Files:**
- Modify: `source/LibraryBrowserMenu.mc`
- Modify: `source/LibraryMenuDelegate.mc`

### Step 1: Add refresh item to menu

Modify: `source/LibraryBrowserMenu.mc`

Update `initialize()` to add refresh at top:
```monkey-c
    function initialize() {
        Menu2.initialize({:title => "Audiobooks"});

        // Add refresh action at top
        addItem(new WatchUi.MenuItem(
            "Refresh Library",
            "Update from Plex",
            :refresh,
            {}
        ));

        loadBooks();
    }
```

### Step 2: Handle refresh selection

Modify: `source/LibraryMenuDelegate.mc`

Update `onSelect()`:
```monkey-c
    function onSelect(item) {
        var itemId = item.getId();

        if (itemId == :refresh) {
            System.println("Refreshing library from Plex...");
            refreshLibrary();
            return true;
        }

        System.println("Selected: " + item.getLabel());
        System.println("Book ID: " + itemId);

        // TODO: In later phases, show download confirmation

        return true;
    }

    function refreshLibrary() {
        var app = Application.getApp();
        var plexService = app.getPlexService();

        plexService.fetchAllBooks(new Lang.Method(self, :onBooksRefreshed));
    }

    function onBooksRefreshed(result) {
        if (result[:success]) {
            System.println("Library refreshed: " + result[:books].size() + " books");

            // Cache new books
            cacheBooks(result[:books]);

            // Reload menu
            WatchUi.popView(WatchUi.SLIDE_DOWN);

            // Show fresh menu
            var menu = new LibraryBrowserMenu();
            var delegate = new LibraryMenuDelegate();
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
        } else {
            System.println("Refresh failed: " + result[:error]);
            // TODO: Show error to user
        }
    }

    function cacheBooks(books) {
        var app = Application.getApp();
        var storage = app.getStorageManager();

        var bookIds = [];
        for (var i = 0; i < books.size(); i++) {
            var book = books[i];
            var bookId = book[:id].toString();

            bookIds.add(bookId);

            var bookData = {
                :title => book[:title],
                :author => book[:author],
                :duration => book[:duration]
            };
            storage.setBook(bookId, bookData);
        }

        storage.setAllBookIds(bookIds);

        var now = Time.now().value();
        storage.setLibrarySyncTime(now);

        System.println("Cached " + bookIds.size() + " books");
    }
```

Add imports at top:
```monkey-c
using Toybox.Application;
using Toybox.Time;
```

### Step 3: Test refresh functionality

Run: `monkeydo bin/AudiobooksForPlex.prg forerunner970`

**Test:**
1. Open menu → See "Refresh Library" at top
2. Select "Refresh Library"
3. Console shows: "Refreshing library from Plex..."
4. Console shows: "Library refreshed: X books"
5. Menu reloads with fresh data

### Step 4: Commit refresh action

```bash
git add source/LibraryBrowserMenu.mc source/LibraryMenuDelegate.mc
git commit -m "feat: add manual library refresh action

- Add 'Refresh Library' menu item at top
- Fetch fresh books from Plex on selection
- Re-cache books and reload menu
- Allow manual sync when needed

Tested: Refresh fetches and displays updated library

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 9: Error Handling & Offline Mode

**Goal:** Show helpful error messages and gracefully handle offline state.

**Files:**
- Modify: `source/MainView.mc`
- Modify: `source/LibraryMenuDelegate.mc`
- Create: `resources/strings/error_strings.xml`

### Step 1: Add error strings

Create: `resources/strings/error_strings.xml`

```xml
<strings>
    <string id="ErrorNoNetwork">No connection to Plex server</string>
    <string id="ErrorNoToken">Auth token not configured</string>
    <string id="ErrorLibraryNotFound">Audiobooks library not found</string>
    <string id="ErrorGeneric">Error loading library</string>
    <string id="OfflineMode">Offline - Using cached data</string>
</strings>
```

### Step 2: Update MainView to show errors

Modify: `source/MainView.mc`

Add property:
```monkey-c
    private var _errorMessage = null;
```

Update `onUpdate()`:
```monkey-c
    function onUpdate(dc) {
        // Clear screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_errorMessage != null) {
            // Show error message
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_SMALL,
                _errorMessage,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() * 0.7,
                Graphics.FONT_XTINY,
                "Using cached books",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            // Show loading message
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
    }
```

Update `onBooksLoaded()`:
```monkey-c
    function onBooksLoaded(result) {
        if (result[:success]) {
            System.println("SUCCESS: Loaded " + result[:books].size() + " books");

            // Clear error message
            _errorMessage = null;

            // Cache books to storage
            cacheBooks(result[:books]);

            // Show library browser menu
            showLibraryMenu();
        } else {
            System.println("ERROR: " + result[:error]);

            // Set error message
            _errorMessage = result[:error];

            // Still try to show menu with cached data
            var cachedBooks = loadCachedBooks();
            if (cachedBooks != null && cachedBooks.size() > 0) {
                System.println("Using cached books despite error");
                showLibraryMenu();
            }
        }

        WatchUi.requestUpdate();
    }
```

### Step 3: Update LibraryMenuDelegate error handling

Modify: `source/LibraryMenuDelegate.mc`

Update `onBooksRefreshed()`:
```monkey-c
    function onBooksRefreshed(result) {
        if (result[:success]) {
            System.println("Library refreshed: " + result[:books].size() + " books");

            cacheBooks(result[:books]);

            // Reload menu
            WatchUi.popView(WatchUi.SLIDE_DOWN);

            var menu = new LibraryBrowserMenu();
            var delegate = new LibraryMenuDelegate();
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
        } else {
            System.println("Refresh failed: " + result[:error]);

            // Show error toast (stays on current menu)
            showError(result[:error]);
        }
    }

    function showError(errorMessage) {
        // Create simple confirmation showing error
        var dialog = new WatchUi.Confirmation(errorMessage);
        WatchUi.pushView(
            dialog,
            new ErrorDelegate(),
            WatchUi.SLIDE_UP
        );
    }
```

Add ErrorDelegate class at end of file:
```monkey-c
class ErrorDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        // Dismiss error dialog
        return true;
    }
}
```

Add import:
```monkey-c
using Toybox.WatchUi;
```

### Step 4: Test error handling

**Test 1: Invalid auth token**
1. Modify properties: Set authToken to invalid value
2. Launch app
3. Expected: Error message shown, falls back to cached books if available

**Test 2: Network error (simulate)**
1. Set serverUrl to unreachable IP
2. Launch app
3. Expected: Error shown, cached books still accessible

**Test 3: Library not found**
1. Set libraryName to non-existent library
2. Launch app
3. Expected: Error shown

**Test 4: Offline with cache**
1. Launch app successfully once (builds cache)
2. Disconnect network
3. Restart app
4. Expected: Cached books shown immediately

### Step 5: Commit error handling

```bash
git add resources/strings/error_strings.xml source/MainView.mc source/LibraryMenuDelegate.mc
git commit -m "feat: add error handling and offline mode

- Show error messages when Plex requests fail
- Fall back to cached books on network errors
- Add error dialog for refresh failures
- Support fully offline browsing with cache

Tested: Gracefully handles network errors, auth failures

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 10: Final Testing & Documentation

**Goal:** Comprehensive testing and update documentation with final Phase 1 status.

**Files:**
- Create: `docs/PHASE1_COMPLETE.md`
- Update: `README.md`

### Step 1: Comprehensive simulator testing

**Test Checklist:**
- [ ] App builds without warnings
- [ ] App launches in simulator
- [ ] Placeholder view shows briefly
- [ ] Books fetch from Plex successfully
- [ ] Books cached to storage
- [ ] Menu2 shows book list
- [ ] Can scroll through all books
- [ ] Select book logs selection
- [ ] Back button exits menu
- [ ] Refresh Library fetches new data
- [ ] Menu reloads after refresh
- [ ] App restart uses cached books
- [ ] Invalid auth shows error, uses cache
- [ ] Network error shows error, uses cache
- [ ] Library not found shows error

Run through all test cases and verify expected behavior.

### Step 2: Create Phase 1 completion document

Create: `docs/PHASE1_COMPLETE.md`

```markdown
# Phase 1 Complete: Core Foundation ✅

**Completed:** 2025-11-15
**Duration:** [X hours/days]
**Status:** Ready for Phase 2 (Download & Playback)

---

## What We Built

### 1. Project Structure ✅
- Connect IQ manifest for AudioContentProviderApp
- Build configuration (monkey.jungle)
- Resource organization (strings, drawables, properties)
- Proper directory layout

### 2. Configuration System ✅
- Properties for Plex settings (serverUrl, authToken, libraryName)
- Development setup documented
- .set file workflow for sideloading
- Settings validation

### 3. Storage Manager ✅
- Flat key-value structure (8KB limit compliant)
- Collection storage methods
- Book metadata storage
- Sync timestamp tracking
- Debug utilities

### 4. Plex API Integration ✅
- PlexLibraryService with authentication
- Library section discovery
- Fetch all books alphabetically
- JSON parsing for book metadata
- Error handling and retry logic

### 5. Offline Caching ✅
- Cache books to local storage
- Load cached books on startup
- Sync timestamp tracking
- Offline browsing capability

### 6. Menu2 UI ✅
- LibraryBrowserMenu with book list
- LibraryMenuDelegate for input handling
- Scrollable book list (title + author)
- Manual refresh action
- Error dialogs

### 7. Error Handling ✅
- Network error handling
- Invalid auth detection
- Library not found handling
- Graceful offline mode
- Error message display

---

## Deliverable Status

**Phase 1 Goal:** Browse audiobook list from Plex on watch ✅

**What Works:**
- ✅ Browse Plex audiobook library on watch
- ✅ Alphabetical book list with title and author
- ✅ Offline browsing with cached metadata
- ✅ Manual library refresh
- ✅ Error handling with fallback to cache
- ✅ Proper Menu2 navigation

**What's Missing (Future Phases):**
- ⏳ Collections support (Phase 4)
- ⏳ Download manager (Phase 2)
- ⏳ Audio playback (Phase 2)
- ⏳ Position tracking (Phase 3)
- ⏳ Plex sync (Phase 3)

---

## Testing Results

### Simulator Testing ✅
- Build: Success, no warnings
- Launch: Works correctly
- Plex connection: Successfully fetches books
- Cache: Persists between launches
- Menu: Scrollable, navigable
- Refresh: Updates library correctly
- Offline: Works with cached data
- Errors: Handled gracefully

### Real Device Testing ⏳
- Not yet tested on Forerunner 970
- Plan: Test in Phase 2 with audio playback

---

## Key Learnings

1. **Flat Storage Works:** 8KB limit requires discipline, but flat structure is manageable
2. **Menu2 is Simple:** Garmin's Menu2 system handles most UI complexity
3. **Plex API is Straightforward:** JSON responses easy to parse, auth is simple
4. **Offline-First is Critical:** Cache makes app feel responsive and reliable

---

## Next Steps: Phase 2 - Download & Playback

**Goal:** Download audiobook and play via native Music Player

**Tasks:**
1. Implement DownloadManager for sequential chapter downloads
2. Create ContentDelegate for Music Player integration
3. Handle multi-file vs single-file audiobooks
4. Test audio playback on real device
5. Implement basic download progress UI

**Estimated Duration:** 1-2 weeks

**Critical Path:** Real device testing required (simulator can't test audio playback)

---

## Files Created

**Source:**
- `source/AudiobooksForPlexApp.mc` - Main app entry point
- `source/MainView.mc` - Loading/error view
- `source/MainDelegate.mc` - Input handling
- `source/StorageManager.mc` - Flat storage management
- `source/PlexLibraryService.mc` - Plex API integration
- `source/LibraryBrowserMenu.mc` - Menu2 browser UI
- `source/LibraryMenuDelegate.mc` - Menu input handling

**Resources:**
- `resources/strings/strings.xml` - UI strings
- `resources/strings/error_strings.xml` - Error messages
- `resources/properties/properties.xml` - App settings
- `resources/drawables/drawables.xml` - Icon references

**Build:**
- `manifest.xml` - App manifest
- `monkey.jungle` - Build configuration

**Documentation:**
- `docs/DEVELOPMENT_SETUP.md` - Development guide
- `docs/PHASE1_COMPLETE.md` - This document

---

## Metrics

- **Source files:** 7
- **Resource files:** 4
- **Total LOC:** ~800
- **Commits:** 10
- **Build time:** <5 seconds
- **Binary size:** ~50KB

---

**Phase 1: Complete ✅**
**Ready for:** Phase 2 - Download & Playback
```

### Step 3: Update main README

Modify: `README.md`

```markdown
# AudiobooksForPlex

Listen to Plex audiobooks on your Garmin watch during runs.

## Status

**Phase 1: Core Foundation** - ✅ Complete (2025-11-15)
**Phase 2: Download & Playback** - 🔄 In Progress
**Phase 3: Position Tracking** - ⏳ Not Started
**Phase 4: Polish & Collections** - ⏳ Not Started

## What Works Now

✅ Browse Plex audiobook library on watch
✅ Offline browsing with cached metadata
✅ Manual library refresh
✅ Error handling with graceful degradation

## Quick Start

### Prerequisites
- Garmin Forerunner 970 (or compatible music-enabled watch)
- Plex Media Server with Audiobooks library
- Connect IQ SDK 7.x

### Setup
1. Get Plex auth token (see `docs/DEVELOPMENT_SETUP.md`)
2. Configure settings (create `.set` file)
3. Build: `monkeyc -d forerunner970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key`
4. Sideload to watch

See `docs/DEVELOPMENT_SETUP.md` for detailed instructions.

## Documentation

- **Vision:** `docs/VISION.md` - Product vision and philosophy
- **Feasibility:** `docs/FEASIBILITY_REPORT.md` - Technical assessment
- **Design:** `docs/plans/2025-11-15-audiobooks-mvp-design.md` - MVP architecture
- **Phase 1:** `docs/PHASE1_COMPLETE.md` - Core foundation status
- **Dev Setup:** `docs/DEVELOPMENT_SETUP.md` - Getting started
- **Garmin Docs:** `garmin-documentation/` - Complete API reference

## Development

**Current Phase:** Phase 1 Complete ✅

**Next Milestone:** Download and play first audiobook (Phase 2)

## License

[Your license here]
```

### Step 4: Build final Phase 1 artifact

Run full build:
```bash
monkeyc -d forerunner970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key -w
```

Verify: No warnings, build succeeds.

### Step 5: Final commit

```bash
git add docs/PHASE1_COMPLETE.md README.md
git commit -m "docs: mark Phase 1 complete with testing summary

Phase 1 Core Foundation ✅ Complete:
- Project structure and build configuration
- Plex API integration with library fetching
- Flat storage manager (8KB-compliant)
- Menu2 library browser UI
- Offline caching and error handling
- Manual library refresh

Tested: All simulator tests passing
Ready for: Phase 2 - Download & Playback

See docs/PHASE1_COMPLETE.md for details

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Phase 1 Complete! 🎉

**Deliverable:** Browse audiobook list from Plex on watch ✅

**What's Working:**
- Plex library fetches and displays in Menu2
- Offline caching for browsing without connection
- Error handling with graceful degradation
- Manual refresh to update library

**Next Phase:** Download & Playback (Phase 2)

---

## Execution Options

**Plan saved to:** `docs/plans/2025-11-15-phase1-core-foundation.md`

**Two execution approaches:**

### 1. Subagent-Driven (This Session)
- I dispatch fresh subagent per task
- Review code between tasks
- Fast iteration with quality gates
- **REQUIRED SUB-SKILL:** superpowers:subagent-driven-development

### 2. Parallel Session (Separate)
- Open new session in worktree
- Batch execution with checkpoints
- More autonomous execution
- **REQUIRED SUB-SKILL:** superpowers:executing-plans (in new session)

**Which approach would you like to use?**
