# Tutorial Overlay Flutter

A production-ready Flutter package for creating guided tutorial overlays, onboarding walkthroughs, and step-by-step UI showcases.

Highlight any widget, show contextual tooltips, and guide users through your app with smooth animations -- all with minimal setup.

## Features

- **Highlight any widget** using `GlobalKey` with rectangle, rounded rectangle, or circle shapes
- **Step-by-step navigation** -- next, previous, skip, jump to step, finish
- **Auto-scroll** targets into view when inside scrollable widgets
- **Smooth animations** -- overlay fade, highlight transition, tooltip scale-in, pulse effect
- **Fully custom tooltips** via builder callbacks, or use the polished default tooltip
- **Persistence** -- optional interface to remember completed tutorials across sessions
- **Responsive** -- adapts to orientation changes, different screen sizes, and safe areas
- **Conditional steps** -- show or hide steps dynamically with `showIf`
- **Auto-advance** -- automatically progress after a configurable duration
- **Zero dependencies** beyond Flutter SDK

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  tutorial_overlay_flutter: ^1.0.0
```

Then run:

```sh
flutter pub get
```

## Quick Start

```dart
import 'package:tutorial_overlay_flutter/tutorial_overlay_flutter.dart';

// 1. Attach GlobalKeys to your widgets.
final searchKey = GlobalKey();
final menuKey = GlobalKey();
final fabKey = GlobalKey();

// 2. Use the keys on your widgets.
IconButton(
  key: searchKey,
  icon: const Icon(Icons.search),
  onPressed: () {},
)

// 3. Show the tutorial (e.g. in initState via addPostFrameCallback).
TutorialOverlay.show(
  context,
  steps: [
    TutorialStep(
      targetKey: searchKey,
      title: 'Search',
      description: 'Find anything in the app.',
    ),
    TutorialStep(
      targetKey: menuKey,
      title: 'Menu',
      description: 'Access navigation and settings.',
      shape: HighlightShape.circle,
    ),
    TutorialStep(
      targetKey: fabKey,
      title: 'Create',
      description: 'Add a new item.',
      shape: HighlightShape.circle,
      padding: 12,
    ),
  ],
  onFinish: () => print('Tutorial completed!'),
  onSkip: () => print('Tutorial skipped.'),
);
```

That's it. Three lines of setup, one call to show.

## Configuration

Customize the entire overlay with `TutorialConfig`:

```dart
TutorialOverlay.show(
  context,
  steps: steps,
  config: const TutorialConfig(
    // Overlay
    overlayColor: Color(0xBB000000),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeOutCubic,

    // Highlight
    enablePulseAnimation: true,
    highlightBorderColor: Color(0xFF2196F3),
    highlightBorderWidth: 3.0,

    // Interaction
    dismissOnOverlayTap: true,
    enableAutoScroll: true,

    // Tooltip
    tooltipBackgroundColor: Color(0xFF1E1E2E),
    tooltipBorderRadius: 16.0,
    tooltipMaxWidth: 340.0,
    tooltipSpacing: 20.0,

    // Buttons
    nextText: 'Continue',
    previousText: 'Back',
    skipText: 'Skip Tour',
    finishText: 'Got it!',
    showStepIndicator: true,
    showNavigationButtons: true,
    showSkipButton: true,

    // Theme
    primaryColor: Color(0xFF6C63FF),
  ),
);
```

## Custom Tooltips

Replace the default tooltip for any step with your own widget:

```dart
TutorialStep(
  targetKey: myKey,
  tooltipBuilder: (context, info) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(info.title ?? '', style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: info.isLast ? info.finish : info.next,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(info.isLast ? 'Done' : 'Next'),
          ),
        ),
      ],
    ),
  ),
)
```

The `StepInfo` object gives you everything you need: `next()`, `previous()`, `skip()`, `finish()`, `currentIndex`, `totalSteps`, `isFirst`, `isLast`, and `progress`.

## Programmatic Control

Get a reference to the controller for external navigation:

```dart
final controller = await TutorialOverlay.show(context, steps: steps);

// Navigate programmatically from anywhere.
controller?.next();
controller?.previous();
controller?.goToStep(2);
controller?.skip();
```

Or create your own controller for full control:

```dart
final controller = TutorialController(
  steps: steps,
  config: const TutorialConfig(dismissOnOverlayTap: false),
  onFinish: () => print('Done'),
);

TutorialOverlay.showWithController(context, controller);

// Later...
controller.next();
```

## Persistence

Prevent showing the tutorial to users who have already completed it:

```dart
// 1. Implement TutorialPersistence (e.g. with SharedPreferences).
class MyPersistence implements TutorialPersistence {
  @override
  Future<bool> isCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_$id') ?? false;
  }

  @override
  Future<void> markCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_$id', true);
  }

  @override
  Future<void> reset(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutorial_$id');
  }
}

