# Connect IQ Project Structure Guide

## Overview

A well-organized Connect IQ project follows consistent patterns that make it maintainable, testable, and easy to build. This guide covers directory layouts, file naming conventions, and resource organization.

## Standard Project Structure

### Basic Project Layout

```
MyConnectIQApp/
├── manifest.xml                 # App configuration
├── monkey.jungle               # Build configuration (optional)
├── source/                     # Source code
│   ├── MyApp.mc               # Application entry point
│   ├── MyView.mc              # Main view
│   ├── MyDelegate.mc          # Input handler
│   └── utils/                 # Utility modules
│       └── Helper.mc
├── resources/                  # App resources
│   ├── resources.xml          # Main resource file
│   ├── strings/               # Localized strings
│   │   ├── strings.xml        # Default (English)
│   │   ├── strings-spa.xml    # Spanish
│   │   └── strings-fre.xml    # French
│   ├── layouts/               # UI layouts
│   │   └── layout.xml
│   ├── drawables/             # Vector graphics
│   │   └── drawables.xml
│   ├── bitmaps/               # Raster images
│   │   ├── launcher_icon.png
│   │   └── background.png
│   ├── fonts/                 # Custom fonts
│   │   └── myfont.ttf
│   ├── menus/                 # Menu definitions
│   │   └── menu.xml
│   ├── settings/              # App settings
│   │   └── settings.xml
│   └── properties/            # Default properties
│       └── properties.xml
├── test/                       # Unit tests
│   └── MyAppTest.mc
├── bin/                        # Build artifacts (auto-generated)
│   ├── MyApp.prg              # Simulator executable
│   └── MyApp.iq               # Store package
└── README.md                   # Project documentation
```

### Minimal Project (Watch Face)

```
SimpleWatchFace/
├── manifest.xml
├── source/
│   ├── SimpleWatchFaceApp.mc
│   └── SimpleWatchFaceView.mc
└── resources/
    ├── resources.xml
    ├── strings/
    │   └── strings.xml
    └── drawables/
        └── launcher_icon.png
```

### Complex Project (Device App)

```
AdvancedDeviceApp/
├── manifest.xml
├── monkey.jungle
├── source/
│   ├── AdvancedApp.mc
│   ├── views/
│   │   ├── MainView.mc
│   │   ├── SettingsView.mc
│   │   ├── WorkoutView.mc
│   │   └── SummaryView.mc
│   ├── delegates/
│   │   ├── MainDelegate.mc
│   │   ├── WorkoutDelegate.mc
│   │   └── MenuDelegate.mc
│   ├── models/
│   │   ├── Workout.mc
│   │   ├── UserProfile.mc
│   │   └── Settings.mc
│   ├── services/
│   │   ├── NetworkService.mc
│   │   ├── StorageService.mc
│   │   └── SensorService.mc
│   ├── utils/
│   │   ├── MathUtils.mc
│   │   ├── FormatUtils.mc
│   │   └── Constants.mc
│   └── background/
│       └── BackgroundService.mc
├── resources/
│   ├── resources.xml
│   ├── strings/
│   │   ├── strings.xml
│   │   ├── strings-spa.xml
│   │   ├── strings-fre.xml
│   │   └── strings-ger.xml
│   ├── layouts/
│   │   ├── MainLayout.xml
│   │   ├── WorkoutLayout.xml
│   │   └── SummaryLayout.xml
│   ├── drawables/
│   │   └── drawables.xml
│   ├── bitmaps/
│   │   ├── launcher_icon.png
│   │   ├── icon_start.png
│   │   ├── icon_stop.png
│   │   └── background.png
│   ├── menus/
│   │   ├── main_menu.xml
│   │   └── workout_menu.xml
│   ├── settings/
│   │   └── settings.xml
│   └── properties/
│       └── properties.xml
├── test/
│   ├── WorkoutTest.mc
│   ├── NetworkServiceTest.mc
│   └── MathUtilsTest.mc
└── bin/
    └── (generated files)
```

---

## File Naming Conventions

### Source Files (.mc)

**Application Entry:**
```
{AppName}App.mc         # Main application class
```
Examples: `MyWatchFaceApp.mc`, `FitnessTrackerApp.mc`

**Views:**
```
{Purpose}View.mc        # View classes
```
Examples: `MainView.mc`, `WorkoutView.mc`, `SettingsView.mc`

**Delegates (Input Handlers):**
```
{Purpose}Delegate.mc    # Behavior delegates
```
Examples: `MainDelegate.mc`, `WorkoutDelegate.mc`, `MenuDelegate.mc`

**Models:**
```
{Entity}.mc            # Data models
```
Examples: `Workout.mc`, `User.mc`, `Settings.mc`

