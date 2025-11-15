# AudiobooksForPlex MVP Design

**Date:** 2025-11-15
**Status:** Ready for Implementation
**Target Device:** Garmin Forerunner 970
**App Type:** AudioContentProviderApp

---

## Overview

AudiobooksForPlex is an AudioContentProviderApp that bridges your Plex media server and Garmin's native Music Player, enabling offline audiobook listening during runs with cross-device position syncing.

**Core Value:** Listen to your Plex audiobooks on your watch during runs, with your listening position automatically synced back to Plex for seamless device switching.

---

## Design Decisions

### Scope: MVP (Position Sync Essential)

**Included in MVP:**
- Browse Plex audiobook library (Collections + alphabetical list)
- Download one audiobook at a time
- Offline playback via native Music Player
- Local position tracking (every 30s + on pause/chapter change)
- Background sync to Plex Timeline API
- Offline-capable with cached library metadata
- Support both multi-file and single-file audiobooks

**Excluded from MVP (Future Enhancements):**
- Multiple audiobooks on watch simultaneously
- Manual download management (auto-cleanup only)
- Smart queue (auto-download next in series)
- Playback speed control
- Statistics tracking

**Rationale:** Position syncing is what makes this genuinely useful versus manually copying MP3s. Without it, you lose your place when switching devices. The MVP focuses on delivering this core value with minimal complexity.

---

## Architecture

### High-Level Components

```
┌─────────────────────────────────────────────────┐
│         AudiobooksForPlex App                   │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────┐    ┌──────────────────┐  │
│  │ LibraryBrowser   │◄───┤ PlexLibrary      │  │
│  │ (Menu2 UI)       │    │ Service          │  │
│  └────────┬─────────┘    └──────────────────┘  │
│           │                                     │
│           ▼                                     │
│  ┌──────────────────┐    ┌──────────────────┐  │
│  │ Download         │◄───┤ StorageManager   │  │
│  │ Manager          │    │ (Flat Structure) │  │
│  └────────┬─────────┘    └──────────────────┘  │
│           │                                     │
│           ▼                                     │
│  ┌──────────────────┐    ┌──────────────────┐  │
│  │ ContentDelegate  │◄───┤ PositionTracker  │  │
│  │ (Playback)       │    │ (Local + Sync)   │  │
│  └────────┬─────────┘    └──────────────────┘  │
│           │                                     │
└───────────┼─────────────────────────────────────┘
            ▼
    ┌───────────────┐
    │ Music Player  │  (Garmin Native)
    │ (System)      │
    └───────────────┘
```

### Component Responsibilities

**1. PlexLibraryService**
- Manages HTTP connection to Plex server
- Fetches library metadata (collections, audiobooks)
- Authenticates with X-Plex-Token
- Handles retry logic and network errors
- Caches responses for offline browsing

**2. DownloadManager**
- Downloads audiobook chapter files sequentially
- One audiobook at a time with auto-cleanup
- Progress tracking and error handling
- Manages encrypted file storage via Media module
- Resume from last successful chapter on failure

**3. PositionTracker**
- Saves position locally every 30 seconds (via Timer)
- Saves on pause, chapter change, playback stop
- Queues sync requests to Plex Timeline API
- Retries failed syncs with exponential backoff
- Works completely offline with pending queue

**4. ContentDelegate** (Media.ContentDelegate)
- Provides chapter files to Music Player
- Receives playback events via onSongEvent()
- Triggers position saves on events
- Manages playback queue (ContentIterator)
- Handles chapter navigation

**5. LibraryBrowserView** (Menu2-based)
- Main UI for browsing collections and audiobooks
- Shows current downloaded book at top
- Collections → Books hierarchy
- Alphabetical book list below Collections
- Download confirmation dialogs

**6. StorageManager**
- FLAT key-value structure (8KB limit workaround)
- Manages cached library metadata
- Stores position data and sync queue
- Handles corrupted storage gracefully

---

## Data Storage Strategy

### Flat Structure (8KB per Value Limit)

**Library Metadata Cache:**
```
"library_last_sync": <timestamp>
"collection_ids": ["col1", "col2", "col3"]
"collection_col1": {name: "Sci-Fi", count: 5}
"collection_col2": {name: "Non-Fiction", count: 12}
"books_col1": ["book1", "book2", "book3"]
"book_book1": {title: "...", author: "...", key: "/library/...", duration: 36000}
"all_book_ids": ["book1", "book2", ..., "book50"]
```

