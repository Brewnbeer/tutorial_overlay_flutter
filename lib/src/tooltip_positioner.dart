import 'dart:math';

import 'package:flutter/widgets.dart';

import 'enums.dart';

/// Computed position constraints for a tooltip relative to its target.
class TooltipPositionData {
  /// Which side the tooltip is placed on.
  final TooltipPosition resolvedPosition;

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const TooltipPositionData({
    required this.resolvedPosition,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });
}

/// Calculates optimal tooltip positioning relative to a target widget.
class TooltipPositioner {
  TooltipPositioner._();

  static const double _screenMargin = 16.0;
  static const double _minSpaceThreshold = 120.0;

  /// Calculates the [TooltipPositionData] for a tooltip placed near
  /// [targetRect] within [screenSize], respecting [safePadding].
  static TooltipPositionData calculate({
    required Rect targetRect,
    required Size screenSize,
    required EdgeInsets safePadding,
    required double spacing,
    required TooltipPosition preferredPosition,
  }) {
    final safeTop = safePadding.top + _screenMargin;
    final safeBottom = safePadding.bottom + _screenMargin;
    final safeLeft = safePadding.left + _screenMargin;
    final safeRight = safePadding.right + _screenMargin;

    final spaceAbove = targetRect.top - safeTop;
    final spaceBelow = screenSize.height - targetRect.bottom - safeBottom;

    // Resolve "auto" position.
    TooltipPosition resolved = preferredPosition;
    if (resolved == TooltipPosition.auto) {
      if (spaceBelow >= _minSpaceThreshold) {
        resolved = TooltipPosition.bottom;
      } else if (spaceAbove >= _minSpaceThreshold) {
        resolved = TooltipPosition.top;
      } else {
        resolved =
            spaceBelow >= spaceAbove ? TooltipPosition.bottom : TooltipPosition.top;
      }
    }

    switch (resolved) {
      case TooltipPosition.bottom:
        return TooltipPositionData(
          resolvedPosition: resolved,
          top: targetRect.bottom + spacing,
          bottom: safeBottom,
          left: safeLeft,
          right: safeRight,
        );
      case TooltipPosition.top:
        return TooltipPositionData(
          resolvedPosition: resolved,
          top: safeTop,
          bottom: screenSize.height - targetRect.top + spacing,
          left: safeLeft,
          right: safeRight,
        );
      case TooltipPosition.left:
        return TooltipPositionData(
          resolvedPosition: resolved,
          right: screenSize.width - targetRect.left + spacing,
          top: max(safeTop, targetRect.center.dy - 80),
          bottom: safeBottom,
        );
      case TooltipPosition.right:
        return TooltipPositionData(
          resolvedPosition: resolved,
          left: targetRect.right + spacing,
          top: max(safeTop, targetRect.center.dy - 80),
          bottom: safeBottom,
        );
      case TooltipPosition.auto:
        // Unreachable after resolution above, but dart needs exhaustive switch.
        return calculate(
          targetRect: targetRect,
          screenSize: screenSize,
          safePadding: safePadding,
          spacing: spacing,
          preferredPosition: TooltipPosition.bottom,
        );
    }
  }
}
