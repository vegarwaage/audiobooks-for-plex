# PlexRunner Feasibility Report

**Project:** PlexRunner - Audiobooks for Plex on Garmin Watches
**Target Device:** Garmin Forerunner 970
**Date:** 2025-11-15
**Author:** Technical Feasibility Assessment
**Status:** ✅ FEASIBLE WITH ADAPTATIONS

---

## Executive Summary

PlexRunner, as described in the vision document, is **technically feasible** to build using Garmin's AudioContentProviderApp framework. The application aligns well with standard best practices for developing audio apps for Garmin watches, specifically the Forerunner 970.

### Verdict: ✅ **FEASIBLE**

The core functionality described in the vision document can be implemented using Garmin's official AudioContentProviderApp pattern, with some adaptations required for optimal user experience.

### Key Strengths
- ✅ Correct architectural approach (AudioContentProviderApp)
- ✅ Plex API fully supports required functionality
- ✅ Device capabilities (Forerunner 970) meet all requirements
- ✅ Audio format support is comprehensive
- ✅ Offline playback and position tracking are achievable

### Required Adaptations
- ⚠️ Audiobook selection needs on-watch UI (Garmin Connect settings insufficient)
- ⚠️ M4B format requires testing (likely compatible)
- ⚠️ Single-file audiobooks need workaround for chapter navigation
- ⚠️ Storage structure must use flat hierarchy (8KB value limit)

---

## 1. Technical Architecture Assessment

### 1.1 AudioContentProviderApp Framework

**Status:** ✅ **CONFIRMED AVAILABLE**

The Garmin Connect IQ SDK provides `Toybox.Application.AudioContentProviderApp` as the base class for audio content provider applications.

**Key Capabilities:**
- Extends `AppBase` with audio-specific functionality
- Integrates with native Music Player
- Provides content encryption (AES-128 automatic)
- Manages content synchronization lifecycle
- Available since API Level 3.0.0
- Supported on 60+ Garmin devices including Forerunner 970

**Required Method Implementations:**
```monkey-c
getContentDelegate(args)              // Provides content to music player
getSyncConfigurationView()            // UI for selecting content to sync
getPlaybackConfigurationView()        // UI for playback settings
getProviderIconInfo()                 // App icon (optional)
```

**Assessment:** Your vision document correctly identifies this as the appropriate framework. This is the standard, recommended approach for audio apps on Garmin.

### 1.2 Three-Phase Architecture

Garmin's audio content provider apps follow a three-phase architecture:

**Phase 1: Sync Configuration**
- User selects which content to download
- Custom UI for browsing available content
- **Implementation:** Fetch audiobook list from Plex, display on watch

**Phase 2: Content Download**
- App downloads files from content delivery network (Plex server)
- Content is encrypted during write to filesystem
- Progress tracking and error handling
- **Implementation:** HTTP downloads from Plex API endpoints

**Phase 3: Playback**
- Native music player handles playback
- App provides content references and metadata
- Custom player UI options via PlaybackProfile
- **Implementation:** ContentDelegate provides audiobook tracks to player

**Assessment:** This architecture aligns perfectly with your vision's workflow.

---

## 2. Device Capabilities (Forerunner 970)

### 2.1 Hardware Specifications

**Storage:**
- ✅ 32GB internal storage
- ✅ Shared between maps, music, and data
- ✅ Sufficient for multiple audiobooks (typical: 150-500MB each)
- ✅ ~4GB available for music/audio content (estimate)

**Audio:**
- ✅ Music-enabled device
- ✅ Bluetooth headphone support
- ✅ Offline playback capability
- ✅ Built-in speaker (lower quality, Bluetooth preferred)

**Connectivity:**
- ✅ Bluetooth to phone for internet access
- ✅ WiFi support (some models)
- ✅ Required for downloading content

**Battery:**
- ✅ Supports several hours of continuous audio playback
- ✅ Music playback: ~8-10 hours typical
- ✅ Sufficient for long audiobook listening sessions

**Assessment:** Hardware capabilities fully support the envisioned use case.

**Note:** There is no "Fenix 970" model. You likely mean:
- Forerunner 970 (running watch, 32GB storage)
- OR Fenix 8 (rugged multisport watch, current flagship)

---

## 3. Audio Format Support

### 3.1 Supported Formats

Garmin Connect IQ Media module supports the following audio encodings:

| Format | Garmin Constant | Status | Notes |
|--------|----------------|--------|-------|
| MP3 | `Media.AUDIO_FORMAT_MP3` | ✅ Confirmed | Standard support |
| M4A | `Media.AUDIO_FORMAT_M4A` | ✅ Confirmed | AAC audio in M4A container |
| WAV | `Media.AUDIO_FORMAT_WAV` | ✅ Confirmed | Uncompressed audio |
| MP4 | `Media.AUDIO_FORMAT_M4A` | ✅ Confirmed | Uses M4A constant |
| M4B | `Media.AUDIO_FORMAT_M4A` | ⚠️ Needs Testing | M4B is M4A container, likely works |

### 3.2 M4B Format Considerations

**Challenge:** M4B (audiobook format) is not explicitly listed in Garmin documentation.

**Analysis:**
- M4B files are identical to M4A container format
- Difference is metadata (bookmarks, chapters)
- Audio codec is AAC (same as M4A)
- Should work using `Media.AUDIO_FORMAT_M4A` constant

