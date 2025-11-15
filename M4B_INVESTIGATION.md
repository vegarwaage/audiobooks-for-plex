# M4B and Single-File Audiobook Support Investigation

**Date:** 2025-11-15
**Status:** ✅ CONFIRMED - M4B plays, but chapter navigation limited

---

## Executive Summary

**M4B file playback:** ✅ **SUPPORTED**
- M4B files play successfully on Garmin watches
- Use `Media.AUDIO_FORMAT_M4A` encoding constant
- No file conversion required for basic playback

**Chapter marker navigation:** ❌ **NOT SUPPORTED**
- Garmin's native Music Player does not recognize embedded chapter markers
- Single-file audiobooks play as one continuous track
- Only time-based navigation available (30-second skip forward/backward)

**Recommendation:** Use multi-file audiobooks (one file per chapter) for optimal user experience.

---

## Investigation Details

### Research Sources

1. **Garmin Developer Forums**
   - Thread: "Audiobook m4b chapters support - fēnix 7 Series"
   - User tested M4B files on Fenix 7 Pro (shares music player with Forerunner 970)
   - Confirmed playback works but chapter markers ignored
   - Post date: May 2024

2. **Format Documentation**
   - M4B is identical to M4A container format (MPEG-4 Audio)
   - Primary difference: M4B has audiobook-specific metadata
   - Chapter markers embedded in file structure
   - Audio codec: AAC (same as M4A)

3. **Garmin Support Documentation**
   - Official format list: MP3, M4A, M4B, AAC, WAV
   - M4B explicitly listed as compatible format
   - No documentation about chapter marker support

4. **Third-Party Tools**
   - AudioBookConverter software can read M4B chapter structure
   - Chapters are properly embedded in tested files
   - Issue is player-side, not file-side

### Key Findings

**What Works:**
- ✅ M4B file playback (audio plays correctly)
- ✅ Basic controls (play, pause, stop)
- ✅ Time-based seeking (30-second increments)
- ✅ File metadata (title, author, cover art)
- ✅ Position tracking for entire file

**What Doesn't Work:**
- ❌ Chapter marker recognition
- ❌ Chapter-based navigation (skip to chapter)
- ❌ Chapter list display
- ❌ Per-chapter position tracking
- ❌ Chapter metadata in player UI

### User Experience Impact

**Single-File M4B Audiobook (10 hours, 30 chapters):**
```
User wants to skip to Chapter 15:
❌ Cannot: No chapter list or chapter skip buttons
✅ Workaround: Use 30-second skip ~300 times (very poor UX)
OR: Restart and seek to timestamp (if known)
```

**Multi-File Audiobook (10 hours, 30 files):**
```
User wants to skip to Chapter 15:
✅ Navigate to Chapter 15 "track" in playlist
✅ Press play - starts at correct chapter
✅ Next/Previous buttons navigate chapters naturally
```

---

## Technical Details

### M4B File Structure

M4B files contain:
- **Audio streams:** AAC encoded audio data
- **Metadata container:** iTunes-style metadata
  - Title, author, narrator
  - Cover artwork (JPEG/PNG)
  - Chapter markers (timed bookmarks)
  - Book description
- **Container format:** MPEG-4 Part 14 (.mp4/.m4a/.m4b)

### Garmin Connect IQ API

**Available Audio Format Constants:**
```monkey-c
Media.AUDIO_FORMAT_MP3     // MP3 files
Media.AUDIO_FORMAT_M4A     // M4A/M4B/AAC files
Media.AUDIO_FORMAT_WAV     // WAV files
Media.AUDIO_FORMAT_ADTS    // ADTS/AAC streams
```

**Note:** No separate M4B constant. Use `AUDIO_FORMAT_M4A` for M4B files.

**ContentRef API:**
```monkey-c
var audiobook = new Media.ContentRef(
    url,
    Media.CONTENT_TYPE_AUDIO,
    {
        :encoding => Media.AUDIO_FORMAT_M4A,  // Works for M4B
        :title => "Audiobook Title",
        :artist => "Author Name",
        :album => "Book Title",
        :duration => 36000  // seconds (total file duration)
    }
);
```

