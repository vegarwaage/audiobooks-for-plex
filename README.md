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
3. Build: `monkeyc -d fr970 -f monkey.jungle -o bin/AudiobooksForPlex.prg -y developer_key`
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