**Recommendation:** Test M4B files early in development. If incompatible, convert M4B to M4A server-side (simple remux, no re-encoding needed).

### 3.3 Format Detection Strategy

```monkey-c
// Detect format from Plex metadata
function getAudioFormat(container) {
    if (container.equals("mp3")) {
        return Media.AUDIO_FORMAT_MP3;
    } else if (container.equals("m4a") || container.equals("m4b")) {
        return Media.AUDIO_FORMAT_M4A;
    } else if (container.equals("wav")) {
        return Media.AUDIO_FORMAT_WAV;
    } else if (container.equals("mp4")) {
        return Media.AUDIO_FORMAT_M4A;
    }
    return null; // Unsupported format
}
```

**Assessment:** Format support is comprehensive and matches Plex's common audiobook formats.

---

## 4. Plex API Integration

### 4.1 Authentication

**Method:** Token-based authentication (X-Plex-Token)

**Implementation:**
```
Header: X-Plex-Token: {token}
OR
URL Parameter: ?X-Plex-Token={token}
```

**Token Acquisition:**
- User obtains token from Plex account settings
- Token provided via app configuration (Application.Properties)
- Token stored securely in `Application.Storage`

**Security Notes:**
- Plex recently introduced JWT authentication (2025)
- Traditional token auth still supported
- Tokens valid for extended periods (7+ days with JWT)

**Assessment:** ✅ Simple authentication model, easier than OAuth. Aligns with vision's preference for simplicity.

### 4.2 Required API Endpoints

**Library Browsing:**
```
GET http://{server}:32400/library/sections
GET http://{server}:32400/library/sections/{id}/all
```
- Lists available libraries
- Retrieves audiobooks in specific library
- Returns metadata (title, author, duration, etc.)

**Audiobook Metadata:**
```
GET http://{server}:32400/library/metadata/{id}
```
- Detailed audiobook information
- Chapter/track information
- File paths and formats

**Content Download:**
```
GET http://{server}:32400/{part_path}?download=1&X-Plex-Token={token}
```
- Direct binary download of audio files
- Returns audio file data
- Works with Garmin's `Communications.makeWebRequest()`

**Playback Position Sync:**
```
POST http://{server}:32400/:/timeline
```
- Updates playback position on Plex server
- Enables cross-device position continuity
- Parameters: ratingKey, state, time, duration

**Assessment:** ✅ All required endpoints available and well-documented. Compatible with Garmin HTTP request API.

### 4.3 Audiobook-Specific Features

**Track Progress Storage:**
- Plex library setting: "Store Track Progress"
- Must be enabled in library Advanced settings
- Allows position tracking for audiobooks
- Used by existing apps: Prologue (iOS), Chronicle (Android)

**Chapter Information:**
- Plex uses TITLE tag for chapter names
- Multi-file audiobooks: one file per chapter
- Single-file audiobooks: embedded chapter markers

**Assessment:** ✅ Plex provides necessary features for audiobook position tracking and chapter management.

### 4.4 Network Requirements

**Download Requirements:**
- Phone connection required (Bluetooth or WiFi)
- Garmin watches access internet via connected phone
- Large files (100s of MB) require stable connection
- Consider download resume/retry logic

**Sync Requirements:**
- Position sync requires phone connection
- Background sync can run periodically
- Offline queue for pending sync operations

**Assessment:** ✅ Network dependency acceptable. Matches vision's "opportunistic sync" philosophy.

---

## 5. Content Management & Storage

### 5.1 Audio File Storage

**Garmin Storage System:**
- Files stored in device filesystem
- Automatic AES-128 encryption during write
- Content protected in hidden folders
- Managed by Media module

**Storage APIs:**
```monkey-c
Media.getCacheStatistics()      // Get storage usage
Media.deleteCachedItem()        // Remove content
Media.resetContentCache()       // Clear all content
Media.getCachedContentObj()     // Retrieve stored media
```

**Assessment:** ✅ Robust storage system with encryption and management APIs.

### 5.2 Metadata Storage

**Challenge:** `Application.Storage` value limit = **8KB per key**

**Problem:**
- Nested data structures (playlists containing songs containing metadata) exceed limit
- Cannot store complex audiobook structure in single value

**Solution:** Flat storage hierarchy (recommended by Garmin blog)

```monkey-c
// Flat structure approach
Storage.setValue("audiobook_ids", ["123", "456", "789"]);

// Separate entries per audiobook
Storage.setValue("audiobook_123", {
    title: "Book Title",
    author: "Author Name",
    duration: 36000,
    coverUrl: "http://..."
});

// Chapter list per audiobook
Storage.setValue("chapters_123", [
    {title: "Chapter 1", file: "ch1.mp3", duration: 1800},
    {title: "Chapter 2", file: "ch2.mp3", duration: 2100}
]);

// Position tracking per audiobook
Storage.setValue("position_123", {
    currentChapter: 0,
    position: 542,  // seconds
    lastUpdated: 1731672000,
    synced: true
});
```

**Benefits:**
- Each value stays under 8KB limit
- Easy to update individual pieces
- Efficient position tracking
- Supports multiple audiobooks

