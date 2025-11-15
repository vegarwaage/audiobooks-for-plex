# Common Monkey C Patterns

## Overview

This guide covers common code patterns, best practices, and idioms used in Connect IQ development, based on real-world applications and sample code from the Garmin repository.

---

## Application Patterns

### Basic App Structure Pattern

```monkey-c
using Toybox.Application;
using Toybox.WatchUi;

// Application class manages lifecycle
class MyApp extends Application.AppBase {
    private var _model;
    private var _controller;

    function initialize() {
        AppBase.initialize();
        _model = new AppModel();
        _controller = new AppController(_model);
    }

    function onStart(state) {
        // Restore from saved state
        if (state != null) {
            _model.restore(state);
        }
        _controller.onStart();
    }

    function onStop(state) {
        // Save state for next launch
        _controller.onStop();
        return _model.getState();
    }

    function getInitialView() {
        var view = new MainView(_model);
        var delegate = new MainDelegate(_controller);
        return [view, delegate];
    }
}
```

### Watch Face Structure Pattern

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;

class MyWatchFace extends WatchUi.WatchFace {
    private var _screenShape;
    private var _cached Data = {};

    function initialize() {
        WatchFace.initialize();
        _screenShape = System.getDeviceSettings().screenShape;
    }

    function onLayout(dc) {
        // Set up layout if using XML resources
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
        // View is displayed
    }

    function onUpdate(dc) {
        // Get fresh data
        var clockTime = System.getClockTime();
        var info = ActivityMonitor.getInfo();

        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw cached elements (background, etc.)
        drawBackground(dc);

        // Draw dynamic elements (time, data)
        drawTime(dc, clockTime);
        drawStats(dc, info);
    }

    function onHide() {
        // View is hidden
    }

    function onEnterSleep() {
        // Reduce update frequency
        _cachedData = {};
    }

    function onExitSleep() {
        WatchUi.requestUpdate();
    }

