# Garmin Connect IQ Documentation

> Comprehensive developer documentation for building Connect IQ applications

## Overview

This documentation library contains **157 markdown files** with detailed information about Garmin Connect IQ development, including 282+ real code examples extracted from official Garmin sample applications.

## Quick Start

**New to Connect IQ?** Start here:
1. [Quick Start Guide](basics/quick-start-guide.md) - Get up and running in minutes
2. [App Types Detailed](basics/app-types-detailed.md) - Choose the right app type
3. [Manifest Structure](core-topics/manifest-structure.md) - Configure your app
4. [Language Essentials](monkey-c/language-essentials.md) - Learn Monkey C syntax

## Documentation Structure

### 📚 Basics (7 files)
Foundation topics for getting started:
- **[Quick Start Guide](basics/quick-start-guide.md)** ⭐ - Complete beginner's guide with examples
- **[App Types Detailed](basics/app-types-detailed.md)** ⭐ - In-depth guide to all 6 app types
- [Getting Started](basics/getting-started.md) - Initial setup
- [Your First App](basics/your-first-app.md) - First app tutorial
- [App Types](basics/app-types.md) - App type overview

### 🔧 Core Topics (46 files)
Essential development topics:

#### Configuration & Setup
- **[Manifest Structure](core-topics/manifest-structure.md)** ⭐ - Complete manifest reference
- **[Project Structure](core-topics/project-structure.md)** ⭐ - File organization and build setup
- [Build Configuration](core-topics/build-configuration.md) - Compilation settings
- [Properties and App Settings](core-topics/properties-and-app-settings.md) - User settings
- [Security](core-topics/security.md) - Security best practices

#### User Interface
- **[UI Development](core-topics/ui-development.md)** ⭐ - Complete UI guide with examples
- [Layouts](core-topics/layouts.md) - XML layouts and positioning
- [Graphics](core-topics/graphics.md) - Drawing and rendering
- [Input Handling](core-topics/input-handling.md) - Touch and button events
- [Native Controls](core-topics/native-controls.md) - Built-in UI components
- [Resources](core-topics/resources.md) - Strings, images, and localization
- [Monkey Style](core-topics/monkey-style.md) - CSS-like styling

#### Data & Sensors
- **[Data and Sensors](core-topics/data-and-sensors.md)** ⭐ - Complete sensor and data guide
- [Sensors](core-topics/sensors.md) - Device sensor access
- [Positioning](core-topics/positioning.md) - GPS and location services
- [Activity Recording](core-topics/activity-recording.md) - FIT file recording
- [Quantifying the User](core-topics/quantifying-the-user.md) - User profile data
- [Persisting Data](core-topics/persisting-data.md) - Local storage

#### Networking
- **[Networking](core-topics/networking.md)** ⭐ - HTTP, OAuth, and web services
- [HTTPS](core-topics/https.md) - Making web requests
- [Authenticated Web Services](core-topics/authenticated-web-services.md) - OAuth integration
- [Communicating with Mobile Apps](core-topics/communicating-with-mobile-apps.md) - Device-to-phone
- [Downloading Content](core-topics/downloading-content.md) - Background downloads

#### Background Processing
- [Backgrounding](core-topics/backgrounding.md) - Background services
- [Glances](core-topics/glances.md) - Quick-view information panels
- [Complications](core-topics/complications.md) - Watch face complications

#### Wireless Connectivity
- [ANT and ANT Plus](core-topics/ant-and-ant-plus.md) - ANT sensor integration
- [Bluetooth Low Energy](core-topics/bluetooth-low-energy.md) - BLE communication
- [Pairing Wireless Devices](core-topics/pairing-wireless-devices.md) - Device pairing

#### Development Tools
- **[Debugging and Testing](core-topics/debugging-and-testing.md)** ⭐ - Complete debugging guide
- [Debugging](core-topics/debugging.md) - Debug techniques
- [Unit Testing](core-topics/unit-testing.md) - Test framework
- [Exception Reporting Tool](core-topics/exception-reporting-tool.md) - Crash reporting
- [Profiling](core-topics/profiling.md) - Performance optimization

#### Publishing
- [Publishing to the Store](core-topics/publishing-to-the-store.md) - Store submission
- [Beta Apps](core-topics/beta-apps.md) - Beta testing
- [Trial Apps](core-topics/trial-apps.md) - Trial versions
- [Requesting Reviews](core-topics/requesting-reviews.md) - In-app reviews

