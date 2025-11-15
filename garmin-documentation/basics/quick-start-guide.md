# Connect IQ Quick Start Guide

## Overview

This guide will help you create your first Connect IQ application, understand the basic project structure, and get your app running on a simulator or device.

## Prerequisites

- **Connect IQ SDK** installed
- **Visual Studio Code** with Connect IQ extension OR **Eclipse** with Connect IQ plugin
- **Simulator** (included with SDK)
- **Garmin Express** (for device deployment)

## Project Structure Overview

Every Connect IQ project follows this basic structure:

```
MyApp/
├── manifest.xml           # App configuration and metadata
├── resources/             # App resources (strings, layouts, images)
│   ├── strings/
│   │   └── strings.xml   # Localized strings
│   ├── layouts/
│   │   └── layout.xml    # UI layouts (optional)
│   ├── drawables/
│   │   └── drawables.xml # Drawable definitions
│   └── resources.xml     # Main resource file
├── source/                # Source code
│   ├── MyAppApp.mc       # Application entry point
│   └── MyAppView.mc      # Main view
└── bin/                   # Build artifacts (auto-generated)
```

## Required Files

### 1. manifest.xml

The manifest defines your app's metadata, target devices, permissions, and SDK version:

```xml
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        entry="MyApp"
        id="unique-app-id-here"
        launcherIcon="@Drawables.LauncherIcon"
        minSdkVersion="3.1.0"
        name="@Strings.AppName"
        type="watchface"
        version="1.0.0">

        <iq:products>
            <iq:product id="fenix6"/>
            <iq:product id="vivoactive4"/>
        </iq:products>

        <iq:permissions>
            <iq:uses-permission id="Positioning"/>
            <iq:uses-permission id="Communications"/>
        </iq:permissions>

        <iq:languages>
            <iq:language>eng</iq:language>
        </iq:languages>
    </iq:application>
</iq:manifest>
```

### 2. Application Class (MyAppApp.mc)

The main application class extends `AppBase` and manages the app lifecycle:

```monkey-c
using Toybox.Application;
using Toybox.WatchUi;

class MyApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Called when app starts
    function onStart(state) {
        // Initialize resources, restore state
    }

    // Called when app stops
    function onStop(state) {
        // Save state, cleanup resources
    }

    // Return the initial view
    function getInitialView() {
        return [ new MyAppView() ];
    }
}
```

### 3. View Class (MyAppView.mc)

The view class handles UI rendering and updates:

```monkey-c
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class MyAppView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Called when view is shown
    function onShow() {
    }

    // Called when view is hidden
    function onHide() {
    }

    // Update the view
    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw something
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            "Hello Connect IQ!",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // Called when device enters low-power mode
    function onEnterSleep() {
    }

    // Called when device exits low-power mode
    function onExitSleep() {
    }
}
```

### 4. Resources (resources/resources.xml)

Define strings, images, and other resources:

```xml
<resources>
    <strings>
        <string id="AppName">My App</string>
    </strings>

    <drawables>
        <bitmap id="LauncherIcon" filename="launcher_icon.png" />
    </drawables>
</resources>
```

## Basic App Anatomy

### Application Lifecycle

1. **initialize()** - Constructor, called once when app is loaded
2. **onStart(state)** - Called when app starts/resumes
3. **getInitialView()** - Returns the initial view hierarchy
4. **onStop(state)** - Called when app stops/pauses

### View Lifecycle

1. **initialize()** - Constructor
2. **onShow()** - View is about to be displayed
3. **onUpdate(dc)** - Render the view
4. **onHide()** - View is about to be hidden

### Watch Face Specific

- **onEnterSleep()** - Device enters low-power mode
- **onExitSleep()** - Device exits low-power mode

## Build and Deployment Workflow

### Using Visual Studio Code

1. **Open project** in VS Code
2. **Configure devices**: Press `Ctrl+Shift+P`, type "Connect IQ: Edit Products"
3. **Build**: Press `Ctrl+Shift+B` or use "Monkey C: Build for Device"
4. **Run in simulator**: Press `Ctrl+Shift+R` or click "Run" in status bar
5. **Deploy to device**: Connect device via USB, select "Export Package"

### Using Command Line

