# Toybox API Overview

## Overview

Toybox is Garmin's comprehensive API framework for Connect IQ development. It provides modules for everything from UI rendering to sensor access, organized into logical namespaces.

## Core Modules

### Toybox.Application

Manages application lifecycle and settings.

```monkey-c
using Toybox.Application;

// Main application class
class MyApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        // App starting
    }

    function onStop(state) {
        // App stopping
        return { :savedData => "value" };
    }

    function getInitialView() {
        return [new MainView(), new MainDelegate()];
    }
}

// Access app instance
var app = Application.getApp();

// Properties (settings)
Application.Properties.getValue("settingKey");
Application.Properties.setValue("settingKey", value);

// Storage (persistent data)
Application.Storage.getValue("dataKey");
Application.Storage.setValue("dataKey", value);
Application.Storage.deleteValue("dataKey");
```

**Key Classes:**
- `AppBase` - Base application class
- `Properties` - App settings
- `Storage` - Persistent data storage

---

### Toybox.WatchUi

UI components, views, and input handling.

```monkey-c
using Toybox.WatchUi;

// View base classes
class MyView extends WatchUi.View {
    function onUpdate(dc) {
        dc.clear();
    }
}

class MyWatchFace extends WatchUi.WatchFace {
    function onUpdate(dc) {
        dc.clear();
        // Draw time
    }

    function onEnterSleep() { }
    function onExitSleep() { }
}

class MyDataField extends WatchUi.DataField {
    function compute(info) {
        // Calculate value
    }

    function onUpdate(dc) {
        // Draw value
    }
}

// Input handling
class MyDelegate extends WatchUi.BehaviorDelegate {
    function onSelect() { return true; }
    function onBack() { return false; }
    function onNextPage() { return true; }
    function onPreviousPage() { return true; }
    function onMenu() { return true; }
}

// Navigation
WatchUi.pushView(view, delegate, transition);
WatchUi.popView(transition);
WatchUi.switchToView(view, delegate, transition);
WatchUi.requestUpdate();

// Transitions
WatchUi.SLIDE_UP
WatchUi.SLIDE_DOWN
WatchUi.SLIDE_LEFT
WatchUi.SLIDE_RIGHT
WatchUi.SLIDE_IMMEDIATE

// Menus
class MyMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Menu"});
        addItem(new WatchUi.MenuItem("Item", "Description", :id, {}));
    }
}

// Pickers
var picker = new WatchUi.NumberPicker(0, 100, 50);
WatchUi.pushView(picker, new MyPickerDelegate(), WatchUi.SLIDE_UP);

// Confirmation dialogs
var dialog = new WatchUi.Confirmation("Delete item?");
WatchUi.pushView(dialog, new MyConfirmationDelegate(), WatchUi.SLIDE_UP);
```

**Key Classes:**
- `View` - Base view class
- `WatchFace` - Watch face base
- `DataField` - Data field base
- `BehaviorDelegate` - Input handler
- `Menu2` - Menu system
- `Picker` - Value pickers
- `Confirmation` - Confirmation dialogs

---

### Toybox.Graphics

Drawing primitives, colors, fonts, and graphics operations.

