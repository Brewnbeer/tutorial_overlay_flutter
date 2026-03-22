import 'dart:async';

import 'package:flutter/material.dart';

import 'default_tooltip.dart';
import 'enums.dart';
import 'overlay_painter.dart';
import 'tooltip_positioner.dart';
import 'tutorial_config.dart';
import 'tutorial_controller.dart';
import 'tutorial_persistence.dart';
import 'tutorial_step.dart';

/// Entry point for displaying tutorial overlays.
///
/// Use the static [show] method for a simple, one-call API:
///
/// ```dart
/// TutorialOverlay.show(
///   context,
///   steps: [
///     TutorialStep(targetKey: key1, title: 'Search', description: '...'),
///     TutorialStep(targetKey: key2, title: 'Menu', description: '...'),
///   ],
///   onFinish: () => print('Tutorial done!'),
/// );
/// ```
///
/// For more control, create a [TutorialController] and pass it to
/// [showWithController].
class TutorialOverlay {
  TutorialOverlay._();

  /// Displays a tutorial overlay with the given [steps].
  ///
  /// Returns a [TutorialController] that can be used to programmatically
  /// control the tutorial, or `null` if the tutorial was skipped
  /// (e.g. already completed via [persistence]).
  ///
  /// If [tutorialId] and [persistence] are provided, the tutorial is
  /// automatically skipped for users who have already completed it,
  /// and marked as completed when finished.
  static Future<TutorialController?> show(
    BuildContext context, {
    required List<TutorialStep> steps,
    TutorialConfig config = const TutorialConfig(),
    VoidCallback? onFinish,
    VoidCallback? onSkip,
    void Function(int index, TutorialStep step)? onStepChanged,
    String? tutorialId,
    TutorialPersistence? persistence,
  }) async {
    // Check persistence.
    if (tutorialId != null && persistence != null) {
      if (await persistence.isCompleted(tutorialId)) return null;
    }

    final controller = TutorialController(
      steps: steps,
      config: config,
      onFinish: () {
        onFinish?.call();
        if (tutorialId != null && persistence != null) {
          persistence.markCompleted(tutorialId);
        }
      },
      onSkip: onSkip,
      onStepChanged: onStepChanged,
    );

    if (controller.totalSteps == 0) return null;

    if (!context.mounted) return null;

    _insertOverlay(context, controller);
    return controller;
  }

  /// Displays a tutorial overlay driven by an existing [controller].
  ///
  /// Use this when you need to hold onto the controller for external
  /// navigation (e.g. triggered by buttons outside the overlay).
  static void showWithController(
    BuildContext context,
    TutorialController controller,
  ) {
    if (controller.totalSteps == 0 || !context.mounted) return;
    _insertOverlay(context, controller);
  }

  static void _insertOverlay(
    BuildContext context,
    TutorialController controller,
  ) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _TutorialOverlayWidget(
        controller: controller,
        onDismiss: () => entry.remove(),
      ),
    );

    overlayState.insert(entry);
    controller.start();
  }
}

// ---------------------------------------------------------------------------
// Overlay widget (private)
// ---------------------------------------------------------------------------

class _TutorialOverlayWidget extends StatefulWidget {
  final TutorialController controller;
  final VoidCallback onDismiss;

  const _TutorialOverlayWidget({
    required this.controller,
    required this.onDismiss,
  });

  @override
  State<_TutorialOverlayWidget> createState() =>
      _TutorialOverlayWidgetState();
}