**Services:**
```
{Purpose}Service.mc    # Service classes
```
Examples: `NetworkService.mc`, `StorageService.mc`, `LocationService.mc`

**Utilities:**
```
{Purpose}Utils.mc      # Utility classes
```
Examples: `MathUtils.mc`, `StringUtils.mc`, `DateUtils.mc`

### Resource Files

**Main Resources:**
```
resources.xml          # Main resource definitions
```

**Strings:**
```
strings.xml           # Default language
strings-{lang}.xml    # Localized versions
```
Examples: `strings-spa.xml`, `strings-fre.xml`

**Layouts:**
```
{screen}Layout.xml    # Screen layouts
```
Examples: `MainLayout.xml`, `WorkoutLayout.xml`

**Drawables:**
```
drawables.xml         # Vector drawable definitions
```

**Images:**
```
{name}_{size}.png     # Raster images
```
Examples: `launcher_icon.png`, `background_240x240.png`

---

## Directory Organization

### source/ Directory

Organize by functional area for larger projects:

```
source/
├── MyApp.mc                    # Entry point
├── views/                      # UI views
│   ├── MainView.mc
│   └── DetailView.mc
├── delegates/                  # Input handlers
│   ├── MainDelegate.mc
│   └── DetailDelegate.mc
├── models/                     # Data models
│   ├── DataModel.mc
│   └── Settings.mc
├── services/                   # Business logic
│   ├── DataService.mc
│   └── SyncService.mc
├── utils/                      # Utilities
│   ├── Constants.mc
│   └── Helpers.mc
└── background/                 # Background tasks
    └── BackgroundService.mc
```

### Flat Structure (Simple Apps)

For simple apps, keep it flat:

```
source/
├── SimpleApp.mc
├── SimpleView.mc
└── SimpleDelegate.mc
```

### resources/ Directory

```
resources/
├── resources.xml               # Main resource file
├── strings/                    # Localization
│   └── *.xml
├── layouts/                    # UI layouts
│   └── *.xml
├── drawables/                  # Vector graphics
│   └── drawables.xml
├── bitmaps/                    # Raster images
│   └── *.png
├── fonts/                      # Custom fonts
│   └── *.ttf
├── menus/                      # Menu definitions
│   └── *.xml
├── settings/                   # App settings UI
│   └── settings.xml
├── properties/                 # Default property values
│   └── properties.xml
└── jsons/                      # JSON data files
    └── data.json
```

---

## Code Organization Patterns

### Application Entry Point

**MyApp.mc:**
```monkey-c
using Toybox.Application;
using Toybox.WatchUi;

class MyApp extends Application.AppBase {
    private var _controller;

    function initialize() {
        AppBase.initialize();
        _controller = new AppController();
    }

    function onStart(state) {
        _controller.onStart(state);
    }

    function onStop(state) {
        _controller.onStop(state);
    }

    function getInitialView() {
        return [ new MainView(), new MainDelegate() ];
    }

    // For glance support
    function getGlanceView() {
        return [ new MyGlanceView() ];
    }

    // For settings
    function getSettingsView() {
        return [ new MySettingsMenu(), new MySettingsDelegate() ];
    }
}
```

### View Organization

**MainView.mc:**
```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;

class MainView extends WatchUi.View {
    private var _model;
    private var _renderer;

    function initialize() {
        View.initialize();
        _model = new DataModel();
        _renderer = new ViewRenderer();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() {
        _model.load();
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        _renderer.render(dc, _model);
    }

    function onHide() {
        _model.save();
    }
}
```

### Delegate Pattern

**MainDelegate.mc:**
```monkey-c
using Toybox.WatchUi;
using Toybox.System;

class MainDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        System.println("Select pressed");
        _view.handleSelect();
        return true;
    }

    function onBack() {
        System.println("Back pressed");
        return false; // Return false to exit
    }

    function onNextPage() {
        _view.nextPage();
        return true;
    }

    function onPreviousPage() {
        _view.previousPage();
        return true;
    }
}
```

### Model Organization

**models/Workout.mc:**
```monkey-c
using Toybox.Time;

module Models {
    class Workout {
        var duration;
        var distance;
        var calories;
        var startTime;

        function initialize() {
            duration = 0;
            distance = 0.0;
            calories = 0;
            startTime = null;
        }

        function start() {
            startTime = Time.now();
        }

        function stop() {
            // Calculate final metrics
        }

        function toDict() {
            return {
                "duration" => duration,
                "distance" => distance,
                "calories" => calories,
                "startTime" => startTime.value()
            };
        }

        static function fromDict(dict) {
            var workout = new Workout();
            workout.duration = dict["duration"];
            workout.distance = dict["distance"];
            workout.calories = dict["calories"];
            workout.startTime = new Time.Moment(dict["startTime"]);
            return workout;
        }
    }
}
```

