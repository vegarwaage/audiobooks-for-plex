# Common APIs Quick Reference

## Overview

This quick reference guide provides commonly used API patterns with concise code examples for rapid development.

---

## Time and Date

### Get Current Time

```monkey-c
using Toybox.System;
using Toybox.Time;
using Toybox.Lang;

// Clock time (hour, minute, second)
var clockTime = System.getClockTime();
var hour = clockTime.hour;      // 0-23
var minute = clockTime.min;     // 0-59
var second = clockTime.sec;     // 0-59

// Format time string
var timeString = Lang.format("$1$:$2$", [
    hour,
    minute.format("%02d")
]);

// 12-hour format
var settings = System.getDeviceSettings();
if (!settings.is24Hour) {
    hour = hour % 12;
    if (hour == 0) { hour = 12; }
}

// Current moment (timestamp)
var now = Time.now();
var timestamp = now.value();  // Unix timestamp
```

### Format Date

```monkey-c
var now = Time.now();
var info = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);

var year = info.year;
var month = info.month;           // "Jan", "Feb", etc.
var day = info.day;
var dayOfWeek = info.day_of_week; // "Mon", "Tue", etc.

// Format date string
var dateString = Lang.format("$1$ $2$ $3$", [
    dayOfWeek,
    month,
    day
]);
```

### Time Calculations

```monkey-c
var now = Time.now();

// Add duration
var oneHour = new Time.Duration(3600);
var future = now.add(oneHour);

// Subtract duration
var past = now.subtract(oneHour);

// Calculate difference
var diff = future.subtract(now);
var seconds = diff.value();
```

---

## Activity Data

### Get Activity Info

```monkey-c
using Toybox.Activity;

var info = Activity.getActivityInfo();
if (info != null) {
    // Location
    var location = info.currentLocation;

    // Speed (m/s)
    var speed = info.currentSpeed;

    // Heart rate (bpm)
    var hr = info.currentHeartRate;

    // Cadence
    var cadence = info.currentCadence;

    // Distance (meters)
    var distance = info.elapsedDistance;

    // Time (milliseconds)
    var elapsedTime = info.elapsedTime;

    // Calories
    var calories = info.calories;
}
```

### Format Activity Data

```monkey-c
// Speed to pace (min/km or min/mile)
function speedToPace(speed, isMetric) {
    if (speed == null || speed <= 0) {
        return "--:--";
    }

    var secondsPerUnit = isMetric ?
        1000.0 / speed :      // min/km
        1609.34 / speed;      // min/mile

    var minutes = (secondsPerUnit / 60).toNumber();
    var seconds = (secondsPerUnit % 60).toNumber();

    return Lang.format("$1$:$2$", [
        minutes,
        seconds.format("%02d")
    ]);
}

// Distance formatting
function formatDistance(meters, isMetric) {
    if (isMetric) {
        return (meters / 1000.0).format("%.2f") + " km";
    } else {
        return (meters / 1609.34).format("%.2f") + " mi";
    }
}

// Duration formatting
function formatDuration(seconds) {
    var hours = seconds / 3600;
    var minutes = (seconds % 3600) / 60;
    var secs = seconds % 60;

    if (hours > 0) {
        return Lang.format("$1$:$2$:$3$", [
            hours,
            minutes.format("%02d"),
            secs.format("%02d")
        ]);
    } else {
        return Lang.format("$1$:$2$", [
            minutes,
            secs.format("%02d")
        ]);
    }
}
```

---

## Daily Activity

### Get Steps and Goals

```monkey-c
using Toybox.ActivityMonitor;

var info = ActivityMonitor.getInfo();

// Steps
var steps = info.steps != null ? info.steps : 0;
var stepGoal = info.stepGoal != null ? info.stepGoal : 0;
var stepProgress = stepGoal > 0 ?
    (steps.toFloat() / stepGoal * 100).toNumber() : 0;

// Floors
var floors = info.floorsClimbed != null ? info.floorsClimbed : 0;
var floorsGoal = info.floorsClimbedGoal != null ? info.floorsClimbedGoal : 0;

// Distance (centimeters)
var distance = info.distance != null ? info.distance : 0;
var distanceKm = distance / 100000.0;

// Calories
var calories = info.calories != null ? info.calories : 0;

// Active minutes
var activeMinutes = info.activeMinutesDay != null ?
    info.activeMinutesDay.total : 0;
```

