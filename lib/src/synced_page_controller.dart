import 'package:flutter/material.dart';

/// A controller that manages synchronized PageControllers
class SyncedPageController extends ChangeNotifier {
  late PageController _primaryController;
  late PageController _secondaryController;
  late ValueNotifier<int> _currentPage;

  bool _isSyncingPrimary = false;
  bool _isSyncingSecondary = false;
  bool _isDisposed = false;

  /// Creates a SyncedPageController with the given parameters
  SyncedPageController({
    int initialPage = 0,
    double primaryViewportFraction = 1.0,
    double secondaryViewportFraction = 1.0,
  }) {
    _primaryController = PageController(
      initialPage: initialPage,
      viewportFraction: primaryViewportFraction,
    );

    _secondaryController = PageController(
      initialPage: initialPage,
      viewportFraction: secondaryViewportFraction,
    );

    _currentPage = ValueNotifier<int>(initialPage);

    _setupSync();
  }

  /// The primary PageController
  PageController get primaryController => _primaryController;

  /// The secondary PageController
  PageController get secondaryController => _secondaryController;

  /// Current page notifier
  ValueNotifier<int> get currentPage => _currentPage;

  /// Current page index
  int get currentPageIndex => _currentPage.value;

  void _setupSync() {
    _primaryController.addListener(_primaryListener);
    _secondaryController.addListener(_secondaryListener);
    _primaryController.addListener(_updateCurrentPage);
  }

  void _primaryListener() {
    if (_isDisposed ||
        !_primaryController.hasClients ||
        !_secondaryController.hasClients) {
      return;
    }
    if (_isSyncingPrimary) return;

    final maxPrimary = _primaryController.position.maxScrollExtent;
    final maxSecondary = _secondaryController.position.maxScrollExtent;
    if (maxPrimary == 0) return;

    final clampedOffsetPrimary =
        _primaryController.offset.clamp(0.0, maxPrimary);
    final progress = clampedOffsetPrimary / maxPrimary;
    final targetOffset = maxSecondary * progress;

    _isSyncingSecondary = true;
    _secondaryController.jumpTo(targetOffset);
    _isSyncingSecondary = false;
  }

  void _secondaryListener() {
    if (_isDisposed ||
        !_primaryController.hasClients ||
        !_secondaryController.hasClients) {
      return;
    }
    if (_isSyncingSecondary) return;

    final maxPrimary = _primaryController.position.maxScrollExtent;
    final maxSecondary = _secondaryController.position.maxScrollExtent;
    if (maxSecondary == 0) return;

    final clampedOffsetSecondary =
        _secondaryController.offset.clamp(0.0, maxSecondary);
    final progress = clampedOffsetSecondary / maxSecondary;
    final targetOffset = maxPrimary * progress;

    _isSyncingPrimary = true;
    _primaryController.jumpTo(targetOffset);
    _isSyncingPrimary = false;
  }

  void _updateCurrentPage() {
    if (_isDisposed || !_primaryController.hasClients) return;

    final page = (_primaryController.page ?? 0).round();
    if (_currentPage.value != page) {
      _currentPage.value = page;
      notifyListeners();
    }
  }

  /// Animate to a specific page
  Future<void> animateToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (_isDisposed) return;

    await Future.wait([
      _primaryController.animateToPage(page, duration: duration, curve: curve),
      _secondaryController.animateToPage(page,
          duration: duration, curve: curve),
    ]);
  }

  /// Jump to a specific page without animation
  void jumpToPage(int page) {
    if (_isDisposed) return;

    _primaryController.jumpToPage(page);
    _secondaryController.jumpToPage(page);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _primaryController.removeListener(_primaryListener);
    _secondaryController.removeListener(_secondaryListener);
    _primaryController.removeListener(_updateCurrentPage);

    _primaryController.dispose();
    _secondaryController.dispose();
    _currentPage.dispose();

    super.dispose();
  }
}
