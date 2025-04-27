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
      expect(info.isMobileOnly, true);
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

    testWidgets('Non-inclusive breakpoints work correctly', (tester) async {
      final settings = ResponsiveSettings(inclusiveBreakpoints: false);
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
      expect(mobileInfo.isMobileOnly, true);

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
      expect(tabletInfo.isTabletOnly, true);

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
      expect(desktopInfo.isDesktopOnly, true);
    });
  });

  group('ResponsiveChild', () {
    testWidgets('ResponsiveChild switches widget based on device', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)), // Mobile
            child: ResponsiveChild(
              child: const Text('Default'),
              mobileChild: (context, child) => const Text('Mobile'),
              tabletChild: (context, child) => const Text('Tablet'),
              desktopChild: (context, child) => const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
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
            info.isMobileOnly ? 'Custom Mobile' : 'Other',
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
            data: const MediaQueryData(size: Size(500, 800)), // Mobile
            child: ResponsivePadding(
              mobileSize: const EdgeInsets.all(10),
              tabletSize: const EdgeInsets.all(20),
              desktopSize: const EdgeInsets.all(30),
              child: Container(width: 100, height: 100, color: Colors.red),
            ),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding));
      expect(paddingWidget.padding, const EdgeInsets.all(10));
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
}
