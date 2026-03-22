/// A Flutter package for creating guided tutorial overlays, onboarding
/// walkthroughs, and step-by-step UI showcases.
///
/// Highlight any widget, show contextual tooltips, and guide users through
/// your app with smooth animations -- all with minimal setup.
///
/// ```dart
/// TutorialOverlay.show(
///   context,
///   steps: [
///     TutorialStep(
///       targetKey: myKey,
///       title: 'Welcome',
///       description: 'This is where you start.',
///     ),
///   ],
/// );
/// ```
library;

export 'src/default_tooltip.dart';
export 'src/enums.dart';
export 'src/step_info.dart';
export 'src/tutorial_config.dart';
export 'src/tutorial_controller.dart';
export 'src/tutorial_overlay.dart' show TutorialOverlay;
export 'src/tutorial_persistence.dart';
export 'src/tutorial_scope.dart';
export 'src/tutorial_step.dart';
