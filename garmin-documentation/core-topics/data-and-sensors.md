# Data and Sensors in Connect IQ

## Overview

This guide covers accessing sensor data, activity recording, data persistence, and FIT file handling in Connect IQ applications.

---

## Activity Data

### Real-Time Activity Information

```monkey-c
using Toybox.Activity;

function getActivityData() {
    var info = Activity.getActivityInfo();

    if (info == null) {
        return null;
    }

    var data = {};

    // Location
    if (info.currentLocation != null) {
        var position = info.currentLocation.toRadians();
        data[:latitude] = position[0];
        data[:longitude] = position[1];

        var degrees = info.currentLocation.toDegrees();
        data[:latDegrees] = degrees[0];
        data[:lonDegrees] = degrees[1];
    }

    // Speed and pace
    data[:speed] = info.currentSpeed;              // m/s
    data[:averageSpeed] = info.averageSpeed;       // m/s
    data[:maxSpeed] = info.maxSpeed;               // m/s

    // Heart rate
    data[:heartRate] = info.currentHeartRate;      // bpm
    data[:averageHR] = info.averageHeartRate;      // bpm
    data[:maxHR] = info.maxHeartRate;              // bpm

    // Cadence (running: steps/min, cycling: rpm)
    data[:cadence] = info.currentCadence;
    data[:averageCadence] = info.averageCadence;

    // Power (cycling)
    data[:power] = info.currentPower;              // watts
    data[:averagePower] = info.averagePower;

    // Distance and time
    data[:distance] = info.elapsedDistance;        // meters
    data[:elapsedTime] = info.elapsedTime;         // milliseconds
    data[:timerTime] = info.timerTime;             // milliseconds

    // Calories
    data[:calories] = info.calories;

    // Altitude
    data[:altitude] = info.altitude;               // meters
    data[:totalAscent] = info.totalAscent;         // meters
    data[:totalDescent] = info.totalDescent;       // meters

    // Environmental
    data[:ambientPressure] = info.ambientPressure; // Pa
    data[:meanSeaLevelPressure] = info.meanSeaLevelPressure;

    // Training effect
    data[:trainingEffect] = info.trainingEffect;

    return data;
}
```

### Data Field Implementation

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;

class CustomDataField extends WatchUi.DataField {
    private var _currentValue = 0.0;
    private var _averageValue = 0.0;
    private var _samples = [];
    private const MAX_SAMPLES = 10;

    function initialize() {
        DataField.initialize();
    }

    function compute(info) {
        // Example: Running efficiency metric
        var speed = info.currentSpeed;
        var hr = info.currentHeartRate;
        var cadence = info.currentCadence;

        if (speed != null && hr != null && speed > 0) {
            // Calculate efficiency (example formula)
            _currentValue = (speed * cadence) / hr;

            // Track moving average
            _samples.add(_currentValue);
            if (_samples.size() > MAX_SAMPLES) {
                _samples = _samples.slice(1, _samples.size());
            }

            var sum = 0.0;
            for (var i = 0; i < _samples.size(); i++) {
                sum += _samples[i];
            }
            _averageValue = sum / _samples.size();
        } else {
            _currentValue = 0.0;
        }
    }

    function onUpdate(dc) {
        // Check for privacy mode
        var obscurityFlags = getObscurityFlags();
        if (obscurityFlags & OBSCURE_TOP) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.clear();
            return;
        }

