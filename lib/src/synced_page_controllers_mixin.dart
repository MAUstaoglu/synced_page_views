import 'package:flutter/material.dart';

/// Enum to track which PageView is currently being scrolled
enum SyncedPageViewType { primary, secondary }

/// A mixin that provides synchronized PageController functionality
///
/// This mixin can be used with StatefulWidget to create synchronized PageViews
mixin SyncedPageControllersMixin<T extends StatefulWidget> on State<T> {
  bool _isSyncingPrimary = false;
  bool _isSyncingSecondary = false;
  late ValueNotifier<SyncedPageViewType> _currentScrolling;

  /// Initialize the sync functionality
  void initializeSync() {
    _currentScrolling =
        ValueNotifier<SyncedPageViewType>(SyncedPageViewType.primary);
  }

  /// Get the current scrolling notifier
  ValueNotifier<SyncedPageViewType> get currentScrolling => _currentScrolling;

  /// Start syncing two PageControllers
  void startSync(
      PageController primaryController, PageController secondaryController) {
    primaryController.addListener(
        () => _primaryListener(primaryController, secondaryController));
    secondaryController.addListener(
        () => _secondaryListener(primaryController, secondaryController));
  }

  /// Stop syncing two PageControllers
  void stopSync(
      PageController primaryController, PageController secondaryController) {
    primaryController.removeListener(
        () => _primaryListener(primaryController, secondaryController));
    secondaryController.removeListener(
        () => _secondaryListener(primaryController, secondaryController));
  }

  void _primaryListener(
      PageController primaryController, PageController secondaryController) {
    if (!primaryController.hasClients || !secondaryController.hasClients) {
      return;
    }
    if (_isSyncingPrimary) return;

    _currentScrolling.value = SyncedPageViewType.primary;
    final maxPrimary = primaryController.position.maxScrollExtent;
    final maxSecondary = secondaryController.position.maxScrollExtent;
    if (maxPrimary == 0) return;

    final clampedOffsetPrimary =
        primaryController.offset.clamp(0.0, maxPrimary);
    final progress = clampedOffsetPrimary / maxPrimary;
    final targetOffset = maxSecondary * progress;

    _isSyncingSecondary = true;
    secondaryController.jumpTo(targetOffset);
    _isSyncingSecondary = false;
  }

  void _secondaryListener(
      PageController primaryController, PageController secondaryController) {
    if (!primaryController.hasClients || !secondaryController.hasClients) {
      return;
    }
    if (_isSyncingSecondary) return;

    _currentScrolling.value = SyncedPageViewType.secondary;
    final maxPrimary = primaryController.position.maxScrollExtent;
    final maxSecondary = secondaryController.position.maxScrollExtent;
    if (maxSecondary == 0) return;

    final clampedOffsetSecondary =
        secondaryController.offset.clamp(0.0, maxSecondary);
    final progress = clampedOffsetSecondary / maxSecondary;
    final targetOffset = maxPrimary * progress;

    _isSyncingPrimary = true;
    primaryController.jumpTo(targetOffset);
    _isSyncingPrimary = false;
  }

  @override
  void dispose() {
    _currentScrolling.dispose();
    super.dispose();
  }
}
