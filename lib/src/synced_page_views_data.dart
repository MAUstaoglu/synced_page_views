import 'package:flutter/material.dart';

/// Configuration class for synchronized PageViews
class SyncedPageViewsConfig {
  /// Animation duration when programmatically changing pages
  final Duration animationDuration;
  
  /// Animation curve when programmatically changing pages
  final Curve animationCurve;
  
  /// Whether to enable infinite scrolling
  final bool infiniteScroll;
  
  /// Scroll direction for both PageViews
  final Axis scrollDirection;
  
  /// Whether to enable page snapping
  final bool pageSnapping;
  
  /// Whether to reverse the page order
  final bool reverse;
  
  /// Physics for both PageViews
  final ScrollPhysics? physics;

  const SyncedPageViewsConfig({
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.infiniteScroll = false,
    this.scrollDirection = Axis.horizontal,
    this.pageSnapping = true,
    this.reverse = false,
    this.physics,
  });
}

/// Data class to hold the controllers and sync state
class SyncedPageViewsData {
  final PageController primaryController;
  final PageController secondaryController;
  final ValueNotifier<bool> isScrolling;
  final ValueNotifier<int> currentPage;

  SyncedPageViewsData({
    required this.primaryController,
    required this.secondaryController,
    required this.isScrolling,
    required this.currentPage,
  });

  /// Animate to a specific page
  Future<void> animateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) async {
    final animationDuration = duration ?? const Duration(milliseconds: 300);
    final animationCurve = curve ?? Curves.easeInOut;
    
    await Future.wait([
      primaryController.animateToPage(
        page,
        duration: animationDuration,
        curve: animationCurve,
      ),
      secondaryController.animateToPage(
        page,
        duration: animationDuration,
        curve: animationCurve,
      ),
    ]);
  }

  /// Jump to a specific page without animation
  void jumpToPage(int page) {
    primaryController.animateToPage(page, duration: Duration.zero, curve: Curves.linear);
    secondaryController.animateToPage(page, duration: Duration.zero, curve: Curves.linear);
  }

  /// Get the current page index (rounded)
  int get currentPageIndex => currentPage.value;

  /// Dispose the controllers and notifiers
  void dispose() {
    primaryController.dispose();
    secondaryController.dispose();
    isScrolling.dispose();
    currentPage.dispose();
  }
}
