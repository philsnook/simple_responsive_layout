import 'package:flutter/material.dart';

/// A provider widget that makes responsive settings available to the widget tree.
///
/// This InheritedWidget allows descendant widgets to access responsive settings
/// without passing them explicitly through constructors.
///
/// Usage:
/// ```dart
/// ResponsiveSettingsProvider(
///   settings: ResponsiveSettings(
///     mobileWidth: 550,
///     tabletWidth: 1200,
///   ),
///   child: MaterialApp(
///     home: HomePage(),
///   ),
/// )
/// ```
class ResponsiveSettingsProvider extends InheritedWidget {
  /// The responsive settings to be provided to descendant widgets.
  final ResponsiveSettingsBase settings;

  const ResponsiveSettingsProvider({
    super.key,
    required this.settings,
    required super.child,
  });

  /// Retrieves the [ResponsiveSettingsBase] from the closest [ResponsiveSettingsProvider]
  /// ancestor in the widget tree.
  ///
  /// Throws an exception if no [ResponsiveSettingsProvider] is found in the widget tree.
  static ResponsiveSettingsBase of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ResponsiveSettingsProvider>();
    if (provider == null) {
      throw Exception('ResponsiveSettingsProvider not found in context.');
    }
    return provider.settings;
  }

  @override
  bool updateShouldNotify(ResponsiveSettingsProvider oldWidget) {
    return settings != oldWidget.settings;
  }
}

/// Base class for responsive settings.
///
/// This abstract class defines the interface for responsive settings
/// implementations. Custom responsive settings classes should implement this.
abstract class ResponsiveSettingsBase {
  /// Returns responsive information based on the current context.
  ResponsiveInfo getResponsiveInfo(BuildContext context);
}

/// Enum representing different device types for responsive layouts.
///
/// Used to categorize devices as mobile, tablet, or desktop based on screen size.
enum ResponsiveDeviceType {
  /// Small screens (phones, small tablets)
  mobile,

  /// Medium screens (larger tablets, small laptops)
  tablet,

  /// Large screens (desktops, large laptops)
  desktop,
}

/// Default implementation of responsive settings.
///
/// Provides configurable width breakpoints to determine device types.
class ResponsiveSettings implements ResponsiveSettingsBase {
  /// Width threshold below which a device is considered mobile.
  final double mobileWidth;

  /// Width threshold below which a device is considered tablet.
  /// Devices with width >= [mobileWidth] and < [tabletWidth] are tablets.
  final double tabletWidth;

  /// Creates responsive settings with configurable breakpoints.
  ///
  /// [mobileWidth] - Width below which devices are considered mobile (default: 600)
  /// [tabletWidth] - Width below which devices are considered tablet (default: 1024)
  ResponsiveSettings({
    this.mobileWidth = 600,
    this.tabletWidth = 1024,
  });

  /// Creates a copy of this [ResponsiveSettings] with the given fields replaced.
  ResponsiveSettings copyWith({
    double? mobileWidth,
    double? tabletWidth,
  }) {
    return ResponsiveSettings(
      mobileWidth: mobileWidth ?? this.mobileWidth,
      tabletWidth: tabletWidth ?? this.tabletWidth,
    );
  }

  /// Default settings used when no specific settings are provided.
  static ResponsiveSettings defaultSettings = ResponsiveSettings();

  @override
  ResponsiveInfo getResponsiveInfo(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < mobileWidth;
    final isTablet = width >= mobileWidth && width < tabletWidth;
    final isDesktop = width >= tabletWidth;
    final orientation =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? ResponsiveOrientation.portrait
            : ResponsiveOrientation.landscape;
    return ResponsiveInfo(
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      orientation: orientation,
      deviceType: isMobile
          ? ResponsiveDeviceType.mobile
          : isTablet
              ? ResponsiveDeviceType.tablet
              : ResponsiveDeviceType.desktop,
    );
  }
}

enum ResponsiveOrientation { portrait, landscape }

/// Container for device type information and responsive flags.
///
/// Provides information about the current device type and flags
/// for checking if the device falls into specific categories.
class ResponsiveInfo {
  /// Whether the device should use mobile layouts.
  final bool isMobile;

  /// Whether the device should use tablet layouts.
  final bool isTablet;

