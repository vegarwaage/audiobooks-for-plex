# PlexRunner - Claude Code Development Guide

**Project:** Audiobooks for Plex on Garmin Watches (PlexRunner)
**Target Device:** Garmin Forerunner 970
**App Type:** AudioContentProviderApp
**Status:** ✅ Feasibility Confirmed - Ready for Development

---

## Quick Start

**Before coding, read:**
1. `/FEASIBILITY_REPORT.md` - Complete technical assessment and architecture decisions
2. `/VISION.md` - Product vision and design philosophy

**Key Decision:** This is an **AudioContentProviderApp**, not a custom audio player. We integrate with Garmin's native Music Player.

---

## Garmin Documentation Navigation

All Garmin Connect IQ documentation is stored locally in `/garmin-documentation/`. Use these files instead of web searches.

### Primary Documentation (Read These First)

**For AudioContentProviderApp Development:**
```
/garmin-documentation/basics/app-types-detailed.md
  → Section 5: Audio Providers (lines 579-636)
  → Shows AudioContentProviderApp structure and manifest config

/garmin-documentation/faq/audio-content-provider.md
  → Overview of audio content provider setup
  → Links to key concepts

/garmin-documentation/api-docs/Media.md
  → Toybox.Media module overview
  → ContentDelegate, ContentRef, PlaybackProfile classes
```

**For Core Implementation:**
```
/garmin-documentation/core-topics/networking.md
  → HTTP requests for Plex API (lines 1-876)
  → Error handling, retry logic, background sync
  → Essential for downloading audiobooks

/garmin-documentation/core-topics/persisting-data.md
  → Storage APIs and patterns
  → Important: 8KB value limit - use FLAT structure

/garmin-documentation/core-topics/downloading-content.md
  → Content delivery mechanisms
  → File management and progress tracking
```

**For Project Structure:**
```
/garmin-documentation/core-topics/project-structure.md
  → Standard layouts and naming conventions (lines 1-879)
  → Code organization patterns

/garmin-documentation/core-topics/manifest-structure.md
  → Complete manifest.xml reference (lines 1-719)
  → Permissions, device targeting
```

### API Reference (Quick Lookups)

```
/garmin-documentation/api-docs/toybox-overview.md
  → All Toybox modules at a glance
  → Lines 165-181: Toybox.Media overview
  → Lines 170-174: Toybox.Communications for HTTP

/garmin-documentation/reference-guides/common-apis.md
  → Quick patterns and code snippets (lines 1-895)
  → Time, storage, network, system APIs
```

### Advanced Topics (As Needed)

```
/garmin-documentation/core-topics/backgrounding.md
  → Background services for position sync

/garmin-documentation/core-topics/ui-development.md
  → Views, layouts, menus for audiobook selection UI

/garmin-documentation/core-topics/debugging-and-testing.md
  → Debugging patterns and simulator usage
```

---

## Architecture Overview

### Three-Phase Model (Garmin Standard)

**Phase 1: Sync Configuration**
- User selects audiobooks to download
- UI: On-watch browsing of Plex library
- See: `/garmin-documentation/core-topics/ui-development.md`

**Phase 2: Content Download**
- Download from Plex API endpoints
- Automatic AES-128 encryption
- See: `/garmin-documentation/core-topics/networking.md`

**Phase 3: Playback**
- Native Music Player integration
- ContentDelegate provides tracks
- See: `/garmin-documentation/basics/app-types-detailed.md` (lines 579-636)

### Required Classes

```monkey-c
// Base application
class PlexRunnerApp extends Application.AudioContentProviderApp

// Provides content to music player
class PlexContentDelegate extends Media.ContentDelegate

// Optional but recommended for background sync
class PositionSyncService extends System.ServiceDelegate
```

---

## Key Technical Constraints

### Storage (CRITICAL)

**8KB per Storage value limit**

❌ **WRONG - Nested structure:**
```monkey-c
Storage.setValue("audiobooks", {
    "123": {
        title: "Book",
        chapters: [{...}, {...}]  // Will exceed 8KB!
    }
});
```

✅ **CORRECT - Flat structure:**
```monkey-c
Storage.setValue("audiobook_ids", ["123", "456"]);
Storage.setValue("audiobook_123", {title: "Book", author: "Author"});
Storage.setValue("chapters_123", [{...}, {...}]);
Storage.setValue("position_123", {chapter: 0, position: 542});
```

**Reference:** `/FEASIBILITY_REPORT.md` Section 5.2 (lines 208-258)

### Audio Formats