### Service Pattern

**services/NetworkService.mc:**
```monkey-c
using Toybox.Communications;
using Toybox.System;

module Services {
    class NetworkService {
        private const BASE_URL = "https://api.example.com";

        function initialize() {
        }

        function fetchData(callback) {
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
                callback
            );
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
                callback
            );
        }
    }
}
```

### Utility Organization

**utils/Constants.mc:**
```monkey-c
module Utils {
    module Constants {
        const APP_NAME = "My App";
        const VERSION = "1.0.0";
        const API_KEY = "your-api-key";

        // Colors
        const COLOR_PRIMARY = 0x0000FF;
        const COLOR_SECONDARY = 0x00FF00;
        const COLOR_BACKGROUND = 0x000000;

        // Sizes
        const FONT_SMALL = Graphics.FONT_TINY;
        const FONT_MEDIUM = Graphics.FONT_SMALL;
        const FONT_LARGE = Graphics.FONT_MEDIUM;

        // Settings Keys
        const SETTING_THEME = "theme";
        const SETTING_UNITS = "units";
    }
}
```

**utils/MathUtils.mc:**
```monkey-c
module Utils {
    module MathUtils {
        function clamp(value, min, max) {
            if (value < min) {
                return min;
            } else if (value > max) {
                return max;
            }
            return value;
        }

        function lerp(a, b, t) {
            return a + (b - a) * t;
        }

        function distance(x1, y1, x2, y2) {
            var dx = x2 - x1;
            var dy = y2 - y1;
            return Math.sqrt(dx * dx + dy * dy);
        }
    }
}
```

---

## Resource Organization

### Main Resource File

**resources/resources.xml:**
```xml
<resources>
    <!-- Strings -->
    <strings filename="strings/strings.xml"/>

    <!-- Layouts -->
    <layouts>
        <layout id="MainLayout">layouts/MainLayout.xml</layout>
        <layout id="WorkoutLayout">layouts/WorkoutLayout.xml</layout>
    </layouts>

    <!-- Drawables -->
    <drawables filename="drawables/drawables.xml"/>

    <!-- Bitmaps -->
    <bitmap id="LauncherIcon">bitmaps/launcher_icon.png</bitmap>
    <bitmap id="Background">bitmaps/background.png</bitmap>

    <!-- Fonts -->
    <font id="CustomFont" filename="fonts/custom.ttf"
          antialias="true" filter="0123456789:"/>

    <!-- Menus -->
    <menu id="MainMenu">menus/main_menu.xml</menu>

    <!-- Settings -->
    <settings filename="settings/settings.xml"/>

    <!-- Properties -->
    <properties filename="properties/properties.xml"/>

    <!-- JSON Data -->
    <jsonData id="ConfigData">jsons/config.json</jsonData>
</resources>
```

### String Resources

**resources/strings/strings.xml:**
```xml
<strings>
    <string id="AppName">My App</string>
    <string id="Start">Start</string>
    <string id="Stop">Stop</string>
    <string id="Resume">Resume</string>
    <string id="Save">Save</string>
    <string id="Discard">Discard</string>
</strings>
```

### Layout Resources

**resources/layouts/MainLayout.xml:**
```xml
<layout id="MainLayout">
    <label id="TitleLabel"
           x="center"
           y="25%"
           font="Graphics.FONT_MEDIUM"
           justification="Graphics.TEXT_JUSTIFY_CENTER"
           color="Graphics.COLOR_WHITE"/>

    <label id="ValueLabel"
           x="center"
           y="50%"
           font="Graphics.FONT_NUMBER_HOT"
           justification="Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER"
           color="Graphics.COLOR_BLUE"/>

    <label id="StatusLabel"
           x="center"
           y="75%"
           font="Graphics.FONT_SMALL"
           justification="Graphics.TEXT_JUSTIFY_CENTER"
           color="Graphics.COLOR_LT_GRAY"/>
</layout>
```

### Drawable Resources

**resources/drawables/drawables.xml:**
```xml
<drawables>
    <bitmap id="LauncherIcon" filename="launcher_icon.png"/>

    <!-- Vector shapes -->
    <shape type="circle" id="CircleShape">
        <point x="120" y="120"/>
        <point x="40" y="0"/>
        <color>Graphics.COLOR_BLUE</color>
    </shape>

    <shape type="rectangle" id="RectShape">
        <point x="0" y="0"/>
        <point x="100" y="50"/>
        <color>Graphics.COLOR_RED</color>
    </shape>
</drawables>
```

### Settings Resources