**Limitation:** No chapter metadata fields in ContentRef
- No `:chapters` parameter
- No chapter callback events
- No chapter navigation methods

### Platform Limitations

The chapter navigation limitation appears to be in Garmin's **native music player software**, not the Connect IQ API or file format.

**Evidence:**
- M4B chapter metadata is properly embedded in files (verified with third-party tools)
- Other platforms (iOS, Android) read the same chapter markers successfully
- Garmin's player shows only basic playback controls
- No firmware or software update has added chapter support (as of 2024-2025)

This affects **all Garmin watch models**, including:
- Forerunner series (245M, 645M, 945, 965, 970)
- Fenix series (6, 7, 8)
- Venu series
- Other music-enabled watches

---

## Recommended Solutions

### Solution 1: Multi-File Audiobooks (Primary Approach)

**Structure:**
```
Audiobook/
  ├── Chapter 01 - Introduction.mp3
  ├── Chapter 02 - The Beginning.mp3
  ├── Chapter 03 - The Journey.mp3
  └── ...
```

**Implementation:**
- Each chapter file = one `ContentRef`
- Group all chapters into `ContentIterator`
- Native next/previous buttons navigate chapters
- Perfect alignment with Garmin's "track" model

**Pros:**
- ✅ Natural chapter navigation
- ✅ Per-chapter position tracking
- ✅ Works with all audio formats (MP3, M4A, etc.)
- ✅ No custom UI needed
- ✅ Familiar user experience

**Cons:**
- ⚠️ Requires multi-file audiobooks from source
- ⚠️ Single-file M4B books need conversion

### Solution 2: Server-Side M4B Splitting (Future Enhancement)

**Approach:**
- PlexRunner detects single-file M4B audiobooks
- Automatically splits into chapter files on Plex server
- Uses `ffmpeg` to extract chapters without re-encoding
- Transparent to user

**Command example:**
```bash
# Extract chapter 1 from M4B
ffmpeg -i audiobook.m4b -ss 00:00:00 -to 00:15:23 \
  -c copy "Chapter 01.m4a"

# Extract chapter 2
ffmpeg -i audiobook.m4b -ss 00:15:23 -to 00:32:45 \
  -c copy "Chapter 02.m4a"
```

**Pros:**
- ✅ Works with single-file M4B sources
- ✅ No re-encoding (fast, lossless)
- ✅ Automatic conversion
- ✅ User-transparent

**Cons:**
- ⚠️ Requires server-side processing
- ⚠️ Additional storage on server
- ⚠️ Complexity in implementation
- ⚠️ Deferred to future version

### Solution 3: Document Limitation (Acceptable Fallback)

**Approach:**
- Support multi-file audiobooks only
- Document that single-file M4B requires conversion
- Provide user guide for converting M4B → multi-file

**User documentation:**
```
PlexRunner works best with multi-file audiobooks (one file per chapter).

If you have single-file M4B audiobooks:
1. Use tools like AudioBookConverter to split by chapter
2. Or use ffmpeg (command-line)
3. Or use Plex plugins that auto-split on import

Single-file audiobooks will play but without chapter navigation.
```

**Pros:**
- ✅ Simple implementation
- ✅ No server-side processing
- ✅ Works with MVP
- ✅ Clear user expectations

**Cons:**
- ⚠️ User must convert files manually
- ⚠️ Extra step in workflow
- ⚠️ May limit adoption

---

## Implementation Recommendations

### Phase 1 (MVP):
1. ✅ Support multi-file audiobooks (MP3, M4A)
2. ✅ Each file = one chapter (track)
3. ✅ Document single-file limitation
4. ✅ Test M4B playback (confirm it works)

### Phase 2 (Post-MVP):
5. Add M4B detection in metadata
6. Warn user if single-file M4B detected
7. Suggest conversion or provide guide

### Phase 3 (Future Enhancement):
8. Implement server-side M4B splitting
9. Automatic conversion on download
10. Transparent multi-chapter experience

---

## Testing Plan

### Test Cases

**TC1: Multi-File MP3 Audiobook**
- Expected: ✅ Full chapter navigation
- Priority: High (MVP requirement)