**Supported:**
- MP3 → `Media.AUDIO_FORMAT_MP3`
- M4A → `Media.AUDIO_FORMAT_M4A`
- WAV → `Media.AUDIO_FORMAT_WAV`
- MP4 → `Media.AUDIO_FORMAT_M4A`
- M4B → `Media.AUDIO_FORMAT_M4A` (⚠️ needs testing)

**Detection pattern:**
```monkey-c
function getAudioFormat(container) {
    if (container.equals("mp3")) { return Media.AUDIO_FORMAT_MP3; }
    else if (container.equals("m4a") || container.equals("m4b")) {
        return Media.AUDIO_FORMAT_M4A;
    }
    else if (container.equals("wav")) { return Media.AUDIO_FORMAT_WAV; }
    return null;
}
```

### Chapter Navigation

**Multi-file audiobooks (RECOMMENDED):**
- Each chapter = separate audio file
- Each file = one "track" in music player
- Next/Previous buttons navigate chapters naturally

**Single-file audiobooks:**
- Garmin doesn't expose chapter markers in API
- Workaround: Server-side split into chapter files
- Alternative: Document as limitation

**Reference:** `/FEASIBILITY_REPORT.md` Section 7 (lines 458-542)

---

## Plex API Integration

### Authentication

**Simple token-based auth:**
```
Header: X-Plex-Token: {token}
OR
URL param: ?X-Plex-Token={token}
```

User provides:
- Server URL (e.g., `http://192.168.1.100:32400`)
- Auth token (from Plex account settings)
- Library name (optional)

Store in `Application.Properties` - see `/garmin-documentation/core-topics/properties-and-app-settings.md`

### Key Endpoints

**Browse Library:**
```
GET {server}/library/sections/{id}/all?X-Plex-Token={token}
```

**Get Metadata:**
```
GET {server}/library/metadata/{id}?X-Plex-Token={token}
```

**Download Audio:**
```
GET {server}/{part_path}?download=1&X-Plex-Token={token}
```

**Sync Position:**
```
POST {server}/:/timeline?ratingKey={id}&state=paused&time={ms}&X-Plex-Token={token}
```

**Implementation patterns:** `/garmin-documentation/core-topics/networking.md` (lines 1-180)

**Reference:** `/FEASIBILITY_REPORT.md` Section 4 (lines 344-507)

---

## Development Workflow

### Phase 1: Core Foundation (Weeks 1-3)

**Goal:** Download and play ONE audiobook

**Tasks:**
1. Create AudioContentProviderApp skeleton
2. Implement Plex authentication
3. Download single audiobook (hardcoded ID)
4. Implement ContentDelegate
5. Test playback on device
6. Add local position tracking

**Key files to reference:**
- `/garmin-documentation/basics/app-types-detailed.md` (Audio Provider example)
- `/garmin-documentation/core-topics/networking.md` (HTTP downloads)
- `/garmin-documentation/core-topics/project-structure.md` (File organization)

### Phase 2: Content Selection (Weeks 4-6)

**Goal:** User can browse and select audiobooks

**Tasks:**
1. Fetch audiobook list from Plex
2. Build on-watch UI for browsing
3. Implement download queue
4. Add progress indicators
5. Storage management (delete old books)

**Key files to reference:**
- `/garmin-documentation/core-topics/ui-development.md` (Views, menus, layouts)
- `/garmin-documentation/reference-guides/common-apis.md` (Quick UI patterns)

### Phase 3: Position Sync (Weeks 7-8)

**Goal:** Positions sync to Plex server

**Tasks:**
1. Implement background sync service
2. POST to Plex Timeline API
3. Handle offline queue
4. Test multi-device continuity

**Key files to reference:**
- `/garmin-documentation/core-topics/backgrounding.md` (Background services)
- `/garmin-documentation/core-topics/networking.md` (Section on Background Data Sync)

### Phase 4: Polish (Weeks 9-11)

**Goal:** Production-ready app

**Tasks:**
1. Error handling and retry logic
2. Chapter navigation (multi-file)
3. UI/UX improvements
4. Battery/memory optimization
5. Testing on real device
6. Store submission

**Key files to reference:**
- `/garmin-documentation/core-topics/debugging-and-testing.md` (Testing patterns)
- `/garmin-documentation/core-topics/profiling.md` (Performance optimization)

---

## Common Patterns

### ContentDelegate Implementation