**resources/settings/settings.xml:**
```xml
<settings>
    <setting propertyKey="@Properties.Theme" title="@Strings.ThemeTitle">
        <settingConfig type="list">
            <listEntry value="0">@Strings.ThemeDark</listEntry>
            <listEntry value="1">@Strings.ThemeLight</listEntry>
        </settingConfig>
    </setting>

    <setting propertyKey="@Properties.Units" title="@Strings.UnitsTitle">
        <settingConfig type="list">
            <listEntry value="0">@Strings.UnitsMetric</listEntry>
            <listEntry value="1">@Strings.UnitsImperial</listEntry>
        </settingConfig>
    </setting>

    <setting propertyKey="@Properties.ShowHeartRate" title="@Strings.ShowHRTitle">
        <settingConfig type="boolean"/>
    </setting>
</settings>
```

### Properties Resources

**resources/properties/properties.xml:**
```xml
<properties>
    <property id="Theme" type="number">0</property>
    <property id="Units" type="number">0</property>
    <property id="ShowHeartRate" type="boolean">true</property>
    <property id="ApiKey" type="string"></property>
</properties>
```

---

## Build Configuration

### monkey.jungle File

Advanced build configuration for different devices and build types:

```jungle
# Project configuration
project.manifest = manifest.xml

# Base resource path
base.resourcePath = resources

# Device-specific configurations
fenix6.resourcePath = $(fenix6.resourcePath);resources-high
vivoactive4s.resourcePath = $(vivoactive4s.resourcePath);resources-low

# Exclude files for specific devices
vivoactive4s.excludeAnnotations = high_memory_only

# Language support
base.lang = eng;spa;fre

# Annotations
base.annotations =
```

---

## Build Artifacts

### bin/ Directory (Auto-generated)

```
bin/
├── MyApp.prg              # Simulator executable
├── MyApp.iq               # Store package (all devices)
├── MyApp-fenix6.prg       # Device-specific builds
├── MyApp-venu2.prg
└── compiler.json          # Build metadata
```

---

## Testing Structure

### test/ Directory

```
test/
├── WorkoutTest.mc
├── MathUtilsTest.mc
└── NetworkServiceTest.mc
```

**Example Test File:**
```monkey-c
using Toybox.Test;

(:test)
function testWorkoutInitialization(logger) {
    var workout = new Workout();
    Test.assertEqual(workout.duration, 0);
    Test.assertEqual(workout.distance, 0.0);
    return true;
}

(:test)
function testWorkoutCalculations(logger) {
    var workout = new Workout();
    workout.duration = 3600; // 1 hour
    workout.distance = 10000; // 10 km

    var pace = workout.calculatePace();
    Test.assertEqual(pace, 360); // 6 min/km
    return true;
}
```

---

## Best Practices

### Project Organization
✅ Group related files in subdirectories
✅ Use consistent naming conventions
✅ Keep views separate from business logic
✅ Use modules for namespacing

❌ Don't put everything in one file
❌ Don't mix concerns (UI + network + storage)
❌ Don't use inconsistent naming

### Resource Management
✅ Organize resources by type
✅ Use resource references (@Strings, @Drawables)
✅ Optimize image sizes for target devices
✅ Provide localized strings

❌ Don't hardcode strings in code
❌ Don't use oversized images
❌ Don't skip localization planning

### Code Structure
✅ Single responsibility per class
✅ Use dependency injection
✅ Write testable code
✅ Document complex logic

❌ Don't create god classes
❌ Don't use global state
❌ Don't skip error handling

---

## Common Patterns

### Singleton Services

```monkey-c
module Services {
    var _networkService = null;

    function getNetworkService() {
        if (_networkService == null) {
            _networkService = new NetworkService();
        }
        return _networkService;
    }
}
```

### Factory Pattern

```monkey-c
class ViewFactory {
    static function createView(type) {
        if (type == :main) {
            return new MainView();
        } else if (type == :workout) {
            return new WorkoutView();
        }
        return null;
    }
}
```

### Observer Pattern

```monkey-c
class DataModel {
    private var _observers = [];

    function addObserver(observer) {
        _observers.add(observer);
    }

    function notifyObservers() {
        for (var i = 0; i < _observers.size(); i++) {
            _observers[i].onDataChanged(self);
        }
    }
}
```

---

## Migration Tips

### From Flat to Organized Structure

1. **Create directory structure**
2. **Move files to appropriate directories**
3. **Update imports if needed**
4. **Test build**

### Refactoring Large Files

1. **Identify logical components**
2. **Extract to separate files**
3. **Use modules for namespacing**
4. **Update references**

---

## Resources

- **Sample Projects**: https://github.com/garmin/connectiq-apps
- **Build Documentation**: https://developer.garmin.com/connect-iq/core-topics/
- **Resource Guide**: https://developer.garmin.com/connect-iq/core-topics/resources/