    private function drawTime(dc, clockTime) {
        var timeString = getTimeString(clockTime);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 3,
            Graphics.FONT_NUMBER_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function getTimeString(clockTime) {
        var hour = clockTime.hour;
        var deviceSettings = System.getDeviceSettings();

        if (!deviceSettings.is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }

        return Lang.format("$1$:$2$", [
            hour,
            clockTime.min.format("%02d")
        ]);
    }

    private function drawStats(dc, info) {
        // Draw steps, calories, etc.
    }

    private function drawBackground(dc) {
        // Draw static background elements
    }
}
```

---

## View-Delegate Pattern

### View Class Pattern

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;

class MainView extends WatchUi.View {
    private var _model;
    private var _currentPage = 0;
    private var _totalPages = 3;

    function initialize(model) {
        View.initialize();
        _model = model;
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() {
        // Refresh data
        _model.refresh();
    }

    function onUpdate(dc) {
        View.onUpdate(dc);

        // Draw page indicator
        drawPageIndicator(dc);

        // Draw current page
        switch (_currentPage) {
            case 0:
                drawPage1(dc);
                break;
            case 1:
                drawPage2(dc);
                break;
            case 2:
                drawPage3(dc);
                break;
        }
    }

    function nextPage() {
        _currentPage = (_currentPage + 1) % _totalPages;
        WatchUi.requestUpdate();
    }

    function previousPage() {
        _currentPage = (_currentPage - 1 + _totalPages) % _totalPages;
        WatchUi.requestUpdate();
    }

    private function drawPageIndicator(dc) {
        var centerX = dc.getWidth() / 2;
        var y = dc.getHeight() - 20;

        for (var i = 0; i < _totalPages; i++) {
            var x = centerX + (i - _totalPages / 2) * 15;
            dc.setColor(
                i == _currentPage ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_TRANSPARENT
            );
            dc.fillCircle(x, y, 4);
        }
    }

    private function drawPage1(dc) { /* ... */ }
    private function drawPage2(dc) { /* ... */ }
    private function drawPage3(dc) { /* ... */ }
}
```

### Delegate Class Pattern

```monkey-c
using Toybox.WatchUi;
using Toybox.System;

class MainDelegate extends WatchUi.BehaviorDelegate {
    private var _view;
    private var _controller;

    function initialize(view, controller) {
        BehaviorDelegate.initialize();
        _view = view;
        _controller = controller;
    }

    function onSelect() {
        _controller.handleSelect();
        return true;  // Event handled
    }

    function onBack() {
        // Return false to exit app
        return false;
    }

    function onNextPage() {
        _view.nextPage();
        return true;
    }

    function onPreviousPage() {
        _view.previousPage();
        return true;
    }

    function onMenu() {
        var menu = new Rez.Menus.MainMenu();
        var menuDelegate = new MainMenuDelegate();
        WatchUi.pushView(menu, menuDelegate, WatchUi.SLIDE_UP);
        return true;
    }
}
```

---

## Model Patterns

### Data Model Pattern

```monkey-c
using Toybox.Application.Storage;
using Toybox.Time;

class AppModel {
    private var _data;
    private var _observers = [];

    function initialize() {
        _data = {
            :count => 0,
            :lastUpdate => null,
            :items => []
        };
        load();
    }

    // Observer pattern
    function addObserver(observer) {
        _observers.add(observer);
    }

    function notifyObservers() {
        for (var i = 0; i < _observers.size(); i++) {
            _observers[i].onModelChanged(self);
        }
    }

    // Data access
    function getCount() {
        return _data[:count];
    }

    function incrementCount() {
        _data[:count]++;
        _data[:lastUpdate] = Time.now();
        save();
        notifyObservers();
    }

    function getItems() {
        return _data[:items];
    }

    function addItem(item) {
        _data[:items].add(item);
        save();
        notifyObservers();
    }

    // Persistence
    function save() {
        Storage.setValue("appData", _data);
    }

    function load() {
        var stored = Storage.getValue("appData");
        if (stored != null) {
            _data = stored;
        }
    }

    // State management for lifecycle
    function getState() {
        return {
            :count => _data[:count],
            :lastUpdate => _data[:lastUpdate] != null ?
                _data[:lastUpdate].value() : null
        };
    }

    function restore(state) {
        if (state != null) {
            _data[:count] = state[:count];
            if (state[:lastUpdate] != null) {
                _data[:lastUpdate] = new Time.Moment(state[:lastUpdate]);
            }
        }
    }
}
```

### Settings Model Pattern

```monkey-c
using Toybox.Application.Properties;

class SettingsModel {
    // Setting keys
    private const KEY_THEME = "theme";
    private const KEY_UNITS = "units";
    private const KEY_SHOW_SECONDS = "showSeconds";

    // Default values
    private const DEFAULT_THEME = 0;        // Dark
    private const DEFAULT_UNITS = 0;        // Metric
    private const DEFAULT_SHOW_SECONDS = true;

    function getTheme() {
        var value = Properties.getValue(KEY_THEME);
        return value != null ? value : DEFAULT_THEME;
    }

    function setTheme(value) {
        Properties.setValue(KEY_THEME, value);
    }

    function getUnits() {
        var value = Properties.getValue(KEY_UNITS);
        return value != null ? value : DEFAULT_UNITS;
    }

    function setUnits(value) {
        Properties.setValue(KEY_UNITS, value);
    }

    function getShowSeconds() {
        var value = Properties.getValue(KEY_SHOW_SECONDS);
        return value != null ? value : DEFAULT_SHOW_SECONDS;
    }

    function setShowSeconds(value) {
        Properties.setValue(KEY_SHOW_SECONDS, value);
    }

    function isMetric() {
        return getUnits() == 0;
    }

    function isDarkTheme() {
        return getTheme() == 0;
    }
}
```

---

## Service Patterns

### Network Service Pattern

```monkey-c
using Toybox.Communications;
using Toybox.System;

module Services {
    class NetworkService {
        private const BASE_URL = "https://api.example.com";
        private var _listeners = [];

        function initialize() {
        }

        function addListener(listener) {
            _listeners.add(listener);
        }

        function fetchData(callback) {
            if (!System.getDeviceSettings().phoneConnected) {
                callback.invoke({
                    :success => false,
                    :error => "Phone not connected"
                });
                return;
            }

            var url = BASE_URL + "/data";
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
                method(:onReceive).bindWith(callback)
            );
        }

        function onReceive(callback, responseCode, data) {
            if (responseCode == 200) {
                callback.invoke({
                    :success => true,
                    :data => data
                });
            } else {
                callback.invoke({
                    :success => false,
                    :error => "HTTP " + responseCode
                });
            }

            // Notify listeners
            for (var i = 0; i < _listeners.size(); i++) {
                _listeners[i].onNetworkResponse(responseCode, data);
            }
        }

        function postData(data, callback) {
            var url = BASE_URL + "/data";
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
                method(:onReceive).bindWith(callback)
            );
        }
    }

    // Singleton pattern
    var _networkService = null;

    function getNetworkService() {
        if (_networkService == null) {
            _networkService = new NetworkService();
        }
        return _networkService;
    }
}

// Usage
var service = Services.getNetworkService();
service.fetchData(new Lang.Method(self, :onDataReceived));
```

### Location Service Pattern

```monkey-c
using Toybox.Position;
using Toybox.System;

module Services {
    class LocationService {
        private var _listeners = [];
        private var _lastPosition = null;
        private var _isEnabled = false;

        function initialize() {
        }

        function addListener(listener) {
            _listeners.add(listener);
        }

        function removeListener(listener) {
            var index = _listeners.indexOf(listener);
            if (index != -1) {
                _listeners.remove(index);
            }
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

        function getLastPosition() {
            return _lastPosition;
        }

        private function onPosition(info) {
            _lastPosition = info.position;

            // Notify all listeners
            for (var i = 0; i < _listeners.size(); i++) {
                _listeners[i].onLocationChanged(info);
            }
        }
    }
}
```

---

## UI Patterns

### Loading State Pattern

```monkey-c
class DataView extends WatchUi.View {
    enum State {
        LOADING,
        SUCCESS,
        ERROR
    }

    private var _state = LOADING;
    private var _data = null;
    private var _errorMessage = "";

    function initialize() {
        View.initialize();
        fetchData();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        switch (_state) {
            case LOADING:
                drawLoading(dc);
                break;
            case SUCCESS:
                drawData(dc);
                break;
            case ERROR:
                drawError(dc);
                break;
        }
    }

    private function drawLoading(dc) {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            "Loading...",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawData(dc) {
        if (_data != null) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_MEDIUM,
                _data.toString(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    private function drawError(dc) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            _errorMessage,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function fetchData() {
        _state = LOADING;
        WatchUi.requestUpdate();

        // Simulate async operation
        var service = Services.getNetworkService();
        service.fetchData(new Lang.Method(self, :onDataReceived));
    }

    function onDataReceived(response) {
        if (response[:success]) {
            _state = SUCCESS;
            _data = response[:data];
        } else {
            _state = ERROR;
            _errorMessage = response[:error];
        }
        WatchUi.requestUpdate();
    }
}
```

### Pagination Pattern

```monkey-c
class PaginatedView extends WatchUi.View {
    private var _items = [];
    private var _currentIndex = 0;
    private var _itemsPerPage = 1;

    function initialize(items) {
        View.initialize();
        _items = items;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_items.size() == 0) {
            drawEmpty(dc);
            return;
        }

        // Draw current item
        var item = _items[_currentIndex];
        drawItem(dc, item);

        // Draw pagination
        drawPagination(dc);
    }

    function nextItem() {
        _currentIndex = (_currentIndex + 1) % _items.size();
        WatchUi.requestUpdate();
    }

    function previousItem() {
        _currentIndex = (_currentIndex - 1 + _items.size()) % _items.size();
        WatchUi.requestUpdate();
    }

    private function drawItem(dc, item) {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            item.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawPagination(dc) {
        var text = (_currentIndex + 1) + " / " + _items.size();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - 30,
            Graphics.FONT_TINY,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function drawEmpty(dc) {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            "No items",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

### Menu Pattern

```monkey-c
using Toybox.WatchUi;

class CustomMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Settings"});

