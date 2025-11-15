# PlexRunner - Project Vision

**Author:** Vegar Waage
**Created:** 2025-11-15

---

## Purpose

PlexRunner brings audiobook listening from a personal Plex server to Garmin watches for phone-free listening during runs, workouts, and outdoor activities.

The app eliminates the dependency on a phone connection by downloading audiobooks directly to the watch, enabling users to enjoy their personal audiobook library anywhere with just their watch and headphones.

---

## Core Functionality

### Audiobook Playback

**Download Audiobooks to Watch**
- Connect to personal Plex server
- Download selected audiobooks to watch storage
- Store audiobook metadata and chapter information locally
- Support multiple audio formats (MP3, M4A, M4B, MP4, WAV)

**Native Music Player Integration**
- Integrate with Garmin's native Music Player
- Use standard playback controls (play, pause, skip)
- Leverage watch's built-in audio session management
- Ensure battery-efficient playback

### Position Tracking & Sync

**Local Position Tracking**
- Track playback position for each audiobook
- Save position on every meaningful event (start, pause, stop, complete)
- Persist positions across app restarts
- Work completely offline without server connectivity

**Plex Server Sync**
- Sync playback positions back to Plex server when connected
- Enable position continuity across devices (watch, phone, tablet, desktop)
- Sync opportunistically without blocking playback
- Handle offline scenarios gracefully

### Configuration

**Server Connection**
- Configure Plex server URL
- Authenticate with Plex auth token
- Specify library name containing audiobooks
- Store configuration securely on watch

**Audiobook Selection**
- Provide method for selecting which audiobooks to download
- Minimize complexity and dependencies
- Avoid building duplicate Plex browsing UI when possible

---

## Design Philosophy

### Simplicity First

**Avoid Over-Engineering**
- Build only what's necessary
- Don't recreate functionality that already exists
- Prefer simple solutions over complex architectures

**Minimize Dependencies**
- Avoid requiring companion mobile apps if alternatives exist
- Use Garmin's built-in configuration system when possible
- Reduce number of components user must install/configure

### Integration Over Innovation

**Leverage Garmin Platform**
- Use native Music Player instead of custom playback UI
- Integrate with standard watch controls and user experience
- Follow Garmin's AudioContentProviderApp pattern

**Respect Plex API**
- Use standard Plex API endpoints
- Support Plex's position tracking via Timeline API
- Enable position continuity across Plex ecosystem

### User-Centric Design

**Phone-Free Operation**
- All playback works completely offline after initial download
- No phone dependency during runs/workouts
- Maximize battery efficiency for long listening sessions

**Seamless Experience**
- Positions sync automatically without user intervention
- Chapter navigation works like any music player
- Configuration is straightforward and one-time

---

## Key Design Decisions

### AudioContentProviderApp Architecture

Use Garmin's AudioContentProviderApp framework rather than building a standalone app. This provides:
- Native Music Player integration
- Standard playback controls
- Battery-efficient audio session management
- Familiar user experience

### Configuration Approach

Prefer Garmin Connect app settings over building a companion mobile app:
- Simpler for users (one less app to install)
- Uses Garmin's built-in configuration sync mechanism
- Reduces development and maintenance burden
- Settings sync automatically to watch via Application.Properties

If companion app proves necessary, it should be minimal and focused purely on audiobook selection from Plex library.

### Development & Testing Strategy

Use sideloading for development testing:
- Faster iteration during development
- Direct .prg file installation via USB
- Manual settings file for testing configuration
- Bypass app store approval during development phase

Final deployment through Garmin Connect IQ Store for end users.

### Storage Strategy

**Local-First Position Tracking**
- Always save positions locally first
- Never block playback waiting for server sync
- Guarantee position tracking works offline

**Opportunistic Server Sync**
- Sync when connectivity is available
- Fail silently when offline
- Don't interrupt user experience for sync failures

### Audio Format Support

Detect audio format from Plex metadata dynamically:
- Support multiple formats (MP3, M4A, M4B, MP4, WAV)
- Match Plex container type to Garmin encoding constant
- Avoid hardcoding format assumptions

---

## User Workflow (when finished)

### Initial Setup

1. Install PlexRunner from Garmin Connect IQ Store
2. Configure Plex server connection via Garmin Connect app:
   - Server URL
   - Auth token
   - Library name (optional)
3. Select audiobooks to download to watch
4. Wait for audiobooks to sync to watch storage

### Daily Use

1. Start activity on watch (run, workout, etc.)
2. Put in headphones
3. Open Music Player
4. Navigate to PlexRunner section
5. Select audiobook and chapter
6. Press play

Position tracking and syncing happens automatically in the background.

### Multi-Device Listening

1. Listen to audiobook on watch during run
2. Position syncs to Plex server when connected
3. Continue listening on phone/tablet/desktop from same position
4. Position updates sync back to watch for next run

---

## Success Criteria

PlexRunner succeeds when:

- Users can download audiobooks from their personal Plex server to their Garmin watch
- Audiobooks play through the native Music Player without phone connection
- Playback positions sync seamlessly across all Plex client devices
- Configuration is straightforward (ideally just server URL and token)
- Battery life supports several hours of continuous listening
- App is available in Garmin Connect IQ Store for all compatible watches

---

## Non-Goals

**Not Building:**
- Custom playback UI (using native Music Player instead)
- Plex server replacement (requires existing Plex server)
- Music streaming (downloads only, no streaming)
- Audiobook discovery/recommendation engine
- Social features or sharing

**Not Supporting:**
- Offline audiobook stores (Audible, Libro.fm, etc.) - Plex only
- DRM-protected content - user must own/control their media
- Real-time streaming - download first, then play

---

## Technical Anchoring

This vision is grounded in Garmin's official documentation:

**AudioContentProviderApp Framework**
- Official Garmin pattern for extending Music Player
- Documented in Connect IQ SDK
- Reference implementation: MonkeyMusic sample app

**Plex API**
- Standard HTTP REST API
- Metadata endpoints for audiobook information
- Timeline API for position sync

**Garmin Connect IQ Store**
- Official distribution channel for end users
- App approval process ensures quality
- Automatic updates for installed apps

---

## Future Enhancements

*Optional features for future versions, not required for initial release:*

- Playback speed control
- Sleep timer
- Download queue management
- Collection/series support
- Smart resume (skip ahead after long pause)

These are intentionally deferred to focus on core functionality first.
