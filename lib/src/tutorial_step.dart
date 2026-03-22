import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'step_info.dart';

/// Defines a single step in a tutorial flow.
///
/// Each step targets a widget identified by [targetKey] and displays
/// a tooltip with [title] and [description], or a fully custom widget
/// via [tooltipBuilder].
///
/// ```dart
/// TutorialStep(
///   targetKey: myButtonKey,
///   title: 'Create New Item',
///   description: 'Tap this button to create a new item.',
///   shape: HighlightShape.circle,
///   padding: 12,
/// )
/// ```
class TutorialStep {
  /// GlobalKey attached to the widget that should be highlighted.
  final GlobalKey targetKey;

  /// Title text displayed in the default tooltip.
  final String? title;

  /// Description text displayed in the default tooltip.
  final String? description;

  /// Custom tooltip builder. When provided, [title] and [description]
  /// are still available via [StepInfo] but the default tooltip is replaced.
  final Widget Function(BuildContext context, StepInfo info)? tooltipBuilder;

  /// Shape of the highlight cutout around the target widget.
  final HighlightShape shape;

  /// Extra padding around the highlighted widget.
  final double padding;

  /// Corner radius for [HighlightShape.roundedRectangle].
  final double borderRadius;

  /// Preferred tooltip position. Defaults to [TooltipPosition.auto].
  final TooltipPosition tooltipPosition;

  /// If set, automatically advance to the next step after this duration.
  final Duration? autoAdvanceAfter;

  /// Conditional display predicate. Return `false` to skip this step.
  final bool Function()? showIf;

  /// Called when this step becomes visible.
  final VoidCallback? onShow;

  /// Called when this step is dismissed (navigated away from).
  final VoidCallback? onDismiss;

  const TutorialStep({
    required this.targetKey,
    this.title,
    this.description,
    this.tooltipBuilder,
    this.shape = HighlightShape.roundedRectangle,
    this.padding = 8.0,
    this.borderRadius = 8.0,
    this.tooltipPosition = TooltipPosition.auto,
    this.autoAdvanceAfter,
    this.showIf,
    this.onShow,
    this.onDismiss,
  });
}
