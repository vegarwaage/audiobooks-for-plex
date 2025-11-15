# Connect IQ Manifest Structure Guide

## Overview

The `manifest.xml` file is the core configuration file for every Connect IQ application. It defines the app's metadata, target devices, permissions, dependencies, and build settings.

## Basic Structure

```xml
<?xml version="1.0" encoding="utf-8"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application>
        <!-- Application configuration -->
        <iq:products>
            <!-- Device targets -->
        </iq:products>
        <iq:permissions>
            <!-- Required permissions -->
        </iq:permissions>
        <iq:languages>
            <!-- Supported languages -->
        </iq:languages>
        <iq:barrels>
            <!-- Library dependencies -->
        </iq:barrels>
    </iq:application>
</iq:manifest>
```

## Root Element

### \<iq:manifest\>

The root element that wraps all configuration.

**Attributes:**
- `xmlns:iq` - XML namespace (always `http://www.garmin.com/xml/connectiq`)
- `version` - Manifest schema version (typically `3`)

```xml
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
```

---

## Application Element

### \<iq:application\>

Defines the application's core metadata and entry point.

**Required Attributes:**

| Attribute | Description | Example |
|-----------|-------------|---------|
| `entry` | Main class name (must match your AppBase class) | `"MyApp"` |
| `id` | Unique application identifier (UUID format) | `"abc123..."` |
| `type` | Application type | `"watchface"`, `"widget"`, `"datafield"`, `"app"`, `"audio"` |
| `name` | Display name (can be string resource) | `"@Strings.AppName"` or `"My App"` |
| `version` | App version (semantic versioning) | `"1.0.0"` |

**Optional Attributes:**

| Attribute | Description | Example |
|-----------|-------------|---------|
| `launcherIcon` | App icon reference | `"@Drawables.LauncherIcon"` |
| `minSdkVersion` | Minimum SDK version required | `"3.1.0"`, `"4.0.0"` |
| `minApiLevel` | Minimum API level | `"3.1.0"` |

### Complete Example

```xml
<iq:application
    entry="MyWatchFaceApp"
    id="a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"
    launcherIcon="@Drawables.LauncherIcon"
    minSdkVersion="3.1.0"
    name="@Strings.AppName"
    type="watchface"
    version="1.2.3">
```

### Application Types

```xml
<!-- Watch Face -->
<iq:application type="watchface" entry="MyWatchFaceApp">

<!-- Widget -->
<iq:application type="widget" entry="MyWidgetApp">

<!-- Data Field -->
<iq:application type="datafield" entry="MyDataFieldApp">

<!-- Device App -->
<iq:application type="app" entry="MyDeviceApp">

<!-- Audio Provider -->
<iq:application type="audio" entry="MyAudioProviderApp">
```

---

## Products Section

### \<iq:products\>

Defines which Garmin devices your app supports.

```xml
<iq:products>
    <iq:product id="fenix6"/>
    <iq:product id="fenix6pro"/>
    <iq:product id="fenix6s"/>
    <iq:product id="vivoactive4"/>
    <iq:product id="venu"/>
</iq:products>
```

### Common Device IDs

**Fenix Series:**
```xml
<iq:product id="fenix5"/>
<iq:product id="fenix5plus"/>
<iq:product id="fenix5s"/>
<iq:product id="fenix5splus"/>
<iq:product id="fenix5x"/>
<iq:product id="fenix5xplus"/>
<iq:product id="fenix6"/>
<iq:product id="fenix6pro"/>
<iq:product id="fenix6s"/>
<iq:product id="fenix6spro"/>
<iq:product id="fenix6xpro"/>
<iq:product id="fenix7"/>
<iq:product id="fenix7s"/>
<iq:product id="fenix7x"/>
```

**Forerunner Series:**
```xml
<iq:product id="fr245"/>
<iq:product id="fr245m"/>
<iq:product id="fr645"/>
<iq:product id="fr645m"/>
<iq:product id="fr745"/>
<iq:product id="fr945"/>
<iq:product id="fr945lte"/>
<iq:product id="fr955"/>
```

**Venu Series:**
```xml
<iq:product id="venu"/>
<iq:product id="venu2"/>
<iq:product id="venu2plus"/>
<iq:product id="venu2s"/>
<iq:product id="venusq"/>
<iq:product id="venusq2"/>
```

**Vivoactive Series:**
```xml
<iq:product id="vivoactive3"/>
<iq:product id="vivoactive3m"/>
<iq:product id="vivoactive3mlte"/>
<iq:product id="vivoactive4"/>
<iq:product id="vivoactive4s"/>
```

