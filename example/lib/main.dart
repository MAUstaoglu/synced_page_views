import 'package:flutter/material.dart';
import 'basic_example.dart';
import 'layout_comparison_example.dart';
import 'overlapping_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synced PageViews Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplesHome(),
    );
  }
}

class ExamplesHome extends StatelessWidget {
  const ExamplesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synced PageViews Examples'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExampleCard(
            context: context,
            title: 'Basic Example',
            description:
                'Simple synced PageViews with color pages and thumbnails',
            icon: Icons.view_carousel,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BasicExample()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context: context,
            title: 'Layout Comparison',
            description: 'Compare Stack, Column, and Row layouts side by side',
            icon: Icons.dashboard,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LayoutComparisonExample(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context: context,
            title: 'Overlapping Example',
            description:
                'Full-screen pages with overlapping selector at bottom',
            icon: Icons.layers,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OverlappingExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