---

## GPS Location

### Enable GPS

```monkey-c
using Toybox.Position;

// Start continuous location tracking
Position.enableLocationEvents(
    Position.LOCATION_CONTINUOUS,
    method(:onPosition)
);

function onPosition(info) {
    var position = info.position;
    if (position != null) {
        var radians = position.toRadians();
        var lat = radians[0];
        var lon = radians[1];

        var accuracy = info.accuracy;
        var speed = info.speed;
        var heading = info.heading;
        var altitude = info.altitude;
    }
}

// Stop location tracking
Position.enableLocationEvents(
    Position.LOCATION_DISABLE,
    method(:onPosition)
);
```

### Calculate Distance

```monkey-c
function calculateDistance(pos1, pos2) {
    var rad1 = pos1.toRadians();
    var rad2 = pos2.toRadians();

    var lat1 = rad1[0];
    var lon1 = rad1[1];
    var lat2 = rad2[0];
    var lon2 = rad2[1];

    var dLat = lat2 - lat1;
    var dLon = lon2 - lon1;

    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1) * Math.cos(lat2) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);

    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return 6371000 * c;  // Earth radius * angle = distance in meters
}
```

---

## Drawing

### Basic Shapes

```monkey-c
using Toybox.Graphics;

function draw(dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();
    var centerX = width / 2;
    var centerY = height / 2;

    // Clear screen
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    // Circle
    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.drawCircle(centerX, centerY, 50);
    dc.fillCircle(centerX, centerY, 40);

    // Rectangle
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawRectangle(50, 50, 100, 80);
    dc.fillRectangle(50, 50, 100, 80);

    // Line
    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(0, 0, width, height);

    // Arc
    dc.drawArc(centerX, centerY, 60, Graphics.ARC_CLOCKWISE, 0, 90);
}
```

### Text Drawing

```monkey-c
// Center text
dc.drawText(
    dc.getWidth() / 2,
    dc.getHeight() / 2,
    Graphics.FONT_MEDIUM,
    "Centered",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
);

// Left-aligned
dc.drawText(
    10,
    10,
    Graphics.FONT_SMALL,
    "Left",
    Graphics.TEXT_JUSTIFY_LEFT
);

// Right-aligned
dc.drawText(
    dc.getWidth() - 10,
    10,
    Graphics.FONT_SMALL,
    "Right",
    Graphics.TEXT_JUSTIFY_RIGHT
);

// Get text dimensions
var dimensions = dc.getTextDimensions("Text", Graphics.FONT_MEDIUM);
var textWidth = dimensions[0];
var textHeight = dimensions[1];
```

---

## User Input

### Button Handling

```monkey-c
using Toybox.WatchUi;

class MyDelegate extends WatchUi.BehaviorDelegate {
    function onSelect() {
        System.println("Select pressed");
        return true;  // Event handled
    }

    function onBack() {
        System.println("Back pressed");
        return false;  // Exit app
    }

    function onNextPage() {
        System.println("Next page");
        return true;
    }

    function onPreviousPage() {
        System.println("Previous page");
        return true;
    }

    function onMenu() {
        System.println("Menu");
        var menu = new Rez.Menus.MainMenu();
        WatchUi.pushView(menu, new MenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}
```

### Touch Events

```monkey-c
class TouchDelegate extends WatchUi.BehaviorDelegate {
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        System.println("Tap at: " + x + ", " + y);
        return true;
    }

    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_UP) {
            System.println("Swipe up");
        } else if (direction == WatchUi.SWIPE_DOWN) {
            System.println("Swipe down");
        } else if (direction == WatchUi.SWIPE_LEFT) {
            System.println("Swipe left");
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            System.println("Swipe right");
        }

        return true;
    }
}
```

---

## Data Storage

### Simple Storage

```monkey-c
using Toybox.Application.Storage;

// Save value
Storage.setValue("key", "value");
Storage.setValue("count", 42);
Storage.setValue("active", true);

// Get value
var value = Storage.getValue("key");
var count = Storage.getValue("count");

// Delete value
Storage.deleteValue("key");

// Save complex data
var data = {
    :name => "John",
    :age => 30,
    :scores => [90, 85, 88]
};
Storage.setValue("userData", data);

// Load complex data
var userData = Storage.getValue("userData");
if (userData != null) {
    var name = userData[:name];
    var age = userData[:age];
}
```

### App Properties (Settings)

