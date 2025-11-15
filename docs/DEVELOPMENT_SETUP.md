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