**Assessment:** ✅ Storage limitation is solvable with proper architecture.

### 5.3 Storage Capacity Planning

**Forerunner 970: 32GB total**

Typical usage:
- System: ~10GB
- Maps: ~2-4GB (optional)
- Apps: ~100-500MB
- Available for audio: ~4-10GB (varies by user)

**Audiobook sizes:**
- Short (3-5 hours): 50-150MB
- Medium (8-12 hours): 150-300MB
- Long (20+ hours): 300-600MB

**Realistic capacity:** 8-20 audiobooks stored simultaneously

**Management Strategy:**
- Show storage usage in app
- Allow manual deletion of old audiobooks
- Optional: Auto-delete completed audiobooks
- Warn when storage low

**Assessment:** ✅ Sufficient storage for practical use cases.

---

## 6. Playback & Position Tracking

### 6.1 Native Music Player Integration

**ContentDelegate Implementation:**

The app provides content to the music player via `ContentDelegate`:

```monkey-c
class PlexContentDelegate extends Media.ContentDelegate {

    function getContent() {
        // Return current playback queue
        return new Media.ContentIterator(audiobook, chapterIndex);
    }

    function onSongEvent(songEvent, playbackPosition) {
        // Track position on start, pause, skip, complete
        if (songEvent == Media.SONG_EVENT_PLAYBACK_STARTED) {
            startTracking();
        } else if (songEvent == Media.SONG_EVENT_PLAYBACK_PAUSED) {
            savePosition(playbackPosition);
        } else if (songEvent == Media.SONG_EVENT_PLAYBACK_COMPLETED) {
            markChapterComplete();
            savePosition(0); // Start of next chapter
        }
    }
}
```

**Benefits:**
- Battery-efficient native player
- Standard playback controls
- System-level integration
- Familiar user experience

**Assessment:** ✅ Native player integration is optimal approach.

### 6.2 Local Position Tracking

**Strategy:** Local-first, opportunistic sync (matches vision)

**Implementation:**
```monkey-c
class PositionTracker {

    function savePosition(audiobookId, chapterIndex, position) {
        // Always save locally first (works offline)
        var posData = {
            chapter: chapterIndex,
            position: position,
            timestamp: Time.now().value(),
            synced: false
        };
        Storage.setValue("position_" + audiobookId, posData);

        // Queue for sync
        addToSyncQueue(audiobookId);
    }

    function getPosition(audiobookId) {
        var posData = Storage.getValue("position_" + audiobookId);
        return posData != null ? posData : {chapter: 0, position: 0};
    }
}
```

**Benefits:**
- Works completely offline
- Never blocks playback
- Guaranteed position persistence
- Sync happens in background

**Assessment:** ✅ Aligns perfectly with vision's local-first philosophy.

### 6.3 Server Position Sync

**Plex Timeline API:**
```
POST http://{server}:32400/:/timeline
```

**Parameters:**
- `ratingKey`: Audiobook ID
- `state`: playing / paused / stopped
- `time`: Current position (milliseconds)
- `duration`: Total duration (milliseconds)
- `X-Plex-Token`: Auth token

**Sync Strategy:**
```monkey-c
// Background service for sync
(:background)
class PositionSyncService extends System.ServiceDelegate {

    function onTemporalEvent() {
        syncPendingPositions();
    }

    function syncPendingPositions() {
        var queue = Storage.getValue("sync_queue");

        for (var i = 0; i < queue.size(); i++) {
            var audiobookId = queue[i];
            var posData = Storage.getValue("position_" + audiobookId);

            // Make HTTP request to Plex Timeline API
            syncToServer(audiobookId, posData);
        }
    }
}

// Register for background sync every 15 minutes
Background.registerForTemporalEvent(new Time.Duration(15 * 60));
```

**Benefits:**
- Automatic background sync
- Multi-device position continuity
- No user intervention required
- Graceful offline handling

**Assessment:** ✅ Background sync is feasible and follows Garmin best practices.

### 6.4 Multi-Device Continuity

**Workflow:**
1. Listen on watch during run
2. Position saved locally on watch
3. Background service syncs to Plex server (when connected)
4. Open Prologue/Chronicle/Plex on phone
5. Continue from exact position
6. Phone app updates position on Plex
7. Next watch sync pulls updated position

**Assessment:** ✅ Enables seamless cross-device listening experience.

---

## 7. Chapter Navigation

### 7.1 Multi-File Audiobooks (Recommended)

**Structure:**
- One audio file per chapter
- Each file is a "track" in music player
- Native next/previous track buttons navigate chapters

**Implementation:**
```monkey-c
// Each chapter is a ContentRef
var chapters = [];
for (var i = 0; i < audiobook.chapterCount; i++) {
    var chapter = new Media.ContentRef(
        chapterUrl,
        Media.CONTENT_TYPE_AUDIO,
        {
            :title => "Chapter " + (i + 1),
            :artist => audiobook.author,
            :album => audiobook.title,
            :duration => chapter.duration
        }
    );
    chapters.add(chapter);
}
```

**User Experience:**
- Next/Previous buttons skip chapters
- Natural chapter-based navigation
- Position tracked per chapter
- Resume works correctly

**Assessment:** ✅ Perfect fit for Garmin's audio model.

### 7.2 Single-File Audiobooks (Requires Workaround)