**Approach (Golf) Series:**
```xml
<iq:product id="approachs60"/>
<iq:product id="approachs62"/>
```

**Edge (Cycling) Series:**
```xml
<iq:product id="edge1030"/>
<iq:product id="edge1030plus"/>
<iq:product id="edge1040"/>
<iq:product id="edge530"/>
<iq:product id="edge830"/>
```

**Marq Series:**
```xml
<iq:product id="marqadventurer"/>
<iq:product id="marqathlete"/>
<iq:product id="marqaviator"/>
<iq:product id="marqcaptain"/>
<iq:product id="marqcommander"/>
<iq:product id="marqdriver"/>
<iq:product id="marqexpedition"/>
```

### Device Selection Strategy

**Target Broad Device Range:**
```xml
<iq:products>
    <!-- High-end devices with more memory -->
    <iq:product id="fenix6xpro"/>
    <iq:product id="fenix7x"/>
    <iq:product id="fr955"/>

    <!-- Mid-range devices -->
    <iq:product id="fenix6"/>
    <iq:product id="fr745"/>
    <iq:product id="venu2"/>

    <!-- Lower-memory devices (test carefully!) -->
    <iq:product id="vivoactive4s"/>
    <iq:product id="venusq"/>
</iq:products>
```

**Target Specific Device Class:**
```xml
<!-- Running watches only -->
<iq:products>
    <iq:product id="fr245"/>
    <iq:product id="fr745"/>
    <iq:product id="fr945"/>
    <iq:product id="fr955"/>
</iq:products>
```

---

## Permissions Section

### \<iq:permissions\>

Declares what device capabilities your app requires.

```xml
<iq:permissions>
    <iq:uses-permission id="Positioning"/>
    <iq:uses-permission id="Communications"/>
    <iq:uses-permission id="SensorHistory"/>
</iq:permissions>
```

### Available Permissions

| Permission | Description | Use Case |
|------------|-------------|----------|
| `Positioning` | GPS and location services | Navigation, tracking, geo-tagging |
| `Communications` | Network access (HTTP/HTTPS) | Web requests, API calls, downloads |
| `SensorHistory` | Access historical sensor data | Analyzing past workouts, trends |
| `UserProfile` | User profile information | Personalized metrics, zones |
| `FitContributor` | Write to FIT files | Custom data fields in recordings |
| `PersistedContent` | Store media offline | Music/podcast downloads |
| `Ant` | ANT connectivity | Sensor pairing (HR, power, etc.) |
| `Ble` | Bluetooth Low Energy | BLE sensor connectivity |
| `BluetoothMeshNetwork` | Bluetooth Mesh | Mesh networking |

### Permission Examples

**GPS Tracking App:**
```xml
<iq:permissions>
    <iq:uses-permission id="Positioning"/>
    <iq:uses-permission id="FitContributor"/>
</iq:permissions>
```

**Weather Widget:**
```xml
<iq:permissions>
    <iq:uses-permission id="Positioning"/>
    <iq:uses-permission id="Communications"/>
</iq:permissions>
```

**Heart Rate Data Field:**
```xml
<iq:permissions>
    <iq:uses-permission id="SensorHistory"/>
    <iq:uses-permission id="UserProfile"/>
</iq:permissions>
```

**No Permissions Needed:**
```xml
<iq:permissions/>
```

### Permission Best Practices

✅ **Request only what you need** - Each permission uses resources
✅ **Test without permissions** - Some APIs return null when permission denied
✅ **Handle permission denial gracefully**

❌ Don't request all permissions "just in case"
❌ Don't assume permissions are granted

---

## Languages Section

### \<iq:languages\>

Declares which languages your app supports.

```xml
<iq:languages>
    <iq:language>eng</iq:language>
    <iq:language>spa</iq:language>
    <iq:language>fre</iq:language>
    <iq:language>ger</iq:language>
</iq:languages>
```

### Common Language Codes

| Code | Language |
|------|----------|
| `eng` | English |
| `spa` | Spanish |
| `fre` | French |
| `ger` | German |
| `ita` | Italian |
| `por` | Portuguese |
| `dut` | Dutch |
| `dan` | Danish |
| `fin` | Finnish |
| `nor` | Norwegian |
| `swe` | Swedish |
| `pol` | Polish |
| `ces` | Czech |
| `rus` | Russian |
| `jpn` | Japanese |
| `kor` | Korean |
| `zhs` | Chinese (Simplified) |
| `zht` | Chinese (Traditional) |

### Language Resource Structure

```
resources/
├── strings/
│   ├── strings.xml           # Default (English)
│   ├── strings-spa.xml       # Spanish
│   ├── strings-fre.xml       # French
│   └── strings-ger.xml       # German
```

