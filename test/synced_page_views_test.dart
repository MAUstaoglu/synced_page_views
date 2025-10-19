import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synced_page_views/synced_page_views.dart';

void main() {
  group('SyncedPageViews', () {
    testWidgets('should render primary and secondary pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncedPageViews(
              itemCount: 2,
              primaryItemBuilder: (context, index) =>
                  Text('Primary ${index + 1}'),
              secondaryItemBuilder: (context, index) =>
                  Text('Secondary ${index + 1}'),
            ),
          ),
        ),
      );

      expect(find.text('Primary 1'), findsOneWidget);
      expect(find.text('Secondary 1'), findsOneWidget);
    });

    testWidgets('should call onPageChanged when page changes',
        (WidgetTester tester) async {
      int? changedToPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncedPageViews(
              itemCount: 3,
              primaryItemBuilder: (context, index) => Container(
                key: Key('primary_$index'),
                color: Colors.blue,
                width: 400,
                height: 400,
              ),
              secondaryItemBuilder: (context, index) => Container(
                key: Key('secondary_$index'),
                color: Colors.red,
                width: 400,
                height: 400,
              ),
              onPageChanged: (index) {
                changedToPage = index;
              },
            ),
          ),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle();

      // Initially should be on page 0 (or null if not called yet)
      expect(changedToPage, isNull);

      // Drag to next page - use a more aggressive swipe
      final pageView = find.byType(PageView).first;
      await tester.fling(pageView, const Offset(-400, 0), 800.0);
      await tester.pumpAndSettle();

      // Should have changed to page 1
      expect(changedToPage, 1);

      // Drag to next page again
      await tester.fling(pageView, const Offset(-400, 0), 800.0);
      await tester.pumpAndSettle();

      // Should have changed to page 2
      expect(changedToPage, 2);
    });

    testWidgets('should handle tap on secondary page',
        (WidgetTester tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncedPageViews(
              itemCount: 3,
              primaryItemBuilder: (context, index) =>
                  Container(key: Key('primary_$index')),
              secondaryItemBuilder: (context, index) => Container(
                key: Key('secondary_$index'),
                child: Text('Tap $index'),
              ),
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