```monkey-c
using Toybox.Media;

class PlexContentDelegate extends Media.ContentDelegate {
    private var _currentAudiobook;
    private var _currentChapter;

    function initialize(audiobook) {
        ContentDelegate.initialize();
        _currentAudiobook = audiobook;
        _currentChapter = 0;
    }

    // Provide content to player
    function getContent() {
        var chapters = Storage.getValue("chapters_" + _currentAudiobook.id);
        var refs = [];

        for (var i = 0; i < chapters.size(); i++) {
            var ref = new Media.ContentRef(
                chapters[i].url,
                Media.CONTENT_TYPE_AUDIO,
                {
                    :encoding => getAudioFormat(chapters[i].format),
                    :title => chapters[i].title,
                    :artist => _currentAudiobook.author,
                    :album => _currentAudiobook.title
                }
            );
            refs.add(ref);
        }

        return new Media.ContentIterator(refs, _currentChapter);
    }

    // Track position on events
    function onSongEvent(songEvent, playbackPosition) {
        if (songEvent == Media.SONG_EVENT_PLAYBACK_PAUSED) {
            savePosition(_currentAudiobook.id, _currentChapter, playbackPosition);
        }
        // Handle other events...
    }
}
```

**Reference:** `/garmin-documentation/core-topics/networking.md` has similar delegate patterns

### Position Tracking

```monkey-c
// Always save locally first (works offline)
function savePosition(audiobookId, chapter, position) {
    var posData = {
        :chapter => chapter,
        :position => position,
        :timestamp => Time.now().value(),
        :synced => false
    };
    Storage.setValue("position_" + audiobookId, posData);

    // Queue for background sync
    addToSyncQueue(audiobookId);
}

// Restore position
function getPosition(audiobookId) {
    var pos = Storage.getValue("position_" + audiobookId);
    return pos != null ? pos : {:chapter => 0, :position => 0};
}
```

### HTTP Download with Retry

```monkey-c
using Toybox.Communications;

function downloadAudioFile(url, callback) {
    var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {"X-Plex-Token" => getAuthToken()},
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO
    };

    Communications.makeWebRequest(
        url,
        {},
        options,
        method(:onDownloadComplete).bindWith(callback)
    );
}

function onDownloadComplete(callback, responseCode, data) {
    if (responseCode == 200) {
        // Save encrypted file via Media module
        callback.invoke({:success => true, :data => data});
    } else {
        // Retry logic - see networking.md lines 553-616
        callback.invoke({:success => false, :error => responseCode});
    }
}
```

**Reference:** `/garmin-documentation/core-topics/networking.md` (lines 553-616) for full retry pattern

---

## Manifest Configuration

**File:** `manifest.xml`

```xml
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        type="audio-content-provider-app"
        entry="PlexRunnerApp"
        id="YOUR_APP_ID"
        launcherIcon="@Drawables.LauncherIcon"
        minApiLevel="3.0.0">

        <iq:products>
            <iq:product id="forerunner970"/>
            <!-- Add other compatible devices -->
        </iq:products>

        <iq:permissions>
            <iq:uses-permission id="Communications"/>
            <iq:uses-permission id="Background"/>
            <iq:uses-permission id="Media"/>
        </iq:permissions>

        <iq:languages>
            <iq:language>eng</iq:language>
        </iq:languages>
    </iq:application>
</iq:manifest>
```

**Full manifest reference:** `/garmin-documentation/core-topics/manifest-structure.md` (lines 1-719)

---

## Testing Strategy

### Simulator Testing (Limited)
- UI and logic testing
- Navigation flows
- **Limitation:** Music player simulation is limited

### Real Device Testing (Essential)
- Forerunner 970 or similar music-enabled device
- Sideload .prg via USB
- Test actual audio playback
- Verify encryption/storage
- Battery usage monitoring

### Test Audiobooks
- Start with multi-file audiobooks (known to work)
- Test various formats (MP3, M4A, M4B)
- Use small files initially (faster iteration)
- Expand to full-size books in later phases

**Full testing guide:** `/garmin-documentation/core-topics/debugging-and-testing.md`

---

## Token-Efficient Documentation Lookups

**Instead of reading entire files, use targeted reads:**

### Example 1: Need HTTP retry logic?
```
Read: /garmin-documentation/core-topics/networking.md
Lines: 553-616 (Retry Logic section)
```

### Example 2: Need storage patterns?
```
Read: /FEASIBILITY_REPORT.md
Lines: 208-258 (Section 5.2 Metadata Storage)
```

### Example 3: Need UI menu code?
```
Read: /garmin-documentation/reference-guides/common-apis.md
Lines: 336-342 (Create menus pattern)
```

### Example 4: Need background service setup?
```
Read: /garmin-documentation/core-topics/networking.md
Lines: 620-698 (Background Data Sync section)
```

### Example 5: Need manifest permissions?
```
Read: /garmin-documentation/core-topics/manifest-structure.md
Lines: 150-250 (Permissions section with all types)
```

---

## Quick Decision Reference

**When you need to:**

