# Debugging and Testing in Connect IQ

## Overview

This guide covers debugging techniques, simulator usage, unit testing, common errors and solutions, and performance optimization for Connect IQ applications.

---

## Debugging Techniques

### Console Logging

```monkey-c
using Toybox.System;

class DebugLogger {
    // Basic logging
    static function log(message) {
        System.println(message);
    }

    // Formatted logging
    static function logf(format, args) {
        System.println(Lang.format(format, args));
    }

    // Log with context
    static function logWithContext(context, message) {
        System.println("[" + context + "] " + message);
    }

    // Log object
    static function logObject(name, obj) {
        System.println(name + ": " + obj.toString());
    }

    // Log array
    static function logArray(name, array) {
        System.println(name + " (" + array.size() + " items):");
        for (var i = 0; i < array.size(); i++) {
            System.println("  [" + i + "] " + array[i]);
        }
    }

    // Log dictionary
    static function logDict(name, dict) {
        System.println(name + ":");
        var keys = dict.keys();
        for (var i = 0; i < keys.size(); i++) {
            var key = keys[i];
            System.println("  " + key + ": " + dict[key]);
        }
    }

    // Conditional logging (debug builds only)
    (:debug)
    static function debug(message) {
        System.println("[DEBUG] " + message);
    }
}

// Usage
DebugLogger.log("App started");
DebugLogger.logf("User $1$ logged in", ["John"]);
DebugLogger.logWithContext("Network", "Request sent");
DebugLogger.logArray("Items", [1, 2, 3]);
DebugLogger.logDict("Settings", {:theme => 0, :units => 1});
DebugLogger.debug("This only appears in debug builds");
```

### Error Tracking

```monkey-c
using Toybox.System;

class ErrorTracker {
    private var _errors = [];
    private const MAX_ERRORS = 20;

    function logError(error, context) {
        var errorInfo = {
            :message => error.getErrorMessage(),
            :context => context,
            :time => Time.now().value(),
            :stackTrace => getStackTrace()
        };

        _errors.add(errorInfo);

        // Limit error history
        if (_errors.size() > MAX_ERRORS) {
            _errors = _errors.slice(-MAX_ERRORS, _errors.size());
        }

        // Log to console
        System.println("ERROR in " + context + ": " + error.getErrorMessage());

        // Save to storage
        Storage.setValue("errors", _errors);
    }

    function getErrors() {
        return _errors;
    }

    function clearErrors() {
        _errors = [];
        Storage.deleteValue("errors");
    }

    private function getStackTrace() {
        // Stack trace not available in Monkey C
        // Return context information instead
        return "Available via simulator";
    }

    // Example usage in try-catch
    static function safeExecute(func, context) {
        try {
            func.invoke();
        } catch (e) {
            getErrorTracker().logError(e, context);
        }
    }
}

// Global error tracker instance
var _globalErrorTracker = null;

function getErrorTracker() {
    if (_globalErrorTracker == null) {
        _globalErrorTracker = new ErrorTracker();
    }
    return _globalErrorTracker;
}

// Usage
try {
    riskyOperation();
} catch (e) {
    getErrorTracker().logError(e, "riskyOperation");
}
```

### Performance Monitoring

```monkey-c
using Toybox.System;

class PerformanceMonitor {
    private var _timers = {};

    function startTimer(name) {
        _timers[name] = System.getTimer();
    }

    function stopTimer(name) {
        if (_timers.hasKey(name)) {
            var elapsed = System.getTimer() - _timers[name];
            System.println(name + " took " + elapsed + "ms");
            _timers.remove(name);
            return elapsed;
        }
        return null;
    }

    function measureFunction(func, name) {
        startTimer(name);
        var result = func.invoke();
        stopTimer(name);
        return result;
    }

    // Memory tracking
    function logMemoryUsage(context) {
        var stats = System.getSystemStats();
        System.println(context + " - Memory:");
        System.println("  Total: " + stats.totalMemory);
        System.println("  Used: " + stats.usedMemory);
        System.println("  Free: " + stats.freeMemory);
        System.println("  % Used: " + ((stats.usedMemory.toFloat() / stats.totalMemory) * 100).format("%.1f") + "%");
    }

    // Battery tracking
    function logBatteryUsage() {
        var stats = System.getSystemStats();
        System.println("Battery: " + stats.battery.format("%.1f") + "%");
        System.println("Charging: " + stats.charging);
    }
}

// Usage
var perfMon = new PerformanceMonitor();

perfMon.startTimer("dataProcessing");
processData();
perfMon.stopTimer("dataProcessing");

perfMon.logMemoryUsage("After data load");

// Measure function
var result = perfMon.measureFunction(
    new Lang.Method(self, :expensiveOperation),
    "expensiveOperation"
);
```

