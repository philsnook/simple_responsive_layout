# 📱 simple_responsive_layout

A **minimal, powerful Flutter package** for building **responsive layouts, widgets, values, and visibility** without the bloat.

## ✨ Features

- 🧩 **ResponsiveChild** – Switch a single widget's layout based on device type
- 🏗️ **ResponsiveLayout** – Switch container layouts (Row ↔ Column ↔ Grid) based on device
- 🔢 **ResponsiveValue<T>** – Dynamically select values based on device type
- 🫥 **ResponsiveVisibility** – Show/hide widgets on specific device types
- 📏 **ResponsiveSizedBox** – Flexible sizing based on device type
- 🛣️ **ResponsivePadding** – Adaptive padding based on device type
- 🧰 **ResponsiveBuilder** – Full control with custom builder and responsive info
- 🔄 **ResponsiveOrientationChild** – Switch layouts based on portrait or landscape mode
- 💫 **ResponsiveOrientationValue<T>** – Values that adapt to device orientation
- ⚙️ **ResponsiveSettings** – Customize breakpoints
- 🔄 **ResponsiveInfo** – Complete device information with helpful properties
- ❌ **Zero dependencies** — pure Flutter implementation
- ⚡ **Extremely lightweight and fast**


## 🚀 Usage

### Basic Setup (Optional)

While the package works with default settings, you can customize breakpoints globally:

```dart
void main() {
  // Optional: Configure global responsive settings
  ResponsiveSettings.defaultSettings = ResponsiveSettings(
    mobileWidth: 600,     // breakpoint between mobile and tablet
    tabletWidth: 1024,    // breakpoint between tablet and desktop
  );
  
  runApp(const MyApp());
}
```

### Provider Setup (Optional)

For more advanced projects, you can use the provider to manage settings:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSettingsProvider(
      settings: ResponsiveSettings(
        mobileWidth: 550,
        tabletWidth: 1200,
      ),
      child: MaterialApp(
        title: 'My Responsive App',
        home: HomePage(),
      ),
    );
  }
}
```

### ResponsiveChild

Switch a single widget's layout based on device:

```dart
ResponsiveChild(
  child: Text('Hello World'),
  mobileChild: (context, child) => Center(
    child: child,
  ),
  tabletChild: (context, child) => Align(
    alignment: Alignment.centerLeft,
    child: child,
  ),
  desktopChild: (context, child) => Container(
    padding: EdgeInsets.all(16),
    child: child,
  ),
)
```

Or build the child dynamically:

```dart
ResponsiveChild(
  childBuilder: (context, info) => Text(
    info.isMobileOnly 
      ? 'Mobile View' 
      : info.isTabletOnly 
          ? 'Tablet View' 
          : 'Desktop View',
    style: TextStyle(
      fontSize: info.isMobile ? 16 : info.isTablet ? 20 : 24,
    ),
  ),
)
```

### ResponsiveLayout

Switch how a group of widgets are arranged:

```dart
ResponsiveLayout(
  children: [
    Card(child: Text('Item 1')),
    Card(child: Text('Item 2')),
    Card(child: Text('Item 3')),
  ],
  mobileChild: (context, children) => Column(
    children: children,
  ),
  tabletChild: (context, children) => Row(
    children: children,
  ),
  desktopChild: (context, children) => Wrap(
    spacing: 16,
    runSpacing: 16,
    children: children,
  ),
)
```

Or dynamically generate different children based on device:

```dart
ResponsiveLayout(
  childrenBuilder: (context, info) => [
    Text('Header'),
    if (info.isMobile) 
      const SizedBox(height: 20),
    if (!info.isMobile) 
      const SizedBox(width: 20),
    Text('Content'),
    if (info.isDesktopOnly) 
      Text('Desktop-only content'),
  ],
  mobileChild: (context, children) => Column(children: children),
  tabletChild: (context, children) => Row(children: children),
)
```

### ResponsiveValue

Choose dynamic values based on device type:

```dart
// In a widget:
final fontSize = ResponsiveValue<double>(
  defaultValue: 16.0,
  mobileValue: 14.0,
  tabletValue: 16.0,
  desktopValue: 18.0,
).value(context);

