import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synced_page_views/synced_page_views.dart';

void main() {
  group('SyncedPageViews', () {
    testWidgets('should render primary and secondary pages', (WidgetTester tester) async {
      final primaryPages = [
        const Text('Primary 1'),
        const Text('Primary 2'),
      ];
      
      final secondaryPages = [
        const Text('Secondary 1'),
        const Text('Secondary 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncedPageViews(
              primaryPages: primaryPages,
              secondaryPages: secondaryPages,
            ),
          ),
        ),
      );

      expect(find.text('Primary 1'), findsOneWidget);
      expect(find.text('Secondary 1'), findsOneWidget);
    });

    testWidgets('should call onPageChanged when page changes', (WidgetTester tester) async {
      int? changedToPage;
      
      final primaryPages = List.generate(3, (i) => Container(key: Key('primary_$i')));
      final secondaryPages = List.generate(3, (i) => Container(key: Key('secondary_$i')));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncedPageViews(
              primaryPages: primaryPages,
              secondaryPages: secondaryPages,
              onPageChanged: (index) {
                changedToPage = index;
              },
            ),
          ),
        ),
      );

      // Simulate page change by dragging
      await tester.drag(find.byType(PageView).first, const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(changedToPage, 1);
    });

    testWidgets('should handle tap on secondary page', (WidgetTester tester) async {
      int? tappedIndex;
      
      final primaryPages = List.generate(3, (i) => Container(key: Key('primary_$i')));
      final secondaryPages = List.generate(3, (i) => 
        Container(key: Key('secondary_$i'), child: Text('Tap $i')));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncedPageViews(
              primaryPages: primaryPages,
              secondaryPages: secondaryPages,
              onSecondaryPageTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap 0'));
      await tester.pump();

      expect(tappedIndex, 0);
    });
  });

  group('SyncedPageViewsConfig', () {
    test('should have default values', () {
      const config = SyncedPageViewsConfig();
      
      expect(config.animationDuration, const Duration(milliseconds: 300));
      expect(config.animationCurve, Curves.easeInOut);
      expect(config.scrollDirection, Axis.horizontal);
      expect(config.pageSnapping, true);
      expect(config.reverse, false);
    });

    test('should accept custom values', () {
      const config = SyncedPageViewsConfig(
        animationDuration: Duration(milliseconds: 500),
        animationCurve: Curves.bounceIn,
        scrollDirection: Axis.vertical,
        pageSnapping: false,
        reverse: true,
      );
      
      expect(config.animationDuration, const Duration(milliseconds: 500));
      expect(config.animationCurve, Curves.bounceIn);
      expect(config.scrollDirection, Axis.vertical);
      expect(config.pageSnapping, false);
      expect(config.reverse, true);
    });
  });

  group('SyncedPageViewsData', () {
    test('should initialize with controllers and notifiers', () {
      final primaryController = PageController();
      final secondaryController = PageController();
      final isScrolling = ValueNotifier<bool>(false);
      final currentPage = ValueNotifier<int>(0);

      final data = SyncedPageViewsData(
        primaryController: primaryController,
        secondaryController: secondaryController,
        isScrolling: isScrolling,
        currentPage: currentPage,
      );

      expect(data.primaryController, primaryController);
      expect(data.secondaryController, secondaryController);
      expect(data.isScrolling, isScrolling);
      expect(data.currentPage, currentPage);
      expect(data.currentPageIndex, 0);

      data.dispose();
    });
  });

  group('SyncedPageController', () {
    test('should initialize with default values', () {
      final controller = SyncedPageController();
      
      expect(controller.currentPageIndex, 0);
      expect(controller.primaryController, isA<PageController>());
      expect(controller.secondaryController, isA<PageController>());
      expect(controller.currentPage, isA<ValueNotifier<int>>());
      
      controller.dispose();
    });

    test('should initialize with custom values', () {
      final controller = SyncedPageController(
        initialPage: 2,
        primaryViewportFraction: 0.8,
        secondaryViewportFraction: 0.3,
      );
      
      expect(controller.currentPageIndex, 2);
      
      controller.dispose();
    });
  });
}