**Current Audiobook:**
```
"current_book_id": "book123"
"current_book_meta": {title, author, key, chapterCount, duration}
"chapters_book123": [{title: "Ch 1", url: "...", duration: 1800}, ...]
"download_status_book123": {downloaded: true, timestamp: <time>}
```

**Position Tracking:**
```
"position_book123": {
    chapter: 2,              // Current chapter index
    position: 542000,        // Position in ms within chapter
    timestamp: 1234567890,   // When saved
    synced: false            // Needs Plex sync?
}
"sync_queue": ["book123", "book456"]  // Books with unsynced positions
```

**Why This Works:**
- Each value stays well under 8KB
- Easy to update individual pieces (just chapter position, not entire book)
- Chapters array might be largest value - split if needed for very long audiobooks
- Sync queue enables offline-first behavior

---

## Plex API Integration

### Authentication

**Method:** Token-based authentication
```
Header: X-Plex-Token: {token}
OR
URL param: ?X-Plex-Token={token}
```

**Configuration:** (via .set file during development)
- `serverUrl` - e.g., "http://192.168.1.100:32400"
- `authToken` - User's Plex auth token
- `libraryName` - e.g., "Audiobooks"

### Key Endpoints

**1. Get Library Section ID:**
```
GET {server}/library/sections?X-Plex-Token={token}
→ Find section matching libraryName ("Audiobooks")
→ Extract section ID
```

**2. Fetch Collections:**
```
GET {server}/library/sections/{id}/collections?X-Plex-Token={token}
→ Returns list of collections with keys
```

**3. Fetch Books in Collection:**
```
GET {server}/library/collections/{collectionKey}/children?X-Plex-Token={token}
→ Returns audiobooks in that collection
```

**4. Fetch All Books (alphabetical):**
```
GET {server}/library/sections/{id}/all?X-Plex-Token={token}&sort=titleSort:asc
→ Returns all audiobooks alphabetically
```

**5. Get Audiobook Metadata:**
```
GET {server}/library/metadata/{ratingKey}?X-Plex-Token={token}
→ Returns chapter/part list with download URLs
```

**6. Download Audio File:**
```
GET {server}{partPath}?download=1&X-Plex-Token={token}
Response type: HTTP_RESPONSE_CONTENT_TYPE_AUDIO
→ Encrypted audio file via Media module
```

**7. Sync Position (Timeline API):**
```
POST {server}/:/timeline?ratingKey={id}&state=paused&time={ms}&X-Plex-Token={token}
→ Updates playback position on Plex server
```

### Error Handling

- Retry logic with exponential backoff (5s, 10s, 30s, 60s max)
- Cache responses when possible (library metadata)
- Queue failed syncs for later retry
- Graceful degradation: offline mode with cached data

---

## UI Flow & Navigation

### Screen Structure (Menu2-based)

**Home Screen - LibraryMenu (Menu2):**
```
┌─────────────────────────┐
│    Audiobooks           │  ← Menu title
├─────────────────────────┤
│ ▶ Foundation            │  ← IconMenuItem (current book)
│   Ch 3/12 • 45%         │     with play icon
├─────────────────────────┤
│ 📁 Collections          │  ← IconMenuItem
│   Browse by collection  │
├─────────────────────────┤
│ Dune                    │  ← MenuItem
│   Frank Herbert         │     (title/author)
├─────────────────────────┤
│ Ender's Game            │
│   Orson Scott Card      │
├─────────────────────────┤
│ ...                     │
└─────────────────────────┘
```

**Collections Menu (Menu2):**
```
┌─────────────────────────┐
│    Collections          │
├─────────────────────────┤
│ Sci-Fi Series           │  ← MenuItem
│   5 books               │     (name/count)
├─────────────────────────┤
│ Non-Fiction             │
│   12 books              │
├─────────────────────────┤
│ Current Reads           │
│   3 books               │
└─────────────────────────┘
```

**Collection Books Menu (Menu2):**
```
┌─────────────────────────┐
│   Sci-Fi Series         │
├─────────────────────────┤
│ Foundation              │  ← MenuItem
│   Isaac Asimov          │
├─────────────────────────┤
│ Dune                    │
│   Frank Herbert         │
└─────────────────────────┘
```

