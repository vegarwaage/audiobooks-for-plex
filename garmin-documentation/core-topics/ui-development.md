# UI Development in Connect IQ

## Overview

This guide covers UI development in Connect IQ, including view hierarchies, the drawable system, layout patterns, and event handling with practical examples.

---

## View Hierarchy

### View Base Classes

Connect IQ provides several base view classes depending on your app type:

```monkey-c
using Toybox.WatchUi;

// Generic view (widgets, device apps)
class MyView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        // Draw UI
    }
}

// Watch face view
class MyWatchFace extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        // Draw watch face
    }

    function onEnterSleep() {
        // Low-power mode
    }

    function onExitSleep() {
        // Normal mode
    }
}

// Data field view
class MyDataField extends WatchUi.DataField {
    function initialize() {
        DataField.initialize();
    }

    function compute(info) {
        // Calculate value
    }

    function onUpdate(dc) {
        // Draw data field
    }
}

// Glance view
class MyGlance extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc) {
        // Draw glance
    }
}
```

### View Lifecycle

```monkey-c
class MyView extends WatchUi.View {
    function initialize() {
        View.initialize();
        // Constructor - initialize state
    }

    function onLayout(dc) {
        // Set up layout from XML resources
        setLayout(Rez.Layouts.MainLayout(dc));

        // Or create layout programmatically
    }

    function onShow() {
        // View is about to be shown
        // Refresh data, start animations
    }

    function onUpdate(dc) {
        // Render the view
        // Called automatically by system
        View.onUpdate(dc);  // Call parent to update XML layout

        // Custom drawing
        drawCustomElements(dc);
    }

    function onHide() {
        // View is about to be hidden
        // Save state, stop animations
    }
}
```

---

## Drawing Context (DC)

### Basic Drawing Operations

```monkey-c
using Toybox.Graphics;

function onUpdate(dc) {
    // Get screen dimensions
    var width = dc.getWidth();
    var height = dc.getHeight();
    var centerX = width / 2;
    var centerY = height / 2;

    // Set colors and clear
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    // Draw shapes
    dc.drawPoint(centerX, centerY);
    dc.drawLine(0, 0, width, height);
    dc.drawCircle(centerX, centerY, 50);
    dc.fillCircle(centerX, centerY, 40);
    dc.drawRectangle(50, 50, 100, 80);
    dc.fillRectangle(50, 50, 100, 80);
    dc.drawRoundedRectangle(50, 50, 100, 80, 10);

    // Draw arcs
    dc.drawArc(
        centerX, centerY,    // center
        50,                   // radius
        Graphics.ARC_CLOCKWISE,
        0,                    // start angle (degrees)
        90                    // end angle (degrees)
    );

    // Draw text
    dc.drawText(
        centerX,
        centerY,
        Graphics.FONT_MEDIUM,
        "Hello World",
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
}
```

### Color Management

```monkey-c
// Predefined colors
dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

// Available colors
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

// Custom colors (RGB hex)
var customColor = 0x00FF00;  // Green
dc.setColor(customColor, Graphics.COLOR_TRANSPARENT);

// Theme-aware colors
var settings = System.getDeviceSettings();
var isDark = settings.theme == 0;
var fgColor = isDark ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
var bgColor = isDark ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
```

### Font Usage

```monkey-c
// System fonts
Graphics.FONT_XTINY          // Smallest
Graphics.FONT_TINY
Graphics.FONT_SMALL
Graphics.FONT_MEDIUM
Graphics.FONT_LARGE          // Largest

// Number fonts (larger, monospaced)
Graphics.FONT_NUMBER_MILD
Graphics.FONT_NUMBER_MEDIUM
Graphics.FONT_NUMBER_HOT
Graphics.FONT_NUMBER_THAI_HOT  // Largest

// Get text dimensions
var text = "Hello World";
var font = Graphics.FONT_MEDIUM;
var dimensions = dc.getTextDimensions(text, font);
var textWidth = dimensions[0];
var textHeight = dimensions[1];

// Custom fonts (from resources)
var customFont = WatchUi.loadResource(Rez.Fonts.MyCustomFont);
dc.drawText(x, y, customFont, text, justification);
```