```monkey-c
using Toybox.Graphics;

function onUpdate(dc) {
    // Colors
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    // Drawing primitives
    dc.drawPoint(x, y);
    dc.drawLine(x1, y1, x2, y2);
    dc.drawCircle(x, y, radius);
    dc.fillCircle(x, y, radius);
    dc.drawRectangle(x, y, width, height);
    dc.fillRectangle(x, y, width, height);
    dc.drawRoundedRectangle(x, y, width, height, radius);
    dc.fillRoundedRectangle(x, y, width, height, radius);
    dc.drawArc(x, y, radius, direction, startAngle, endAngle);

    // Text
    dc.drawText(
        x, y,
        Graphics.FONT_MEDIUM,
        "Hello",
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Get text dimensions
    var dimensions = dc.getTextDimensions("Hello", Graphics.FONT_MEDIUM);
    var width = dimensions[0];
    var height = dimensions[1];

    // Bitmaps
    var bitmap = WatchUi.loadResource(Rez.Drawables.MyBitmap);
    dc.drawBitmap(x, y, bitmap);
    dc.drawBitmap2(x, y, bitmap, {
        :tintColor => Graphics.COLOR_BLUE
    });

    // Clipping
    dc.setClip(x, y, width, height);
    dc.clearClip();

    // Screen info
    var width = dc.getWidth();
    var height = dc.getHeight();
}

// Colors
Graphics.COLOR_BLACK
Graphics.COLOR_DK_GRAY
Graphics.COLOR_LT_GRAY
Graphics.COLOR_WHITE
Graphics.COLOR_RED
Graphics.COLOR_ORANGE
Graphics.COLOR_YELLOW
Graphics.COLOR_GREEN
Graphics.COLOR_BLUE
Graphics.COLOR_PURPLE
Graphics.COLOR_PINK
Graphics.COLOR_TRANSPARENT

// Fonts
Graphics.FONT_XTINY
Graphics.FONT_TINY
Graphics.FONT_SMALL
Graphics.FONT_MEDIUM
Graphics.FONT_LARGE
Graphics.FONT_NUMBER_MILD
Graphics.FONT_NUMBER_MEDIUM
Graphics.FONT_NUMBER_HOT
Graphics.FONT_NUMBER_THAI_HOT

// Text justification
Graphics.TEXT_JUSTIFY_LEFT
Graphics.TEXT_JUSTIFY_CENTER
Graphics.TEXT_JUSTIFY_RIGHT
Graphics.TEXT_JUSTIFY_VCENTER

// Arc directions
Graphics.ARC_CLOCKWISE
Graphics.ARC_COUNTER_CLOCKWISE
```

---

### Toybox.System

System information, time, and device settings.

```monkey-c
using Toybox.System;

// Logging
System.println("Debug message");

// Device settings
var settings = System.getDeviceSettings();
var screenWidth = settings.screenWidth;
var screenHeight = settings.screenHeight;
var screenShape = settings.screenShape;  // SCREEN_SHAPE_ROUND, SCREEN_SHAPE_SEMI_ROUND, SCREEN_SHAPE_RECTANGLE
var is24Hour = settings.is24Hour;
var phoneConnected = settings.phoneConnected;
var bluetoothConnected = settings.connectionInfo[:bluetooth].state;

// System stats
var stats = System.getSystemStats();
var battery = stats.battery;              // 0-100
var charging = stats.charging;            // true/false
var memory = stats.totalMemory;
var usedMemory = stats.usedMemory;
var freeMemory = stats.freeMemory;

// Clock time
var clockTime = System.getClockTime();
var hour = clockTime.hour;                // 0-23
var minute = clockTime.min;               // 0-59
var second = clockTime.sec;               // 0-59

// Timer
var timer = new System.Timer();
timer.start(method(:onTimer), 1000, true);  // 1 second, repeating
timer.stop();

// Exit app
System.exit();
```

---

### Toybox.Activity

Activity and fitness data during workouts.

```monkey-c
using Toybox.Activity;

// Get activity info
var info = Activity.getActivityInfo();

if (info != null) {
    // Location
    var location = info.currentLocation;
    if (location != null) {
        var position = location.toRadians();
        var lat = position[0];
        var lon = position[1];
    }

    // Speed and pace
    var speed = info.currentSpeed;              // m/s
    var averageSpeed = info.averageSpeed;       // m/s

    // Heart rate
    var hr = info.currentHeartRate;             // bpm
    var averageHR = info.averageHeartRate;      // bpm

    // Cadence
    var cadence = info.currentCadence;          // steps/min or rpm

    // Power
    var power = info.currentPower;              // watts

    // Distance
    var distance = info.elapsedDistance;        // meters

    // Time
    var elapsedTime = info.elapsedTime;         // milliseconds
    var timerTime = info.timerTime;             // milliseconds

    // Calories
    var calories = info.calories;

    // Altitude
    var altitude = info.altitude;               // meters

    // Training effect
    var trainingEffect = info.trainingEffect;
}

// Activity recording
var session = ActivityRecording.createSession({
    :name => "My Workout",
    :sport => ActivityRecording.SPORT_RUNNING,
    :subSport => ActivityRecording.SUB_SPORT_GENERIC
});

session.start();
session.isRecording();  // true/false
session.stop();
session.save();
session.discard();

// Add lap
session.addLap();

// Sport types
ActivityRecording.SPORT_RUNNING
ActivityRecording.SPORT_CYCLING
ActivityRecording.SPORT_SWIMMING
ActivityRecording.SPORT_GENERIC
// ... many more
```