  /// Whether the device should use desktop layouts.
  final bool isDesktop;

  /// The specific device type category (mobile, tablet, or desktop).
  final ResponsiveDeviceType deviceType;

  bool get isPortrait => orientation == ResponsiveOrientation.portrait;
  bool get isLandscape => orientation == ResponsiveOrientation.landscape;
  final ResponsiveOrientation orientation;

  /// Creates responsive information with device type flags.
  const ResponsiveInfo({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.deviceType,
    required this.orientation,
  });
}

/// Internal utility function to resolve settings from context or parameters.
///
/// First uses the provided [settings] if not null, otherwise tries to find
/// settings from [ResponsiveSettingsProvider] in the widget tree, and finally
/// falls back to [ResponsiveSettings.defaultSettings].
ResponsiveSettingsBase _resolveSettings(
  BuildContext context,
  ResponsiveSettingsBase? settings,
) {
  if (settings != null) return settings;
  final provider =
      context.dependOnInheritedWidgetOfExactType<ResponsiveSettingsProvider>();
  return provider?.settings ?? ResponsiveSettings.defaultSettings;
}

/// A widget that adapts its child layout based on the device type.
///
/// Allows specifying different wrapper layouts for mobile, tablet, and desktop
/// devices, or building a child dynamically based on device information.
///
/// Example:
/// ```dart
/// ResponsiveChild(
///   child: Text('Hello World'),
///   mobileChild: (context, child) => Center(child: child),
///   tabletChild: (context, child) => Align(alignment: Alignment.centerLeft, child: child),
///   desktopChild: (context, child) => Container(padding: EdgeInsets.all(16), child: child),
/// )
/// ```
class ResponsiveChild extends StatelessWidget {
  /// Builder function for default layout.
  /// Takes the build context and child widget and returns a wrapped widget.
  final Widget Function(BuildContext context, Widget child)? defaultChild;

  /// Builder function for mobile layout.
  /// Takes the build context and child widget and returns a wrapped widget.
  final Widget Function(BuildContext context, Widget child)? mobileChild;

  /// Builder function for tablet layout.
  /// Takes the build context and child widget and returns a wrapped widget.
  final Widget Function(BuildContext context, Widget child)? tabletChild;

  /// Builder function for desktop layout.
  /// Takes the build context and child widget and returns a wrapped widget.
  final Widget Function(BuildContext context, Widget child)? desktopChild;

  /// The child widget to be wrapped in device-specific layouts.
  /// If [childBuilder] is provided, this is ignored.
  final Widget? child;

  /// Dynamic builder function for the child widget based on responsive info.
  /// Takes precedence over [child] if provided.
  final Widget Function(BuildContext context, ResponsiveInfo info)?
      childBuilder;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Creates a responsive child widget.
  ///
  /// Either [child] or [childBuilder] should be provided.
  /// Device-specific wrappers can be specified with [mobileChild],
  /// [tabletChild], and [desktopChild].
  const ResponsiveChild({
    super.key,
    this.settings,
    this.child,
    this.childBuilder,
    this.defaultChild,
    this.mobileChild,
    this.tabletChild,
    this.desktopChild,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSettings = _resolveSettings(context, settings);
    final info = resolvedSettings.getResponsiveInfo(context);
    final childWidget =
        childBuilder?.call(context, info) ?? child ?? const SizedBox.shrink();

    return ResponsiveValue<Widget>(
      defaultValue: defaultChild?.call(context, childWidget) ?? childWidget,
      mobileValue: mobileChild?.call(context, childWidget),
      tabletValue: tabletChild?.call(context, childWidget),
      desktopValue: desktopChild?.call(context, childWidget),
      settings: settings,
    ).value(context);
  }
}

/// A widget that adapts its layout for a list of children based on device type.
///
/// Allows specifying different container layouts (like Row, Column, Grid) for
/// mobile, tablet, and desktop devices, or dynamically building the children
/// based on device information.
///
/// Example:
/// ```dart
/// ResponsiveLayout(
///   children: [Text('Item 1'), Text('Item 2')],
///   mobileChild: (context, children) => Column(children: children),
///   tabletChild: (context, children) => Row(children: children),
///   desktopChild: (context, children) => Wrap(children: children),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Builder function for default layout.
  /// Takes the build context and children list and returns a container widget.
  final Widget Function(BuildContext context, List<Widget> children)?
      defaultChild;

