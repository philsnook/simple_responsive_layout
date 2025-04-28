import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_responsive_layout/simple_responsive_layout.dart';

void main() {
  group('ResponsiveSettings', () {
    testWidgets('Uses settings provided in ResponsiveSettingsProvider', (
      tester,
    ) async {
      final customSettings = ResponsiveSettings(mobileWidth: 400);

      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveSettingsProvider(
            settings: customSettings,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 800),
              ), // Mobile based on custom settings
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      final info = ResponsiveSettingsProvider.of(
        testContext,
      ).getResponsiveInfo(testContext);
      expect(info.isMobile, true);
    });

    testWidgets('Uses settings provided directly to widget', (tester) async {
      final customSettings = ResponsiveSettings(mobileWidth: 400);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 800),
            ), // Mobile based on custom settings
            child: ResponsiveChild(
              settings: customSettings,
              child: const Text('Test'),
              mobileChild: (context, child) => const Text('Mobile'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });

    testWidgets('Falls back to default settings if none provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(500, 800),
            ), // Mobile according to default
            child: ResponsiveChild(
              child: const Text('Test Default'),
              mobileChild: (context, child) => const Text('Mobile Default'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Default'), findsOneWidget);
    });
    testWidgets('Default breakpoints classify devices correctly', (
      tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)), // Mobile
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final settings = ResponsiveSettings();

      expect(
        settings.getResponsiveInfo(testContext).deviceType,
        ResponsiveDeviceType.mobile,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)), // Tablet
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(
        settings.getResponsiveInfo(testContext).deviceType,
        ResponsiveDeviceType.tablet,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)), // Desktop
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(
        settings.getResponsiveInfo(testContext).deviceType,
        ResponsiveDeviceType.desktop,
      );
    });

    testWidgets('breakpoints work correctly', (tester) async {
      final settings = ResponsiveSettings();
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)), // Mobile
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final mobileInfo = settings.getResponsiveInfo(testContext);
      expect(mobileInfo.isMobile, true);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)), // Tablet
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final tabletInfo = settings.getResponsiveInfo(testContext);
      expect(tabletInfo.isTablet, true);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)), // Desktop
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final desktopInfo = settings.getResponsiveInfo(testContext);
      expect(desktopInfo.isDesktop, true);
    });

    testWidgets('ResponsiveBuilder builds different layouts based on device',
        (tester) async {
      late Widget builtWidget;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)), // Mobile
            child: ResponsiveBuilder(
              builder: (context, info) {
                builtWidget = Text(info.deviceType.name);
                return builtWidget;
              },
            ),
          ),
        ),
      );

      expect(find.byWidget(builtWidget), findsOneWidget);
    });
  });

  group('ResponsiveChild', () {
    testWidgets('ResponsiveChild switches widget based on device',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)), // Mobile size
            child: ResponsiveChild(
              child: const Text('Default'),
              mobileChild: (context, child) => const Text('Mobile'),
              tabletChild: (context, child) => const Text('Tablet'),
              desktopChild: (context, child) => const Text('Desktop'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(); // <- Important to let layout complete

      expect(find.text('Mobile'), findsOneWidget); // Should now pass!
    });
    testWidgets(
      'ResponsiveChild falls back to child when no device-specific widget',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(size: Size(1300, 800)), // Desktop
              child: ResponsiveChild(child: Text('Default Child')),
            ),
          ),
        );

        expect(find.text('Default Child'), findsOneWidget);
      },
    );
  });

  group('ResponsiveValue', () {
    testWidgets('ResponsiveValue returns correct value', (tester) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)), // Tablet
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final value = const ResponsiveValue<String>(
        defaultValue: 'Default',
        mobileValue: 'Mobile',
        tabletValue: 'Tablet',
        desktopValue: 'Desktop',
      ).value(testContext);

      expect(value, 'Tablet');
    });

    testWidgets('ResponsiveValue uses valueBuilder when provided', (
      tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(300, 800)), // Mobile
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final value = ResponsiveValue<String>(
        defaultValue: 'Default',
        valueBuilder: (context, info) =>
            info.isMobile ? 'Custom Mobile' : 'Other',
      ).value(testContext);

      expect(value, 'Custom Mobile');
    });
  });

  group('ResponsiveVisibility', () {
    testWidgets('ResponsiveVisibility shows only for specified device types', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(500, 800)), // Mobile
            child: ResponsiveVisibility(
              deviceTypes: [ResponsiveDeviceType.mobile],
              child: Text('Visible'),
            ),
          ),
        ),
      );
      expect(find.text('Visible'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1200, 800)), // Desktop
            child: ResponsiveVisibility(
              deviceTypes: [ResponsiveDeviceType.mobile],
              child: Text('Visible'),
            ),
          ),
        ),
      );
      expect(find.text('Visible'), findsNothing);
    });
  });

  group('ResponsivePadding', () {
    testWidgets('ResponsivePadding applies correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
                size: Size(500, 800)), // Mobile width (<600)
            child: ResponsivePadding(
              mobileSize: const EdgeInsets.all(10),
              tabletSize: const EdgeInsets.all(20),
              desktopSize: const EdgeInsets.all(30),
              child: Container(width: 100, height: 100, color: Colors.red),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(); // <- Ensure layout completes

      final paddingWidget = tester.widget<Padding>(find.byType(Padding));
      expect(
          paddingWidget.padding, const EdgeInsets.all(10)); // Should now match
    });
  });

  group('ResponsiveSizedBox', () {
    testWidgets('ResponsiveSizedBox applies correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1300, 800)), // Desktop
            child: ResponsiveSizedBox(
              mobileSize: const Size(50, 50),
              tabletSize: const Size(100, 100),
              desktopSize: const Size(200, 200),
              child: Container(color: Colors.blue),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));

      final sizedBoxWidget = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byWidget(container),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBoxWidget.width, 200);
      expect(sizedBoxWidget.height, 200);
    });
  });
  group('Orientation Features', () {
    group('ResponsiveOrientationChild', () {
      testWidgets('Renders portrait child in portrait orientation',
          (tester) async {
        // Set up portrait orientation (height > width means portrait)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: ResponsiveOrientationChild(
                child: const Text('Default Child'),
                portraitChild: (context, child) =>
                    Text('Portrait: ${(child as Text).data}'),
                landscapeChild: (context, child) =>
                    Text('Landscape: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        expect(find.text('Portrait: Default Child'), findsOneWidget);
        expect(find.text('Landscape: Default Child'), findsNothing);
      });

      testWidgets('Renders landscape child in landscape orientation',
          (tester) async {
        // Set up landscape orientation (width > height means landscape)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 400),
              ),
              child: ResponsiveOrientationChild(
                child: const Text('Default Child'),
                portraitChild: (context, child) =>
                    Text('Portrait: ${(child as Text).data}'),
                landscapeChild: (context, child) =>
                    Text('Landscape: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        expect(find.text('Landscape: Default Child'), findsOneWidget);
        expect(find.text('Portrait: Default Child'), findsNothing);
      });

      testWidgets(
          'Falls back to child when no orientation-specific child provided',
          (tester) async {
        // Portrait with no portraitChild
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: ResponsiveOrientationChild(
                child: const Text('Default Child'),
                // No portraitChild provided
                landscapeChild: (context, child) =>
                    Text('Landscape: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        expect(find.text('Default Child'), findsOneWidget);

        // Landscape with no landscapeChild
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 400),
              ),
              child: ResponsiveOrientationChild(
                child: const Text('Default Child'),
                portraitChild: (context, child) =>
                    Text('Portrait: ${(child as Text).data}'),
                // No landscapeChild provided
              ),
            ),
          ),
        );

        expect(find.text('Default Child'), findsOneWidget);
      });

      testWidgets('Works with custom ResponsiveSettings', (tester) async {
        final customSettings = ResponsiveSettings(
          mobileWidth: 400,
          tabletWidth: 800,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: ResponsiveOrientationChild(
                settings: customSettings,
                child: const Text('Default Child'),
                portraitChild: (context, child) =>
                    Text('Portrait: ${(child as Text).data}'),
                landscapeChild: (context, child) =>
                    Text('Landscape: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        expect(find.text('Portrait: Default Child'), findsOneWidget);
      });
    });

    group('ResponsiveOrientationValue', () {
      testWidgets('Returns portrait value in portrait orientation',
          (tester) async {
        late BuildContext testContext;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        final value = const ResponsiveOrientationValue<String>(
          defaultValue: 'Default',
          portraitValue: 'Portrait Value',
          landscapeValue: 'Landscape Value',
        ).value(testContext);

        expect(value, 'Portrait Value');
      });

      testWidgets('Returns landscape value in landscape orientation',
          (tester) async {
        late BuildContext testContext;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 400),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        final value = const ResponsiveOrientationValue<String>(
          defaultValue: 'Default',
          portraitValue: 'Portrait Value',
          landscapeValue: 'Landscape Value',
        ).value(testContext);

        expect(value, 'Landscape Value');
      });

      testWidgets(
          'Falls back to defaultValue when no orientation-specific value provided',
          (tester) async {
        late BuildContext testContext;

        // Portrait with no portraitValue
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        final portraitValue = const ResponsiveOrientationValue<String>(
          defaultValue: 'Default',
          // No portraitValue
          landscapeValue: 'Landscape Value',
        ).value(testContext);

        expect(portraitValue, 'Default');

        // Landscape with no landscapeValue
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 400),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        final landscapeValue = const ResponsiveOrientationValue<String>(
          defaultValue: 'Default',
          portraitValue: 'Portrait Value',
          // No landscapeValue
        ).value(testContext);

        expect(landscapeValue, 'Default');
      });

      testWidgets('Works with custom ResponsiveSettings', (tester) async {
        late BuildContext testContext;
        final customSettings = ResponsiveSettings(
          mobileWidth: 400,
          tabletWidth: 800,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        final value = ResponsiveOrientationValue<String>(
          settings: customSettings,
          defaultValue: 'Default',
          portraitValue: 'Portrait Value',
          landscapeValue: 'Landscape Value',
        ).value(testContext);

        expect(value, 'Portrait Value');
      });
    });

    group('ResponsiveInfo Orientation Properties', () {
      testWidgets('Reports correct orientation information', (tester) async {
        late BuildContext testContext;
        late ResponsiveInfo info;

        // Test portrait
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        info = ResponsiveSettings().getResponsiveInfo(testContext);
        expect(info.orientation, ResponsiveOrientation.portrait);
        expect(info.isPortrait, true);
        expect(info.isLandscape, false);

        // Test landscape (width > height means landscape)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 400),
              ),
              child: Builder(
                builder: (context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        info = ResponsiveSettings().getResponsiveInfo(testContext);
        expect(info.orientation, ResponsiveOrientation.landscape);
        expect(info.isPortrait, false);
        expect(info.isLandscape, true);
      });
    });

    group('Combined Device and Orientation Tests', () {
      testWidgets('Can combine ResponsiveChild with ResponsiveOrientationChild',
          (tester) async {
        // Test mobile & portrait
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
              ),
              child: ResponsiveChild(
                child: const Text('Base Child'),
                mobileChild: (context, child) => ResponsiveOrientationChild(
                  child: child,
                  portraitChild: (ctx, c) =>
                      Text('Mobile Portrait: ${(c as Text).data}'),
                  landscapeChild: (ctx, c) =>
                      Text('Mobile Landscape: ${(c as Text).data}'),
                ),
                desktopChild: (context, child) =>
                    Text('Desktop: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        expect(find.text('Mobile Portrait: Base Child'), findsOneWidget);

        // Test tablet with landscape - need to use tablet dimensions that are larger than mobile breakpoint
        // but smaller than desktop breakpoint, with width > height for landscape
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 500), // Tablet size in landscape
              ),
              child: ResponsiveChild(
                child: const Text('Base Child'),
                mobileChild: (context, child) => ResponsiveOrientationChild(
                  child: child,
                  portraitChild: (ctx, c) =>
                      Text('Mobile Portrait: ${(c as Text).data}'),
                  landscapeChild: (ctx, c) =>
                      Text('Mobile Landscape: ${(c as Text).data}'),
                ),
                tabletChild: (context, child) => ResponsiveOrientationChild(
                  child: child,
                  portraitChild: (ctx, c) =>
                      Text('Tablet Portrait: ${(c as Text).data}'),
                  landscapeChild: (ctx, c) =>
                      Text('Tablet Landscape: ${(c as Text).data}'),
                ),
                desktopChild: (context, child) =>
                    Text('Desktop: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        await tester.pump(); // Make sure the UI updates
        expect(find.text('Tablet Landscape: Base Child'), findsOneWidget);

        // Test desktop (should not use orientation child)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1200, 800),
              ),
              child: ResponsiveChild(
                child: const Text('Base Child'),
                mobileChild: (context, child) => ResponsiveOrientationChild(
                  child: child,
                  portraitChild: (ctx, c) =>
                      Text('Mobile Portrait: ${(c as Text).data}'),
                  landscapeChild: (ctx, c) =>
                      Text('Mobile Landscape: ${(c as Text).data}'),
                ),
                desktopChild: (context, child) =>
                    Text('Desktop: ${(child as Text).data}'),
              ),
            ),
          ),
        );

        await tester.pump(); // Make sure the UI updates
        expect(find.text('Desktop: Base Child'), findsOneWidget);
      });

      testWidgets('ResponsiveValue can use ResponsiveOrientationValue',
          (tester) async {
        // We need to use explicit settings to ensure predictable breakpoints
        final testSettings = ResponsiveSettings(
          mobileWidth: 500, // Width below 500 is mobile
          tabletWidth: 1000, // Width 500-999 is tablet, 1000+ is desktop
        );

        // Mobile & Portrait - using width 400 (< 500 = mobile)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800), // Mobile size in portrait
              ),
              child: Builder(
                builder: (context) {
                  // Use the settings directly in both responsive values
                  final fontSize = ResponsiveValue<double>(
                    settings: testSettings,
                    defaultValue: 16.0,
                    mobileValue: ResponsiveOrientationValue<double>(
                      settings: testSettings,
                      defaultValue: 14.0,
                      portraitValue: 12.0,
                      landscapeValue: 10.0,
                    ).value(context),
                    tabletValue: 18.0,
                    desktopValue: 20.0,
                  ).value(context);

                  return Text('Size: $fontSize',
                      style: TextStyle(fontSize: fontSize));
                },
              ),
            ),
          ),
        );

        expect(find.text('Size: 12.0'), findsOneWidget);

        // Mobile & Landscape - using width 480, height 300 (< 500 = mobile)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(480, 300), // Mobile size in landscape
              ),
              child: Builder(
                builder: (context) {
                  // Use the settings directly in both responsive values
                  final fontSize = ResponsiveValue<double>(
                    settings: testSettings,
                    defaultValue: 16.0,
                    mobileValue: ResponsiveOrientationValue<double>(
                      settings: testSettings,
                      defaultValue: 14.0,
                      portraitValue: 12.0,
                      landscapeValue: 10.0,
                    ).value(context),
                    tabletValue: 18.0,
                    desktopValue: 20.0,
                  ).value(context);

                  return Text('Size: $fontSize',
                      style: TextStyle(fontSize: fontSize));
                },
              ),
            ),
          ),
        );

        expect(find.text('Size: 10.0'), findsOneWidget);
      });

      testWidgets(
          'ResponsiveBuilder can handle both device type and orientation',
          (tester) async {
        // Using explicit settings to ensure predictable breakpoints
        final testSettings = ResponsiveSettings(
          mobileWidth: 500, // Width below 500 is mobile
          tabletWidth: 1000, // Width 500-999 is tablet, 1000+ is desktop
        );

        // Mobile & Portrait
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800), // Mobile portrait
              ),
              child: ResponsiveBuilder(
                settings: testSettings,
                builder: (context, info) {
                  if (info.isMobile) {
                    if (info.isPortrait) {
                      return const Text('Mobile Portrait');
                    } else {
                      return const Text('Mobile Landscape');
                    }
                  } else if (info.isTablet) {
                    return const Text('Tablet');
                  } else {
                    return const Text('Desktop');
                  }
                },
              ),
            ),
          ),
        );

        expect(find.text('Mobile Portrait'), findsOneWidget);

        // Mobile & Landscape
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(480, 300), // Mobile landscape
              ),
              child: ResponsiveBuilder(
                settings: testSettings,
                builder: (context, info) {
                  if (info.isMobile) {
                    if (info.isPortrait) {
                      return const Text('Mobile Portrait');
                    } else {
                      return const Text('Mobile Landscape');
                    }
                  } else if (info.isTablet) {
                    return const Text('Tablet');
                  } else {
                    return const Text('Desktop');
                  }
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Mobile Landscape'), findsOneWidget);
      });
    });
  });
}