        // Clear background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            20,
            Graphics.FONT_TINY,
            "EFFICIENCY",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw current value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_NUMBER_MEDIUM,
            _currentValue.format("%.1f"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Draw average
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - 20,
            Graphics.FONT_XTINY,
            "Avg: " + _averageValue.format("%.1f"),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
```

---

## Activity Recording

### Creating and Managing Sessions

```monkey-c
using Toybox.ActivityRecording;
using Toybox.Activity;
using Toybox.FitContributor;

class WorkoutRecorder {
    private var _session;
    private var _fitField;
    private var _isRecording = false;

    function initialize() {
        _session = null;
        _fitField = null;
    }

    function startRecording() {
        if (_isRecording) {
            return;
        }

        // Create session
        if (Toybox has :ActivityRecording) {
            _session = ActivityRecording.createSession({
                :name => "Custom Workout",
                :sport => ActivityRecording.SPORT_RUNNING,
                :subSport => ActivityRecording.SUB_SPORT_GENERIC
            });

            // Create FIT field for custom data
            if (Toybox has :FitContributor) {
                _fitField = _session.createField(
                    "efficiency",
                    0,  // field ID
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType => FitContributor.MESG_TYPE_RECORD,
                     :units => "score"}
                );
            }

            _session.start();
            _isRecording = true;
        }
    }

    function stopRecording() {
        if (_session != null && _isRecording) {
            _session.stop();
            _isRecording = false;
        }
    }

    function saveRecording() {
        if (_session != null) {
            _session.save();
            _session = null;
            _fitField = null;
            _isRecording = false;
        }
    }

    function discardRecording() {
        if (_session != null) {
            _session.discard();
            _session = null;
            _fitField = null;
            _isRecording = false;
        }
    }

    function addLap() {
        if (_session != null && _isRecording) {
            _session.addLap();
        }
    }

    function isRecording() {
        return _isRecording;
    }

    function setCustomData(value) {
        if (_fitField != null) {
            _fitField.setData(value);
        }
    }

    // Get session status
    function getSessionInfo() {
        if (_session == null) {
            return null;
        }

        var info = Activity.getActivityInfo();
        return {
            :isRecording => _session.isRecording(),
            :isPaused => !_session.isRecording(),
            :elapsedTime => info.elapsedTime,
            :distance => info.elapsedDistance,
            :calories => info.calories
        };
    }
}

// Usage in app
var recorder = new WorkoutRecorder();

// Start workout
recorder.startRecording();

// During workout, log custom data
recorder.setCustomData(customValue);

// Add lap
recorder.addLap();

// Stop and save
recorder.stopRecording();
recorder.saveRecording();
```

### Sport Types

```monkey-c
// Sport types available
ActivityRecording.SPORT_RUNNING
ActivityRecording.SPORT_CYCLING
ActivityRecording.SPORT_SWIMMING
ActivityRecording.SPORT_FITNESS_EQUIPMENT
ActivityRecording.SPORT_HIKING
ActivityRecording.SPORT_WALKING
ActivityRecording.SPORT_MULTISPORT
ActivityRecording.SPORT_GENERIC

// Sub-sport types
ActivityRecording.SUB_SPORT_GENERIC
ActivityRecording.SUB_SPORT_TREADMILL
ActivityRecording.SUB_SPORT_TRAIL
ActivityRecording.SUB_SPORT_TRACK
ActivityRecording.SUB_SPORT_INDOOR_CYCLING
ActivityRecording.SUB_SPORT_ROAD
ActivityRecording.SUB_SPORT_MOUNTAIN
```

---

## Sensors

### Enabling Sensors

```monkey-c
using Toybox.Sensor;

class SensorManager {
    private var _listeners = [];

    function initialize() {
    }