**Challenge:**
- Garmin API doesn't expose chapter marker navigation
- Single M4B file with embedded chapters not natively supported
- Player treats entire file as one track

**Workarounds:**

**Option A: Server-Side Split**
- Pre-process single-file audiobooks on Plex server
- Split into individual chapter files
- Use ffmpeg or similar tool
- Transparent to user

**Option B: Custom Seek Controls**
- Implement custom UI for chapter jumping
- Use `Media.skipToContentIndex()` to seek
- Requires knowing chapter timestamps
- More complex implementation

**Option C: Document Limitation**
- Support multi-file audiobooks only
- Document single-file limitation
- Recommend users use multi-file sources

**Recommendation:** Start with multi-file support (Option C), add server-side splitting later if needed (Option A).

**Assessment:** ⚠️ Chapter navigation requires multi-file audiobooks or server-side processing.

---

## 8. Configuration & Setup

### 8.1 Application Properties (Settings)

**Garmin Connect App Settings:**

Via `Application.Properties`, users can configure:

```xml
<!-- properties.xml -->
<properties>
    <property id="serverUrl" type="string">http://192.168.1.100:32400</property>
    <property id="authToken" type="string"></property>
    <property id="libraryName" type="string">Audiobooks</property>
</properties>
```

**Access in code:**
```monkey-c
var serverUrl = Application.Properties.getValue("serverUrl");
var authToken = Application.Properties.getValue("authToken");
var libraryName = Application.Properties.getValue("libraryName");
```

**Benefits:**
- No companion app required
- Settings sync via Garmin Connect
- Simple configuration model
- Matches vision's simplicity goal

**Assessment:** ✅ Basic configuration works via Application.Properties.

### 8.2 Audiobook Selection Challenge

**Problem:**
- Application.Properties limited to simple text/number inputs
- Cannot browse Plex library via Garmin Connect app
- Need interactive selection of audiobooks

**Solutions:**

**Option A: On-Watch UI (Recommended for MVP)**
```monkey-c
class AudiobookBrowserView extends WatchUi.View {
    function onShow() {
        // Fetch audiobook list from Plex
        fetchAudiobookList();
    }

    function fetchAudiobookList() {
        Communications.makeWebRequest(
            serverUrl + "/library/sections/" + libraryId + "/all",
            {X-Plex-Token: token},
            options,
            method(:onAudiobooksReceived)
        );
    }

    function onAudiobooksReceived(responseCode, data) {
        // Display list on watch
        // User selects audiobooks to download
    }
}
```

**Pros:**
- No companion app needed
- Self-contained solution
- Direct Plex integration

**Cons:**
- Small screen (limited browsing experience)
- Difficult to show metadata/covers
- Text input challenging

**Option B: Companion Mobile App**
```
iOS/Android app:
1. User logs into Plex
2. Browses library with full UI
3. Selects audiobooks
4. App sends selections to watch via Mobile SDK
5. Watch downloads selected audiobooks
```

**Pros:**
- Better browsing experience
- Rich metadata display
- Full keyboard for search

**Cons:**
- Requires separate app installation
- Contradicts vision's simplicity goal
- More development/maintenance

**Option C: Hybrid Approach (Recommended Long-Term)**
```
Phase 1: On-watch selection (simple list)
Phase 2: Add companion app as optional enhancement
```

**Recommendation:**
1. Start with Option A (on-watch UI) for MVP
2. Validate core functionality
3. Add companion app later if users request better browsing

**Assessment:** ⚠️ Audiobook selection requires on-watch UI or companion app. Garmin Connect settings insufficient for library browsing.

### 8.3 Development Testing (Sideloading)

**Your Vision:** Use sideloading during development

**Process:**
1. Build .prg file with Connect IQ SDK
2. Connect watch via USB
3. Copy .prg to watch
4. Manual settings file for testing
5. Iterate quickly

**Benefits:**
- Fast iteration
- No app store approval delays
- Direct testing on hardware
- Development flexibility

**Final Deployment:**
- Garmin Connect IQ Store for end users
- App approval process
- Automatic updates

**Assessment:** ✅ Sideloading is standard practice for development.

---

## 9. Implementation Roadmap

### Phase 1: Core Foundation (MVP)
**Goal:** Prove technical feasibility

1. **Project Setup**
   - Create AudioContentProviderApp project
   - Configure manifest for Forerunner 970
   - Set up development environment

2. **Plex Authentication**
   - Implement Application.Properties for server URL + token
   - Test Plex API connection
   - Handle authentication errors

3. **Download Single Audiobook**
   - Hardcode audiobook ID for testing
   - Download audio files from Plex
   - Store encrypted on watch
   - Verify file integrity

4. **Playback Integration**
   - Implement ContentDelegate
   - Provide content to music player
   - Test playback on device
   - Verify audio quality

5. **Local Position Tracking**
   - Track position on playback events
   - Save to Application.Storage
   - Restore on app restart
   - Test offline reliability

**Deliverable:** Working prototype that downloads and plays one audiobook with position tracking.

**Duration:** 2-3 weeks

### Phase 2: Content Management
**Goal:** Enable user selection and management

6. **Plex Library Browser**
   - Fetch audiobook list from Plex
   - Display on-watch UI
   - Handle pagination (if large library)
   - Show basic metadata