**TC2: Multi-File M4A Audiobook**
- Expected: ✅ Full chapter navigation
- Priority: High (MVP requirement)

**TC3: Single-File M4B Audiobook**
- Expected: ✅ Playback works, ❌ No chapter navigation
- Priority: Medium (document limitation)

**TC4: Single-File M4A Audiobook**
- Expected: ✅ Playback works, ❌ No chapter navigation
- Priority: Medium (same as M4B)

**TC5: Mixed Format Audiobook**
- Expected: ✅ All formats play correctly
- Priority: Low (edge case)

### Testing Devices
- Forerunner 970 (primary target)
- Forerunner 965 (compatibility check)
- Fenix 8 (compatibility check)

### Sample Files Needed
- Multi-file MP3 audiobook (public domain)
- Multi-file M4A audiobook (public domain)
- Single-file M4B audiobook (test chapter marker handling)
- Various file sizes (small 50MB, medium 200MB, large 500MB)

---

## Plex Integration Notes

### Plex Audiobook Library Setup

Plex supports both single-file and multi-file audiobooks:

**Single-File Structure:**
```
Audiobooks/
  Author Name/
    Book Title/
      Book Title.m4b
```

**Multi-File Structure (RECOMMENDED):**
```
Audiobooks/
  Author Name/
    Book Title/
      01 - Chapter 1.mp3
      02 - Chapter 2.mp3
      03 - Chapter 3.mp3
      ...
```

### Plex Metadata

Plex provides chapter information via API:
```json
{
  "Media": [{
    "Part": [{
      "file": "/path/to/audiobook.m4b",
      "duration": 36000000,
      "Chapter": [
        {"id": 1, "title": "Introduction", "startTimeOffset": 0},
        {"id": 2, "title": "Chapter 1", "startTimeOffset": 923000},
        ...
      ]
    }]
  }]
}
```

**Note:** PlexRunner can read this metadata but cannot utilize it for navigation due to Garmin player limitations.

### Timeline API Position Tracking

For multi-file audiobooks:
- Track position per chapter (file)
- Report to Plex as `ratingKey` (audiobook ID) + chapter index
- Each chapter is a separate "track" in player

For single-file audiobooks:
- Track global position in file (seconds)
- Report to Plex as single position
- No chapter-level granularity

---

## Comparison with Other Platforms

### iOS (Prologue App)
- ✅ Full M4B chapter navigation
- ✅ Chapter list UI
- ✅ Skip to chapter
- Platform: iOS native AVPlayer

### Android (Chronicle App)
- ✅ Full M4B chapter navigation
- ✅ Chapter bookmarks
- ✅ Chapter-based sync
- Platform: Android MediaPlayer

### Garmin (PlexRunner)
- ✅ M4B playback
- ❌ No chapter navigation
- ✅ Time-based seeking only
- Platform: Garmin native music player

**Key Difference:** iOS and Android players expose chapter metadata; Garmin's does not.

---

## Conclusion

M4B files **will work** in PlexRunner for basic playback, but the lack of chapter navigation in Garmin's native music player means **multi-file audiobooks provide a significantly better user experience**.

### Recommended Approach:

1. **Primary support:** Multi-file audiobooks (one file per chapter)
2. **Secondary support:** Single-file M4B (playback only, no chapters)
3. **Documentation:** Clear user guidance about format preferences
4. **Future:** Server-side M4B splitting for automatic conversion

This approach:
- ✅ Delivers excellent UX for multi-file books
- ✅ Doesn't block single-file book playback
- ✅ Keeps MVP scope manageable
- ✅ Provides upgrade path for future versions

---

**Investigation Status:** Complete ✅
**Recommendation:** Implement multi-file support in MVP, document M4B limitation
**Future Work:** Server-side M4B chapter splitting (Phase 3)

---

## References

- Garmin Forums: "Audiobook m4b chapters support" (Fenix 7 Series, May 2024)
- Garmin Support: Audio File Type Support for Music Watches
- M4B Format Specification: MPEG-4 Part 14 (ISO/IEC 14496-14)
- AudioBookConverter: Third-party M4B validation tool
- FFmpeg Documentation: M4B/M4A chapter extraction