### Text Justification

```monkey-c
// Horizontal alignment
Graphics.TEXT_JUSTIFY_LEFT
Graphics.TEXT_JUSTIFY_CENTER
Graphics.TEXT_JUSTIFY_RIGHT

// Vertical alignment
Graphics.TEXT_JUSTIFY_VCENTER

// Combined (use bitwise OR)
dc.drawText(
    x, y,
    Graphics.FONT_MEDIUM,
    "Centered",
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
);

// Examples
// Left-aligned, vertically centered
dc.drawText(x, y, font, text,
    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

// Right-aligned, top
dc.drawText(x, y, font, text,
    Graphics.TEXT_JUSTIFY_RIGHT);

// Center both axes
dc.drawText(x, y, font, text,
    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
```

---

## Layout Patterns

### XML Layouts

**resources/layouts/MainLayout.xml:**
```xml
<layout id="MainLayout">
    <!-- Title label -->
    <label id="TitleLabel"
           x="center"
           y="25%"
           font="Graphics.FONT_MEDIUM"
           justification="Graphics.TEXT_JUSTIFY_CENTER"
           color="Graphics.COLOR_WHITE"
           text="@Strings.Title"/>

    <!-- Value label -->
    <label id="ValueLabel"
           x="center"
           y="50%"
           font="Graphics.FONT_NUMBER_HOT"
           justification="Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER"
           color="Graphics.COLOR_BLUE"/>

    <!-- Status label -->
    <label id="StatusLabel"
           x="center"
           y="75%"
           font="Graphics.FONT_SMALL"
           justification="Graphics.TEXT_JUSTIFY_CENTER"
           color="Graphics.COLOR_LT_GRAY"/>

    <!-- Bitmap -->
    <bitmap id="BackgroundImage"
            x="0"
            y="0"
            filename="../drawables/background.png"/>
</layout>
```

**Using XML Layout in Code:**
```monkey-c
class MyView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onUpdate(dc) {
        // Update layout elements
        var titleLabel = View.findDrawableById("TitleLabel");
        titleLabel.setText("My Title");

        var valueLabel = View.findDrawableById("ValueLabel");
        valueLabel.setText("123");

        // Call parent to render layout
        View.onUpdate(dc);

        // Add custom drawing on top
        drawCustomElements(dc);
    }

    function drawCustomElements(dc) {
        // Custom drawing not in layout
    }
}
```

### Programmatic Layouts

```monkey-c
class MyView extends WatchUi.View {
    private var _title;
    private var _value;
    private var _status;

    function initialize() {
        View.initialize();
        _title = "Title";
        _value = "0";
        _status = "Ready";
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Clear
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height * 0.25,
            Graphics.FONT_MEDIUM,
            _title,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw value
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_NUMBER_HOT,
            _value,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Draw status
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height * 0.75,
            Graphics.FONT_SMALL,
            _status,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function setValue(value) {
        _value = value;
        WatchUi.requestUpdate();
    }
}
```

### Responsive Layouts

```monkey-c
class ResponsiveView extends WatchUi.View {
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var settings = System.getDeviceSettings();

        // Adapt to screen shape
        if (settings.screenShape == System.SCREEN_SHAPE_ROUND) {
            drawRoundLayout(dc, width, height);
        } else if (settings.screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
            drawSemiRoundLayout(dc, width, height);
        } else {
            drawRectangleLayout(dc, width, height);
        }
    }

    private function drawRoundLayout(dc, width, height) {
        // Center-focused layout for round screens
        var centerX = width / 2;
        var centerY = height / 2;

        dc.drawText(
            centerX,
            centerY,
            Graphics.FONT_LARGE,
            "Round",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawSemiRoundLayout(dc, width, height) {
        // Flat-bottom layout
        dc.drawText(
            width / 2,
            height * 0.4,
            Graphics.FONT_LARGE,
            "Semi-Round",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function drawRectangleLayout(dc, width, height) {
        // Corner-to-corner layout
        dc.drawText(
            10,
            10,
            Graphics.FONT_LARGE,
            "Rectangle",
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
}
```

