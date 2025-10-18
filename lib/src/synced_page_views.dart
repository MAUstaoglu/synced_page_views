import 'package:flutter/material.dart';
import 'synced_page_controllers_hook.dart';
import 'synced_page_views_data.dart';

/// A widget that provides synchronized PageViews with bidirectional scrolling sync
class SyncedPageViews extends StatefulWidget {
  /// List of widgets for the primary PageView
  final List<Widget> primaryPages;
  
  /// List of widgets for the secondary PageView
  final List<Widget> secondaryPages;
  
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
  
  /// Builder for the primary PageView
  final Widget Function(BuildContext context, PageController controller, List<Widget> pages)?
      primaryBuilder;
  
  /// Builder for the secondary PageView
  final Widget Function(BuildContext context, PageController controller, List<Widget> pages)?
      secondaryBuilder;

  const SyncedPageViews({
    super.key,
    required this.primaryPages,
    required this.secondaryPages,
    this.initialPage = 0,
    this.primaryViewportFraction = 1.0,
    this.secondaryViewportFraction = 1.0,
    this.config = const SyncedPageViewsConfig(),
    this.onPageChanged,
    this.onPrimaryPageTap,
    this.onSecondaryPageTap,
    this.primaryBuilder,
    this.secondaryBuilder,
  }) : assert(primaryPages.length == secondaryPages.length,
            'Primary and secondary pages must have the same length');

  @override
  State<SyncedPageViews> createState() => _SyncedPageViewsState();
}

class _SyncedPageViewsState extends State<SyncedPageViews> 
    with SyncedPageControllersMixin {
  late PageController _primaryController;
  late PageController _secondaryController;
  late ValueNotifier<int> _currentPage;
  late SyncedPageViewsData _syncData;

  @override
  void initState() {
    super.initState();
    
    _primaryController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.primaryViewportFraction,
    );
    
    _secondaryController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.secondaryViewportFraction,
    );

    _currentPage = ValueNotifier<int>(widget.initialPage);
    
    // Initialize sync functionality
    initializeSync();
    
    // Start syncing the controllers
    startSync(_primaryController, _secondaryController);
    
    // Listen for page changes
    _primaryController.addListener(_updateCurrentPage);
    
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

  @override
  void dispose() {
    _primaryController.removeListener(_updateCurrentPage);
    stopSync(_primaryController, _secondaryController);
    _primaryController.dispose();
    _secondaryController.dispose();
    _currentPage.dispose();
    _syncData.isScrolling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SyncedPageViewsProvider(
      data: _syncData,
      child: Column(
        children: [
          // Primary PageView
          Expanded(
            child: widget.primaryBuilder?.call(context, _primaryController, widget.primaryPages) ??
                _buildPageView(
                  controller: _primaryController,
                  pages: widget.primaryPages,
                  onPageTap: widget.onPrimaryPageTap,
                ),
          ),
          // Secondary PageView
          Expanded(
            child: widget.secondaryBuilder?.call(context, _secondaryController, widget.secondaryPages) ??
                _buildPageView(
                  controller: _secondaryController,
                  pages: widget.secondaryPages,
                  onPageTap: widget.onSecondaryPageTap,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView({
    required PageController controller,
    required List<Widget> pages,
    void Function(int index)? onPageTap,
  }) {
    return PageView.builder(
      controller: controller,
      scrollDirection: widget.config.scrollDirection,
      reverse: widget.config.reverse,
      physics: widget.config.physics,
      pageSnapping: widget.config.pageSnapping,
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        if (onPageTap != null) {
          return GestureDetector(
            onTap: () => onPageTap(index),
            child: page,
          );
        }
        return page;
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
    return context.dependOnInheritedWidgetOfExactType<SyncedPageViewsProvider>()?.data;
  }

  @override
  bool updateShouldNotify(SyncedPageViewsProvider oldWidget) {
    return data != oldWidget.data;
  }
}