---

### Toybox.ActivityMonitor

Daily activity metrics (steps, calories, etc).

```monkey-c
using Toybox.ActivityMonitor;

// Get activity monitor info
var info = ActivityMonitor.getInfo();

var steps = info.steps;                      // total steps today
var stepGoal = info.stepGoal;               // step goal
var floorsClimbed = info.floorsClimbed;     // floors
var floorsGoal = info.floorsClimbedGoal;    // floor goal
var distance = info.distance;                // centimeters
var calories = info.calories;                // kcal
var activeMinutesDay = info.activeMinutesDay;
var activeMinutesWeek = info.activeMinutesWeek;
var activeMinutesWeekGoal = info.activeMinutesWeekGoal;

// Heart rate samples
var heartRateHistory = ActivityMonitor.getHeartRateHistory(
    1,              // Sample period (1 = most recent)
    true            // Most recent first
);

if (heartRateHistory != null) {
    var iterator = heartRateHistory.next();
    while (iterator != null) {
        var hr = iterator.heartRate;
        var time = iterator.when;
        iterator = heartRateHistory.next();
    }
}
```

---

### Toybox.Position

GPS and location services.

```monkey-c
using Toybox.Position;

// Enable location events
Position.enableLocationEvents(
    Position.LOCATION_CONTINUOUS,
    method(:onPosition)
);

// Location modes
Position.LOCATION_CONTINUOUS    // Continuous tracking
Position.LOCATION_ONE_SHOT     // Single location
Position.LOCATION_DISABLE      // Disable

// Position callback
function onPosition(info) {
    var position = info.position;
    if (position != null) {
        var radians = position.toRadians();
        var lat = radians[0];
        var lon = radians[1];

        var degrees = position.toDegrees();
        var latDeg = degrees[0];
        var lonDeg = degrees[1];
    }

    var accuracy = info.accuracy;
    var speed = info.speed;              // m/s
    var heading = info.heading;          // radians
    var altitude = info.altitude;        // meters

    var when = info.when;                // Time.Moment
}

// Get last known position
var position = Position.getInfo();
```

---

### Toybox.Communications

Network requests and OAuth.

```monkey-c
using Toybox.Communications;

// HTTP request
Communications.makeWebRequest(
    "https://api.example.com/data",
    {
        "param1" => "value1",
        "param2" => "value2"
    },
    {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
            "Authorization" => "Bearer token"
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    },
    method(:onReceive)
);

// Response callback
function onReceive(responseCode, data) {
    if (responseCode == 200) {
        // Success
        System.println("Data: " + data);
    } else {
        // Error
        System.println("Error: " + responseCode);
    }
}

// HTTP methods
Communications.HTTP_REQUEST_METHOD_GET
Communications.HTTP_REQUEST_METHOD_POST
Communications.HTTP_REQUEST_METHOD_PUT
Communications.HTTP_REQUEST_METHOD_DELETE
Communications.HTTP_REQUEST_METHOD_HEAD

// Content types
Communications.REQUEST_CONTENT_TYPE_JSON
Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
Communications.HTTP_RESPONSE_CONTENT_TYPE_IMAGE_JPEG
Communications.HTTP_RESPONSE_CONTENT_TYPE_IMAGE_PNG

// OAuth
Communications.registerForOAuthMessages(method(:onOAuthMessage));

function onOAuthMessage(message) {
    var data = message.data;
    var accessToken = data["access_token"];
    // Save token
}

// Initiate OAuth
Communications.makeOAuthRequest(
    "https://oauth.example.com/authorize",
    {
        "client_id" => "your_client_id",
        "response_type" => "code"
    },
    "https://oauth.example.com/token",
    Communications.OAUTH_RESULT_TYPE_URL,
    {
        "client_id" => "your_client_id",
        "client_secret" => "your_secret"
    }
);
```