    function startSensors() {
        // Enable specific sensors
        var sensors = [
            Sensor.SENSOR_HEARTRATE,
            Sensor.SENSOR_TEMPERATURE,
            Sensor.SENSOR_PRESSURE
        ];

        Sensor.setEnabledSensors(sensors);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function stopSensors() {
        Sensor.setEnabledSensors([]);
        Sensor.enableSensorEvents(null);
    }

    function addListener(listener) {
        _listeners.add(listener);
    }

    function onSensor(info) {
        var data = {
            :heartRate => info.heartRate,
            :temperature => info.temperature,      // Celsius
            :pressure => info.pressure,            // Pa
            :altitude => info.altitude,            // meters
            :cadence => info.cadence,
            :speed => info.speed,                  // m/s
            :heading => info.heading               // radians
        };

        // Notify listeners
        for (var i = 0; i < _listeners.size(); i++) {
            _listeners[i].onSensorData(data);
        }
    }
}

// Available sensors (device-dependent)
Sensor.SENSOR_HEARTRATE
Sensor.SENSOR_TEMPERATURE
Sensor.SENSOR_PRESSURE
Sensor.SENSOR_ONBOARD
```

### Sensor History

```monkey-c
using Toybox.Sensor;
using Toybox.SensorHistory;

function getHeartRateHistory() {
    if (!(Toybox has :SensorHistory)) {
        return null;
    }

    var options = {
        :period => 1,  // 1 = most recent samples
        :order => Sensor.ORDER_NEWEST_FIRST
    };

    var history = Sensor.getHeartRateHistory(options);
    var samples = [];

    if (history != null) {
        var iterator = history.next();
        while (iterator != null && samples.size() < 10) {
            samples.add({
                :heartRate => iterator.heartRate,
                :when => iterator.when
            });
            iterator = history.next();
        }
    }

    return samples;
}

// Temperature history
function getTemperatureHistory() {
    var options = {
        :period => 1,
        :order => Sensor.ORDER_NEWEST_FIRST
    };

    var history = Sensor.getTemperatureHistory(options);
    var samples = [];

    if (history != null) {
        var iterator = history.next();
        while (iterator != null && samples.size() < 10) {
            samples.add({
                :temperature => iterator.data,
                :when => iterator.when
            });
            iterator = history.next();
        }
    }

    return samples;
}
```

---

## Activity Monitor

### Daily Activity Metrics

```monkey-c
using Toybox.ActivityMonitor;
using Toybox.Time;

class DailyActivityTracker {
    function getCurrentStats() {
        var info = ActivityMonitor.getInfo();

        return {
            // Steps
            :steps => info.steps != null ? info.steps : 0,
            :stepGoal => info.stepGoal != null ? info.stepGoal : 0,
            :stepsProgress => getProgress(info.steps, info.stepGoal),

            // Floors
            :floorsClimbed => info.floorsClimbed != null ? info.floorsClimbed : 0,
            :floorsGoal => info.floorsClimbedGoal != null ? info.floorsClimbedGoal : 0,
            :floorsProgress => getProgress(info.floorsClimbed, info.floorsClimbedGoal),

            // Distance (centimeters)
            :distance => info.distance != null ? info.distance : 0,
            :distanceKm => info.distance != null ? info.distance / 100000.0 : 0.0,

            // Calories
            :calories => info.calories != null ? info.calories : 0,

            // Active minutes
            :activeMinutesDay => info.activeMinutesDay != null ?
                info.activeMinutesDay.total : 0,
            :activeMinutesWeek => info.activeMinutesWeek != null ?
                info.activeMinutesWeek.total : 0,
            :activeMinutesWeekGoal => info.activeMinutesWeekGoal != null ?
                info.activeMinutesWeekGoal : 0
        };
    }

    private function getProgress(current, goal) {
        if (current == null || goal == null || goal == 0) {
            return 0.0;
        }
        return (current.toFloat() / goal) * 100.0;
    }

    function getHeartRateStats() {
        var history = ActivityMonitor.getHeartRateHistory(1, true);
        var samples = [];
        var sum = 0;
        var count = 0;
        var max = 0;
        var min = 999;

        if (history != null) {
            var iterator = history.next();
            while (iterator != null) {
                var hr = iterator.heartRate;
                if (hr != null && hr != ActivityMonitor.INVALID_HR_SAMPLE) {
                    samples.add(hr);
                    sum += hr;
                    count++;
                    if (hr > max) { max = hr; }
                    if (hr < min) { min = hr; }
                }
                iterator = history.next();
            }
        }

        return {
            :current => samples.size() > 0 ? samples[0] : null,
            :average => count > 0 ? sum / count : 0,
            :max => max > 0 ? max : null,
            :min => min < 999 ? min : null,
            :samples => samples
        };
    }
}
```

---

## GPS and Location

### Location Services

```monkey-c
using Toybox.Position;
using Toybox.Math;

class LocationService {
    private var _listeners = [];
    private var _lastPosition = null;
    private var _totalDistance = 0.0;
    private var _isEnabled = false;