  /// Builder function for mobile layout.
  /// Takes the build context and children list and returns a container widget.
  final Widget Function(BuildContext context, List<Widget> children)?
      mobileChild;

  /// Builder function for tablet layout.
  /// Takes the build context and children list and returns a container widget.
  final Widget Function(BuildContext context, List<Widget> children)?
      tabletChild;

  /// Builder function for desktop layout.
  /// Takes the build context and children list and returns a container widget.
  final Widget Function(BuildContext context, List<Widget> children)?
      desktopChild;

  /// The list of children widgets to be arranged in device-specific layouts.
  /// If [childrenBuilder] is provided, this is ignored.
  final List<Widget>? children;

  /// Dynamic builder function for the children list based on responsive info.
  /// Takes precedence over [children] if provided.
  final List<Widget> Function(BuildContext context, ResponsiveInfo info)?
      childrenBuilder;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Creates a responsive layout widget.
  ///
  /// Either [children] or [childrenBuilder] should be provided.
  /// Device-specific layouts can be specified with [mobileChild],
  /// [tabletChild], and [desktopChild].
  const ResponsiveLayout({
    super.key,
    this.settings,
    this.children,
    this.childrenBuilder,
    this.defaultChild,
    this.mobileChild,
    this.tabletChild,
    this.desktopChild,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSettings = _resolveSettings(context, settings);
    final info = resolvedSettings.getResponsiveInfo(context);
    final childWidgets = childrenBuilder?.call(context, info) ?? children ?? [];

    return ResponsiveValue<Widget>(
      defaultValue: defaultChild?.call(context, childWidgets) ??
          Column(children: childWidgets),
      mobileValue: mobileChild?.call(context, childWidgets),
      tabletValue: tabletChild?.call(context, childWidgets),
      desktopValue: desktopChild?.call(context, childWidgets),
      settings: settings,
    ).value(context);
  }
}

/// A utility class for selecting values based on device type.
///
/// Allows specifying different values for different device types,
/// and automatically selects the appropriate value based on the current device.
///
/// Example:
/// ```dart
/// final fontSize = ResponsiveValue<double>(
///   defaultValue: 16.0,
///   mobileValue: 14.0,
///   tabletValue: 16.0,
///   desktopValue: 18.0,
/// ).value(context);
/// ```
class ResponsiveValue<T> {
  /// The value to use for mobile devices.
  final T? mobileValue;

  /// The value to use for tablet devices.
  final T? tabletValue;

  /// The value to use for desktop devices.
  final T? desktopValue;

  /// The fallback value to use when no device-specific value matches.
  final T defaultValue;

  /// Dynamic builder function for the value based on responsive info.
  /// Takes precedence over device-specific values if provided.
  final T Function(BuildContext context, ResponsiveInfo info)? valueBuilder;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Creates a responsive value selector.
  ///
  /// [defaultValue] is required and used as fallback when no device-specific
  /// value is provided for the current device type.
  ///
  /// Optional device-specific values can be provided with [mobileValue],
  /// [tabletValue], and [desktopValue].
  ///
  /// For full custom logic, [valueBuilder] can be used which takes precedence
  /// over the device-specific values.
  const ResponsiveValue({
    this.settings,
    required this.defaultValue,
    this.valueBuilder,
    this.mobileValue,
    this.tabletValue,
    this.desktopValue,
  });

  /// Returns the appropriate value for the current device.
  ///
  /// First tries [valueBuilder] if provided, then tries device-specific
  /// values ([mobileValue], [tabletValue], [desktopValue]), and finally
  /// falls back to [defaultValue].
  T value(BuildContext context) {
    final resolvedSettings = _resolveSettings(context, settings);
    final info = resolvedSettings.getResponsiveInfo(context);

    if (valueBuilder != null) return valueBuilder!(context, info);

    if (info.isDesktop && desktopValue != null) {
      return desktopValue!;
    }
    if (info.isTablet && tabletValue != null) {
      return tabletValue!;
    }
    if (info.isMobile && mobileValue != null) {
      return mobileValue!;
    }

    return defaultValue;
  }
}

/// A widget that is only visible on specific device types.
///
/// Shows or hides a widget based on whether the current device type
/// is included in the specified list of device types.
///
/// Example:
/// ```dart
/// ResponsiveVisibility(
///   deviceTypes: [ResponsiveDeviceType.mobile, ResponsiveDeviceType.tablet],
///   child: FloatingActionButton(
///     onPressed: () {},
///     child: Icon(Icons.add),
///   ),
/// )
/// ```
class ResponsiveVisibility extends StatelessWidget {
  /// List of device types on which the child should be visible.
  final List<ResponsiveDeviceType> deviceTypes;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// The widget to show or hide based on device type.
  final Widget child;