// 2. Pass it when showing the tutorial.
TutorialOverlay.show(
  context,
  steps: steps,
  tutorialId: 'home_onboarding',
  persistence: MyPersistence(),
);
```

An `InMemoryPersistence` class is included for development and testing.

## TutorialScope

Share a controller across the widget tree using `TutorialScope`:

```dart
TutorialScope(
  controller: myController,
  child: MyApp(),
)

// In any descendant widget:
final controller = TutorialScope.of(context);
controller.next();
```

## Conditional Steps

Show or hide steps dynamically:

```dart
TutorialStep(
  targetKey: premiumKey,
  title: 'Premium Feature',
  description: 'Unlock advanced analytics.',
  showIf: () => user.isPremium,
)
```

## Auto-Advance

Automatically move to the next step after a delay:

```dart
TutorialStep(
  targetKey: splashKey,
  title: 'Welcome!',
  description: 'This tour will guide you through the app.',
  autoAdvanceAfter: const Duration(seconds: 3),
)
```

## API Reference

### TutorialOverlay

| Method | Description |
|---|---|
| `show(context, steps, ...)` | Show tutorial with simple API. Returns `Future<TutorialController?>`. |
| `showWithController(context, controller)` | Show tutorial with an existing controller. |

### TutorialStep

| Property | Type | Default | Description |
|---|---|---|---|
| `targetKey` | `GlobalKey` | required | Key of the widget to highlight |
| `title` | `String?` | `null` | Tooltip title |
| `description` | `String?` | `null` | Tooltip description |
| `tooltipBuilder` | `Widget Function(...)? ` | `null` | Custom tooltip widget |
| `shape` | `HighlightShape` | `roundedRectangle` | Cutout shape |
| `padding` | `double` | `8.0` | Padding around highlight |
| `borderRadius` | `double` | `8.0` | Corner radius (rounded rect) |
| `tooltipPosition` | `TooltipPosition` | `auto` | Preferred tooltip side |
| `autoAdvanceAfter` | `Duration?` | `null` | Auto-advance delay |
| `showIf` | `bool Function()?` | `null` | Conditional display |
| `onShow` | `VoidCallback?` | `null` | Called when step shown |
| `onDismiss` | `VoidCallback?` | `null` | Called when step dismissed |

### TutorialController

| Property/Method | Description |
|---|---|
| `currentIndex` | Current step index |
| `status` | `idle`, `active`, `completed`, or `skipped` |
| `isActive` | Whether tutorial is currently showing |
| `currentStepInfo` | `StepInfo` for the current step |
| `start()` | Begin the tutorial |
| `next()` | Advance to next step |
| `previous()` | Go back one step |
| `goToStep(index)` | Jump to a specific step |
| `skip()` | Skip the entire tutorial |
| `complete()` | Complete the tutorial |

### Enums

- **`HighlightShape`**: `rectangle`, `roundedRectangle`, `circle`
- **`TooltipPosition`**: `auto`, `top`, `bottom`, `left`, `right`
- **`TutorialStatus`**: `idle`, `active`, `completed`, `skipped`

## Architecture

```
lib/
  tutorial_overlay_flutter.dart    # Barrel exports
  src/
    enums.dart                     # HighlightShape, TooltipPosition, TutorialStatus
    step_info.dart                 # Step metadata passed to tooltip builders
    tutorial_step.dart             # Step configuration model
    tutorial_config.dart           # Global configuration
    tutorial_controller.dart       # State management (ChangeNotifier)
    tutorial_overlay.dart          # Overlay lifecycle + animated widget
    overlay_painter.dart           # CustomPainter for dimmed overlay with cutout
    tooltip_positioner.dart        # Smart tooltip positioning
    default_tooltip.dart           # Built-in tooltip widget
    tutorial_scope.dart            # InheritedWidget for tree-level access
    tutorial_persistence.dart      # Persistence interface + in-memory impl
```

## Roadmap (v2)

- Arrow/pointer connecting tooltip to target
- Tooltip entry/exit animations (slide, bounce)
- Keyboard navigation and accessibility labels
- Haptic feedback option
- Step groups and branching flows
- Built-in SharedPreferences persistence adapter
- Analytics hooks (step viewed, skipped, completed)
- Backdrop blur option
- Multiple simultaneous highlights
- Widget-level API (`TutorialTarget` wrapper widget as alternative to GlobalKey)

## License

MIT License - Copyright (c) 2026 Brewnbeer

See [LICENSE](LICENSE) for details.