    function initialize() {
    }

    function start() {
        if (!_isEnabled) {
            Position.enableLocationEvents(
                Position.LOCATION_CONTINUOUS,
                method(:onPosition)
            );
            _isEnabled = true;
        }
    }

    function stop() {
        if (_isEnabled) {
            Position.enableLocationEvents(
                Position.LOCATION_DISABLE,
                method(:onPosition)
            );
            _isEnabled = false;
        }
    }

    function addListener(listener) {
        _listeners.add(listener);
    }

    function getLastPosition() {
        return _lastPosition;
    }

    function getTotalDistance() {
        return _totalDistance;
    }

    private function onPosition(info) {
        var position = info.position;

        if (position != null) {
            // Calculate distance if we have previous position
            if (_lastPosition != null) {
                var distance = calculateDistance(_lastPosition, position);
                _totalDistance += distance;
            }

            _lastPosition = position;

            var locationData = {
                :position => position,
                :latitude => position.toRadians()[0],
                :longitude => position.toRadians()[1],
                :accuracy => info.accuracy,
                :speed => info.speed,
                :heading => info.heading,
                :altitude => info.altitude,
                :when => info.when
            };

            // Notify listeners
            for (var i = 0; i < _listeners.size(); i++) {
                _listeners[i].onLocationChanged(locationData);
            }
        }
    }

    private function calculateDistance(pos1, pos2) {
        // Haversine formula
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

        var R = 6371000; // Earth radius in meters
        return R * c;
    }
}
```

---

## Data Persistence

### Using Storage

```monkey-c
using Toybox.Application.Storage;
using Toybox.Time;

class DataStorage {
    // Save simple values
    function saveValue(key, value) {
        Storage.setValue(key, value);
    }

    function getValue(key) {
        return Storage.getValue(key);
    }

    function deleteValue(key) {
        Storage.deleteValue(key);
    }

    // Save complex data
    function saveWorkout(workout) {
        var data = {
            :date => workout.date.value(),
            :duration => workout.duration,
            :distance => workout.distance,
            :calories => workout.calories,
            :avgHR => workout.avgHeartRate
        };

        Storage.setValue("workout_" + workout.id, data);
    }

    function loadWorkout(workoutId) {
        var data = Storage.getValue("workout_" + workoutId);

        if (data == null) {
            return null;
        }

        return {
            :id => workoutId,
            :date => new Time.Moment(data[:date]),
            :duration => data[:duration],
            :distance => data[:distance],
            :calories => data[:calories],
            :avgHeartRate => data[:avgHR]
        };
    }

    // Save arrays
    function saveHistory(history) {
        Storage.setValue("history", history);
    }

    function loadHistory() {
        var history = Storage.getValue("history");
        return history != null ? history : [];
    }

    function addToHistory(item) {
        var history = loadHistory();
        history.add(item);

        // Limit history size
        if (history.size() > 50) {
            history = history.slice(-50, history.size());
        }

        saveHistory(history);
    }
}

// Usage
var storage = new DataStorage();
storage.saveValue("lastRun", Time.now().value());
var lastRun = storage.getValue("lastRun");
```

### Using Properties

```monkey-c
using Toybox.Application.Properties;

class SettingsManager {
    // Settings keys
    private const KEY_THEME = "theme";
    private const KEY_UNITS = "units";
    private const KEY_AUTO_LAP = "autoLap";
    private const KEY_LAP_DISTANCE = "lapDistance";

    // Get settings
    function getTheme() {
        return Properties.getValue(KEY_THEME);
    }

