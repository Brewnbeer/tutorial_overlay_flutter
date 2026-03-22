import 'dart:ui';

/// Information about the current tutorial step, passed to tooltip builders.
///
/// Provides navigation callbacks and metadata that tooltip widgets can use
/// to render step-aware UI (progress indicators, navigation buttons, etc.).
class StepInfo {
  /// Zero-based index of the current step.
  final int currentIndex;

  /// Total number of steps in the tutorial.
  final int totalSteps;

  /// Title of the current step, if provided.
  final String? title;

  /// Description of the current step, if provided.
  final String? description;

  /// Advance to the next step. On the last step, this completes the tutorial.
  final VoidCallback next;

  /// Go back to the previous step. No-op on the first step.
  final VoidCallback previous;

  /// Skip the entire tutorial immediately.
  final VoidCallback skip;

  /// Complete the tutorial immediately, regardless of current step.
  final VoidCallback finish;

  const StepInfo({
    required this.currentIndex,
    required this.totalSteps,
    this.title,
    this.description,
    required this.next,
    required this.previous,
    required this.skip,
    required this.finish,
  });

  /// Whether this is the first step.
  bool get isFirst => currentIndex == 0;

  /// Whether this is the last step.
  bool get isLast => currentIndex == totalSteps - 1;

  /// Progress as a value between 0.0 and 1.0.
  double get progress =>
      totalSteps > 0 ? (currentIndex + 1) / totalSteps : 1.0;
}