Text(
  'Hello World',
  style: TextStyle(fontSize: fontSize),
)
```

Or with custom logic:

```dart
final padding = ResponsiveValue<EdgeInsets>(
  defaultValue: EdgeInsets.all(16),
  valueBuilder: (context, info) {
    // Full custom logic for any scenario
    if (info.isMobileOnly) {
      return EdgeInsets.all(8);
    } else if (info.isTabletOnly) {
      return EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  },
).value(context);
```

### ResponsiveVisibility

Show or hide widgets for different device types:

```dart
// Only visible on mobile and tablet
ResponsiveVisibility(
  deviceTypes: [ResponsiveDeviceType.mobile, ResponsiveDeviceType.tablet],
  child: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)

// Only visible on desktop
ResponsiveVisibility(
  deviceTypes: [ResponsiveDeviceType.desktop],
  child: Row(
    children: [
      Icon(Icons.settings),
      Text('Advanced Settings'),
    ],
  ),
)
```

### ResponsiveSizedBox

Different sizes for spacing based on device:

```dart
// Vertical gap that changes based on device
ResponsiveSizedBox(
  defaultSize: const Size(double.infinity, 16),
  mobileSize: const Size(double.infinity, 8),
  tabletSize: const Size(double.infinity, 16),
  desktopSize: const Size(double.infinity, 24),
)

// Or with child
ResponsiveSizedBox(
  mobileSize: const Size(double.infinity, 100),
  tabletSize: const Size(300, double.infinity),
  desktopSize: const Size(500, double.infinity),
  child: Text('Sized content'),
)
```

### ResponsivePadding

Adaptive padding based on device:

```dart
ResponsivePadding(
  defaultSize: EdgeInsets.all(16),
  mobileSize: EdgeInsets.all(8),
  tabletSize: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  desktopSize: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
  child: Card(
    child: Text('Content with device-specific padding'),
  ),
)
```

### NEW in v1.1.0: Orientation Support

#### ResponsiveOrientationChild

Adapt your widget layout based on portrait or landscape orientation:

```dart
ResponsiveOrientationChild(
  child: Text('Hello World'),
  portraitChild: (context, child) => Center(
    child: Container(
      width: 300,
      child: child,
    ),
  ),
  landscapeChild: (context, child) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: 500,
      child: child,
    ),
  ),
)
```

#### ResponsiveOrientationValue

Select different values based on device orientation:

```dart
// In a widget:
final padding = ResponsiveOrientationValue<EdgeInsets>(
  defaultValue: EdgeInsets.all(16),
  portraitValue: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  landscapeValue: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
).value(context);

Container(
  padding: padding,
  child: Text('Orientation-aware padding'),
)
```

### Combining Device Type and Orientation

You can easily combine device type and orientation responsiveness:

```dart
// First adapt to device type, then to orientation
ResponsiveChild(
  // Device type first
  mobileChild: (context, child) => Container(
    color: Colors.blue,
    // Then orientation for the mobile layout
    child: ResponsiveOrientationChild(
      child: child,
      portraitChild: (ctx, c) => Padding(
        padding: EdgeInsets.all(8),
        child: c,
      ),
      landscapeChild: (ctx, c) => Padding(
        padding: EdgeInsets.all(16),
        child: c,
      ),
    ),
  ),
  desktopChild: (context, child) => Container(
    color: Colors.green,
    child: child,
  ),
  child: Text('Responsive content'),
)
```

Or use orientation-aware values in device-specific layouts:

```dart
ResponsiveValue<TextStyle>(
  // Default style
  defaultValue: TextStyle(fontSize: 16),
  // Mobile style with orientation-specific sizes
  mobileValue: TextStyle(
    fontSize: ResponsiveOrientationValue<double>(
      defaultValue: 14,
      portraitValue: 14,
      landscapeValue: 12,
    ).value(context),
  ),
  // Desktop style
  desktopValue: TextStyle(fontSize: 18),
).value(context)
```

### ResponsiveBuilder

For complete custom control:

```dart
ResponsiveBuilder(
  builder: (context, info) {
    // Full access to device info for custom layouts
    if (info.isMobile) {
      // Check orientation for mobile layouts
      if (info.isPortrait) {
        return Column(
          children: [
            Text('Mobile Portrait Layout'),
            // Portrait-specific widgets
          ],
        );
      } else {
        return Row(
          children: [
            Text('Mobile Landscape Layout'),
            // Landscape-specific widgets
          ],
        );
      }
    } else if (info.isTablet) {
      // Similar tablet orientation checks
      // ...
    } else {
      // Desktop layout
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('Sidebar'),
          ),
          Expanded(
            flex: 4,
            child: Text('Main Content'),
          ),
          Expanded(
            flex: 1,
            child: Text('Additional Sidebar'),
          ),
        ],
      );
    }
  },
)
```

## 🧠 Understanding ResponsiveInfo

The `ResponsiveInfo` class now includes orientation information:

```dart
ResponsiveBuilder(
  builder: (context, info) {
    // Device type information
    print('Device type: ${info.deviceType}');
    
    // Orientation information
    print('Is portrait: ${info.isPortrait}');
    print('Is landscape: ${info.isLandscape}');
    print('Orientation: ${info.orientation}');
    
    // Device type properties
    print('Is mobile: ${info.isMobile}');
    print('Is tablet: ${info.isTablet}');
    print('Is desktop: ${info.isDesktop}');

    return Text('Device: ${info.deviceType}, Orientation: ${info.orientation}');
  },
)
```

## ⚙️ Customizing Settings

### Global Settings

```dart
// Change the global defaults
ResponsiveSettings.defaultSettings = ResponsiveSettings(
  mobileWidth: 480,    // Smaller mobile breakpoint
  tabletWidth: 1024,   // Standard tablet breakpoint
);
```

### Local Settings Override

You can override settings for specific widgets:

```dart
final myCustomSettings = ResponsiveSettings(
  mobileWidth: 400,
  tabletWidth: 800,
);