---

### Toybox.Sensor

Sensor data access.

```monkey-c
using Toybox.Sensor;

// Register for sensor data
Sensor.setEnabledSensors([
    Sensor.SENSOR_HEARTRATE,
    Sensor.SENSOR_TEMPERATURE,
    Sensor.SENSOR_PRESSURE
]);

Sensor.enableSensorEvents(method(:onSensor));

// Sensor callback
function onSensor(info) {
    var heartRate = info.heartRate;
    var temperature = info.temperature;        // Celsius
    var pressure = info.pressure;              // Pa
    var altitude = info.altitude;              // meters
    var cadence = info.cadence;
}

// Available sensors
Sensor.SENSOR_HEARTRATE
Sensor.SENSOR_TEMPERATURE
Sensor.SENSOR_PRESSURE
Sensor.SENSOR_ONBOARD
// ... device-dependent

// Get sensor history
var options = {
    :period => 1,                    // Latest sample
    :order => Sensor.ORDER_NEWEST_FIRST
};

var history = Sensor.getHeartRateHistory(options);
```

---

### Toybox.Time

Time and date operations.

```monkey-c
using Toybox.Time;

// Current time
var now = Time.now();
var seconds = now.value();  // Unix timestamp

// Gregorian calendar
var info = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
var year = info.year;
var month = info.month;           // string: "Jan", "Feb", etc.
var day = info.day;
var hour = info.hour;
var min = info.min;
var sec = info.sec;
var day_of_week = info.day_of_week;  // string: "Mon", "Tue", etc.

// Time formats
Time.FORMAT_SHORT   // "1/15"
Time.FORMAT_MEDIUM  // "Jan 15"
Time.FORMAT_LONG    // "January 15"

// Create moment
var moment = Time.Gregorian.moment({
    :year => 2024,
    :month => 1,
    :day => 15,
    :hour => 12,
    :minute => 30,
    :second => 0
});

// Duration
var duration = new Time.Duration(3600);  // 1 hour in seconds
var future = now.add(duration);
var past = now.subtract(duration);

// Compare times
var diff = future.subtract(now);
var seconds = diff.value();

// Format duration
function formatDuration(seconds) {
    var hours = seconds / 3600;
    var minutes = (seconds % 3600) / 60;
    var secs = seconds % 60;
    return Lang.format("$1$:$2$:$3$", [
        hours.format("%02d"),
        minutes.format("%02d"),
        secs.format("%02d")
    ]);
}
```

---

### Toybox.Lang

Language utilities and formatting.

```monkey-c
using Toybox.Lang;

// String formatting
var name = "John";
var age = 30;
var message = Lang.format("$1$ is $2$ years old", [name, age]);
// "John is 30 years old"

// Multiple placeholders
var text = Lang.format("$1$ + $2$ = $3$", [2, 3, 5]);
// "2 + 3 = 5"

// Method references
var callback = new Lang.Method(self, :onCallback);

// Object methods
var obj = new MyClass();
var method = new Lang.Method(obj, :someMethod);

// Exception types
try {
    // risky operation
} catch (e instanceof Lang.InvalidValueException) {
    System.println("Invalid value");
} catch (e instanceof Lang.OutOfMemoryException) {
    System.println("Out of memory");
} catch (e instanceof Lang.UnexpectedTypeException) {
    System.println("Unexpected type");
}
```

---

### Toybox.Math

Mathematical functions.