```monkey-c
using Toybox.Application.Properties;

// Get property
var theme = Properties.getValue("theme");
var showSeconds = Properties.getValue("showSeconds");

// Set property
Properties.setValue("theme", 0);
Properties.setValue("showSeconds", true);

// With defaults
var theme = Properties.getValue("theme");
if (theme == null) {
    theme = 0;  // Default dark theme
}
```

---

## Network Requests

### Simple GET Request

```monkey-c
using Toybox.Communications;

function fetchData() {
    var url = "https://api.example.com/data";
    var params = {
        "key" => "value"
    };
    var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    Communications.makeWebRequest(
        url,
        params,
        options,
        method(:onReceive)
    );
}

function onReceive(responseCode, data) {
    if (responseCode == 200) {
        // Success
        processData(data);
    } else {
        // Error
        System.println("Error: " + responseCode);
    }
}
```

### POST Request

```monkey-c
function postData() {
    var url = "https://api.example.com/submit";
    var data = {
        "name" => "John",
        "value" => 42
    };
    var options = {
        :method => Communications.HTTP_REQUEST_METHOD_POST,
        :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    Communications.makeWebRequest(
        url,
        data,
        options,
        method(:onReceive)
    );
}
```

---

## System Information

### Device Settings

```monkey-c
using Toybox.System;

var settings = System.getDeviceSettings();

// Screen info
var width = settings.screenWidth;
var height = settings.screenHeight;
var shape = settings.screenShape;  // SCREEN_SHAPE_ROUND, SEMI_ROUND, RECTANGLE

// Time format
var is24Hour = settings.is24Hour;

// Connection
var phoneConnected = settings.phoneConnected;

// Units
var distanceUnits = settings.distanceUnits;  // UNIT_METRIC or UNIT_STATUTE
var isMetric = distanceUnits == System.UNIT_METRIC;
```

### System Stats

```monkey-c
var stats = System.getSystemStats();

// Battery
var battery = stats.battery;            // 0-100
var charging = stats.charging;          // true/false

// Memory
var totalMemory = stats.totalMemory;
var usedMemory = stats.usedMemory;
var freeMemory = stats.freeMemory;
var percentUsed = (usedMemory.toFloat() / totalMemory * 100).toNumber();
```

---

## Timers

### One-time Timer

```monkey-c
using Toybox.System;

var timer = new System.Timer();
timer.start(method(:onTimer), 3000, false);  // 3 seconds, non-repeating

function onTimer() {
    System.println("Timer fired!");
}
```

### Repeating Timer

```monkey-c
var timer = new System.Timer();
timer.start(method(:onTimer), 1000, true);  // 1 second, repeating

function onTimer() {
    updateDisplay();
}

// Stop timer
timer.stop();
```

---

## Menus

### Create Menu

```monkey-c
using Toybox.WatchUi;

class MyMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Settings"});

        addItem(new WatchUi.MenuItem(
            "Option 1",
            "Description",
            :option1,
            {}
        ));

        addItem(new WatchUi.ToggleMenuItem(
            "Enable Feature",
            "Turn on/off",
            :toggle1,
            true,
            {}
        ));
    }
}

class MyMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :option1) {
            System.println("Option 1 selected");
        } else if (id == :toggle1) {
            var enabled = item.isEnabled();
            Properties.setValue("feature1", enabled);
        }
    }
}

// Show menu
var menu = new MyMenu();
WatchUi.pushView(menu, new MyMenuDelegate(), WatchUi.SLIDE_UP);
```

---

## View Navigation

### Push/Pop Views

```monkey-c
// Push new view
var view = new DetailView();
var delegate = new DetailDelegate();
WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);

// Pop current view
WatchUi.popView(WatchUi.SLIDE_RIGHT);

// Switch to view (replace current)
WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);

// Request update
WatchUi.requestUpdate();
```

### Transitions

```monkey-c
WatchUi.SLIDE_UP
WatchUi.SLIDE_DOWN
WatchUi.SLIDE_LEFT
WatchUi.SLIDE_RIGHT
WatchUi.SLIDE_IMMEDIATE  // No animation
```

---

## String Formatting

### Format with Placeholders