  /// Creates a responsive visibility widget.
  ///
  /// [deviceTypes] specifies which device types the [child] should be
  /// visible on. The [child] will be hidden on all other device types.
  const ResponsiveVisibility({
    super.key,
    this.settings,
    required this.deviceTypes,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSettings = _resolveSettings(context, settings);
    final info = resolvedSettings.getResponsiveInfo(context);
    if (deviceTypes.contains(info.deviceType)) {
      return child;
    }
    return const SizedBox.shrink();
  }
}

/// A sized box that adapts its size based on device type.
///
/// Allows specifying different sizes for different device types,
/// and automatically selects the appropriate size based on the current device.
///
/// Example:
/// ```dart
/// ResponsiveSizedBox(
///   mobileSize: Size(double.infinity, 8),
///   tabletSize: Size(double.infinity, 16),
///   desktopSize: Size(double.infinity, 24),
/// )
/// ```
class ResponsiveSizedBox extends StatelessWidget {
  /// The size to use for mobile devices.
  final Size? mobileSize;

  /// The size to use for tablet devices.
  final Size? tabletSize;

  /// The size to use for desktop devices.
  final Size? desktopSize;

  /// The fallback size to use when no device-specific size matches.
  final Size defaultSize;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Optional child widget to be placed inside the sized box.
  final Widget? child;

  /// Creates a responsive sized box.
  ///
  /// Device-specific sizes can be specified with [mobileSize],
  /// [tabletSize], and [desktopSize].
  ///
  /// [defaultSize] is used as fallback when no device-specific
  /// size is provided for the current device type.
  ///
  /// An optional [child] widget can be provided.
  const ResponsiveSizedBox({
    super.key,
    this.settings,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.defaultSize = Size.zero,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final childWidget = child ?? const SizedBox.shrink();
    return SizedBox(
      child: ResponsiveValue<SizedBox>(
        defaultValue: SizedBox.fromSize(size: defaultSize, child: childWidget),
        mobileValue: SizedBox.fromSize(
          size: mobileSize ?? defaultSize,
          child: childWidget,
        ),
        tabletValue: SizedBox.fromSize(
          size: tabletSize ?? defaultSize,
          child: childWidget,
        ),
        desktopValue: SizedBox.fromSize(
          size: desktopSize ?? defaultSize,
          child: childWidget,
        ),
        settings: settings,
      ).value(context),
    );
  }
}

/// A padding widget that adapts its padding based on device type.
///
/// Allows specifying different padding values for different device types,
/// and automatically selects the appropriate padding based on the current device.
///
/// Example:
/// ```dart
/// ResponsivePadding(
///   defaultSize: EdgeInsets.all(16),
///   mobileSize: EdgeInsets.all(8),
///   tabletSize: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
///   desktopSize: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
///   child: Card(...),
/// )
/// ```
class ResponsivePadding extends StatelessWidget {
  /// The padding to use for mobile devices.
  final EdgeInsets? mobileSize;

  /// The padding to use for tablet devices.
  final EdgeInsets? tabletSize;

  /// The padding to use for desktop devices.
  final EdgeInsets? desktopSize;

  /// The fallback padding to use when no device-specific padding matches.
  final EdgeInsets defaultSize;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Optional child widget to apply the padding to.
  final Widget? child;

