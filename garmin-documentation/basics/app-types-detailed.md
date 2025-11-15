# Connect IQ App Types - Detailed Guide

## Overview

Connect IQ supports six main application types, each designed for specific use cases and device interactions. Understanding which type to use is crucial for your app's success.

## App Type Comparison

| Type | Power Usage | Interaction | Background | Use Case |
|------|-------------|-------------|------------|----------|
| **Watch Face** | Low | Passive | Limited | Replace default watch face |
| **Widget** | Low | Quick glance | No | At-a-glance information |
| **Data Field** | Medium | In-activity | Yes | Activity metrics |
| **Device App** | High | Full interaction | Yes | Standalone applications |
| **Audio Provider** | Medium | Indirect | Yes | Music/podcast streaming |
| **Glance** | Very Low | Passive | No | Quick information summary |

---

## 1. Watch Faces

### Description
Watch faces replace the default watch face on Garmin wearables. They're the home screen and are optimized for low power consumption.

### Capabilities
- Always visible (except in activity mode)
- Low-power updates (every second when active, every minute in low-power mode)
- Access to system information (time, date, battery, steps, etc.)
- Customizable settings
- Limited sensor access

### Limitations
- No network access in low-power mode
- Limited background processing
- Memory constraints (varies by device)
- Cannot record activities

### When to Use
✅ Custom time display with fitness metrics
✅ Personalized watch face with complications
✅ Themed designs for specific user preferences

### Complete Example

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.ActivityMonitor;

class MyWatchFace extends WatchUi.WatchFace {
    private var _dateFont;
    private var _timeFont;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
        // View is shown
    }

    function onUpdate(dc) {
        var clockTime = System.getClockTime();
        var info = ActivityMonitor.getInfo();
        var deviceSettings = System.getDeviceSettings();

        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw time
        var timeString = getTimeString(clockTime, deviceSettings.is24Hour);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 3,
            Graphics.FONT_NUMBER_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Draw date
        var dateString = getDateString();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw steps
        var steps = info.steps != null ? info.steps : 0;
        dc.drawText(
            dc.getWidth() / 2,
            (dc.getHeight() * 2) / 3,
            Graphics.FONT_TINY,
            steps.toString() + " steps",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw battery
        var battery = System.getSystemStats().battery;
        dc.drawText(
            dc.getWidth() - 10,
            10,
            Graphics.FONT_XTINY,
            battery.format("%.0f") + "%",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function onHide() {
    }

    function onEnterSleep() {
        // Low-power mode - update less frequently
    }

    function onExitSleep() {
        // Normal mode - resume normal updates
    }

    private function getTimeString(clockTime, is24Hour) {
        var hour = clockTime.hour;

        if (!is24Hour) {
            hour = clockTime.hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        return Lang.format("$1$:$2$", [
            hour,
            clockTime.min.format("%02d")
        ]);
    }

    private function getDateString() {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);

        return Lang.format("$1$ $2$ $3$", [
            info.day_of_week,
            info.month,
            info.day
        ]);
    }
}

// Application class
class MyWatchFaceApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new MyWatchFace() ];
    }
}
```

---

## 2. Widgets

### Description
Widgets provide quick, at-a-glance information accessible from the widget loop (usually accessed by swiping up from the watch face).

### Capabilities
- Quick access from widget glance
- Can use network and GPS
- User input handling
- App settings
- Up to 60 seconds of active display time

### Limitations
- No background processing
- Closed after inactivity timeout
- Cannot record activities
- Limited memory

### When to Use
✅ Weather updates
✅ Calendar events
✅ Quick sports scores
✅ Social media notifications

### Complete Example

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.System;

class WeatherWidget extends WatchUi.View {
    private var _temperature;
    private var _conditions;
    private var _loading;

    function initialize() {
        View.initialize();
        _temperature = null;
        _conditions = "Loading...";
        _loading = true;
    }

    function onShow() {
        // Fetch weather data
        fetchWeather();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_loading) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_MEDIUM,
                "Loading...",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            // Draw temperature
            var tempString = _temperature != null ?
                _temperature.format("%d") + "°F" : "--";
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 3,
                Graphics.FONT_NUMBER_MEDIUM,
                tempString,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            // Draw conditions
            dc.drawText(
                dc.getWidth() / 2,
                (dc.getHeight() * 2) / 3,
                Graphics.FONT_SMALL,
                _conditions,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    function fetchWeather() {
        var url = "https://api.weather.example.com/current";
        var params = {
            "lat" => "45.52",
            "lon" => "-122.68"
        };

        Communications.makeWebRequest(
            url,
            params,
            {},
            method(:onWeatherReceived)
        );
    }

    function onWeatherReceived(responseCode, data) {
        _loading = false;

        if (responseCode == 200 && data != null) {
            _temperature = data["temp"];
            _conditions = data["conditions"];
        } else {
            _conditions = "Error";
        }

        WatchUi.requestUpdate();
    }

    function onHide() {
    }
}

class WeatherWidgetDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        // Handle select button press
        System.println("Select pressed");
        return true;
    }
}

class WeatherWidgetApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new WeatherWidget(), new WeatherWidgetDelegate() ];
    }
}
```