// Apply to a specific widget
ResponsiveChild(
  settings: myCustomSettings,
  child: Text('Custom breakpoints apply here'),
  // ...
)
```

## 📏 How Device Detection Works

Simple MediaQuery width-based detection:

| Device Type | Width Range |
|:---|:---|
| Mobile | < mobileWidth (default: 600px) |
| Tablet | >= mobileWidth && < tabletWidth |
| Desktop | >= tabletWidth (default: 1024px) |

Orientation is determined using MediaQuery:

```dart
final orientation = MediaQuery.of(context).orientation == Orientation.portrait
    ? ResponsiveOrientation.portrait
    : ResponsiveOrientation.landscape;
```

## 🏆 Example with Orientation Support

```dart
import 'package:flutter/material.dart';
import 'package:simple_responsive_layout/simple_responsive_layout.dart';

class OrientationAwareWidget extends StatelessWidget {
  const OrientationAwareWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        // Check both device type and orientation
        if (info.isMobile) {
          return ResponsiveOrientationChild(
            // Portrait layout for mobile
            portraitChild: (ctx, child) => Column(
              children: [
                Text('Mobile Portrait', 
                  style: TextStyle(fontSize: 20)),
                child,
              ],
            ),
            // Landscape layout for mobile
            landscapeChild: (ctx, child) => Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text('Mobile Landscape', 
                    style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  flex: 2,
                  child: child,
                ),
              ],
            ),
            // The content that will be placed in the layout
            child: Container(
              padding: ResponsiveOrientationValue<EdgeInsets>(
                defaultValue: EdgeInsets.all(16),
                portraitValue: EdgeInsets.all(24),
                landscapeValue: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              ).value(context),
              color: Colors.amber[200],
              child: Text('Content area'),
            ),
          );
        } else if (info.isTablet) {
          // Tablet layout with orientation handling
          // ...
        } else {
          // Desktop layout
          return Container(
            padding: EdgeInsets.all(32),
            color: Colors.purple[100],
            child: Text('Desktop Layout'),
          );
        }
      },
    );
  }
}
```

## 📄 License

MIT License.  
Free for personal and commercial use.

## ❤️ Why simple_responsive_layout?

- **No unnecessary complexity** - Lightweight yet powerful
- **Full control when you need it** - Override anything
- **Tiny package size** - No dependency bloat
- **Pure Flutter philosophy** - No extras required
- **Perfect for any project size** - From small apps to enterprise projects

## 🎯 Conclusion

> Simple. Clean. Powerful Flutter responsiveness.

## 📦 Coming soon

- AnimatedResponsive widgets for smooth transitions
- Additional responsive helpers (ResponsiveGridView, etc.)
- Media query shortcuts for more device metrics
- More orientation-specific widgets and utilities

## 🛡️ Status

✅ Production ready  
✅ No known issues  
✅ Backed by real-world Flutter projects

## 🙌 Contributing

If you like this package, ⭐️ star it on GitHub, share it, or contribute!
