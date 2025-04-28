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
        settings: ResponsiveSettings(
          mobileWidth: 600,
          tabletWidth: 1200,
          // inclusiveBreakpoints: false,
        ),
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
                mobileChild: (context, children) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
                tabletChild: (context, children) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
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