```monkey-c
using Toybox.Math;

// Constants
Math.PI        // 3.14159...
Math.E         // 2.71828...

// Basic functions
Math.abs(-5)         // 5
Math.ceil(3.2)       // 4
Math.floor(3.8)      // 3
Math.round(3.5)      // 4
Math.pow(2, 3)       // 8
Math.sqrt(16)        // 4

// Trigonometry (radians)
Math.sin(angle)
Math.cos(angle)
Math.tan(angle)
Math.asin(value)
Math.acos(value)
Math.atan(value)
Math.atan2(y, x)

// Logarithms
Math.log(value)     // Natural log
Math.log10(value)   // Base 10 log

// Random
Math.srand(seed)
Math.rand()         // Random number

// Degrees/Radians conversion
var radians = degrees * Math.PI / 180;
var degrees = radians * 180 / Math.PI;
```

---

### Toybox.UserProfile

User profile information.

```monkey-c
using Toybox.UserProfile;

// Get user profile
var profile = UserProfile.getProfile();

var heartRateZones = profile.heartRateZones;  // Array of zone boundaries
var maxHeartRate = heartRateZones[heartRateZones.size() - 1];

var gender = profile.gender;
var weight = profile.weight;                   // grams
var height = profile.height;                   // centimeters
var birthYear = profile.birthYear;
var restingHeartRate = profile.restingHeartRate;

// Gender constants
UserProfile.GENDER_MALE
UserProfile.GENDER_FEMALE
```

---

### Toybox.Ant

ANT+ sensor connectivity.

```monkey-c
using Toybox.Ant;

// Create ANT channel
var channel = new Ant.GenericChannel(
    method(:onMessage)
);

// Configure channel
channel.open();
channel.setDeviceConfig({
    :deviceType => 120,        // Heart rate monitor
    :period => 8070,
    :frequency => 57,
    :transmission_type => 0
});

// Message callback
function onMessage(msg) {
    var payload = msg.getPayload();
    // Parse ANT+ data
}

// Close channel
channel.close();
channel.release();
```

---

### Toybox.BluetoothLowEnergy

Bluetooth Low Energy connectivity.

```monkey-c
using Toybox.BluetoothLowEnergy;

// BLE device scanning
var profileManager = BluetoothLowEnergy.getProfileManager();

profileManager.registerProfile(
    "service-uuid",
    method(:onProfileRegistered)
);

function onProfileRegistered(profile, status) {
    if (status == BluetoothLowEnergy.STATUS_SUCCESS) {
        // Profile registered
    }
}
```

---

## Module Organization Best Practices

### Import Only What You Need

```monkey-c
// Good - specific imports
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

// Avoid - importing everything
using Toybox;
```

### Organize Imports

```monkey-c
// Group by functionality
// Core application
using Toybox.Application;
using Toybox.WatchUi;

// Graphics and UI
using Toybox.Graphics;

// Data and sensors
using Toybox.Activity;
using Toybox.Sensor;

// Utilities
using Toybox.System;
using Toybox.Lang;
```

---

## Common API Combinations

### Watch Face with Activity Data

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Time;
using Toybox.Lang;

class MyWatchFace extends WatchUi.WatchFace {
    function onUpdate(dc) {
        var clockTime = System.getClockTime();
        var info = ActivityMonitor.getInfo();

        // Draw time
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour,
            clockTime.min.format("%02d")
        ]);

        // Draw steps
        var steps = info.steps != null ? info.steps : 0;
    }
}
```

### Data Field with GPS

```monkey-c
using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.Position;
using Toybox.Lang;

class MyDataField extends WatchUi.DataField {
    function compute(info) {
        var location = info.currentLocation;
        var speed = info.currentSpeed;

        // Calculate metrics
    }
}
```

### Widget with Network

```monkey-c
using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application.Storage;

class MyWidget extends WatchUi.View {
    function fetchData() {
        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onReceive)
        );
    }

    function onReceive(code, data) {
        Storage.setValue("data", data);
        WatchUi.requestUpdate();
    }
}
```

---

## Resources

- **Complete API Docs**: https://developer.garmin.com/connect-iq/api-docs/
- **Sample Apps**: https://github.com/garmin/connectiq-apps
- **Device Capabilities**: https://developer.garmin.com/connect-iq/compatible-devices/
