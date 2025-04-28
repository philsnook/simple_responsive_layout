# Changelog

## 1.0.0

- Initial release
- Support for simple mobile, tablet, and desktop responsive layouts
- Includes:
  - `ResponsiveChild`
  - `ResponsiveLayout`
  - `ResponsiveValue`
  - `ResponsiveVisibility`
  - `ResponsiveBuilder`
  - `ResponsivePadding`
  - `ResponsiveSizedBox`
  - `ResponsiveSettingsProvider`
- Allows custom breakpoints
- Lightweight, zero dependencies beyond Flutter

# 1.0.1
- Introduced a defaultChild parameter in the ResponsiveLayout widget to provide a fallback widget when no matching breakpoint is found.

# 1.0.2
- Introduced a defaultChild parameter in the ResponsiveChild widget to provide a fallback widget when no matching breakpoint is found.

# 1.0.3
- Removed the inclusiveBreakpoints parameter from the ResponsiveLayout widget. This parameter was causing confusion and was not necessary for the intended functionality of the widget. Let's keep things simple!
- The ResponsiveChild widget no longer requires a child to be passed. If no child is provided, the widget will simply return an empty container. This change makes the widget more flexible and easier to use in various scenarios.

## 1.1.0
- Added ResponsiveOrientationChild and ResponsiveOrientationValue.
- Simple orientation-based layouts and values (portrait/landscape support).
- No breaking changes.