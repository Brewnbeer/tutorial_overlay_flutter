import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'step_info.dart';
import 'tutorial_config.dart';
import 'tutorial_step.dart';

/// Controls the state and navigation of a tutorial flow.
///
/// The controller manages the list of steps, current index, and status.
/// It does **not** manage the overlay lifecycle -- that is handled by
/// [TutorialOverlay].
///
/// ```dart
/// final controller = TutorialController(
///   steps: [
///     TutorialStep(targetKey: key1, title: 'Step 1'),
///     TutorialStep(targetKey: key2, title: 'Step 2'),
///   ],
///   onFinish: () => print('Done!'),
/// );
/// ```
class TutorialController extends ChangeNotifier {
  final List<TutorialStep> _steps;

  /// Configuration for the tutorial appearance and behavior.
  final TutorialConfig config;

  int _currentIndex = 0;
  TutorialStatus _status = TutorialStatus.idle;

  /// Called when the tutorial is completed (all steps finished).
  VoidCallback? onFinish;

  /// Called when the tutorial is skipped.
  VoidCallback? onSkip;

  /// Called when the active step changes.
  void Function(int index, TutorialStep step)? onStepChanged;

  /// Creates a controller with the given [steps] and optional [config].
  ///
  /// Steps where [TutorialStep.showIf] returns `false` are filtered out
  /// at construction time.
  TutorialController({
    required List<TutorialStep> steps,
    this.config = const TutorialConfig(),
    this.onFinish,
    this.onSkip,
    this.onStepChanged,
  }) : _steps = steps.where((s) => s.showIf?.call() ?? true).toList();

  /// The filtered list of active steps.
  List<TutorialStep> get steps => List.unmodifiable(_steps);

  /// Zero-based index of the current step.
  int get currentIndex => _currentIndex;

  /// Current status of the tutorial.
  TutorialStatus get status => _status;

  /// Whether the tutorial is actively showing steps.
  bool get isActive => _status == TutorialStatus.active;

  /// Total number of active steps.
  int get totalSteps => _steps.length;

  /// The current [TutorialStep].
  TutorialStep get currentStep {
    assert(_steps.isNotEmpty, 'No tutorial steps available');
    return _steps[_currentIndex];
  }

  /// Creates a [StepInfo] snapshot for the current step.
  ///
  /// Useful for passing to tooltip builders.
  StepInfo get currentStepInfo => StepInfo(
        currentIndex: _currentIndex,
        totalSteps: _steps.length,
        title: currentStep.title,
        description: currentStep.description,
        next: next,
        previous: previous,
        skip: skip,
        finish: complete,
      );

  /// Activates the tutorial and sets the current step to the first one.
  void start() {
    if (_steps.isEmpty) return;
    _currentIndex = 0;
    _status = TutorialStatus.active;
    notifyListeners();
  }

  /// Advances to the next step. Completes the tutorial if on the last step.
  void next() {
    if (!isActive) return;
    currentStep.onDismiss?.call();
    if (_currentIndex >= _steps.length - 1) {
      complete();
      return;
    }
    _currentIndex++;
    onStepChanged?.call(_currentIndex, _steps[_currentIndex]);
    notifyListeners();
  }

  /// Goes back to the previous step. No-op if already on the first step.
  void previous() {
    if (!isActive || _currentIndex <= 0) return;
    currentStep.onDismiss?.call();
    _currentIndex--;
    onStepChanged?.call(_currentIndex, _steps[_currentIndex]);
    notifyListeners();
  }

  /// Jumps to a specific step by [index].
  void goToStep(int index) {
    if (!isActive) return;
    if (index < 0 || index >= _steps.length) return;
    currentStep.onDismiss?.call();
    _currentIndex = index;
    onStepChanged?.call(_currentIndex, _steps[_currentIndex]);
    notifyListeners();
  }

  /// Skips the tutorial entirely.
  void skip() {
    if (!isActive) return;
    currentStep.onDismiss?.call();
    _status = TutorialStatus.skipped;
    onSkip?.call();
    notifyListeners();
  }

  /// Completes the tutorial (marks as finished).
  void complete() {
    if (_status == TutorialStatus.completed) return;
    _status = TutorialStatus.completed;
    onFinish?.call();
    notifyListeners();
  }
}