---

## Simulator Usage

### Command Line Simulator

```bash
# Run app in simulator
monkeydo bin/MyApp.prg fenix6

# Run with specific device
monkeydo bin/MyApp.prg vivoactive4

# Run tests
monkeydo bin/MyApp.prg fenix6 -t

# Run with specific test
monkeydo bin/MyApp.prg fenix6 -t MyTest

# View available devices
monkeyc --devices
```

### Simulator Key Bindings

```
# Common actions in simulator
Enter       - Select button
Escape      - Back button
Up/Down     - Up/Down buttons
Left/Right  - Previous/Next page
M           - Menu
Space       - Start/Stop
L           - Lap button

# Watch face specific
T           - Advance time
Shift+T     - Go back in time

# Data field specific
S           - Start activity
P           - Pause activity
L           - Add lap
```

### Simulator Limitations

```monkey-c
// Check if running in simulator
function isSimulator() {
    var deviceSettings = System.getDeviceSettings();
    // Simulator doesn't have actual device identifiers
    return deviceSettings.partNumber.equals("006-B2362-00");
}

// Provide test data in simulator
function getTestData() {
    if (isSimulator()) {
        return {
            :heartRate => 145,
            :speed => 2.5,
            :distance => 5000
        };
    } else {
        return getActualData();
    }
}
```

---

## Unit Testing

### Basic Test Structure

```monkey-c
using Toybox.Test;

// Test annotation
(:test)
function testAddition(logger) {
    var result = 2 + 2;
    Test.assertEqual(result, 4);
    return true;
}

(:test)
function testSubtraction(logger) {
    var result = 5 - 3;
    Test.assertEqual(result, 2);
    return true;
}

(:test)
function testFailure(logger) {
    var result = 2 + 2;
    Test.assertNotEqual(result, 5);
    return true;
}
```

### Test Assertions

```monkey-c
using Toybox.Test;

(:test)
function testAssertions(logger) {
    // Equal
    Test.assertEqual(5, 5);
    Test.assertEqual("hello", "hello");

    // Not equal
    Test.assertNotEqual(5, 3);

    // True/False
    Test.assertTrue(true);
    Test.assertFalse(false);

    // Null
    Test.assertNull(null);
    Test.assertNotNull("value");

    // Type checking
    var value = 42;
    Test.assert(value instanceof Number);

    return true;
}
```

### Testing Classes

```monkey-c
using Toybox.Test;

class Calculator {
    function add(a, b) {
        return a + b;
    }

    function subtract(a, b) {
        return a - b;
    }

    function multiply(a, b) {
        return a * b;
    }

    function divide(a, b) {
        if (b == 0) {
            throw new Lang.InvalidValueException("Division by zero");
        }
        return a / b;
    }
}

(:test)
function testCalculatorAdd(logger) {
    var calc = new Calculator();
    Test.assertEqual(calc.add(2, 3), 5);
    Test.assertEqual(calc.add(-1, 1), 0);
    return true;
}

(:test)
function testCalculatorSubtract(logger) {
    var calc = new Calculator();
    Test.assertEqual(calc.subtract(5, 3), 2);
    Test.assertEqual(calc.subtract(3, 5), -2);
    return true;
}

(:test)
function testCalculatorMultiply(logger) {
    var calc = new Calculator();
    Test.assertEqual(calc.multiply(3, 4), 12);
    Test.assertEqual(calc.multiply(-2, 3), -6);
    return true;
}

(:test)
function testCalculatorDivide(logger) {
    var calc = new Calculator();
    Test.assertEqual(calc.divide(10, 2), 5);

    // Test exception
    try {
        calc.divide(10, 0);
        Test.assert(false);  // Should not reach here
    } catch (e instanceof Lang.InvalidValueException) {
        Test.assert(true);
    }

    return true;
}
```

### Mock Data for Tests

