import 'package:flutter/widgets.dart';

import 'tutorial_controller.dart';

/// Provides a [TutorialController] to descendant widgets via the widget tree.
///
/// Wrap a subtree in [TutorialScope] to allow any descendant to access the
/// controller and react to tutorial state changes.
///
/// ```dart
/// TutorialScope(
///   controller: myController,
///   child: MyApp(),
/// )
///
/// // Later, in any descendant:
/// final controller = TutorialScope.of(context);
/// controller.next();
/// ```
class TutorialScope extends InheritedNotifier<TutorialController> {
  const TutorialScope({
    super.key,
    required TutorialController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the nearest [TutorialController], or `null` if none exists.
  static TutorialController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TutorialScope>()
        ?.notifier;
  }

  /// Returns the nearest [TutorialController].
  ///
  /// Throws if no [TutorialScope] is found in the widget tree.
  static TutorialController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No TutorialScope found in the widget tree.');
    return controller!;
  }
}
