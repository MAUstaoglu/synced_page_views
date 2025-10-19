import 'package:flutter/material.dart';
import 'synced_page_controller.dart';
import 'synced_page_controllers_mixin.dart';
import 'synced_page_views_data.dart';

/// A widget that provides synchronized PageViews with bidirectional scrolling sync
class SyncedPageViews extends StatefulWidget {
  /// Number of pages in both PageViews
  final int itemCount;

  /// Builder for primary page items
  final IndexedWidgetBuilder primaryItemBuilder;

  /// Builder for secondary page items
  final IndexedWidgetBuilder secondaryItemBuilder;

  /// Initial page index
  final int initialPage;

  /// Viewport fraction for primary PageView (default: 1.0)
  final double primaryViewportFraction;

  /// Viewport fraction for secondary PageView (default: 1.0)
  final double secondaryViewportFraction;

  /// Configuration for the synchronized PageViews
  final SyncedPageViewsConfig config;

  /// Callback when page changes
  final void Function(int index)? onPageChanged;

  /// Callback when primary PageView is tapped
  final void Function(int index)? onPrimaryPageTap;

  /// Callback when secondary PageView is tapped
  final void Function(int index)? onSecondaryPageTap;

  /// Builder function to arrange primary and secondary views
  /// Receives the primary and secondary widgets and returns the layout
  /// Default is a Stack layout
  final Widget Function(Widget primary, Widget secondary)? layoutBuilder;

  /// Optional SyncedPageController to use
  /// If provided, this controller will be used instead of creating internal controllers
  final SyncedPageController? controller;

  const SyncedPageViews({
    super.key,
    required this.itemCount,
    required this.primaryItemBuilder,
    required this.secondaryItemBuilder,
    this.initialPage = 0,
    this.primaryViewportFraction = 1.0,
    this.secondaryViewportFraction = 1.0,
    this.config = const SyncedPageViewsConfig(),
    this.onPageChanged,
    this.onPrimaryPageTap,
    this.onSecondaryPageTap,
    this.layoutBuilder,
    this.controller,
  });

  @override
  State<SyncedPageViews> createState() => _SyncedPageViewsState();
}

class _SyncedPageViewsState extends State<SyncedPageViews>
    with SyncedPageControllersMixin {
  late PageController _primaryController;
  late PageController _secondaryController;
  late ValueNotifier<int> _currentPage;
  late SyncedPageViewsData _syncData;
  bool _ownsControllers = false;

  @override
  void initState() {
    super.initState();

    // Always initialize sync (needed for currentScrolling notifier)
    initializeSync();

    // Use provided controller or create new ones
    if (widget.controller != null) {
      _primaryController = widget.controller!.primaryController;
      _secondaryController = widget.controller!.secondaryController;
      _currentPage = widget.controller!.currentPage;
      _ownsControllers = false;
      // Don't start sync - the SyncedPageController handles it
    } else {
      _primaryController = PageController(
        initialPage: widget.initialPage,
        viewportFraction: widget.primaryViewportFraction,
      );

      _secondaryController = PageController(
        initialPage: widget.initialPage,
        viewportFraction: widget.secondaryViewportFraction,
      );

      _currentPage = ValueNotifier<int>(widget.initialPage);
      _ownsControllers = true;

      // Start syncing the controllers
      startSync(_primaryController, _secondaryController);
    }

    // Listen for page changes
    if (_ownsControllers) {
      _primaryController.addListener(_updateCurrentPage);
    } else {
      // When using external controller, listen to its currentPage notifier
      _currentPage.addListener(_notifyPageChanged);
    }

    // Create sync data
    _syncData = SyncedPageViewsData(
      primaryController: _primaryController,
      secondaryController: _secondaryController,
      isScrolling: ValueNotifier<bool>(false),
      currentPage: _currentPage,
    );
  }

  void _updateCurrentPage() {
    if (_primaryController.hasClients) {
      final page = (_primaryController.page ?? 0).round();
      if (_currentPage.value != page) {
        _currentPage.value = page;
        widget.onPageChanged?.call(page);
      }
    }
  }

  void _notifyPageChanged() {
    widget.onPageChanged?.call(_currentPage.value);
  }

  @override
  void dispose() {
    // Remove the appropriate listener
    if (_ownsControllers) {
      _primaryController.removeListener(_updateCurrentPage);
      stopSync(_primaryController, _secondaryController);
      _primaryController.dispose();
      _secondaryController.dispose();
      _currentPage.dispose();
    } else {
      _currentPage.removeListener(_notifyPageChanged);
    }

    _syncData.isScrolling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SyncedPageViewsProvider(
      data: _syncData,
      child: _buildLayoutWidget(),
    );
  }

  Widget _buildLayoutWidget() {
    // Wrap primary item builder with tap gesture if needed
    Widget primaryItemBuilderWithTap(BuildContext context, int index) {
      final item = widget.primaryItemBuilder(context, index);
      if (widget.onPrimaryPageTap != null) {
        return GestureDetector(
          onTap: () => widget.onPrimaryPageTap!(index),
          child: item,
        );
      }
      return item;
    }

    // Wrap secondary item builder with tap gesture if needed
    Widget secondaryItemBuilderWithTap(BuildContext context, int index) {
      final item = widget.secondaryItemBuilder(context, index);
      if (widget.onSecondaryPageTap != null) {
        return GestureDetector(
          onTap: () => widget.onSecondaryPageTap!(index),
          child: item,
        );
      }
      return item;
    }

    final primaryView = _buildPageView(
      controller: _primaryController,
      itemCount: widget.itemCount,
      itemBuilder: primaryItemBuilderWithTap,
      viewType: SyncedPageViewType.primary,
    );

    final secondaryView = _buildPageView(
      controller: _secondaryController,
      itemCount: widget.itemCount,
      itemBuilder: secondaryItemBuilderWithTap,
      viewType: SyncedPageViewType.secondary,
    );

    // Use custom layoutBuilder if provided, otherwise use default Stack
    if (widget.layoutBuilder != null) {
      return widget.layoutBuilder!(primaryView, secondaryView);
    }

    // Default layout is Stack
    return Stack(
      children: [primaryView, secondaryView],
    );
  }

  Widget _buildPageView({
    required PageController controller,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required SyncedPageViewType viewType,
  }) {
    // Only the currently scrolling PageView should have pageSnapping enabled
    // to avoid conflicts between the two synchronized views.
    return ValueListenableBuilder(
      valueListenable: currentScrolling,
      builder: (context, SyncedPageViewType currentlyScrolling, _) {
        // Enable snapping only if config says true AND this view is currently scrolling
        final bool effectivePageSnapping =
            widget.config.pageSnapping && (currentlyScrolling == viewType);

        return PageView.builder(
          controller: controller,
          scrollDirection: widget.config.scrollDirection,
          reverse: widget.config.reverse,
          physics: widget.config.physics,
          pageSnapping: effectivePageSnapping,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Provider widget to access SyncedPageViewsData from descendants
class SyncedPageViewsProvider extends InheritedWidget {
  final SyncedPageViewsData data;

  const SyncedPageViewsProvider({
    super.key,
    required this.data,
    required super.child,
  });

  static SyncedPageViewsData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SyncedPageViewsProvider>()
        ?.data;
  }

  @override
  bool updateShouldNotify(SyncedPageViewsProvider oldWidget) {
    return data != oldWidget.data;
  }
}
