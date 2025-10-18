# Synced PageViews

A Flutter package for creating synchronized PageViews with bidirectional scrolling sync. Perfect for creating interfaces where two PageViews need to stay in sync, such as main content with thumbnails, tabs with content, or any dual-pane scrolling interface.

## Features

- 🔄 **Bidirectional Sync**: Scrolling one PageView automatically syncs the other
- 🎯 **Tap Navigation**: Support for tapping to navigate between pages
- ⚙️ **Highly Customizable**: Custom viewport fractions, animation curves, and builders
- 🔧 **No External Dependencies**: Built with pure Flutter, no additional packages required
- 🎨 **Custom Builders**: Override default PageView builders for complete control
- 📱 **Responsive**: Works with different screen sizes and orientations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  synced_page_views: ^1.0.0
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:synced_page_views/synced_page_views.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryPages = List.generate(5, (index) => 
      Container(
        color: Colors.blue[100 * (index + 1)],
        child: Center(child: Text('Page $index')),
      ),
    );

    final secondaryPages = List.generate(5, (index) => 
      Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue[100 * (index + 1)],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('Thumb $index')),
      ),
    );

    return Scaffold(
      body: SyncedPageViews(
        primaryPages: primaryPages,
        secondaryPages: secondaryPages,
        primaryViewportFraction: 1.0,
        secondaryViewportFraction: 0.3,
        onPageChanged: (index) => print('Page: $index'),
        onSecondaryPageTap: (index) {
          final syncData = SyncedPageViewsProvider.of(context);
          syncData?.animateToPage(index);
        },
      ),
    );
  }
}
```

### Advanced Example with Custom Builders

```dart
SyncedPageViews(
  primaryPages: mainContentPages,
  secondaryPages: thumbnailPages,
  config: SyncedPageViewsConfig(
    animationDuration: Duration(milliseconds: 500),
    animationCurve: Curves.elasticOut,
    scrollDirection: Axis.horizontal,
  ),
  // Custom builder for the main content
  primaryBuilder: (context, controller, pages) {
    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      itemBuilder: (context, index) => AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: pages[index],
      ),
    );
  },
  // Custom builder for thumbnails
  secondaryBuilder: (context, controller, pages) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: controller,
        itemCount: pages.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            SyncedPageViewsProvider.of(context)?.animateToPage(index);
          },
          child: pages[index],
        ),
      ),
    );
  },
)
```

### Using SyncedPageController Directly

If you need maximum control, you can use `SyncedPageController` directly:

```dart
class CustomSyncedPageViews extends StatefulWidget {
  @override
  State<CustomSyncedPageViews> createState() => _CustomSyncedPageViewsState();
}

class _CustomSyncedPageViewsState extends State<CustomSyncedPageViews> {
  late SyncedPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SyncedPageController(
      initialPage: 0,
      primaryViewportFraction: 1.0,
      secondaryViewportFraction: 0.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller.primaryController,
            itemBuilder: (context, index) => YourPrimaryPage(index),
          ),
        ),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _controller.secondaryController,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _controller.animateToPage(index),
              child: YourSecondaryPage(index),
            ),
          ),
        ),
      ],
    );
  }
}
```

## API Reference

### SyncedPageViews

| Property | Type | Description |
|----------|------|-------------|
| `primaryPages` | `List<Widget>` | Pages for the main PageView |
| `secondaryPages` | `List<Widget>` | Pages for the secondary PageView |
| `initialPage` | `int` | Initial page index (default: 0) |
| `primaryViewportFraction` | `double` | Viewport fraction for primary PageView (default: 1.0) |
| `secondaryViewportFraction` | `double` | Viewport fraction for secondary PageView (default: 1.0) |
| `config` | `SyncedPageViewsConfig` | Configuration for animations and behavior |
| `onPageChanged` | `Function(int)?` | Callback when page changes |
| `onPrimaryPageTap` | `Function(int)?` | Callback when primary page is tapped |
| `onSecondaryPageTap` | `Function(int)?` | Callback when secondary page is tapped |
| `primaryBuilder` | `Widget Function(...)?` | Custom builder for primary PageView |
| `secondaryBuilder` | `Widget Function(...)?` | Custom builder for secondary PageView |

### SyncedPageViewsConfig

| Property | Type | Description |
|----------|------|-------------|
| `animationDuration` | `Duration` | Animation duration (default: 300ms) |
| `animationCurve` | `Curve` | Animation curve (default: Curves.easeInOut) |
| `scrollDirection` | `Axis` | Scroll direction (default: Axis.horizontal) |
| `pageSnapping` | `bool` | Enable page snapping (default: true) |
| `reverse` | `bool` | Reverse page order (default: false) |
| `physics` | `ScrollPhysics?` | Custom scroll physics |

### SyncedPageController

For advanced use cases, `SyncedPageController` provides direct access to synchronized PageControllers:

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `primaryController` | `PageController` | The primary PageController |
| `secondaryController` | `PageController` | The secondary PageController |
| `currentPage` | `ValueNotifier<int>` | Current page notifier |
| `currentPageIndex` | `int` | Current page index |
| `animateToPage(int, {Duration, Curve})` | `Future<void>` | Animate to specific page |
| `jumpToPage(int)` | `void` | Jump to specific page |

## Use Cases

- **Video/Media Players**: Main video with thumbnail navigation
- **Image Galleries**: Full-size images with thumbnail strip
- **Tabbed Interfaces**: Tab headers synced with content pages
- **Product Showcases**: Product images with detail thumbnails
- **Tutorial/Onboarding**: Steps with progress indicators

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