        addItem(new WatchUi.MenuItem(
            "Option 1",
            "Description 1",
            :option1,
            {}
        ));

        addItem(new WatchUi.MenuItem(
            "Option 2",
            "Description 2",
            :option2,
            {}
        ));

        addItem(new WatchUi.ToggleMenuItem(
            "Enable Feature",
            "Turn on/off",
            :toggle1,
            Properties.getValue("feature1"),
            {}
        ));
    }
}

class CustomMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :option1) {
            handleOption1();
        } else if (id == :option2) {
            handleOption2();
        } else if (id == :toggle1) {
            var value = item.isEnabled();
            Properties.setValue("feature1", value);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    private function handleOption1() {
        // Handle option 1
    }

    private function handleOption2() {
        // Handle option 2
    }
}

// Usage in delegate
function onMenu() {
    var menu = new CustomMenu();
    var delegate = new CustomMenuDelegate();
    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
    return true;
}
```

---

## Data Field Patterns

### Basic Data Field Pattern

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.Lang;

class CustomDataField extends WatchUi.DataField {
    private var _value = 0.0;
    private var _label = "Custom";

    function initialize() {
        DataField.initialize();
    }

    function onLayout(dc) {
        View.setLayout(Rez.Layouts.DataFieldLayout(dc));
    }

    // Compute data field value
    function compute(info) {
        // Get activity data
        var speed = info.currentSpeed;
        var hr = info.currentHeartRate;
        var cadence = info.currentCadence;

        // Calculate custom metric
        if (speed != null && hr != null && speed > 0) {
            _value = hr / (speed * 3.6); // Example calculation
        } else {
            _value = 0.0;
        }
    }

    // Display the value
    function onUpdate(dc) {
        // Check privacy flags
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
            _label,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var valueString = _value.format("%.1f");
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

## Utility Patterns

### Format Utilities Pattern

```monkey-c
module Utils {
    module Format {
        // Distance formatting
        function formatDistance(meters, isMetric) {
            if (isMetric) {
                var km = meters / 1000.0;
                return km.format("%.2f") + " km";
            } else {
                var miles = meters / 1609.34;
                return miles.format("%.2f") + " mi";
            }
        }