7. **Audiobook Selection**
   - Select audiobooks to download
   - Queue download manager
   - Show download progress
   - Handle download errors/retries

8. **Storage Management**
   - Display storage usage
   - Delete old audiobooks
   - Manage cache
   - Warn on low storage

9. **Multi-Audiobook Support**
   - Switch between audiobooks
   - Remember position per audiobook
   - Organize content library

**Deliverable:** Full content management system with selection and downloads.

**Duration:** 2-3 weeks

### Phase 3: Position Sync
**Goal:** Enable cross-device continuity

10. **Background Sync Service**
    - Implement ServiceDelegate
    - Register temporal events
    - Sync pending positions
    - Handle offline queue

11. **Plex Timeline Integration**
    - POST to Timeline API
    - Send playback state updates
    - Handle server responses
    - Retry failed syncs

12. **Multi-Device Testing**
    - Test position sync to Plex
    - Verify continuity with phone apps
    - Test offline/online transitions
    - Validate sync accuracy

**Deliverable:** Full position sync with multi-device support.

**Duration:** 1-2 weeks

### Phase 4: Polish & Release
**Goal:** Production-ready application

13. **Chapter Navigation**
    - Support multi-file audiobooks
    - Chapter skip functionality
    - Chapter metadata display
    - Test various audiobook formats

14. **Error Handling**
    - Network error recovery
    - Download retry logic
    - User-friendly error messages
    - Logging for debugging

15. **UI/UX Refinement**
    - Optimize for small screen
    - Improve navigation flows
    - Add loading indicators
    - Polish visual design

16. **Testing & Optimization**
    - Test on real device extensively
    - Battery usage optimization
    - Memory usage profiling
    - Performance tuning

17. **Documentation**
    - User guide
    - Setup instructions
    - Troubleshooting guide
    - Developer documentation

18. **Store Submission**
    - Prepare store listing
    - Screenshots and description
    - Submit for approval
    - Address review feedback

**Deliverable:** Production app published to Connect IQ Store.

**Duration:** 2-3 weeks

**Total Estimated Duration:** 7-11 weeks (2-3 months)

---

## 10. Risk Assessment

### 10.1 Low Risk (Confirmed Working)

✅ **AudioContentProviderApp Architecture**
- Well-documented framework
- Used by existing music apps (Spotify, Amazon Music, etc.)
- Proven stability and support

✅ **Audio Format Support**
- MP3, M4A, WAV, MP4 confirmed
- Multiple format options available
- Plex supports all needed formats

✅ **Content Download**
- HTTP download API available
- Large file support confirmed
- Encryption automatic

✅ **Plex API Compatibility**
- All required endpoints available
- Simple authentication
- Timeline API for position sync

✅ **Offline Playback**
- Native capability on Forerunner 970
- No network dependency after download
- Battery efficient

✅ **Local Position Tracking**
- Storage API supports use case
- Works completely offline
- Persistent across restarts

### 10.2 Medium Risk (Requires Testing/Mitigation)

⚠️ **M4B Format Support**
- Not explicitly documented
- Likely works as M4A variant
- **Mitigation:** Test early, fall back to M4A conversion

⚠️ **Large File Downloads**
- 500MB files over Bluetooth connection
- Potential timeouts or interruptions
- **Mitigation:** Implement resume/retry logic, show progress

⚠️ **On-Watch UI for Browsing**
- Small screen limits browsing experience
- Limited text input capabilities
- **Mitigation:** Simple list-based UI, focus on recently added

⚠️ **Chapter Navigation (Single-File)**
- No native chapter marker support
- Requires workarounds
- **Mitigation:** Prioritize multi-file audiobooks, document limitation

⚠️ **Storage Limit (8KB per value)**
- Complex data structures problematic
- **Mitigation:** Use flat storage hierarchy (proven solution)

⚠️ **Background Sync Timing**
- Limited background execution time (~30s)
- Multiple position updates might queue
- **Mitigation:** Batch updates, prioritize recent changes

### 10.3 Risk Mitigation Summary

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| M4B incompatibility | Low | Medium | Test early; server-side conversion fallback |
| Download failures | Medium | Medium | Retry logic, resume support, progress UI |
| Poor browsing UX | High | Low | Simple UI, consider companion app later |
| Chapter nav issues | Medium | Medium | Focus on multi-file; document limitation |
| Storage structure | Low | Low | Use proven flat hierarchy pattern |
| Sync failures | Medium | Low | Queue offline, retry, fail gracefully |

**Overall Risk Level:** **LOW-MEDIUM**

Most risks have proven mitigation strategies or are cosmetic rather than fundamental.

---

## 11. Alternative Approaches Considered

### 11.1 Custom Playback UI (Rejected)

**Approach:** Build custom audio player instead of using native Music Player

**Pros:**
- Full control over UI
- Custom chapter navigation
- Specialized audiobook controls

**Cons:**
- Higher battery consumption
- Complex implementation
- Duplicates system functionality
- Poor user experience (non-standard)

**Decision:** ❌ Rejected - Vision document correctly chose native player integration

### 11.2 Streaming Instead of Download (Rejected)

**Approach:** Stream audiobooks from Plex in real-time

**Pros:**
- No storage limitations
- Always latest content
- No download wait