---

## Bitmaps and Images

### Loading Bitmaps

```monkey-c
// From resources
var bitmap = WatchUi.loadResource(Rez.Drawables.MyImage);

// Draw bitmap
dc.drawBitmap(x, y, bitmap);

// Draw with options
dc.drawBitmap2(x, y, bitmap, {
    :tintColor => Graphics.COLOR_BLUE,
    :transform => new Graphics.AffineTransform()
});

// Get bitmap dimensions
var width = bitmap.getWidth();
var height = bitmap.getHeight();
```

### Bitmap Resources

**resources/drawables/drawables.xml:**
```xml
<drawables>
    <bitmap id="LauncherIcon" filename="launcher_icon.png"/>
    <bitmap id="Background" filename="background.png"/>
    <bitmap id="Icon1" filename="icon_1.png"/>
</drawables>
```

### Image Optimization

```monkey-c
// Use appropriate image sizes for each device
// resources-high/  (for high-res devices)
// resources-medium/  (for medium-res devices)
// resources-low/  (for low-res devices)

// Jungle file configuration
// fenix6.resourcePath = $(fenix6.resourcePath);resources-high
// vivoactive4s.resourcePath = $(vivoactive4s.resourcePath);resources-low
```

---

## Event Handling

### Input Delegates

```monkey-c
using Toybox.WatchUi;
using Toybox.System;

class MyDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Select button
    function onSelect() {
        System.println("Select pressed");
        _view.handleSelect();
        return true;  // Event handled
    }

    // Back button
    function onBack() {
        System.println("Back pressed");
        // Return false to exit app
        // Return true to handle in app
        return false;
    }

    // Up/Down buttons (or swipe)
    function onNextPage() {
        _view.nextPage();
        return true;
    }

    function onPreviousPage() {
        _view.previousPage();
        return true;
    }

    // Menu button (or long-press select)
    function onMenu() {
        var menu = new Rez.Menus.MainMenu();
        WatchUi.pushView(menu, new MyMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Key events (for devices with keys)
    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER) {
            // Handle enter key
            return true;
        }
        return false;
    }
}
```

### Touch Events

```monkey-c
class MyDelegate extends WatchUi.BehaviorDelegate {
    // Screen tap
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        System.println("Tap at: " + x + ", " + y);
        _view.handleTap(x, y);
        return true;
    }

    // Swipe gestures
    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_UP) {
            _view.handleSwipeUp();
        } else if (direction == WatchUi.SWIPE_DOWN) {
            _view.handleSwipeDown();
        } else if (direction == WatchUi.SWIPE_LEFT) {
            _view.handleSwipeLeft();
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _view.handleSwipeRight();
        }

        return true;
    }

    // Hold (long press)
    function onHold(clickEvent) {
        var coords = clickEvent.getCoordinates();
        System.println("Hold at: " + coords[0] + ", " + coords[1]);
        return true;
    }

    // Drag
    function onDrag(dragEvent) {
        var coords = dragEvent.getCoordinates();
        _view.handleDrag(coords[0], coords[1]);
        return true;
    }
}
```

### Click Detection in Views

```monkey-c
class InteractiveView extends WatchUi.View {
    private var _buttons = [];

    function initialize() {
        View.initialize();

        // Define clickable regions
        _buttons = [
            {:x => 60, :y => 60, :width => 120, :height => 40, :id => :button1},
            {:x => 60, :y => 120, :width => 120, :height => 40, :id => :button2}
        ];
    }

    function handleTap(x, y) {
        // Check which button was tapped
        for (var i = 0; i < _buttons.size(); i++) {
            var btn = _buttons[i];
            if (x >= btn[:x] && x <= btn[:x] + btn[:width] &&
                y >= btn[:y] && y <= btn[:y] + btn[:height]) {

                onButtonPressed(btn[:id]);
                return true;
            }
        }
        return false;
    }

    function onButtonPressed(buttonId) {
        if (buttonId == :button1) {
            System.println("Button 1 pressed");
        } else if (buttonId == :button2) {
            System.println("Button 2 pressed");
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw buttons
        for (var i = 0; i < _buttons.size(); i++) {
            drawButton(dc, _buttons[i]);
        }
    }

    private function drawButton(dc, button) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(button[:x], button[:y], button[:width], button[:height]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            button[:x] + button[:width] / 2,
            button[:y] + button[:height] / 2,
            Graphics.FONT_SMALL,
            button[:id].toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

---

## Menus

### Menu2 System

```monkey-c
using Toybox.WatchUi;

class MyMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Settings"});

        // Simple menu item
        addItem(new WatchUi.MenuItem(
            "Option 1",          // label
            "Description",       // sublabel
            :option1,            // id
            {}                   // options
        ));

        // Toggle menu item
        addItem(new WatchUi.ToggleMenuItem(
            "Enable Feature",
            "Turn on/off",
            :toggle1,
            true,                // initial state
            {}
        ));

        // Icon menu item
        addItem(new WatchUi.IconMenuItem(
            "With Icon",
            "Has an icon",
            :icon1,
            Rez.Drawables.MyIcon,
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

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

// Show menu
var menu = new MyMenu();
var delegate = new MyMenuDelegate();
WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
```

---

## Animations and Timers

### Timer-Based Animation

```monkey-c
using Toybox.System;
using Toybox.WatchUi;

class AnimatedView extends WatchUi.View {
    private var _timer;
    private var _angle = 0;

    function initialize() {
        View.initialize();
    }

    function onShow() {
        // Start animation timer
        _timer = new System.Timer();
        _timer.start(method(:onTimer), 50, true);  // 50ms, repeating
    }

    function onHide() {
        // Stop animation timer
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onTimer() {
        _angle = (_angle + 5) % 360;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        // Draw rotating element
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(
            centerX, centerY,
            50,
            Graphics.ARC_CLOCKWISE,
            0,
            _angle
        );
    }
}
```

---

## Advanced UI Techniques

### Clipping

```monkey-c
function onUpdate(dc) {
    // Set clipping region
    dc.setClip(50, 50, 140, 140);

    // Draw (only visible within clip region)
    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(120, 120, 100);

    // Clear clipping
    dc.clearClip();

    // Draw outside clip region
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawCircle(120, 120, 50);
}
```

### Double Buffering Pattern

```monkey-c
class BufferedView extends WatchUi.View {
    private var _buffer;

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        // Use cached buffer if available
        if (_buffer != null) {
            dc.drawBitmap(0, 0, _buffer);
            return;
        }

        // Create buffer
        _buffer = createBuffer(dc);
        dc.drawBitmap(0, 0, _buffer);
    }

    private function createBuffer(dc) {
        var buffer = new Graphics.BufferedBitmap({
            :width => dc.getWidth(),
            :height => dc.getHeight()
        });

        var bufferDc = buffer.getDc();

        // Draw to buffer
        bufferDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        bufferDc.clear();
        drawComplexGraphics(bufferDc);

        return buffer;
    }

    function invalidateBuffer() {
        _buffer = null;
        WatchUi.requestUpdate();
    }
}
```

---

## Best Practices

### Performance
✅ Cache calculated values
✅ Minimize onUpdate() complexity
✅ Use appropriate font sizes
✅ Optimize bitmap sizes

❌ Don't recalculate every frame
❌ Don't use oversized images
❌ Don't perform network calls in onUpdate()

### Memory
✅ Release resources in onHide()
✅ Use memory-efficient data structures
✅ Test on low-memory devices

❌ Don't leak timers or listeners
❌ Don't store unnecessary data
❌ Don't create large buffers

### User Experience
✅ Provide visual feedback
✅ Handle all input methods
✅ Support different screen shapes
✅ Test on actual devices

❌ Don't assume touch support
❌ Don't ignore device differences
❌ Don't block the UI thread

---

## Resources

- **API Documentation**: https://developer.garmin.com/connect-iq/api-docs/
- **UI Samples**: https://github.com/garmin/connectiq-apps
- **Design Guidelines**: https://developer.garmin.com/connect-iq/core-topics/