        // Time formatting
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

        // Pace formatting
        function formatPace(metersPerSecond, isMetric) {
            if (metersPerSecond == null || metersPerSecond <= 0) {
                return "--:--";
            }

            var secondsPerUnit;
            if (isMetric) {
                secondsPerUnit = 1000.0 / metersPerSecond; // min/km
            } else {
                secondsPerUnit = 1609.34 / metersPerSecond; // min/mile
            }

            var minutes = secondsPerUnit / 60;
            var seconds = secondsPerUnit % 60;

            return Lang.format("$1$:$2$", [
                minutes.format("%d"),
                seconds.format("%02d")
            ]);
        }

        // Heart rate zone
        function getHeartRateZone(hr, maxHr) {
            if (hr == null || maxHr == null) {
                return 0;
            }

            var percentage = (hr.toFloat() / maxHr) * 100;

            if (percentage < 60) { return 1; }
            else if (percentage < 70) { return 2; }
            else if (percentage < 80) { return 3; }
            else if (percentage < 90) { return 4; }
            else { return 5; }
        }
    }
}
```

### Math Utilities Pattern

```monkey-c
module Utils {
    module Math {
        function clamp(value, min, max) {
            if (value < min) { return min; }
            if (value > max) { return max; }
            return value;
        }

        function lerp(a, b, t) {
            return a + (b - a) * t;
        }

        function map(value, inMin, inMax, outMin, outMax) {
            var normalized = (value - inMin) / (inMax - inMin);
            return outMin + normalized * (outMax - outMin);
        }

        function distance(x1, y1, x2, y2) {
            var dx = x2 - x1;
            var dy = y2 - y1;
            return Math.sqrt(dx * dx + dy * dy);
        }

        function average(array) {
            if (array.size() == 0) {
                return 0;
            }

            var sum = 0;
            for (var i = 0; i < array.size(); i++) {
                sum += array[i];
            }

            return sum.toFloat() / array.size();
        }

        function max(array) {
            if (array.size() == 0) {
                return null;
            }

            var maxVal = array[0];
            for (var i = 1; i < array.size(); i++) {
                if (array[i] > maxVal) {
                    maxVal = array[i];
                }
            }

            return maxVal;
        }

        function min(array) {
            if (array.size() == 0) {
                return null;
            }

            var minVal = array[0];
            for (var i = 1; i < array.size(); i++) {
                if (array[i] < minVal) {
                    minVal = array[i];
                }
            }

            return minVal;
        }
    }
}
```

---

## Error Handling Patterns

### Null-Safe Pattern

```monkey-c
// Always check for null
function processActivityInfo() {
    var info = Activity.getActivityInfo();
    if (info == null) {
        return;
    }

    var location = info.currentLocation;
    if (location != null) {
        var position = location.toRadians();
        var lat = position[0];
        var lon = position[1];
        // Use lat, lon
    }

    var hr = info.currentHeartRate;
    if (hr != null) {
        // Use HR data
    }
}
```

### Try-Catch Pattern

```monkey-c
function safeNetworkRequest() {
    try {
        var url = "https://api.example.com/data";
        Communications.makeWebRequest(
            url,
            {},
            {},
            method(:onReceive)
        );
    } catch (e) {
        System.println("Network error: " + e.getErrorMessage());
        handleNetworkError(e);
    }
}

function handleNetworkError(exception) {
    // Log error
    // Show user message
    // Retry logic
}
```

---

## Performance Patterns

### Caching Pattern

```monkey-c
class CachedRenderer {
    private var _cache = {};
    private var _cacheValid = false;

    function render(dc, data) {
        if (!_cacheValid) {
            updateCache(data);
            _cacheValid = true;
        }

        // Use cached data
        drawCachedElements(dc);
    }

    function invalidateCache() {
        _cacheValid = false;
    }

    private function updateCache(data) {
        _cache[:processedData] = processData(data);
        _cache[:formattedStrings] = formatStrings(data);
    }

    private function drawCachedElements(dc) {
        // Draw using cached data
    }
}
```

### Lazy Initialization Pattern

```monkey-c
class LazyLoader {
    private var _expensiveResource = null;

    function getResource() {
        if (_expensiveResource == null) {
            _expensiveResource = createExpensiveResource();
        }
        return _expensiveResource;
    }

    private function createExpensiveResource() {
        // Only created when first needed
        return new ExpensiveResource();
    }
}
```

---

## Resources

- **Sample Apps**: https://github.com/garmin/connectiq-apps
- **Best Practices**: https://developer.garmin.com/connect-iq/core-topics/
- **API Docs**: https://developer.garmin.com/connect-iq/api-docs/