```monkey-c
using Toybox.Lang;

// Basic formatting
var name = "John";
var age = 30;
var text = Lang.format("$1$ is $2$ years old", [name, age]);
// "John is 30 years old"

// Number formatting
var value = 3.14159;
var formatted = value.format("%.2f");  // "3.14"

var integer = 42;
var padded = integer.format("%03d");   // "042"

// Time formatting
var hour = 9;
var minute = 5;
var timeString = Lang.format("$1$:$2$", [
    hour,
    minute.format("%02d")
]);  // "9:05"
```

---

## Error Handling

### Try-Catch

```monkey-c
try {
    var result = riskyOperation();
    processResult(result);
} catch (e instanceof Lang.InvalidValueException) {
    System.println("Invalid value: " + e.getErrorMessage());
} catch (e instanceof Lang.OutOfMemoryException) {
    System.println("Out of memory!");
} catch (e) {
    System.println("Error: " + e.getErrorMessage());
}
```

### Null Checking

```monkey-c
// Check before use
var info = Activity.getActivityInfo();
if (info != null) {
    var hr = info.currentHeartRate;
    if (hr != null) {
        processHeartRate(hr);
    }
}

// Provide default
var hr = info.currentHeartRate != null ?
    info.currentHeartRate : 0;

// Early return
if (info == null) {
    return;
}
```

---

## Math Functions

### Common Operations

```monkey-c
using Toybox.Math;

// Basic
var abs = Math.abs(-5);          // 5
var ceil = Math.ceil(3.2);       // 4
var floor = Math.floor(3.8);     // 3
var round = Math.round(3.5);     // 4
var pow = Math.pow(2, 3);        // 8
var sqrt = Math.sqrt(16);        // 4

// Trig (radians)
var sin = Math.sin(Math.PI / 2); // 1
var cos = Math.cos(0);           // 1
var tan = Math.tan(Math.PI / 4); // 1

// Min/Max
function min(a, b) {
    return a < b ? a : b;
}

function max(a, b) {
    return a > b ? a : b;
}

// Clamp
function clamp(value, min, max) {
    if (value < min) { return min; }
    if (value > max) { return max; }
    return value;
}
```

---

## Resource Loading

### Load Resources

```monkey-c
using Toybox.WatchUi;

// Load bitmap
var bitmap = WatchUi.loadResource(Rez.Drawables.MyImage);
if (bitmap != null) {
    dc.drawBitmap(0, 0, bitmap);
}

// Load string
var appName = WatchUi.loadResource(Rez.Strings.AppName);

// Load font
var customFont = WatchUi.loadResource(Rez.Fonts.MyFont);
```

---

## Quick Patterns

### Progress Bar

```monkey-c
function drawProgressBar(dc, x, y, width, height, progress) {
    // Background
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(x, y, width, height);

    // Progress
    var fillWidth = (width * progress).toNumber();
    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(x, y, fillWidth, height);

    // Border
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawRectangle(x, y, width, height);
}

// Usage
drawProgressBar(dc, 50, 100, 140, 20, 0.75);  // 75% progress
```

### Battery Indicator

```monkey-c
function drawBattery(dc, x, y) {
    var battery = System.getSystemStats().battery;
    var color = battery > 20 ?
        Graphics.COLOR_GREEN :
        Graphics.COLOR_RED;

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
        x, y,
        Graphics.FONT_XTINY,
        battery.format("%.0f") + "%",
        Graphics.TEXT_JUSTIFY_RIGHT
    );
}
```

### Heart Rate Zone

```monkey-c
function getHeartRateZone(hr, maxHr) {
    if (hr == null || maxHr == null) {
        return 0;
    }

    var percent = (hr.toFloat() / maxHr) * 100;

    if (percent < 60) { return 1; }      // Easy
    else if (percent < 70) { return 2; } // Moderate
    else if (percent < 80) { return 3; } // Aerobic
    else if (percent < 90) { return 4; } // Threshold
    else { return 5; }                   // Maximum
}

function getZoneColor(zone) {
    switch (zone) {
        case 1: return Graphics.COLOR_LT_GRAY;
        case 2: return Graphics.COLOR_BLUE;
        case 3: return Graphics.COLOR_GREEN;
        case 4: return Graphics.COLOR_ORANGE;
        case 5: return Graphics.COLOR_RED;
        default: return Graphics.COLOR_WHITE;
    }
}
```

---

## Resources

- **Complete API Docs**: https://developer.garmin.com/connect-iq/api-docs/
- **Sample Code**: https://github.com/garmin/connectiq-apps
- **Developer Forum**: https://forums.garmin.com/developer/