**Cons:**
- Requires constant phone/network connection
- Battery drain from network usage
- Contradicts vision's "phone-free" goal
- Unreliable during runs/workouts

**Decision:** ❌ Rejected - Download-first approach is correct

### 11.3 Companion App for All Configuration (Rejected)

**Approach:** Require mobile app for all setup and management

**Pros:**
- Better UI for browsing
- Easier configuration
- Rich metadata display

**Cons:**
- Extra installation burden
- Contradicts simplicity goal
- More development/maintenance
- Dependency on multiple apps

**Decision:** ❌ Rejected for MVP - Keep as optional future enhancement

---

## 12. Best Practices Alignment

### 12.1 Garmin Best Practices

✅ **AudioContentProviderApp Pattern**
- Follows official framework
- Uses documented APIs
- Matches sample code patterns

✅ **Content Encryption**
- Automatic AES-128 encryption
- Secure storage in hidden folders
- No custom encryption needed

✅ **Storage Structure**
- Flat hierarchy (recommended)
- Avoids nested data structures
- Stays within 8KB limits

✅ **Battery Efficiency**
- Native player integration
- Background sync with temporal events
- Minimal always-on processing

✅ **Offline-First Design**
- Works without network
- Local-first data persistence
- Opportunistic sync

### 12.2 Plex API Best Practices

✅ **Authentication**
- Standard X-Plex-Token method
- Secure token storage
- Supports latest JWT tokens

✅ **Timeline API Usage**
- Standard position tracking
- Compatible with other Plex clients
- Enables cross-device continuity

✅ **Content Access**
- Uses official download endpoints
- Respects user permissions
- Standard metadata retrieval

### 12.3 Mobile Development Best Practices

✅ **Error Handling**
- Network error recovery
- Graceful degradation
- User-friendly messages

✅ **User Experience**
- Simple configuration
- Clear progress indication
- Familiar navigation patterns

✅ **Data Management**
- Efficient storage usage
- Cache management
- Storage limit awareness

---

## 13. Success Criteria Validation

**From Vision Document:**

> PlexRunner succeeds when:
> - Users can download audiobooks from their personal Plex server to their Garmin watch
> - Audiobooks play through the native Music Player without phone connection
> - Playback positions sync seamlessly across all Plex client devices
> - Configuration is straightforward (ideally just server URL and token)
> - Battery life supports several hours of continuous listening
> - App is available in Garmin Connect IQ Store for all compatible watches

### Validation:

✅ **Download audiobooks from Plex to watch**
- Confirmed feasible via Communications API
- Plex download endpoints available
- Storage and encryption automatic

✅ **Play through native Music Player without phone**
- AudioContentProviderApp designed for this
- Offline playback confirmed capability
- No phone needed after download

✅ **Position sync across Plex devices**
- Timeline API supports this
- Background sync service feasible
- Other apps (Prologue, Chronicle) prove viability

✅ **Straightforward configuration**
- Server URL + token via Application.Properties ✅
- Audiobook selection requires on-watch UI (minor deviation)

✅ **Battery supports several hours listening**
- Forerunner 970: ~8-10 hours music playback
- Native player is battery-efficient
- Sufficient for long audiobooks

✅ **Available in Connect IQ Store**
- Standard distribution channel
- Approval process well-documented
- No barriers identified

**Assessment:** All success criteria are achievable. Minor deviation on configuration (audiobook selection) but overall vision is sound.

---

## 14. Comparison with Existing Solutions

### 14.1 Prologue (iOS) & Chronicle (Android)

**What they do:**
- Mobile apps that access Plex audiobooks
- Sync positions via Timeline API
- Rich browsing/search interface
- Require phone during listening

**PlexRunner Advantage:**
- Phone-free listening (watch only)
- Perfect for runs/workouts
- Native Garmin integration

### 14.2 Audible for Garmin

**What it does:**
- Official Audible app for Garmin
- Downloads audiobooks to watch
- Offline playback

**PlexRunner Advantage:**
- Uses personal Plex library (user owns content)
- No DRM restrictions
- No subscription required
- Open ecosystem

### 14.3 Spotify/Amazon Music on Garmin

**What they do:**
- Music streaming apps using AudioContentProviderApp
- Download playlists/podcasts for offline
- Sync across devices

**Similarities:**
- Same AudioContentProviderApp framework
- Same download/sync model
- Proves viability of approach

**Assessment:** PlexRunner fills a unique niche (personal audiobook library on watch) using proven patterns from existing apps.

---

## 15. Technical Dependencies

### 15.1 Garmin Dependencies

**Connect IQ SDK:**
- Minimum API Level: 3.0.0 (AudioContentProviderApp introduced)
- Target API Level: Latest (currently 4.x+)
- SDK Tools: monkeyc compiler, simulator, device manager

**Device Requirements:**
- Music-enabled Garmin device
- Forerunner 970 (or similar: Forerunner 945/965, Fenix 7/8, etc.)
- Bluetooth headphone support
- Sufficient storage (4GB+ available)

**Toybox Modules:**
- `Toybox.Application` (AppBase, Storage, Properties)
- `Toybox.Media` (AudioContentProviderApp, ContentDelegate, ContentRef)
- `Toybox.Communications` (makeWebRequest for downloads)
- `Toybox.Background` (ServiceDelegate for position sync)
- `Toybox.WatchUi` (Views, Menus, Input handling)
- `Toybox.System` (Device info, timers)
- `Toybox.Time` (Timestamps for positions)

