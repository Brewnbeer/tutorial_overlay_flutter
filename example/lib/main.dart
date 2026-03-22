import 'package:flutter/material.dart';
import 'package:tutorial_overlay_flutter/tutorial_overlay_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial Overlay Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Basic Usage
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Create GlobalKeys for widgets you want to highlight.
  final _menuKey = GlobalKey();
  final _searchKey = GlobalKey();
  final _profileKey = GlobalKey();
  final _fabKey = GlobalKey();
  final _listItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start the tutorial after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTutorial());
  }

  void _startTutorial() {
    // 2. Show the tutorial overlay.
    TutorialOverlay.show(
      context,
      steps: [
        TutorialStep(
          targetKey: _menuKey,
          title: 'Navigation Menu',
          description: 'Open the drawer to navigate between sections.',
          shape: HighlightShape.circle,
        ),
        TutorialStep(
          targetKey: _searchKey,
          title: 'Search',
          description: 'Quickly find any item using the search button.',
          shape: HighlightShape.circle,
        ),
        TutorialStep(
          targetKey: _profileKey,
          title: 'Your Profile',
          description: 'View and manage your account settings here.',
          shape: HighlightShape.circle,
        ),
        TutorialStep(
          targetKey: _listItemKey,
          title: 'Items List',
          description: 'Browse through your items. Tap any card for details.',
          padding: 4,
        ),
        TutorialStep(
          targetKey: _fabKey,
          title: 'Create New',
          description: 'Tap here to add a new item to your collection.',
          shape: HighlightShape.circle,
          padding: 12,
        ),
      ],
      config: const TutorialConfig(
        primaryColor: Color(0xFF6C63FF),
        overlayColor: Color(0xCC000000),
        enablePulseAnimation: true,
      ),
      onFinish: () => _showSnackBar('Tutorial completed!'),
      onSkip: () => _showSnackBar('Tutorial skipped.'),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: _menuKey,
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Tutorial Demo'),
        actions: [
          IconButton(
            key: _searchKey,
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            key: _profileKey,
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            key: index == 0 ? _listItemKey : null,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text('Item ${index + 1}'),
              subtitle: const Text('Tap to see details'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Advanced Customization
// ---------------------------------------------------------------------------

class AdvancedScreen extends StatefulWidget {
  const AdvancedScreen({super.key});

  @override
  State<AdvancedScreen> createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends State<AdvancedScreen> {
  final _headerKey = GlobalKey();
  final _toggleKey = GlobalKey();
  final _sliderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTutorial());
  }

  void _startTutorial() {
    TutorialOverlay.show(
      context,
      steps: [
        TutorialStep(
          targetKey: _headerKey,
          title: 'Settings Header',
          description: 'This section contains your key preferences.',
          tooltipPosition: TooltipPosition.bottom,
        ),
        TutorialStep(
          targetKey: _toggleKey,
          title: 'Dark Mode',
          description: 'Toggle between light and dark themes.',
        ),
        // Custom tooltip example.
        TutorialStep(
          targetKey: _sliderKey,
          title: 'Volume',
          tooltipBuilder: (context, info) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x406C63FF),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      info.title ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drag the slider to adjust notification volume.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: info.isLast ? info.finish : info.next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          info.isLast ? 'Got it!' : 'Next',
                          style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      config: const TutorialConfig(
        primaryColor: Color(0xFF6C63FF),
        dismissOnOverlayTap: false,
        tooltipMaxWidth: 300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: _headerKey,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Preferences',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              key: _toggleKey,
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: false,
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            ListTile(
              key: _sliderKey,
              title: const Text('Volume'),
              subtitle: Slider(value: 0.7, onChanged: (_) {}),
            ),
          ],
        ),
      ),
    );
  }
}