  /// Creates a responsive padding widget.
  ///
  /// Device-specific padding can be specified with [mobileSize],
  /// [tabletSize], and [desktopSize].
  ///
  /// [defaultSize] is used as fallback when no device-specific
  /// padding is provided for the current device type.
  ///
  /// An optional [child] widget can be provided.
  const ResponsivePadding({
    super.key,
    this.settings,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.defaultSize = const EdgeInsets.all(0),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveValue<EdgeInsets>(
        defaultValue: defaultSize,
        mobileValue: mobileSize,
        tabletValue: tabletSize,
        desktopValue: desktopSize,
        settings: settings,
      ).value(context),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

/// A builder widget for fully custom responsive layouts.
///
/// Provides [ResponsiveInfo] to a builder function, allowing for
/// complete control over responsive behavior.
///
/// Example:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, info) {
///     if (info.isMobileOnly) {
///       return Text('Mobile layout');
///     } else if (info.isTabletOnly) {
///       return Text('Tablet layout');
///     } else {
///       return Text('Desktop layout');
///     }
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Builder function for creating a widget based on responsive info.
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Creates a responsive builder widget.
  ///
  /// [builder] is called with the current build context and responsive info,
  /// and should return a widget to be built.
  const ResponsiveBuilder({super.key, required this.builder, this.settings});

  @override
  Widget build(BuildContext context) {
    final resolvedSettings = _resolveSettings(context, settings);
    final info = resolvedSettings.getResponsiveInfo(context);
    return builder(context, info);
  }
}

/// A widget that adapts its child layout based on device orientation.
///
/// Allows specifying different wrappers for portrait and landscape modes,
/// or falling back to the provided child if no orientation-specific builder
/// is provided.
///
/// Example:
/// ```dart
/// ResponsiveOrientationChild(
///   child: Text('Hello World'),
///   portraitChild: (context, child) => Center(child: child),
///   landscapeChild: (context, child) => Row(children: [child]),
/// )
/// ```
class ResponsiveOrientationChild extends StatelessWidget {
  /// Builder function for portrait layout.
  final Widget Function(BuildContext context, Widget child)? portraitChild;

  /// Builder function for landscape layout.
  final Widget Function(BuildContext context, Widget child)? landscapeChild;

  /// The base child widget to be wrapped in orientation-specific layouts.
  final Widget? child;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Creates an orientation-based child widget.
  ///
  /// [child] provides the base widget, while [portraitChild] and [landscapeChild]
  /// allow customizing its layout depending on device orientation.
  const ResponsiveOrientationChild({
    super.key,
    this.portraitChild,
    this.landscapeChild,
    this.child,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final childWidget = child ?? const SizedBox.shrink();
    final info = (settings ?? ResponsiveSettings.defaultSettings)
        .getResponsiveInfo(context);

    return (info.isPortrait ? portraitChild : landscapeChild)
            ?.call(context, childWidget) ??
        childWidget;
  }
}

/// A utility class for selecting values based on device orientation.
///
/// Allows specifying different values for portrait and landscape modes,
/// and automatically selects the appropriate value based on the current orientation.
///
/// Example:
/// ```dart
/// final padding = ResponsiveOrientationValue<EdgeInsets>(
///   defaultValue: EdgeInsets.all(16),
///   portraitValue: EdgeInsets.all(8),
///   landscapeValue: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
/// ).value(context);
/// ```
class ResponsiveOrientationValue<T> {
  /// The value to use for portrait orientation.
  final T? portraitValue;

  /// The value to use for landscape orientation.
  final T? landscapeValue;

  /// The fallback value to use when no orientation-specific value matches.
  final T defaultValue;

  /// Optional responsive settings to override those from context.
  final ResponsiveSettingsBase? settings;

  /// Creates an orientation-based value selector.
  ///
  /// [defaultValue] is required and used when no specific orientation value is provided.
  /// [portraitValue] and [landscapeValue] can be provided to override values
  /// for specific orientations.
  const ResponsiveOrientationValue({
    required this.defaultValue,
    this.portraitValue,
    this.landscapeValue,
    this.settings,
  });

  /// Returns the appropriate value for the current device orientation.
  ///
  /// Uses [portraitValue] or [landscapeValue] if provided,
  /// otherwise falls back to [defaultValue].
  T value(BuildContext context) {
    final info = (settings ?? ResponsiveSettings.defaultSettings)
        .getResponsiveInfo(context);

    return info.isPortrait
        ? (portraitValue ?? defaultValue)
        : (landscapeValue ?? defaultValue);
  }
}