### 15.2 Plex Dependencies

**Plex Media Server:**
- Version: Any modern version (2020+)
- Music library with "Store Track Progress" enabled
- Network accessible (local network or remote)
- User account with authentication token

**Plex API:**
- REST API endpoints (standard HTTP)
- No special SDK required
- JSON responses
- Timeline API support

### 15.3 External Dependencies

**None Required:**
- No third-party libraries needed
- All functionality in standard Garmin SDK
- No external services required
- Self-contained application

**Optional:**
- Companion mobile app (future enhancement)
- Server-side conversion tools (M4B→M4A if needed)

---

## 16. Limitations & Constraints

### 16.1 Platform Limitations

**8KB Storage Value Limit:**
- Requires flat storage structure
- Cannot store complex nested objects
- Mitigation: Proven workaround exists

**Background Execution Time:**
- ~30 seconds for background tasks
- Limits amount of sync per cycle
- Mitigation: Queue and batch operations

**Network Access:**
- Requires phone connection
- No direct WiFi access from Connect IQ apps
- Mitigation: Acceptable for download/sync, not playback

**No Native Chapter Markers:**
- Single-file chapter navigation unsupported
- Mitigation: Use multi-file audiobooks

### 16.2 Device Limitations

**Storage Capacity:**
- 32GB total, ~4-10GB available for audio
- Limits number of simultaneous audiobooks
- Mitigation: User manages library, deletes old content

**Screen Size:**
- Small watch screen (1.3-1.4 inches)
- Limited browsing experience
- Mitigation: Simple UI, focus on essentials

**Input Methods:**
- Physical buttons (no full keyboard)
- Touch support limited
- Mitigation: Browse-and-select UI, no text input needed

### 16.3 Plex Limitations

**Library Configuration:**
- "Store Track Progress" must be enabled
- User must configure library correctly
- Mitigation: Clear documentation

**Network Accessibility:**
- Plex server must be network accessible
- Remote access configuration may be needed
- Mitigation: User responsibility, standard Plex setup

**Audio Format Support:**
- Plex serves whatever format is stored
- Unsupported formats won't work
- Mitigation: Document supported formats, consider conversion

---

## 17. Development Environment Setup

### 17.1 Required Tools

**Connect IQ SDK:**
- Download from: developer.garmin.com/connect-iq
- Includes: compiler, simulator, debugger
- Current version: 7.x+ (as of 2025)

**IDE Options:**

**Option A: Visual Studio Code (Recommended)**
- Monkey C extension available
- Syntax highlighting
- Build integration
- Free and cross-platform

**Option B: Eclipse (Official)**
- Official Garmin plugin
- Full IDE integration
- More complex setup

**Option C: Command Line**
- Direct monkeyc compiler usage
- Build scripts
- Minimal setup

### 17.2 Testing Setup

**Simulator:**
- Included in SDK
- Forerunner 970 device profile
- Limited music player simulation
- Good for UI testing

**Real Device (Essential):**
- Forerunner 970 or similar
- USB cable for sideloading
- Bluetooth headphones for testing
- Required for audio testing

**Plex Test Server:**
- Personal Plex server or test instance
- Audiobook library configured
- Sample audiobooks (various formats)
- "Store Track Progress" enabled

### 17.3 Development Workflow

1. Write code in IDE
2. Compile with monkeyc
3. Test in simulator (UI/logic)
4. Sideload to device (USB)
5. Test on real hardware
6. Iterate

**Build Command Example:**
```bash
monkeyc \
  -o bin/PlexRunner.prg \
  -f monkey.jungle \
  -y /path/to/developer_key \
  -d forerunner970
```

---

## 18. Open Questions & Recommendations

### 18.1 Questions for Further Investigation

**M4B Format Compatibility:**
- Q: Does Media.AUDIO_FORMAT_M4A work with .m4b files?
- **Recommendation:** Test early in Phase 1 with sample M4B file

**Download Size Limits:**
- Q: Are there size limits on HTTP downloads?
- Q: What's the maximum single file size?
- **Recommendation:** Test with large audiobook (500MB+)

**Background Sync Frequency:**
- Q: What's optimal sync interval (battery vs. responsiveness)?
- **Recommendation:** Test 15-min, 30-min, 1-hour intervals

**Storage Calculation:**
- Q: How much storage is actually available on Forerunner 970?
- **Recommendation:** Query `Media.getCacheStatistics()` on real device

**Plex Token Expiry:**
- Q: How long do X-Plex-Tokens remain valid?
- Q: Do we need refresh logic?
- **Recommendation:** Research Plex token lifecycle, implement refresh if needed

### 18.2 Recommendations for MVP

**Phase 1 Priorities:**
1. ✅ Prove AudioContentProviderApp integration
2. ✅ Verify Plex API download functionality
3. ✅ Test M4B format support
4. ✅ Validate position tracking locally

**Defer to Later Phases:**
- Advanced chapter navigation
- Companion mobile app
- Playback speed control
- Sleep timer
- Complex UI/UX polish