```bash
# Build the project
monkeyc -o bin/MyApp.prg -m manifest.xml -w -y ~/connectiq_key.der -d fenix6 $(find source -name '*.mc') -r resources/resources.xml

# Run in simulator
monkeydo bin/MyApp.prg fenix6

# Create IQ package for store
monkeyc -o bin/MyApp.iq -e -m manifest.xml -w -y ~/connectiq_key.der $(find source -name '*.mc') -r resources/resources.xml
```

### Build Artifacts

- **.prg** - Executable for simulator and testing
- **.iq** - Package for Connect IQ store
- **compiler.json** - Build configuration

## Creating Different App Types

### Watch Face

```monkey-c
class MyWatchFace extends WatchUi.WatchFace {
    function onUpdate(dc) {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour,
            clockTime.min.format("%02d")
        ]);

        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_LARGE,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

### Widget

```monkey-c
class MyWidget extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            "Widget Content",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

// App class returns widget delegate
function getInitialView() {
    return [ new MyWidget(), new MyWidgetDelegate() ];
}
```

### Data Field

```monkey-c
using Toybox.Activity;

class MyDataField extends WatchUi.DataField {

    function initialize() {
        DataField.initialize();
    }

    function compute(info) {
        // Calculate data field value
        var speed = info.currentSpeed;
        if (speed != null) {
            return speed;
        }
        return 0.0;
    }

    function onUpdate(dc) {
        var value = getObscurityFlags() & OBSCURE_TOP;
        if (value != 0) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.clear();
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_LARGE,
            "12.5",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

## Common Setup Tasks

### Add Device Support

Edit `manifest.xml` to add product IDs:

```xml
<iq:products>
    <iq:product id="fenix6"/>
    <iq:product id="fenix6pro"/>
    <iq:product id="vivoactive4"/>
    <iq:product id="venu"/>
</iq:products>
```

### Add Permissions

```xml
<iq:permissions>
    <iq:uses-permission id="Positioning"/>      <!-- GPS -->
    <iq:uses-permission id="Communications"/>   <!-- Network -->
    <iq:uses-permission id="SensorHistory"/>    <!-- Sensor data -->
    <iq:uses-permission id="UserProfile"/>      <!-- User info -->
</iq:permissions>
```

### Add App Settings

Create `resources/settings/settings.xml`:

```xml
<settings>
    <setting propertyKey="@Properties.BackgroundColor" title="@Strings.BackgroundColorTitle">
        <settingConfig type="list">
            <listEntry value="0">@Strings.ColorBlack</listEntry>
            <listEntry value="1">@Strings.ColorWhite</listEntry>
        </settingConfig>
    </setting>
</settings>
```

Access in code:

```monkey-c
using Toybox.Application.Properties;

var bgColor = Properties.getValue("BackgroundColor");
```

## Debugging Tips

### Print Statements

```monkey-c
System.println("Debug: value = " + value);
```

### Exception Handling

```monkey-c
try {
    // Your code
    var result = riskyOperation();
} catch (e) {
    System.println("Error: " + e.getErrorMessage());
}
```

### Check for Null

```monkey-c
var position = Activity.getActivityInfo().currentLocation;
if (position != null) {
    var lat = position.toRadians()[0];
}
```

## Next Steps

1. **Explore sample apps** at https://github.com/garmin/connectiq-apps
2. **Read API documentation** at https://developer.garmin.com/connect-iq/api-docs/
3. **Join the forum** at https://forums.garmin.com/developer/
4. **Test on real devices** - Simulator doesn't catch all issues
5. **Study existing apps** - Learn from published apps on Connect IQ store

## Common Pitfalls

❌ **Don't** use large resources that exceed memory limits
✅ **Do** optimize images and limit resource usage

❌ **Don't** perform heavy operations in onUpdate()
✅ **Do** cache computed values and update only when needed

❌ **Don't** assume all devices have all features
✅ **Do** check feature availability at runtime

❌ **Don't** forget to test on multiple devices
✅ **Do** test on both high-end and low-memory devices

## Additional Resources

- **Official Documentation**: https://developer.garmin.com/connect-iq/
- **API Reference**: https://developer.garmin.com/connect-iq/api-docs/
- **Sample Apps**: https://github.com/garmin/connectiq-apps
- **Developer Forum**: https://forums.garmin.com/developer/
