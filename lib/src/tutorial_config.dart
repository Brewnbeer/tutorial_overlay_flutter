import 'package:flutter/widgets.dart';

import 'step_info.dart';

/// Global configuration for the tutorial overlay appearance and behavior.
///
/// Pass this to [TutorialOverlay.show] or [TutorialController] to customize
/// the look and feel of the entire tutorial flow.
///
/// ```dart
/// const TutorialConfig(
///   overlayColor: Color(0xBB000000),
///   primaryColor: Color(0xFF2196F3),
///   enablePulseAnimation: true,
///   dismissOnOverlayTap: true,
/// )
/// ```
class TutorialConfig {
  // -- Overlay --

  /// Color of the dimmed overlay background.
  final Color overlayColor;

  /// Duration of the highlight transition animation between steps.
  final Duration animationDuration;

  /// Curve for the highlight transition animation.
  final Curve animationCurve;

  // -- Highlight --

  /// Whether to show a pulsing animation on the highlight border.
  final bool enablePulseAnimation;

  /// Border color around the highlighted widget. Defaults to [primaryColor].
  final Color? highlightBorderColor;

  /// Border width around the highlighted widget.
  final double highlightBorderWidth;

  // -- Auto-scroll --

  /// Automatically scroll the target widget into view if needed.
  final bool enableAutoScroll;

  /// Duration of the auto-scroll animation.
  final Duration autoScrollDuration;

  // -- Interaction --

  /// Advance to the next step when the overlay (outside tooltip) is tapped.
  final bool dismissOnOverlayTap;

  // -- Tooltip text styles --

  /// Text style for step titles in the default tooltip.
  final TextStyle? titleStyle;

  /// Text style for step descriptions in the default tooltip.
  final TextStyle? descriptionStyle;

  // -- Button labels --

  /// Label for the "next" button.
  final String nextText;

  /// Label for the "previous" / back button.
  final String previousText;

  /// Label for the "skip" button.
  final String skipText;

  /// Label for the "finish" button shown on the last step.
  final String finishText;

  // -- Tooltip layout --

  /// Whether to show a step indicator (e.g. "Step 2 of 5") and progress bar.
  final bool showStepIndicator;

  /// Whether to show navigation buttons (next, previous, skip).
  final bool showNavigationButtons;

  /// Whether to show the skip button.
  final bool showSkipButton;

  /// Global custom tooltip builder. Per-step builders take priority.
  final Widget Function(BuildContext context, StepInfo info)? tooltipBuilder;

  /// Background color of the default tooltip.
  final Color tooltipBackgroundColor;

  /// Corner radius of the default tooltip.
  final double tooltipBorderRadius;

  /// Internal padding of the default tooltip.
  final EdgeInsets tooltipPadding;

  /// Maximum width of the tooltip widget.
  final double tooltipMaxWidth;

  /// Spacing between the highlighted widget and the tooltip.
  final double tooltipSpacing;

  // -- Theme --

  /// Primary accent color used for buttons, progress bar, and borders.
  final Color primaryColor;

  const TutorialConfig({
    this.overlayColor = const Color(0xCC000000),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enablePulseAnimation = true,
    this.highlightBorderColor,
    this.highlightBorderWidth = 2.0,
    this.enableAutoScroll = true,
    this.autoScrollDuration = const Duration(milliseconds: 300),
    this.dismissOnOverlayTap = true,
    this.titleStyle,
    this.descriptionStyle,
    this.nextText = 'Next',
    this.previousText = 'Back',
    this.skipText = 'Skip',
    this.finishText = 'Done',
    this.showStepIndicator = true,
    this.showNavigationButtons = true,
    this.showSkipButton = true,
    this.tooltipBuilder,
    this.tooltipBackgroundColor = const Color(0xFF1E1E2E),
    this.tooltipBorderRadius = 12.0,
    this.tooltipPadding = const EdgeInsets.all(20),
    this.tooltipMaxWidth = 320.0,
    this.tooltipSpacing = 16.0,
    this.primaryColor = const Color(0xFF6C63FF),
  });

  /// Creates a copy with the given fields replaced.
  TutorialConfig copyWith({
    Color? overlayColor,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enablePulseAnimation,
    Color? highlightBorderColor,
    double? highlightBorderWidth,
    bool? enableAutoScroll,
    Duration? autoScrollDuration,
    bool? dismissOnOverlayTap,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    String? nextText,
    String? previousText,
    String? skipText,
    String? finishText,
    bool? showStepIndicator,
    bool? showNavigationButtons,
    bool? showSkipButton,
    Widget Function(BuildContext, StepInfo)? tooltipBuilder,
    Color? tooltipBackgroundColor,
    double? tooltipBorderRadius,
    EdgeInsets? tooltipPadding,
    double? tooltipMaxWidth,
    double? tooltipSpacing,
    Color? primaryColor,
  }) {
    return TutorialConfig(
      overlayColor: overlayColor ?? this.overlayColor,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enablePulseAnimation: enablePulseAnimation ?? this.enablePulseAnimation,
      highlightBorderColor: highlightBorderColor ?? this.highlightBorderColor,
      highlightBorderWidth: highlightBorderWidth ?? this.highlightBorderWidth,
      enableAutoScroll: enableAutoScroll ?? this.enableAutoScroll,
      autoScrollDuration: autoScrollDuration ?? this.autoScrollDuration,
      dismissOnOverlayTap: dismissOnOverlayTap ?? this.dismissOnOverlayTap,
      titleStyle: titleStyle ?? this.titleStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      nextText: nextText ?? this.nextText,
      previousText: previousText ?? this.previousText,
      skipText: skipText ?? this.skipText,
      finishText: finishText ?? this.finishText,
      showStepIndicator: showStepIndicator ?? this.showStepIndicator,
      showNavigationButtons:
          showNavigationButtons ?? this.showNavigationButtons,
      showSkipButton: showSkipButton ?? this.showSkipButton,
      tooltipBuilder: tooltipBuilder ?? this.tooltipBuilder,
      tooltipBackgroundColor:
          tooltipBackgroundColor ?? this.tooltipBackgroundColor,
      tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipMaxWidth: tooltipMaxWidth ?? this.tooltipMaxWidth,
      tooltipSpacing: tooltipSpacing ?? this.tooltipSpacing,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}