    function isMetric() {
        return Properties.getValue(KEY_UNITS) == 0;
    }

    function getAutoLapEnabled() {
        return Properties.getValue(KEY_AUTO_LAP);
    }

    function getLapDistance() {
        var distance = Properties.getValue(KEY_LAP_DISTANCE);
        return distance != null ? distance : 1000;  // Default 1km
    }

    // Set settings
    function setTheme(theme) {
        Properties.setValue(KEY_THEME, theme);
    }

    function setUnits(units) {
        Properties.setValue(KEY_UNITS, units);
    }

    function setAutoLapEnabled(enabled) {
        Properties.setValue(KEY_AUTO_LAP, enabled);
    }

    function setLapDistance(distance) {
        Properties.setValue(KEY_LAP_DISTANCE, distance);
    }

    // Format values based on settings
    function formatDistance(meters) {
        if (isMetric()) {
            return (meters / 1000.0).format("%.2f") + " km";
        } else {
            return (meters / 1609.34).format("%.2f") + " mi";
        }
    }

    function formatSpeed(metersPerSecond) {
        if (metersPerSecond == null || metersPerSecond <= 0) {
            return "--";
        }

        if (isMetric()) {
            return (metersPerSecond * 3.6).format("%.1f") + " km/h";
        } else {
            return (metersPerSecond * 2.23694).format("%.1f") + " mph";
        }
    }
}
```

---

## FIT File Contributions

### Custom FIT Fields

```monkey-c
using Toybox.FitContributor;

class CustomFitData {
    private var _session;
    private var _efficiencyField;
    private var _powerBalanceField;

    function initialize(session) {
        _session = session;

        if (Toybox has :FitContributor) {
            // Create custom efficiency field
            _efficiencyField = _session.createField(
                "run_efficiency",
                0,
                FitContributor.DATA_TYPE_FLOAT,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                    :units => "score"
                }
            );

            // Create power balance field
            _powerBalanceField = _session.createField(
                "power_balance",
                1,
                FitContributor.DATA_TYPE_UINT8,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                    :units => "percent"
                }
            );
        }
    }

    function setEfficiency(value) {
        if (_efficiencyField != null) {
            _efficiencyField.setData(value);
        }
    }

    function setPowerBalance(value) {
        if (_powerBalanceField != null) {
            _powerBalanceField.setData(value);
        }
    }
}

// FIT data types
FitContributor.DATA_TYPE_SINT8
FitContributor.DATA_TYPE_UINT8
FitContributor.DATA_TYPE_SINT16
FitContributor.DATA_TYPE_UINT16
FitContributor.DATA_TYPE_SINT32
FitContributor.DATA_TYPE_UINT32
FitContributor.DATA_TYPE_FLOAT
FitContributor.DATA_TYPE_STRING

// Message types
FitContributor.MESG_TYPE_RECORD
FitContributor.MESG_TYPE_SESSION
FitContributor.MESG_TYPE_LAP
```

---

## Best Practices

### Data Handling
✅ Always check for null values
✅ Handle missing sensor data gracefully
✅ Validate data ranges
✅ Use appropriate data types

❌ Don't assume sensors are available
❌ Don't ignore data quality indicators
❌ Don't store excessive history

### Performance
✅ Batch sensor updates
✅ Use efficient data structures
✅ Minimize storage operations
✅ Cache frequently accessed data

❌ Don't poll sensors continuously
❌ Don't write to storage every second
❌ Don't store raw sensor data

### Memory
✅ Limit history size
✅ Clear old data periodically
✅ Use appropriate precision
✅ Test on low-memory devices

❌ Don't keep unlimited history
❌ Don't use excessive precision
❌ Don't leak resources

---

## Resources

- **Activity API**: https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html
- **Sensor API**: https://developer.garmin.com/connect-iq/api-docs/Toybox/Sensor.html
- **FIT SDK**: https://developer.garmin.com/fit/overview/
- **Sample Apps**: https://github.com/garmin/connectiq-apps