### 💻 Monkey C Language (11 files)
Programming language reference:
- **[Language Essentials](monkey-c/language-essentials.md)** ⭐ - Complete language reference (1,016 lines, 43 examples)
- **[Common Patterns](monkey-c/common-patterns.md)** ⭐ - Best practices and patterns (1,162 lines, 18 examples)
- [Functions](monkey-c/functions.md) - Function definitions
- [Objects and Memory](monkey-c/objects-and-memory.md) - OOP and memory management
- [Containers](monkey-c/containers.md) - Arrays and dictionaries
- [Monkey Types](monkey-c/monkey-types.md) - Type system
- [Exceptions and Errors](monkey-c/exceptions-and-errors.md) - Error handling
- [Annotations](monkey-c/annotations.md) - Code annotations
- [Coding Conventions](monkey-c/coding-conventions.md) - Style guide
- [Compiler Options](monkey-c/compiler-options.md) - Build flags

### 📖 API Documentation (34 files)
Complete Toybox API reference:
- **[Toybox Overview](api-docs/toybox-overview.md)** ⭐ - All modules with examples

#### Core APIs
- [Application](api-docs/Application.md) - App lifecycle
- [System](api-docs/System.md) - System information
- [Lang](api-docs/Lang.md) - Language utilities
- [Timer](api-docs/Timer.md) - Timers and scheduling
- [Time](api-docs/Time.md) - Time and date handling

#### UI APIs
- [WatchUi](api-docs/WatchUi.md) - UI components and views
- [Graphics](api-docs/Graphics.md) - Drawing APIs
- [Attention](api-docs/Attention.md) - Alerts and vibrations

#### Data APIs
- [Activity](api-docs/Activity.md) - Activity data
- [ActivityMonitor](api-docs/ActivityMonitor.md) - Daily activity tracking
- [ActivityRecording](api-docs/ActivityRecording.md) - FIT recording
- [UserProfile](api-docs/UserProfile.md) - User profile and health data

#### Sensor APIs
- [Sensor](api-docs/Sensor.md) - Device sensors
- [SensorHistory](api-docs/SensorHistory.md) - Historical sensor data
- [SensorLogging](api-docs/SensorLogging.md) - Sensor data logging
- [Position](api-docs/Position.md) - GPS and positioning

#### Communication APIs
- [Communications](api-docs/Communications.md) - HTTP and web services
- [Authentication](api-docs/Authentication.md) - OAuth
- [BluetoothLowEnergy](api-docs/BluetoothLowEnergy.md) - BLE
- [Ant](api-docs/Ant.md) - ANT wireless
- [AntPlus](api-docs/AntPlus.md) - ANT+ sensors

#### Utility APIs
- [Math](api-docs/Math.md) - Mathematical functions
- [StringUtil](api-docs/StringUtil.md) - String utilities
- [Cryptography](api-docs/Cryptography.md) - Encryption and hashing
- [Test](api-docs/Test.md) - Unit testing framework

#### Specialized APIs
- [Media](api-docs/Media.md) - Audio playback
- [Complications](api-docs/Complications.md) - Watch face complications
- [FitContributor](api-docs/FitContributor.md) - Custom FIT fields
- [PersistedContent](api-docs/PersistedContent.md) - Content persistence
- [PersistedLocations](api-docs/PersistedLocations.md) - Location persistence
- [Background](api-docs/Background.md) - Background processes
- [Notifications](api-docs/Notifications.md) - System notifications
- [Weather](api-docs/Weather.md) - Weather data

### 📚 Reference Guides (8 files)
Technical references:
- **[Common APIs](reference-guides/common-apis.md)** ⭐ - Quick API reference (895 lines, 31 examples)
- [Monkey C Reference](reference-guides/monkey-c-reference.md) - Language reference
- [Jungle Reference](reference-guides/jungle-reference.md) - Build system
- [Monkey Motion Reference](reference-guides/monkey-motion-reference.md) - Animation library
- [Monkey Graph Reference](reference-guides/monkey-graph-reference.md) - Graphing library
- [Visual Studio Code Extension](reference-guides/visual-studio-code-extension.md) - VS Code setup
- [Monkey C Command Line Setup](reference-guides/monkey-c-command-line-setup.md) - CLI tools