**strings.xml (Default):**
```xml
<strings>
    <string id="AppName">My App</string>
    <string id="StartButton">Start</string>
</strings>
```

**strings-spa.xml (Spanish):**
```xml
<strings>
    <string id="AppName">Mi Aplicación</string>
    <string id="StartButton">Iniciar</string>
</strings>
```

### Empty Languages (No Localization)

```xml
<iq:languages/>
```

---

## Barrels Section

### \<iq:barrels\>

Declares dependencies on Monkey Barrel libraries (reusable Connect IQ libraries).

```xml
<iq:barrels>
    <iq:depends name="BarrelName" version="1.0.0"/>
    <iq:depends name="AnotherBarrel" version="2.1.0"/>
</iq:barrels>
```

### Using Barrels

**Example: Generic ANT+ Heart Rate Barrel**
```xml
<iq:barrels>
    <iq:depends name="GenericHeartRate" version="1.0.0"/>
</iq:barrels>
```

**Example: Multiple Barrels**
```xml
<iq:barrels>
    <iq:depends name="BluetoothMeshBarrel" version="1.0.0"/>
    <iq:depends name="Cryptography" version="1.0.1"/>
    <iq:depends name="StringUtils" version="2.0.0"/>
</iq:barrels>
```

### Finding Barrels

- **Connect IQ Store**: Search for barrels
- **GitHub**: https://github.com/garmin/connectiq-apps/tree/master/barrels
- **Community**: Garmin Developer Forum

### Creating Your Own Barrel

**Barrel manifest.xml:**
```xml
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:barrel
        id="unique-barrel-id"
        name="MyBarrel"
        version="1.0.0"
        minSdkVersion="3.1.0">

        <iq:products>
            <iq:product id="fenix6"/>
            <!-- Other products -->
        </iq:products>

        <iq:permissions/>
        <iq:languages/>
    </iq:barrel>
</iq:manifest>
```

---

## Complete Manifest Examples

### Simple Watch Face

```xml
<?xml version="1.0" encoding="utf-8"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        entry="SimpleWatchFaceApp"
        id="1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d"
        launcherIcon="@Drawables.LauncherIcon"
        minSdkVersion="3.1.0"
        name="@Strings.AppName"
        type="watchface"
        version="1.0.0">

        <iq:products>
            <iq:product id="fenix6"/>
            <iq:product id="vivoactive4"/>
            <iq:product id="venu"/>
        </iq:products>

        <iq:permissions/>
        <iq:languages/>
        <iq:barrels/>
    </iq:application>
</iq:manifest>
```

### Advanced Widget with All Features

```xml
<?xml version="1.0" encoding="utf-8"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        entry="WeatherWidgetApp"
        id="a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"
        launcherIcon="@Drawables.LauncherIcon"
        minSdkVersion="3.2.0"
        name="@Strings.AppName"
        type="widget"
        version="2.1.0">

        <iq:products>
            <iq:product id="fenix5"/>
            <iq:product id="fenix5plus"/>
            <iq:product id="fenix6"/>
            <iq:product id="fenix6pro"/>
            <iq:product id="fenix7"/>
            <iq:product id="fr245"/>
            <iq:product id="fr745"/>
            <iq:product id="fr945"/>
            <iq:product id="vivoactive3"/>
            <iq:product id="vivoactive4"/>
            <iq:product id="venu"/>
            <iq:product id="venu2"/>
        </iq:products>

        <iq:permissions>
            <iq:uses-permission id="Positioning"/>
            <iq:uses-permission id="Communications"/>
        </iq:permissions>

        <iq:languages>
            <iq:language>eng</iq:language>
            <iq:language>spa</iq:language>
            <iq:language>fre</iq:language>
            <iq:language>ger</iq:language>
            <iq:language>ita</iq:language>
        </iq:languages>

        <iq:barrels>
            <iq:depends name="WeatherIcons" version="1.0.0"/>
        </iq:barrels>
    </iq:application>
</iq:manifest>
```

### Data Field with Sensor Access