class _TutorialOverlayWidgetState extends State<_TutorialOverlayWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _fadeController;
  late final AnimationController _transitionController;
  late final AnimationController _pulseController;
  late final AnimationController _tooltipController;

  Rect _fromRect = Rect.zero;
  Rect _toRect = Rect.zero;

  Timer? _autoAdvanceTimer;
  bool _isDismissing = false;
  int _showStepGeneration = 0;

  TutorialConfig get _config => widget.controller.config;

  Rect get _animatedRect {
    if (_fromRect == Rect.zero) return _toRect;
    final t = _config.animationCurve.transform(_transitionController.value);
    return Rect.lerp(_fromRect, _toRect, t)!;
  }

  // ---- Lifecycle ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: _config.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _tooltipController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _tooltipController.forward();
        _startPulse();
        _startAutoAdvance();
      }
    });

    widget.controller.addListener(_onControllerChanged);

    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showStep(animate: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerChanged);
    _autoAdvanceTimer?.cancel();
    _fadeController.dispose();
    _transitionController.dispose();
    _pulseController.dispose();
    _tooltipController.dispose();
    super.dispose();
  }

  // ---- Orientation / resize -----------------------------------------------

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.isActive) {
        _showStep(animate: false);
      }
    });
  }

  // ---- Controller listener ------------------------------------------------

  void _onControllerChanged() {
    if (!mounted) return;
    final status = widget.controller.status;

    if (status == TutorialStatus.completed ||
        status == TutorialStatus.skipped) {
      _dismiss();
      return;
    }

    if (status == TutorialStatus.active) {
      _showStep(animate: true);
    }
  }

  // ---- Step display -------------------------------------------------------

  Future<void> _showStep({required bool animate}) async {
    final generation = ++_showStepGeneration;
    if (!mounted || !widget.controller.isActive) return;

    final step = widget.controller.currentStep;

    // Auto-scroll target into view.
    if (_config.enableAutoScroll) {
      await _ensureVisible(step);
      if (generation != _showStepGeneration || !mounted) return;
    }

    // Obtain target rect (retry once after a frame if needed).
    var rect = _getTargetRect(step);
    if (rect == null) {
      await Future.delayed(Duration.zero); // yield to allow layout
      if (generation != _showStepGeneration || !mounted) return;
      rect = _getTargetRect(step);
    }

    if (rect == null) {
      // Target genuinely unavailable -- skip this step.
      if (widget.controller.currentIndex <
          widget.controller.totalSteps - 1) {
        widget.controller.next();
      }
      return;
    }

    if (animate && _toRect != Rect.zero) {
      _tooltipController.reverse();
      _pulseController.stop();
      _fromRect = _toRect;
      _toRect = rect;
      _transitionController.forward(from: 0);
    } else {
      _fromRect = rect;
      _toRect = rect;
      _transitionController.value = 1.0;
      _tooltipController.forward();
      _startPulse();
      _startAutoAdvance();
    }

    step.onShow?.call();
  }

  Rect? _getTargetRect(TutorialStep step) {
    final ctx = step.targetKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final p = step.padding;

    return Rect.fromLTWH(
      position.dx - p,
      position.dy - p,
      size.width + p * 2,
      size.height + p * 2,
    );
  }

  Future<void> _ensureVisible(TutorialStep step) async {
    final ctx = step.targetKey.currentContext;
    if (ctx == null) return;
    try {
      await Scrollable.ensureVisible(
        ctx,
        duration: _config.autoScrollDuration,
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (_) {
      // Target is not inside a scrollable -- that's fine.
    }
  }

  // ---- Helpers ------------------------------------------------------------

  void _startPulse() {
    if (_config.enablePulseAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    final duration = widget.controller.currentStep.autoAdvanceAfter;
    if (duration != null) {
      _autoAdvanceTimer = Timer(duration, () {
        if (mounted && widget.controller.isActive) {
          widget.controller.next();
        }
      });
    }
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _autoAdvanceTimer?.cancel();
    _pulseController.stop();

    await _fadeController.reverse();
    if (mounted) widget.onDismiss();
  }

  // ---- Build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenSize = mq.size;
    final safePadding = mq.padding;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: FadeTransition(
        opacity: _fadeController,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _transitionController,
            _pulseController,
            _tooltipController,
          ]),
          builder: (context, _) {
            if (!widget.controller.isActive) return const SizedBox.shrink();

            final step = widget.controller.currentStep;
            final rect = _animatedRect;

            // Pulse inflation.
            double pulseInflation = 0;
            if (_config.enablePulseAnimation &&
                _pulseController.isAnimating) {
              pulseInflation = _pulseController.value * 4;
            }
            final highlightRect = rect.inflate(pulseInflation);

            return Stack(
              children: [
                // Dimmed overlay with cutout.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _config.dismissOnOverlayTap
                        ? () => widget.controller.next()
                        : null,
                    child: CustomPaint(
                      painter: OverlayPainter(
                        targetRect: highlightRect,
                        shape: step.shape,
                        borderRadius: step.borderRadius,
                        overlayColor: _config.overlayColor,
                        borderColor: _config.highlightBorderColor ??
                            _config.primaryColor,
                        borderWidth: _config.highlightBorderWidth,
                        animationProgress: _transitionController.value,
                      ),
                    ),
                  ),
                ),

                // Tooltip.
                if (_tooltipController.value > 0)
                  _buildTooltip(
                    context,
                    rect,
                    screenSize,
                    safePadding,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    Rect targetRect,
    Size screenSize,
    EdgeInsets safePadding,
  ) {
    final step = widget.controller.currentStep;
    final info = widget.controller.currentStepInfo;

    // Resolve tooltip content.
    Widget content;
    if (step.tooltipBuilder != null) {
      content = step.tooltipBuilder!(context, info);
    } else if (_config.tooltipBuilder != null) {
      content = _config.tooltipBuilder!(context, info);
    } else {
      content = DefaultTooltip(info: info, config: _config);
    }

    // Position.
    final pos = TooltipPositioner.calculate(
      targetRect: targetRect,
      screenSize: screenSize,
      safePadding: safePadding,
      spacing: _config.tooltipSpacing,
      preferredPosition: step.tooltipPosition,
    );

    // Horizontal alignment toward the target center.
    final targetCenterX = targetRect.center.dx / screenSize.width;
    final hAlign = Alignment((targetCenterX * 2) - 1, 0);

    return Positioned(
      left: pos.left,
      top: pos.top,
      right: pos.right,
      bottom: pos.bottom,
      child: Align(
        alignment: hAlign,
        child: Opacity(
          opacity: _tooltipController.value,
          child: Transform.scale(
            scale: 0.92 + (_tooltipController.value * 0.08),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _config.tooltipMaxWidth),
              child: Material(
                type: MaterialType.transparency,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