---

## 3. Data Fields

### Description
Data fields run within Garmin's native activities (running, cycling, etc.) and compute custom metrics based on activity data.

### Capabilities
- Access to real-time activity data (HR, GPS, cadence, power, etc.)
- Multiple field layouts (1-4 fields per screen)
- Background activity recording
- Sensor integration (ANT+, Bluetooth)
- FIT field contributions

### Limitations
- Must fit in allocated screen space
- Limited UI customization
- Runs alongside system activity
- Performance constraints

### When to Use
✅ Custom running metrics (efficiency, power)
✅ Specialized cycling data
✅ Training zone displays
✅ Custom pace/speed calculations

### Complete Example

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.Lang;

class RunEfficiencyField extends WatchUi.DataField {
    private var _efficiency;
    private var _label;

    function initialize() {
        DataField.initialize();
        _efficiency = 0.0;
        _label = "Efficiency";
    }

    // Set your layout here
    function onLayout(dc) {
        View.setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Compute the data field value
    function compute(info) {
        // Calculate running efficiency (example: pace * heart rate)
        var speed = info.currentSpeed;
        var hr = info.currentHeartRate;

        if (speed != null && hr != null && speed > 0) {
            // Example efficiency calculation
            _efficiency = hr / (speed * 3.6); // Convert m/s to km/h
        } else {
            _efficiency = 0.0;
        }
    }

    // Display the value
    function onUpdate(dc) {
        // Check for privacy mode
        var obscurityFlags = getObscurityFlags();
        if (obscurityFlags & OBSCURE_TOP) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.clear();
            return;
        }

        // Set background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 4,
            Graphics.FONT_TINY,
            _label,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var valueString = _efficiency.format("%.1f");
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_NUMBER_MEDIUM,
            valueString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

---

## 4. Device Apps

### Description
Full-featured applications with complete control over the user interface and device capabilities. Most powerful but also most complex app type.

### Capabilities
- Full UI control with multiple views
- Background processes
- Activity recording
- Network and GPS access
- Sensor integration
- Data storage
- Custom activities

### Limitations
- Higher power consumption
- More complex development
- Larger memory footprint
- Store approval requirements

### When to Use
✅ Fitness tracking apps
✅ Games
✅ Navigation tools
✅ Custom activity types

### Complete Example

```monkey-c
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Position;
using Toybox.ActivityRecording;

class WorkoutTrackerApp extends Application.AppBase {
    private var _session;

    function initialize() {
        AppBase.initialize();
        _session = null;
    }

    function onStart(state) {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onStop(state) {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        if (_session != null && _session.isRecording()) {
            _session.stop();
            _session.save();
        }
    }

    function getInitialView() {
        return [ new WorkoutView(), new WorkoutDelegate() ];
    }

    function onPosition(info) {
        // Handle position updates
    }

    function startWorkout() {
        if (Toybox has :ActivityRecording) {
            _session = ActivityRecording.createSession({
                :name => "Custom Workout",
                :sport => ActivityRecording.SPORT_GENERIC,
                :subSport => ActivityRecording.SUB_SPORT_GENERIC
            });
            _session.start();
        }
    }

    function stopWorkout() {
        if (_session != null && _session.isRecording()) {
            _session.stop();
            _session.save();
            _session = null;
        }
    }
}

class WorkoutView extends WatchUi.View {
    private var _timer;
    private var _distance;

    function initialize() {
        View.initialize();
        _timer = 0;
        _distance = 0.0;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw timer
        var minutes = _timer / 60;
        var seconds = _timer % 60;
        var timeString = Lang.format("$1$:$2$", [
            minutes.format("%02d"),
            seconds.format("%02d")
        ]);

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 3,
            Graphics.FONT_NUMBER_MEDIUM,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Draw distance
        var distString = _distance.format("%.2f") + " km";
        dc.drawText(
            dc.getWidth() / 2,
            (dc.getHeight() * 2) / 3,
            Graphics.FONT_MEDIUM,
            distString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function updateTimer(elapsed) {
        _timer = elapsed;
        WatchUi.requestUpdate();
    }

    function updateDistance(dist) {
        _distance = dist / 1000.0; // Convert to km
        WatchUi.requestUpdate();
    }
}

class WorkoutDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        // Start/stop workout
        var app = Application.getApp();
        app.startWorkout();
        return true;
    }

    function onBack() {
        // Stop and exit
        var app = Application.getApp();
        app.stopWorkout();
        return false;
    }
}
```

---

## 5. Audio Providers

### Description
Specialized apps that integrate with the device's music player to stream audio content (music, podcasts, audiobooks).

### Capabilities
- Stream audio content
- Playlist management
- Offline sync capability
- Media controls integration
- Background playback

### Limitations
- Requires audio-capable devices
- Complex authentication flows
- Storage management
- Bandwidth considerations

### When to Use
✅ Music streaming services
✅ Podcast apps
✅ Audiobook players
✅ Radio streaming

### Example Structure

```monkey-c
using Toybox.Application;
using Toybox.Media;

class MyAudioProvider extends Application.AudioContentProvider {

    function initialize() {
        AudioContentProvider.initialize();
    }

    // Get content for playback
    function getContent() {
        var contentItem = new Media.ContentRef(
            "http://example.com/stream.mp3",
            Media.CONTENT_TYPE_AUDIO,
            {
                :title => "Track Title",
                :artist => "Artist Name",
                :album => "Album Name"
            }
        );
        return contentItem;
    }

    // Get playback queue
    function getPlaybackQueue() {
        var queue = [];
        // Build queue of content
        return queue;
    }
}
```

---

## 6. Glances

### Description
Ultra-lightweight, read-only displays that provide quick information snippets. Shown in the glance loop on compatible devices.

### Capabilities
- Extremely low power usage
- Quick information display
- Background updates
- Tap to open full app

### Limitations
- No user interaction (except tap to open)
- Very limited screen space
- Read-only display
- Minimal data

### When to Use
✅ Quick stats summary
✅ Notification counts
✅ Simple status indicators
✅ Companion to device app

### Complete Example

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application.Properties;

class MyGlanceView extends WatchUi.GlanceView {
    private var _messageCount;

    function initialize() {
        GlanceView.initialize();
        _messageCount = Properties.getValue("messageCount");
        if (_messageCount == null) {
            _messageCount = 0;
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw icon (if you have one)
        // dc.drawBitmap(10, 10, getIcon());

        // Draw message count
        var text = _messageCount.toString() + " messages";
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onShow() {
        // Refresh data
        _messageCount = Properties.getValue("messageCount");
    }

    function onHide() {
    }
}
```

---

## Choosing the Right App Type

### Decision Tree

```
Do you need to replace the watch face?
└─ YES → Watch Face

Do you need to run during activities?
└─ YES → Data Field

Do you need complex UI with multiple screens?
└─ YES → Device App

Do you need to provide audio content?
└─ YES → Audio Provider

Do you need quick, at-a-glance info with some interaction?
└─ YES → Widget

Do you need minimal, read-only info display?
└─ YES → Glance
```

### Performance Considerations

**Low Memory Devices** (<32KB available)
- Prefer: Watch Faces, Glances
- Avoid: Complex Device Apps

**Battery Concerns**
- Prefer: Glances, Watch Faces (with efficient updates)
- Avoid: Apps with constant GPS/network usage

**User Engagement**
- High engagement: Device Apps, Widgets
- Low engagement: Glances, Watch Faces

## Manifest Configuration for Each Type

### Watch Face
```xml
<iq:application type="watchface" entry="MyWatchFaceApp">
```

### Widget
```xml
<iq:application type="widget" entry="MyWidgetApp">
```

### Data Field
```xml
<iq:application type="datafield" entry="MyDataFieldApp">
```

### Device App
```xml
<iq:application type="app" entry="MyDeviceApp">
```

### Audio Provider
```xml
<iq:application type="audio" entry="MyAudioProviderApp">
```

## Best Practices by Type

### Watch Faces
- Minimize onUpdate() complexity
- Cache computed values
- Use low-power mode efficiently
- Test battery impact

### Widgets
- Keep network requests minimal
- Handle offline gracefully
- Provide loading states
- Cache data when possible

### Data Fields
- Optimize compute() method
- Handle null values
- Test in actual activities
- Respect privacy modes

### Device Apps
- Manage memory carefully
- Handle lifecycle properly
- Test background behavior
- Optimize battery usage

### Audio Providers
- Handle network errors
- Manage storage efficiently
- Provide offline support
- Optimize streaming quality

### Glances
- Keep it simple
- Update efficiently
- Use background processes
- Make tap action valuable

## Resources

- **API Documentation**: https://developer.garmin.com/connect-iq/api-docs/
- **Sample Apps**: https://github.com/garmin/connectiq-apps
- **Device Capabilities**: https://developer.garmin.com/connect-iq/compatible-devices/
