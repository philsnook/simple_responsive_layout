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
- ⚙️ **ResponsiveSettings** – Customize breakpoints and cascading behavior
- 🔄 **ResponsiveInfo** – Complete device information with helpful properties
- ❌ **Zero dependencies** — pure Flutter implementation
- ⚡ **Extremely lightweight and fast**

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  simple_responsive_layout: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🛠️ Usage

### Basic Setup (Optional)

While the package works with default settings, you can customize breakpoints globally:

```dart
void main() {
  // Optional: Configure global responsive settings
  ResponsiveSettings.defaultSettings = ResponsiveSettings(
    mobileWidth: 600,     // breakpoint between mobile and tablet
    tabletWidth: 1024,    // breakpoint between tablet and desktop
    inclusiveBreakpoints: true,  // cascading behavior (default)
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

### ResponsiveBuilder

For complete custom control:

```dart
ResponsiveBuilder(
  builder: (context, info) {
    // Full access to device info for custom layouts
    if (info.isMobileOnly) {
      return ListView(
        children: [
          Text('Mobile Layout'),
          // Mobile-specific widgets
        ],
      );
    } else if (info.isTabletOnly) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('Sidebar'),
          ),
          Expanded(
            flex: 3,
            child: Text('Main Content'),
          ),
        ],
      );
    } else {
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

The `ResponsiveInfo` class gives you complete information about the current device:

```dart
ResponsiveBuilder(
  builder: (context, info) {
    // Direct device type
    print('Device type: ${info.deviceType}');
    
    // Equality checks
    if (info.deviceType == ResponsiveDeviceType.mobile) {
      // Do something
    }
    
    // Inclusive properties (with cascading behavior)
    print('Is mobile (inclusive): ${info.isMobile}');
    print('Is tablet (inclusive): ${info.isTablet}');
    print('Is desktop (inclusive): ${info.isDesktop}');
    
    // Exclusive properties (specific device only)
    print('Is mobile only: ${info.isMobileOnly}');
    print('Is tablet only: ${info.isTabletOnly}');
    print('Is desktop only: ${info.isDesktopOnly}');
    
    return Text('Device type: ${info.deviceType}');
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
  inclusiveBreakpoints: true,  // Cascading behavior
);
```

### Local Settings Override

You can override settings for specific widgets:

```dart
final myCustomSettings = ResponsiveSettings(
  mobileWidth: 400,
  tabletWidth: 800,
  inclusiveBreakpoints: false, // No cascading behavior
);

// Apply to a specific widget
ResponsiveChild(
  settings: myCustomSettings,
  child: Text('Custom breakpoints apply here'),
  // ...
)
```

### Cascading Behavior Explained

With `inclusiveBreakpoints: true` (default):
- `isMobile` = true for mobile devices
- `isTablet` = true for tablet AND mobile devices
- `isDesktop` = true for desktop AND tablet AND mobile devices

With `inclusiveBreakpoints: false`:
- `isMobile` = true ONLY for mobile devices
- `isTablet` = true ONLY for tablet devices
- `isDesktop` = true ONLY for desktop devices

For specific device types only, use:
- `isMobileOnly` - Always true only on mobile
- `isTabletOnly` - Always true only on tablet
- `isDesktopOnly` - Always true only on desktop

## 📏 How Device Detection Works

Simple MediaQuery width-based detection:

| Device Type | Width Range |
|:---|:---|
| Mobile | < mobileWidth (default: 600px) |
| Tablet | >= mobileWidth && < tabletWidth |
| Desktop | >= tabletWidth (default: 1024px) |

## 🏆 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:simple_responsive_layout/simple_responsive_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSettingsProvider(
      settings: ResponsiveSettings(
        mobileWidth: 600,
        tabletWidth: 1024,
        inclusiveBreakpoints: true,
      ),
      child: MaterialApp(
        title: 'Responsive App Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Demo'),
      ),
      body: ResponsivePadding(
        mobileSize: const EdgeInsets.all(8),
        tabletSize: const EdgeInsets.all(16),
        desktopSize: const EdgeInsets.all(24),
        child: ResponsiveBuilder(
          builder: (context, info) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current device type: ${info.deviceType}',
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      defaultValue: 16,
                      mobileValue: 16,
                      tabletValue: 20,
                      desktopValue: 24,
                    ).value(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ResponsiveLayout(
                  children: [
                    _buildCard('Item 1', Colors.red.shade100),
                    _buildCard('Item 2', Colors.green.shade100),
                    _buildCard('Item 3', Colors.blue.shade100),
                  ],
                  mobileChild: (context, children) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                  tabletChild: (context, children) => Row(
                    children: children.map((child) => Expanded(child: child)).toList(),
                  ),
                  desktopChild: (context, children) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children.map((child) => Expanded(child: child)).toList(),
                  ),
                ),
                ResponsiveSizedBox(
                  mobileSize: const Size(double.infinity, 24),
                  tabletSize: const Size(double.infinity, 32),
                  desktopSize: const Size(double.infinity, 48),
                ),
                ResponsiveVisibility(
                  deviceTypes: [ResponsiveDeviceType.mobile],
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Mobile-Only Button'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This card adjusts its layout based on device size'),
          ],
        ),
      ),
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

- Better orientation support (portrait/landscape)
- AnimatedResponsive widgets for smooth transitions
- Additional responsive helpers (ResponsiveGridView, etc.)
- Media query shortcuts for more device metrics
- Orientation-specific overrides (landscape/portrait)

## 🛡️ Status

✅ Production ready  
✅ No known issues  
✅ Backed by real-world Flutter projects

## 🙌 Contributing

If you like this package, ⭐️ star it on GitHub, share it, or contribute!