**Download Confirmation (WatchUi.Confirmation):**
```
┌─────────────────────────┐
│                         │
│   Download this book?   │
│                         │
│     [ Yes ] [ No ]      │
└─────────────────────────┘
```

**Download Progress (Custom View):**
```
┌─────────────────────────┐
│    Downloading          │
│                         │
│    Foundation           │
│    Chapter 5/12         │
│    ████████░░░ 65%      │
└─────────────────────────┘
```

### Navigation Controls

- **Up/Down:** Scroll list
- **Select:** Choose item / Confirm
- **Back:** Return to previous screen / Exit app
- **Long-press Select (on current book):** Delete downloaded book

### Why Menu2?

- ✅ Handles scrolling automatically
- ✅ Adapts to screen shape (round/rectangle/semi-round)
- ✅ Consistent with other Garmin apps
- ✅ Built-in touch and button support
- ✅ Less code to maintain

---

## Position Tracking & Sync

### Local Position Saves

**Frequency:** Every 30 seconds during playback + on events

**Implementation:**
```monkey-c
// In ContentDelegate.onSongEvent()
function onSongEvent(songEvent, playbackPosition) {
    if (songEvent == Media.SONG_EVENT_PLAYBACK_PAUSED ||
        songEvent == Media.SONG_EVENT_PLAYBACK_COMPLETE) {

        savePositionLocal(currentChapter, playbackPosition);
    }
}

// Timer-based save during playback
var positionTimer = new System.Timer();
positionTimer.start(method(:saveCurrentPosition), 30000, true);  // 30s, repeating
```

**Storage:**
```
"position_book123": {
    chapter: 2,              // Current chapter index
    position: 542000,        // Position in ms within chapter
    timestamp: 1234567890,   // When saved
    synced: false            // Needs Plex sync?
}
```

### Sync to Plex (Hybrid Strategy)

**Trigger sync on:**
- Playback paused (immediate)
- Chapter change (immediate)
- Playback stopped (immediate)
- App backgrounded (if unsynced position exists)

**Failed syncs:**
- Add book ID to `"sync_queue": ["book123", "book456"]`
- Retry when: App returns to foreground + network available
- Retry logic: Exponential backoff (5s, 10s, 30s, 60s max)

**Timeline API Call:**
```
POST {server}/:/timeline
Params:
  ratingKey: <plex book id>
  state: paused/playing
  time: <position in ms>
  duration: <total duration in ms>
  X-Plex-Token: <token>
```

**Sync Queue Processing:**
```
On app resume / network reconnected:
  For each book in sync_queue:
    Try sync position to Plex
    If success: Remove from queue, mark position.synced = true
    If fail: Leave in queue, schedule retry
```

**Position Restoration:**
```
When book downloaded & playing:
  Read "position_book123" from Storage
  Start Music Player at chapter X, position Y ms
  ContentDelegate provides ContentIterator starting at correct chapter
```

---

## Download & Playback Flow

### Download Process

**1. User selects book → Fetch Metadata:**
```
GET {server}/library/metadata/{ratingKey}
→ Get list of Media parts (chapter files)
→ Extract: title, author, duration, chapter URLs
```

**2. Delete Previous Book (if exists):**
```
If "current_book_id" exists:
  Delete all chapter files from device (Media.deleteCachedItem)
  Clear position data
  Clear metadata
```

**3. Download Chapters Sequentially:**
```
For each chapter URL:
  GET {server}{partPath}?download=1&X-Plex-Token={token}
  Response type: HTTP_RESPONSE_CONTENT_TYPE_AUDIO
  Save encrypted file via Media.ContentRef
  Update progress: "Chapter X/Y downloaded"
```

**4. Store Metadata:**
```
"current_book_id": "book123"
"current_book_meta": {title, author, key, chapterCount, duration}
"chapters_book123": [{title, url, duration, localPath}, ...]
```

**5. Auto-launch Playback:**
```
Once all chapters downloaded:
  Create ContentDelegate with chapter list
  Push to Music Player
  Start playback from beginning (or saved position)
```

### Playback via ContentDelegate

**Provide Content to Music Player:**
```monkey-c
function getContent() {
    var chapters = Storage.getValue("chapters_" + currentBookId);
    var position = Storage.getValue("position_" + currentBookId);
    var startChapter = position != null ? position.chapter : 0;

    var refs = [];
    for (var i = 0; i < chapters.size(); i++) {
        var ref = new Media.ContentRef(
            chapters[i].localPath,
            Media.CONTENT_TYPE_AUDIO,
            {
                :encoding => getAudioFormat(chapters[i].format),
                :title => chapters[i].title,
                :artist => bookMeta.author,
                :album => bookMeta.title
            }
        );
        refs.add(ref);
    }

    return new Media.ContentIterator(refs, startChapter);
}
```

