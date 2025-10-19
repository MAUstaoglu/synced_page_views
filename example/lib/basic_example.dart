import 'package:flutter/material.dart';
import 'package:synced_page_views/synced_page_views.dart';

/// Basic example demonstrating synced PageViews with Column layout
class BasicExample extends StatefulWidget {
  const BasicExample({super.key});

  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  int _currentPage = 0;

  // Sample data for the pages
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
        title: const Text('Basic Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Current page indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current Page: ${_currentPage + 1} of ${_titles.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // SyncedPageViews widget
          Expanded(
            child: SyncedPageViews(
              itemCount: _titles.length,
              primaryItemBuilder: _buildPrimaryPage,
              secondaryItemBuilder: _buildSecondaryPage,
              initialPage: 0,
              primaryViewportFraction: 1.0,
              secondaryViewportFraction: 0.8,
              config: const SyncedPageViewsConfig(
                animationDuration: Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                scrollDirection: Axis.horizontal,
                pageSnapping: true,
              ),
              layoutBuilder: (primary, secondary) => Column(
                children: [
                  Expanded(child: primary),
                  Expanded(child: secondary),
                ],
              ),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              onPrimaryPageTap: (index) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Primary page $index tapped'),
                    duration: const Duration(milliseconds: 500),
                  ),
                );
              },
              onSecondaryPageTap: (index) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Secondary page $index tapped'),
                    duration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
          ),

          // Page dots indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _titles.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: _currentPage == index ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            const Icon(Icons.pages, size: 80, color: Colors.white),
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
            const Text(
              'Primary View',
              style: TextStyle(fontSize: 16, color: Colors.white70),
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
            Icon(Icons.preview, size: 48, color: _colors[index]),
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
            Text(
              'Secondary View',
              style: TextStyle(
                fontSize: 12,
                color: _colors[index].withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
