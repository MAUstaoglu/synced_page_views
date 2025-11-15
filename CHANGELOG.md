## 2.0.0

- **Breaking Change**: Made `controller` and individual parameters mutually exclusive
  - `initialPage`, `primaryViewportFraction`, and `secondaryViewportFraction` are now nullable
  - When using `controller`, do not provide the individual parameters (similar to Container's color/decoration)
  - Added assertion to prevent conflicting parameter usage
  - Improved API clarity and prevents developer confusion

## 1.1.0

- **New Feature**: Added configurable layout system
  - Stack layout: Views overlap (perfect for overlays)
  - Column layout: Views arranged vertically
  - Row layout: Views arranged horizontally
- Added `SyncedPageViewsLayout` enum with three layout options
- Added `layout` parameter to `SyncedPageViewsConfig`
- Updated examples to demonstrate all three layout types
- New layout comparison example in the demo app
- Updated overlapping example to use Stack layout with custom builders

## 1.0.1

- Fixed code formatting to match Dart formatter standards
- Improved pub.dev package score

## 1.0.0

- Initial release
- Synced PageViews with bidirectional scrolling
- Dynamic page snapping (only active scrolling PageView has snapping enabled)
- Customizable viewport fractions and animations
- Support for tap navigation
- Custom builders for complete control
- Low-level `SyncedPageController` for advanced use cases
- Mixin support for custom implementations
- Comprehensive example with all platform support (iOS, Android, Web, macOS, Linux, Windows)
- Full documentation and API reference
