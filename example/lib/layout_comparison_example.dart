import 'package:flutter/material.dart';
import 'package:synced_page_views/synced_page_views.dart';

/// Example demonstrating all three layout types: Stack, Column, and Row
class LayoutComparisonExample extends StatefulWidget {
  const LayoutComparisonExample({super.key});

  @override
  State<LayoutComparisonExample> createState() =>
      _LayoutComparisonExampleState();
}

class _LayoutComparisonExampleState extends State<LayoutComparisonExample> {
  String _selectedLayout = 'column';
  int _currentPage = 0;

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  final List<String> _titles = [
    'Page 1',
    'Page 2',
    'Page 3',
    'Page 4',
    'Page 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Comparison'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Layout selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Select Layout Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'stack',
                      label: Text('Stack'),
                      icon: Icon(Icons.layers),
                    ),
                    ButtonSegment(
                      value: 'column',
                      label: Text('Column'),
                      icon: Icon(Icons.view_agenda),
                    ),
                    ButtonSegment(
                      value: 'row',
                      label: Text('Row'),
                      icon: Icon(Icons.view_week),
                    ),
                  ],
                  selected: {_selectedLayout},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedLayout = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _getLayoutDescription(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // SyncedPageViews with selected layout
          Expanded(
            child: SyncedPageViews(
              key: ValueKey(_selectedLayout), // Rebuild when layout changes
              itemCount: _titles.length,
              primaryItemBuilder: _buildPrimaryPage,
              secondaryItemBuilder: _buildSecondaryPage,
              initialPage: _currentPage,
              primaryViewportFraction: 0.9,
              secondaryViewportFraction: 0.7,
              config: SyncedPageViewsConfig(
                animationDuration: Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                scrollDirection: _selectedLayout == 'row'
                    ? Axis.vertical
                    : Axis.horizontal,
                pageSnapping: true,
              ),
              layoutBuilder: _getLayoutBuilder(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),

          // Current page indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current Page: ${_currentPage + 1} of ${_titles.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getLayoutDescription() {
    switch (_selectedLayout) {
      case 'stack':
        return 'Views overlap each other (perfect for overlays)';
      case 'column':
        return 'Views arranged vertically (one above the other)';
      case 'row':
        return 'Views arranged horizontally (side by side)';
      default:
        return 'Unknown layout';
    }
  }

  Widget Function(Widget, Widget) _getLayoutBuilder() {
    switch (_selectedLayout) {
      case 'stack':
        return (primary, secondary) => Stack(children: [primary, secondary]);
      case 'column':
        return (primary, secondary) => Column(
          children: [
            Expanded(child: primary),
            Expanded(child: secondary),
          ],
        );
      case 'row':
        return (primary, secondary) => Row(
          children: [
            Expanded(child: primary),
            Expanded(child: secondary),
          ],
        );
      default:
        return (primary, secondary) => Stack(children: [primary, secondary]);
    }
  }

  Widget _buildPrimaryPage(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _colors[index].withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.panorama, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _titles[index],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PRIMARY VIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryPage(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _colors[index].withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _colors[index], width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 48, color: _colors[index]),
            const SizedBox(height: 8),
            Text(
              _titles[index],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _colors[index],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _colors[index].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'SECONDARY VIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _colors[index],
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