```monkey-c
module TestData {
    function getMockActivityInfo() {
        return {
            :currentSpeed => 2.5,
            :averageSpeed => 2.3,
            :currentHeartRate => 145,
            :averageHeartRate => 140,
            :currentCadence => 180,
            :elapsedDistance => 5000,
            :elapsedTime => 1800000,  // 30 minutes
            :calories => 350
        };
    }

    function getMockLocation() {
        return new Position.Location({
            :latitude => 45.5231,
            :longitude => -122.6765,
            :format => :degrees
        });
    }

    function getMockSensorInfo() {
        return {
            :heartRate => 145,
            :temperature => 22.5,
            :pressure => 101325,
            :altitude => 100
        };
    }
}

(:test)
function testWithMockData(logger) {
    var info = TestData.getMockActivityInfo();
    Test.assertEqual(info[:currentSpeed], 2.5);
    Test.assertEqual(info[:currentHeartRate], 145);
    return true;
}
```

---

## Common Errors and Solutions

### Memory Errors

```monkey-c
// OutOfMemoryException
try {
    var largeArray = new [10000];
} catch (e instanceof Lang.OutOfMemoryException) {
    System.println("Out of memory!");
    // Reduce memory usage
}

// Solutions:
// 1. Reduce resource sizes
// 2. Clear unused objects
// 3. Use smaller data structures
// 4. Target higher-memory devices
```

### Null Pointer Errors

```monkey-c
// Always check for null
var info = Activity.getActivityInfo();
if (info == null) {
    return;  // Early return
}

// Null-safe access
var hr = info.currentHeartRate;
if (hr != null) {
    // Use heart rate
    processHeartRate(hr);
}

// Provide defaults
var hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
```

### Type Errors

```monkey-c
// UnexpectedTypeException
var value = getSomeValue();

// Check type before using
if (value instanceof Number) {
    var doubled = value * 2;
} else if (value instanceof String) {
    var upper = value.toUpper();
}

// Type conversion
var str = "123";
try {
    var num = str.toNumber();
} catch (e instanceof Lang.InvalidValueException) {
    System.println("Invalid number format");
}
```

### Invalid Value Errors

```monkey-c
// InvalidValueException
function divide(a, b) {
    if (b == 0) {
        throw new Lang.InvalidValueException("Division by zero");
    }
    return a / b;
}

// Handle invalid values
function processSpeed(speed) {
    if (speed == null || speed < 0) {
        System.println("Invalid speed: " + speed);
        return 0;
    }
    return speed;
}
```

### Resource Not Found

```monkey-c
// Resource loading errors
try {
    var bitmap = WatchUi.loadResource(Rez.Drawables.MyImage);
    if (bitmap != null) {
        dc.drawBitmap(0, 0, bitmap);
    }
} catch (e) {
    System.println("Failed to load resource: " + e.getErrorMessage());
    // Draw placeholder
    dc.drawText(50, 50, Graphics.FONT_SMALL, "No Image", Graphics.TEXT_JUSTIFY_LEFT);
}
```

---

## Performance Optimization

### Memory Optimization

```monkey-c
class MemoryOptimizedView extends WatchUi.View {
    private var _cachedData = null;
    private var _cacheValid = false;

    function onUpdate(dc) {
        // Use cache when possible
        if (_cacheValid && _cachedData != null) {
            drawCached(dc);
            return;
        }

        // Compute and cache
        _cachedData = computeExpensiveData();
        _cacheValid = true;
        draw(dc);
    }

    function invalidateCache() {
        _cacheValid = false;
        _cachedData = null;  // Free memory
    }

    function onHide() {
        // Free memory when hidden
        invalidateCache();
    }

    private function computeExpensiveData() {
        // Expensive computation
        return data;
    }

    private function draw(dc) {
        // Draw using cached data
    }

    private function drawCached(dc) {
        // Quick draw using cache
    }
}
```

### Rendering Optimization

```monkey-c
class OptimizedRenderer {
    private var _lastUpdateTime = 0;
    private const UPDATE_INTERVAL = 1000;  // 1 second

    function onUpdate(dc) {
        var now = System.getTimer();

        // Throttle updates
        if (now - _lastUpdateTime < UPDATE_INTERVAL) {
            return;
        }

        _lastUpdateTime = now;

        // Only draw what changed
        drawStaticElements(dc);
        drawDynamicElements(dc);
    }

    private function drawStaticElements(dc) {
        // Draw once and cache
    }

    private function drawDynamicElements(dc) {
        // Update only changing elements
    }
}
```

