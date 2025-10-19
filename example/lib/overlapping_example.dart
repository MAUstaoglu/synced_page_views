import 'package:flutter/material.dart';
import 'package:synced_page_views/synced_page_views.dart';

/// Overlapping synced PageViews example
/// Shows full-screen pages with an overlapping style selector at the bottom
class OverlappingExample extends StatefulWidget {
  const OverlappingExample({super.key});

  @override
  State<OverlappingExample> createState() => _OverlappingExampleState();
}

class _OverlappingExampleState extends State<OverlappingExample> {
  int _currentPage = 1;
  late final SyncedPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SyncedPageController(
      initialPage: 1,
      primaryViewportFraction: 1.0,
      secondaryViewportFraction: 0.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<PageStyle> _styles = [
    PageStyle(
      name: 'Page 1',
      icon: Icons.looks_one,
      color: Colors.purple,
      description: 'First page',
    ),
    PageStyle(
      name: 'Page 2',
      icon: Icons.looks_two,
      color: Colors.blue,
      description: 'Second page',
    ),
    PageStyle(
      name: 'Page 3',
      icon: Icons.looks_3,
      color: Colors.orange,
      description: 'Third page',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Overlapping Example'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SyncedPageViews(
        controller: _controller,
        itemCount: _styles.length,
        primaryItemBuilder: _buildPrimaryPage,
        secondaryItemBuilder: _buildSecondaryPage,
        config: const SyncedPageViewsConfig(
          animationDuration: Duration(milliseconds: 300),
          animationCurve: Curves.easeOut,
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
        ),
        layoutBuilder: (primary, secondary) => Stack(
          children: [
            primary,
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(height: 150, child: secondary),
            ),
          ],
        ),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        onSecondaryPageTap: (index) {
          // Animate to tapped page using the controller
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }

  Widget _buildPrimaryPage(BuildContext context, int index) {
    final style = _styles[index];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.color.withValues(alpha: 0.8),
            style.color.withValues(alpha: 0.4),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(style.icon, size: 120, color: Colors.white),
            const SizedBox(height: 32),
            Text(
              style.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              style.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryPage(BuildContext context, int index) {
    final style = _styles[index];
    final isActive = index == _currentPage;
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: isActive ? 0.3 : 0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            style.icon,
            size: isActive ? 36 : 28,
            color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            style.name,
            style: TextStyle(
              fontSize: isActive ? 16 : 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class PageStyle {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  PageStyle({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}