```xml
<?xml version="1.0" encoding="utf-8"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        entry="PowerDataFieldApp"
        id="9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c"
        launcherIcon="@Drawables.LauncherIcon"
        minSdkVersion="3.1.0"
        name="@Strings.AppName"
        type="datafield"
        version="1.5.2">

        <iq:products>
            <iq:product id="fenix6"/>
            <iq:product id="fenix6pro"/>
            <iq:product id="fenix7"/>
            <iq:product id="fr745"/>
            <iq:product id="fr945"/>
            <iq:product id="edge830"/>
            <iq:product id="edge1030"/>
        </iq:products>

        <iq:permissions>
            <iq:uses-permission id="SensorHistory"/>
            <iq:uses-permission id="UserProfile"/>
            <iq:uses-permission id="FitContributor"/>
            <iq:uses-permission id="Ant"/>
        </iq:permissions>

        <iq:languages>
            <iq:language>eng</iq:language>
        </iq:languages>

        <iq:barrels>
            <iq:depends name="GenericAntPlusPower" version="1.0.0"/>
        </iq:barrels>
    </iq:application>
</iq:manifest>
```

### Complex Device App

```xml
<?xml version="1.0" encoding="utf-8"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application
        entry="WorkoutTrackerApp"
        id="2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e"
        launcherIcon="@Drawables.LauncherIcon"
        minSdkVersion="4.0.0"
        name="@Strings.AppName"
        type="app"
        version="3.0.1">

        <iq:products>
            <iq:product id="fenix6xpro"/>
            <iq:product id="fenix7"/>
            <iq:product id="fenix7x"/>
            <iq:product id="fr945"/>
            <iq:product id="fr955"/>
            <iq:product id="venu2"/>
        </iq:products>

        <iq:permissions>
            <iq:uses-permission id="Positioning"/>
            <iq:uses-permission id="Communications"/>
            <iq:uses-permission id="SensorHistory"/>
            <iq:uses-permission id="UserProfile"/>
            <iq:uses-permission id="FitContributor"/>
        </iq:permissions>

        <iq:languages>
            <iq:language>eng</iq:language>
            <iq:language>spa</iq:language>
            <iq:language>fre</iq:language>
            <iq:language>ger</iq:language>
            <iq:language>ita</iq:language>
            <iq:language>por</iq:language>
            <iq:language>dut</iq:language>
        </iq:languages>

        <iq:barrels>
            <iq:depends name="Analytics" version="1.2.0"/>
            <iq:depends name="CloudSync" version="2.0.0"/>
        </iq:barrels>
    </iq:application>
</iq:manifest>
```

---

## Manifest Validation

### Common Errors

**Missing Required Attribute:**
```
Error: Application element missing 'entry' attribute
```
Fix: Add `entry="YourAppClassName"`

**Invalid Product ID:**
```
Error: Unknown product id: 'fenix99'
```
Fix: Use valid device ID from documentation

**Version Format:**
```
Error: Invalid version format
```
Fix: Use semantic versioning (e.g., "1.0.0")

**Duplicate Product:**
```
Warning: Duplicate product id
```
Fix: Remove duplicate `<iq:product>` entries

### Validation Tools

**IDE Validation:**
- Visual Studio Code: Real-time validation
- Eclipse: Built-in manifest editor

**Command Line:**
```bash
monkeyc -m manifest.xml -w
```

---

## Best Practices

### Device Selection
✅ Start with fewer devices, expand after testing
✅ Test on lowest-memory target device
✅ Group devices by capability (GPS, audio, etc.)

❌ Don't target all devices without testing
❌ Don't assume all features available

### Permissions
✅ Request minimal permissions needed
✅ Document why each permission is needed
✅ Test behavior when permission denied

❌ Don't request unused permissions
❌ Don't assume permissions granted

### Versioning
✅ Use semantic versioning (MAJOR.MINOR.PATCH)
✅ Increment appropriately for changes
✅ Document changes in release notes

### SDK Version
✅ Use oldest SDK that provides needed features
✅ Test against specified minSdkVersion
✅ Document SDK-specific features used

---

## Advanced Configuration

### Conditional Product Configuration

Some devices may require specific configurations. Use the SDK's jungle files (.jungle) for conditional compilation:

**jungle/vivoactive4s.jungle:**
```
vivoactive4s.resourcePath = $(vivoactive4s.resourcePath);resources-small
```

### Background Mode Configuration

For apps that use background services:

**manifest.xml:**
```xml
<iq:application ...>
    <!-- Regular config -->
</iq:application>

<!-- Background services defined separately in code -->
```

### Glances

Add glance support to device apps:

```monkey-c
// In your App class
function getGlanceView() {
    return [ new MyGlanceView() ];
}
```

---

## Resources

- **Device Capabilities**: https://developer.garmin.com/connect-iq/compatible-devices/
- **API Documentation**: https://developer.garmin.com/connect-iq/api-docs/
- **Manifest Reference**: https://developer.garmin.com/connect-iq/core-topics/manifest/
- **Product IDs**: https://developer.garmin.com/connect-iq/reference-guides/devices-reference/