| Task | Check | Line Range |
|------|-------|------------|
| Understand AudioContentProvider pattern | `/garmin-documentation/basics/app-types-detailed.md` | 579-636 |
| Implement HTTP downloads | `/garmin-documentation/core-topics/networking.md` | 1-180 |
| Store data efficiently | `/FEASIBILITY_REPORT.md` | 208-258 |
| Add background sync | `/garmin-documentation/core-topics/networking.md` | 620-698 |
| Create UI views/menus | `/garmin-documentation/core-topics/ui-development.md` | 1-907 |
| Configure manifest | `/garmin-documentation/core-topics/manifest-structure.md` | 1-719 |
| Handle errors | `/garmin-documentation/core-topics/networking.md` | 460-552 |
| Optimize performance | `/garmin-documentation/core-topics/debugging-and-testing.md` | 272-299 |

---

## Critical Reminders

### ✅ DO

- Use AudioContentProviderApp (not custom player)
- Store data in FLAT structure (8KB limit)
- Track positions locally first (offline-first)
- Support multi-file audiobooks
- Test M4B format early
- Read targeted sections of docs (save tokens)
- Reference feasibility report for architecture decisions

### ❌ DON'T

- Build custom audio player UI
- Use nested storage structures
- Block playback waiting for server sync
- Assume single-file chapter navigation works
- Re-download Garmin documentation (it's local!)
- Ignore the 8KB storage limit

---

## File Organization

**Recommended structure:**

```
/source/
  PlexRunnerApp.mc           # AudioContentProviderApp entry point
  PlexContentDelegate.mc     # ContentDelegate implementation
  PositionTracker.mc         # Position tracking logic
  PlexApi.mc                 # Plex API wrapper
  StorageManager.mc          # Flat storage handling

/source/views/
  AudiobookBrowserView.mc    # Browse Plex library
  DownloadProgressView.mc    # Download UI
  SettingsView.mc            # Configuration

/source/services/
  PositionSyncService.mc     # Background sync

/resources/
  layouts/                   # XML layouts
  drawables/                 # Icons, images
  strings/                   # Localization
  properties.xml             # App settings

manifest.xml                 # App manifest
monkey.jungle                # Build config
```

**Reference:** `/garmin-documentation/core-topics/project-structure.md` (lines 74-165)

---

## Getting Unstuck

**If you're stuck on:**

1. **"How do AudioContentProviderApps work?"**
   → Read `/garmin-documentation/basics/app-types-detailed.md` lines 579-636
   → Read `/FEASIBILITY_REPORT.md` Section 1.1

2. **"How do I download files from Plex?"**
   → Read `/garmin-documentation/core-topics/networking.md` lines 1-180
   → Read `/FEASIBILITY_REPORT.md` Section 4.2

3. **"Why is my storage failing?"**
   → Check if using nested structures (8KB limit!)
   → Read `/FEASIBILITY_REPORT.md` lines 208-258

4. **"How do I integrate with Music Player?"**
   → Implement ContentDelegate - see patterns above
   → Read `/garmin-documentation/basics/app-types-detailed.md` lines 605-636

5. **"How do I sync positions to Plex?"**
   → Background service with Timeline API
   → Read `/garmin-documentation/core-topics/networking.md` lines 620-698
   → Read `/FEASIBILITY_REPORT.md` Section 6.3

---

## Success Metrics

**MVP is successful when:**
1. ✅ Can download ONE audiobook from Plex
2. ✅ Playback works through native Music Player
3. ✅ Position tracked locally and persists
4. ✅ Runs on real Forerunner 970 device

**Full app is successful when:**
1. ✅ All success criteria from `/VISION.md` met
2. ✅ Published to Connect IQ Store
3. ✅ User can listen phone-free during runs

---

## External Resources (Only if Needed)

**Garmin Official:**
- API Docs: https://developer.garmin.com/connect-iq/api-docs/
- Forums: https://forums.garmin.com/developer/
- Store: https://apps.garmin.com/

**Plex:**
- API: https://developer.plex.tv/pms/
- Forums: https://forums.plex.tv/

**Note:** Most information is already in local documentation. Only use external resources for latest API changes or specific device issues.

---

**Last Updated:** 2025-11-15
**Project Status:** Feasibility Confirmed ✅
**Next Step:** Begin Phase 1 - Core Foundation

---

## Quick Command Reference

**Build:**
```bash
monkeyc -o bin/PlexRunner.prg -f monkey.jungle -y developer_key -d forerunner970
```

**Sideload:**
```bash
# Copy bin/PlexRunner.prg to watch via USB
```

**Test in simulator:**
```bash
connectiq
# Load PlexRunner.prg in simulator
```

---

*This guide is your roadmap. The local documentation has everything you need. Read targeted sections to save tokens. Build incrementally. Test frequently on real hardware.*