**Audio Format Detection:**
```monkey-c
function getAudioFormat(container) {
    if (container.equals("mp3")) {
        return Media.AUDIO_FORMAT_MP3;
    } else if (container.equals("m4a") || container.equals("m4b") || container.equals("mp4")) {
        return Media.AUDIO_FORMAT_M4A;
    } else if (container.equals("wav")) {
        return Media.AUDIO_FORMAT_WAV;
    }
    return null; // Unsupported format
}
```

**Music Player Handles:**
- Play/pause/next/previous buttons
- Volume control
- Lock screen controls
- Chapter navigation (next/previous track)

**App Only Handles:**
- Position tracking (via onSongEvent callbacks)
- Sync to Plex
- Library browsing/downloading

---

## Error Handling

### Network Failures

**During Library Browsing:**
- Show cached library if available
- Display "Last synced: 2 hours ago" indicator
- Retry button if sync fails
- Graceful degradation: can still browse/play downloaded content offline

**During Download:**
- Show error: "Download failed - retry?"
- Resume from last successful chapter (don't re-download completed chapters)
- Timeout handling: Retry after 10s, max 3 attempts per chapter
- Partial downloads: Clean up and allow fresh retry

**During Position Sync:**
- Silent failure (queued for later)
- No user interruption
- Sync indicator in UI: "Sync pending" badge on current book
- User never blocked by sync failures

### Storage Failures

**Out of Memory:**
- Detect before download starts (check available space)
- Show: "Not enough space - delete current book first"
- Provide delete option in confirmation dialog

**Corrupted Storage:**
- Try to read, catch exception
- Fall back to defaults if corrupt
- Log error for debugging
- Rebuild cache from Plex if needed

### Plex Server Issues

**Server Unreachable:**
- Use cached library (if exists)
- Show "Offline mode" indicator
- Allow playback of downloaded content
- Queue all syncs for later

**Authentication Failure:**
- Show: "Check Plex token in settings"
- Provide re-configuration instructions
- Don't delete downloaded content

**Library Not Found:**
- Show: "Audiobooks library not found"
- List available libraries for user
- Update settings with correct library name

### Audio Format Issues

**Unsupported Format:**
- Detect during metadata fetch
- Show: "Format not supported - MP3/M4A/M4B only"
- Don't attempt download

**Single-File Audiobook:**
- Show info: "Single file - no chapter navigation"
- Allow download anyway
- Plays as one long track

---

## Testing Strategy

### Hybrid Approach (Simulator + Real Device)

**Simulator Testing (Fast Iteration):**
- UI flow and Menu2 navigation
- Library browsing logic
- Storage operations (save/load/delete)
- Mock Plex responses (JSON files)
- Error handling paths

**Real Device Testing (Validation):**
- Audio playback (ContentDelegate → Music Player)
- Position tracking and sync
- Download performance
- Network error handling
- Battery impact
- Full end-to-end flow

**Test Audiobooks Setup:**
- Start with small multi-file audiobook (3-5 chapters, 10-15 min total)
- Then test full-length book (12+ chapters, 8+ hours)
- Test single-file audiobook for format compatibility
- Test various formats: MP3, M4A, M4B

---

## Development Phases

### Phase 1: Core Foundation (Week 1-2)
- Project setup (manifest, properties, basic structure)
- Plex API integration (auth, library fetch, metadata)
- Storage manager (flat structure implementation)
- Simple UI (Menu2 setup, basic library list)

**Deliverable:** Browse audiobook list from Plex on watch

### Phase 2: Download & Playback (Week 2-3)
- Download manager (sequential chapter downloads)
- ContentDelegate implementation
- Music Player integration
- Basic playback (no position tracking yet)

**Deliverable:** Download and play audiobook on watch

### Phase 3: Position Tracking (Week 3-4)
- Local position saves (every 30s + events)
- Plex Timeline API sync
- Sync queue and retry logic
- Position restoration on launch

**Deliverable:** Position syncs to Plex, survives app restarts

### Phase 4: Polish & Collections (Week 4-5)
- Collections support (browse hierarchy)
- Current book indicator in menu
- Download progress UI
- Error handling refinement
- Testing on real device with real audiobooks

**Deliverable:** Fully functional MVP ready for daily use

---

## Future Enhancements (Post-MVP)

**Documented for later implementation:**

1. **Manual Download Management**
   - Keep multiple audiobooks on watch
   - Manual delete controls
   - Storage usage display
   - **Note:** Currently MVP supports one book at a time with auto-cleanup

2. **Smart Queue**
   - Auto-download next book in series
   - Delete finished books automatically
   - Seamless progression through collections

3. **Playback Speed Control**
   - 0.5x to 2x speed (if Music Player supports)
   - Per-book speed preferences

4. **Statistics & Progress**
   - Listening time tracking
   - Books completed counter
   - Reading streak tracking

5. **Enhanced Browsing**
   - Search/filter capability
   - Recently listened
   - Favorites/bookmarks

---

## Technical Constraints

### Must Follow

**8KB Storage Limit:**
- Use FLAT key-value structure
- Never nest complex objects
- Split large arrays if needed

**AudioContentProviderApp Pattern:**
- Extend Application.AudioContentProvider
- Implement getContentDelegate()
- Use Media.ContentDelegate for playback integration

**Music Player Integration:**
- Provide content via ContentRef
- Receive events via onSongEvent()
- Don't build custom player UI

**Offline-First:**
- Save positions locally first
- Queue sync requests
- Never block on network operations

**Menu2 for Lists:**
- Use WatchUi.Menu2 for all list UIs
- Leverage built-in scrolling and formatting
- Consistent with Garmin conventions

### Format Support

**Confirmed:**
- MP3 (Media.AUDIO_FORMAT_MP3)
- M4A (Media.AUDIO_FORMAT_M4A)
- WAV (Media.AUDIO_FORMAT_WAV)
- MP4 (Media.AUDIO_FORMAT_M4A)

**Needs Testing:**
- M4B (likely Media.AUDIO_FORMAT_M4A)

**Multi-file vs Single-file:**
- Multi-file: Natural chapter navigation (recommended)
- Single-file: Works but no chapter markers (acceptable)

---

## Configuration

### Development (Sideloading)

**Settings via .set file:**

Create `AudiobooksForPlex.set`:
```xml
<?xml version="1.0"?>
<properties>
    <property id="serverUrl">http://192.168.1.100:32400</property>
    <property id="authToken">YOUR_PLEX_TOKEN_HERE</property>
    <property id="libraryName">Audiobooks</property>
</properties>
```

Copy to watch: `/GARMIN/APPS/SETTINGS/AudiobooksForPlex.set`

**Where to get Plex token:**
1. Log into Plex web interface
2. Play any media item
3. Click "..." → Get Info → View XML
4. Look for `X-Plex-Token` in URL

### Production (Connect IQ Store)

- Garmin Connect settings UI works automatically
- No manual file copying needed
- Same Properties code works unchanged

---

## Success Criteria

**MVP is successful when:**

1. ✅ Can browse Plex audiobook library on watch (Collections + alphabetical)
2. ✅ Can download one audiobook to watch
3. ✅ Downloaded audiobook plays via native Music Player
4. ✅ Position saves locally and survives app restart
5. ✅ Position syncs to Plex when connected
6. ✅ Can resume from saved position after switching devices
7. ✅ Works offline after initial download
8. ✅ Auto-cleanup when downloading new book
9. ✅ Both multi-file and single-file audiobooks work

**Ready for daily use when you trust it during actual runs.**

---

## Known Limitations (MVP)

1. **One book at a time** - Downloading new book deletes current book
2. **M4B format untested** - May need server-side conversion
3. **Single-file books** - No chapter navigation within file
4. **Manual settings** - .set file required during development
5. **No companion app** - All configuration on watch
6. **No playback speed** - Uses native player's default speed

All limitations documented for future enhancement.

---

## References

- **VISION.md** - Original product vision and design philosophy
- **FEASIBILITY_REPORT.md** - Technical assessment and API verification
- **Garmin Documentation** - `/garmin-documentation/` (comprehensive local docs)
- **Plex API** - https://developer.plex.tv/pms/ (Timeline API reference)

---

**Design Status:** ✅ Validated against Garmin documentation
**Next Step:** Implementation (Phase 1: Core Foundation)
