import 'dart:math';

import 'package:flutter/rendering.dart';

import 'enums.dart';

/// Custom painter that draws the dimmed overlay with a transparent
/// cutout highlighting the target widget.
class OverlayPainter extends CustomPainter {
  final Rect targetRect;
  final HighlightShape shape;
  final double borderRadius;
  final Color overlayColor;
  final Color? borderColor;
  final double borderWidth;
  final double animationProgress;

  OverlayPainter({
    required this.targetRect,
    required this.shape,
    required this.borderRadius,
    required this.overlayColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    // Build combined path with even-odd fill for the cutout effect.
    final path = Path()
      ..addRect(fullRect)
      ..addPath(_cutoutPath(), Offset.zero)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);

    // Optional border around the cutout.
    if (borderColor != null && animationProgress > 0) {
      final a = (borderColor!.a * animationProgress).clamp(0.0, 1.0);
      canvas.drawPath(
        _cutoutPath(),
        Paint()
          ..color = borderColor!.withValues(alpha: a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  Path _cutoutPath() {
    switch (shape) {
      case HighlightShape.rectangle:
        return Path()..addRect(targetRect);
      case HighlightShape.roundedRectangle:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              targetRect,
              Radius.circular(borderRadius),
            ),
          );
      case HighlightShape.circle:
        final radius = max(targetRect.width, targetRect.height) / 2;
        return Path()
          ..addOval(
            Rect.fromCenter(
              center: targetRect.center,
              width: radius * 2,
              height: radius * 2,
            ),
          );
    }
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        shape != oldDelegate.shape ||
        borderRadius != oldDelegate.borderRadius ||
        overlayColor != oldDelegate.overlayColor ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        animationProgress != oldDelegate.animationProgress;
  }
}