### 🎨 User Experience (16 files)
Design guidelines:
- [Design Principles](user-experience/design-principles.md) - Core principles
- [Understanding What You Are Building](user-experience/understanding-what-you-are-building.md) - Planning
- [Designing Workflows and Interactions](user-experience/designing-workflows-and-interactions.md) - UX patterns
- [Watch Faces](user-experience/watch-faces.md) - Watch face design
- [Data Fields](user-experience/data-fields.md) - Data field design
- [Views](user-experience/views.md) - View design
- [Menus](user-experience/menus.md) - Menu patterns
- [Localization](user-experience/localization.md) - i18n best practices

### 🎭 Personality Library (11 files)
UI components and patterns:
- [Colors](personality-library/colors.md) - Color palette
- [Typography](personality-library/typography.md) - Font guidelines
- [Iconography](personality-library/iconography.md) - Icon design
- [Input Hints](personality-library/input-hints.md) - User guidance
- [Confirmations](personality-library/confirmations.md) - Confirmation patterns
- [Progress Bars](personality-library/progress-bars.md) - Progress indicators

### ❓ FAQ (11 files)
Common questions and solutions:
- [Watch Face Second Updates](faq/watch-face-second-updates.md) - Update every second
- [REST Services](faq/rest-services.md) - API integration
- [AMOLED Watch Faces](faq/amoled-watch-faces.md) - AMOLED optimization
- [Background Services](faq/background-services.md) - Background tasks
- [Optimize Bitmaps](faq/optimize-bitmaps.md) - Image optimization
- [Custom Fonts](faq/custom-fonts.md) - Font integration
- [MapView](faq/mapview.md) - Map implementation
- [Mobile SDK](faq/mobile-sdk.md) - Companion apps
- [Audio Content Provider](faq/audio-content-provider.md) - Music apps

### 💰 Monetization (5 files)
Paid apps and revenue:
- [Merchant Onboarding](monetization/merchant-onboarding.md) - Setup merchant account
- [App Sales](monetization/app-sales.md) - Pricing and sales
- [Price Points](monetization/price-points.md) - Available prices

### 📱 Overview (6 files)
Platform overview:
- [Overview](overview/overview.md) - Connect IQ platform
- [Compatible Devices](overview/compatible-devices.md) - Device compatibility
- [SDK](overview/sdk.md) - SDK downloads
- [Submit an App](overview/submit-an-app.md) - Submission process

## Statistics

- **Total Files**: 157 markdown files
- **Total Code Examples**: 282+ working examples
- **Total Documentation Lines**: 10,000+ lines
- **Source**: Official Garmin sample repositories

## Key Features

✅ **Real Code Examples** - All examples from actual Connect IQ apps
✅ **Comprehensive Coverage** - All app types, APIs, and development topics
✅ **Developer-Focused** - Practical, actionable information
✅ **Well-Organized** - Clear structure from basics to advanced
✅ **Production-Ready** - Best practices and error handling
✅ **Cross-Referenced** - Related topics linked together

## Most Important Files

Start with these **⭐ starred** files for maximum impact:

1. **[Quick Start Guide](basics/quick-start-guide.md)** - Get started in minutes
2. **[App Types Detailed](basics/app-types-detailed.md)** - Choose your app type
3. **[Language Essentials](monkey-c/language-essentials.md)** - Learn Monkey C
4. **[Manifest Structure](core-topics/manifest-structure.md)** - Configure your app
5. **[UI Development](core-topics/ui-development.md)** - Build your interface
6. **[Data and Sensors](core-topics/data-and-sensors.md)** - Access device data
7. **[Networking](core-topics/networking.md)** - Connect to web services
8. **[Debugging and Testing](core-topics/debugging-and-testing.md)** - Debug and optimize
9. **[Common Patterns](monkey-c/common-patterns.md)** - Best practices
10. **[Common APIs](reference-guides/common-apis.md)** - Quick API reference

## Official Resources

For the latest official documentation, visit:
- **Developer Portal**: https://developer.garmin.com/connect-iq/
- **API Documentation**: https://developer.garmin.com/connect-iq/api-docs/
- **Forums**: https://forums.garmin.com/developer/connect-iq/
- **GitHub Samples**: https://github.com/garmin/connectiq-apps

## Usage Notes

This documentation is designed to be referenced by Claude Code and other AI assistants to help with Garmin Connect IQ development. All examples are production-ready and follow Garmin's best practices.

For detailed API specifications and the latest features, always refer to the official Garmin Developer Portal.

---

**Last Updated**: 2025-11-14
**SDK Version**: Connect IQ 8.3.0
**Source**: Official Garmin GitHub repositories and developer documentation