### Data Structure Optimization

```monkey-c
// Efficient data structures
class OptimizedDataStructure {
    // Use appropriate types
    private var _count as Number = 0;
    private var _active as Boolean = false;
    private var _name as String = "";

    // Limit collection sizes
    private var _history = [];
    private const MAX_HISTORY = 100;

    function addToHistory(item) {
        _history.add(item);

        // Prune old data
        if (_history.size() > MAX_HISTORY) {
            _history = _history.slice(-MAX_HISTORY, _history.size());
        }
    }

    // Use dictionaries for lookups
    private var _lookup = {};

    function addItem(id, item) {
        _lookup[id] = item;  // O(1) lookup
    }

    function getItem(id) {
        return _lookup[id];
    }
}
```

### Battery Optimization

```monkey-c
class BatteryOptimized extends WatchUi.WatchFace {
    private var _inLowPowerMode = false;

    function onEnterSleep() {
        _inLowPowerMode = true;
        // Stop unnecessary updates
        stopTimers();
        clearCache();
    }

    function onExitSleep() {
        _inLowPowerMode = false;
        // Resume normal operation
    }

    function onUpdate(dc) {
        if (_inLowPowerMode) {
            // Minimal updates in low power mode
            drawMinimal(dc);
        } else {
            // Full updates when active
            drawFull(dc);
        }
    }

    private function stopTimers() {
        // Stop background timers
    }

    private function clearCache() {
        // Free memory
    }

    private function drawMinimal(dc) {
        // Draw only essential information
    }

    private function drawFull(dc) {
        // Draw complete UI
    }
}
```

---

## Debugging Checklist

### Pre-Release Testing

```
☐ Test on all target devices
☐ Test on lowest-memory device
☐ Test with GPS enabled
☐ Test with various sensor configurations
☐ Test with network errors
☐ Test offline mode
☐ Test battery impact
☐ Test memory usage
☐ Test with different settings
☐ Test edge cases (null values, zeros, etc.)
☐ Test interruptions (calls, notifications)
☐ Test data field in actual activities
☐ Test watch face for 24 hours
☐ Review all error logs
☐ Check for memory leaks
```

### Common Issues

```
Issue: App crashes on low-memory devices
Solution: Reduce resource sizes, optimize data structures

Issue: GPS not working
Solution: Check permissions, enable location events

Issue: Network requests fail
Solution: Check phone connection, handle errors

Issue: Data field not updating
Solution: Check compute() method, verify data sources

Issue: Watch face draining battery
Solution: Optimize onUpdate(), reduce timer frequency

Issue: Resources not loading
Solution: Check resource paths, verify manifest

Issue: Tests failing
Solution: Check assertions, verify test data
```

---

## Tools and Resources

### Development Tools

```bash
# Compiler
monkeyc --help

# Simulator
monkeydo --help

# Graphics tool
monkeygraph

# Documentation generator
monkeydoc
```

### Useful Commands

```bash
# Build with warnings
monkeyc -w -o output.prg ...

# Run tests
monkeydo output.prg device -t

# Profile memory
monkeydo output.prg device --profile

# View device info
monkeyc --devices

# Clean build
rm -rf bin/*
```

---

## Best Practices

### Debugging
✅ Use descriptive log messages
✅ Log at key decision points
✅ Track errors with context
✅ Monitor memory usage

❌ Don't leave debug logs in production
❌ Don't ignore warnings
❌ Don't skip error handling

### Testing
✅ Write tests for critical logic
✅ Test edge cases
✅ Use mock data
✅ Test on actual devices

❌ Don't rely only on simulator
❌ Don't skip regression testing
❌ Don't ignore failed tests

### Performance
✅ Profile before optimizing
✅ Cache when appropriate
✅ Minimize memory allocations
✅ Throttle updates

❌ Don't optimize prematurely
❌ Don't ignore memory limits
❌ Don't update unnecessarily

---

## Resources

- **Testing Guide**: https://developer.garmin.com/connect-iq/core-topics/unit-testing/
- **Debugging Guide**: https://developer.garmin.com/connect-iq/core-topics/debugging/
- **Profiling Guide**: https://developer.garmin.com/connect-iq/core-topics/profiling/
- **Exception Reporting**: https://developer.garmin.com/connect-iq/core-topics/exception-reporting/
