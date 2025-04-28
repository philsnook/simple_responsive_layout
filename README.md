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
- ⚙️ **ResponsiveSettings** – Customize breakpoints
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
    
    // Properties
    print('Is mobile: ${info.isMobile}');
    print('Is tablet: ${info.isTablet}');
    print('Is desktop: ${info.isDesktop}');

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

## 🏆 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:simple_responsive_layout/simple_responsive_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Responsive Layout Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ResponsiveSettingsProvider(
        // Optional - Use ResponsiveSettingsProvider to provide the breakpoints to the widget tree
        settings: ResponsiveSettings(mobileWidth: 600, tabletWidth: 1200),
        child: const ResponsiveHomePage(),
      ),
    );
  }
}

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        // Use ResponsiveValue to set the background color based on device type
        color: ResponsiveValue<Color>(
          defaultValue: Colors.grey,
          mobileValue: Colors.blue.shade300,
          tabletValue: Colors.green.shade300,
          desktopValue: Colors.purple.shade300,
        ).value(context),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Use ResponsiveBuilder to get the device type and display it
              ResponsiveBuilder(
                builder: (context, info) {
                  return Text(
                    'Device Type: ${info.deviceType.name.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ResponsiveLayout(
                defaultChild: (context, children) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                ),
                tabletChild: (context, children) =>
                    Center(child: Wrap(children: children)),
                desktopChild: (context, children) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: children,
                ),
                children: const [
                  BoxWidget(label: 'Box 1'),
                  BoxWidget(label: 'Box 2'),
                  BoxWidget(label: 'Box 3'),
                ],
              ),
              //Mobile only widget
              const ResponsiveVisibility(
                deviceTypes: [ResponsiveDeviceType.mobile],
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "This text is only visible on mobile",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoxWidget extends StatelessWidget {
  final String label;
  const BoxWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ResponsiveSizedBox(
        mobileSize: const Size(120, 120),
        tabletSize: const Size(170, 170),
        desktopSize: const Size(220, 220),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              // Use ResponsiveValue to set the font size in a text style based on device type
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: const ResponsiveValue<double>(
                  defaultValue: 12,
                  mobileValue: 40,
                  tabletValue: 18,
                  desktopValue: 25,
                ).value(context),
              ),
            ),
            ResponsiveVisibility(
              // Use ResponsiveVisibility to show/hide widgets based on device type
              deviceTypes: const [
                ResponsiveDeviceType.tablet,
                ResponsiveDeviceType.desktop,
              ],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "This is only visible on desktop and tablet - larger text on desktop.",
                  textAlign: TextAlign.center,
                  // Use ResponsiveValue to set an entire text style based on device type
                  style: const ResponsiveValue(
                    defaultValue: TextStyle(fontSize: 14),
                    desktopValue: TextStyle(fontSize: 20),
                  ).value(context),
                ),
              ),
            ),
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