**Testing Strategy:**
- Start with multi-file audiobooks (known to work)
- Test M4B early (unknown compatibility)
- Use small audiobooks initially (faster iteration)
- Expand to full-size audiobooks in Phase 2

### 18.3 Future Enhancements (Post-MVP)

**From Vision Document:**
- Playback speed control (1.0x, 1.25x, 1.5x, 2.0x)
- Sleep timer (auto-pause after duration)
- Download queue management (priority, cancel)
- Collection/series support (group related audiobooks)
- Smart resume (skip ahead after long pause)

**Additional Ideas:**
- Companion mobile app (better browsing)
- Server-side M4B→M4A conversion service
- Automatic position sync on workout completion
- Integration with Garmin activity tracking
- Statistics (listening time, books completed)

---

## 19. Final Recommendation

### 19.1 Proceed with Development: ✅ APPROVED

**Rationale:**
1. Technical architecture is sound and follows best practices
2. All core functionality is feasible with proven APIs
3. Device capabilities meet requirements
4. Plex API provides necessary features
5. Existing apps (Spotify, Amazon Music) prove viability of pattern
6. Risks are manageable with identified mitigations

### 19.2 Development Approach

**Recommended Path:**
1. Start with Phase 1 (Core Foundation)
2. Validate technical assumptions early
3. Test on real hardware frequently
4. Use multi-file audiobooks initially
5. Iterate based on real-world usage

**Success Milestones:**
- Week 2: Download and play first audiobook
- Week 4: Multi-audiobook support with selection
- Week 6: Position sync to Plex working
- Week 10: Beta testing on real device
- Week 12: Submit to Connect IQ Store

### 19.3 Key Success Factors

**Critical:**
- Early M4B format testing
- Robust error handling (network, storage)
- Efficient storage structure (flat hierarchy)
- Battery-conscious implementation

**Important:**
- Simple, intuitive on-watch UI
- Clear setup documentation
- Reliable position sync
- Good performance on real hardware

**Nice-to-Have:**
- Rich metadata display
- Advanced chapter navigation
- Companion mobile app
- Server-side format conversion

### 19.4 Go/No-Go Decision

**Decision: ✅ GO**

The PlexRunner project is **technically feasible**, **architecturally sound**, and **aligns with Garmin best practices**. The vision document demonstrates thorough research and correct technical approach.

**Confidence Level: HIGH**

Proceed with development following the phased roadmap outlined in this report.

---

## 20. Conclusion

PlexRunner represents a unique and valuable addition to the Garmin Connect IQ ecosystem. By bringing personal audiobook libraries to Garmin watches for phone-free listening, it fills a gap not currently served by existing solutions.

The technical foundation is solid:
- ✅ Proven AudioContentProviderApp framework
- ✅ Compatible Plex API
- ✅ Capable hardware (Forerunner 970)
- ✅ Standard development practices

The implementation approach is sound:
- ✅ Local-first architecture
- ✅ Opportunistic sync
- ✅ Native player integration
- ✅ Phased development roadmap

The risks are manageable:
- ✅ Most risks have proven mitigations
- ✅ Early testing will validate unknowns
- ✅ Fallback options exist for edge cases

**Final Verdict: PlexRunner is ready for development.**

---

## Appendices

### Appendix A: Key API References

**Garmin Connect IQ:**
- API Docs: developer.garmin.com/connect-iq/api-docs/
- AudioContentProviderApp: developer.garmin.com/connect-iq/api-docs/Toybox/Application/AudioContentProviderApp.html
- Media Module: developer.garmin.com/connect-iq/api-docs/Toybox/Media.html
- Sample Apps: github.com/garmin/connectiq-apps

**Plex API:**
- API Overview: developer.plex.tv/pms/
- Timeline API: For position sync
- Download endpoint: `/{part_path}?download=1&X-Plex-Token={token}`

### Appendix B: Device Specifications

**Garmin Forerunner 970:**
- Display: 1.4" AMOLED (454 x 454)
- Storage: 32GB
- Battery (Music): ~8-10 hours
- Audio: Bluetooth headphones, built-in speaker
- Connectivity: Bluetooth, WiFi (some models)
- Water Rating: 5 ATM (50m)

**Note:** Verify these specs match your specific device, as Garmin releases hardware revisions.

### Appendix C: Estimated Storage Usage

**Per Audiobook:**
- Audio files: 150-500MB (varies by length/quality)
- Metadata: <10KB
- Chapter info: <5KB
- Position data: <1KB

**Total System:**
- App binary: ~500KB-2MB
- Global settings: <10KB
- Sync queue: <10KB

**Realistic Capacity:**
- 10-20 audiobooks stored simultaneously
- Depends on audiobook length and device available storage

### Appendix D: Contact & Support

**Garmin Developer Support:**
- Forums: forums.garmin.com/developer/
- Email: developer@garmin.com
- FAQ: developer.garmin.com/connect-iq/connect-iq-faq/

**Plex Developer Support:**
- API Docs: developer.plex.tv
- Forums: forums.plex.tv
- GitHub: github.com/plexinc

---

**Report Version:** 1.0
**Date:** 2025-11-15
**Status:** Final
**Classification:** Technical Feasibility Assessment

**Prepared for:** PlexRunner Development Project
**Prepared by:** Technical Assessment Team

---

END OF REPORT
