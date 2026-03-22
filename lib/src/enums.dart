/// Shape of the highlight cutout around the target widget.
enum HighlightShape {
  /// Rectangular highlight with sharp corners.
  rectangle,

  /// Rectangular highlight with rounded corners.
  roundedRectangle,

  /// Circular highlight centered on the target widget.
  circle,
}

/// Preferred position for the tooltip relative to the target widget.
enum TooltipPosition {
  /// Automatically determine the best position based on available space.
  auto,

  /// Position the tooltip above the target.
  top,

  /// Position the tooltip below the target.
  bottom,

  /// Position the tooltip to the left of the target.
  left,

  /// Position the tooltip to the right of the target.
  right,
}

/// Current status of the tutorial flow.
enum TutorialStatus {
  /// Tutorial has not started yet.
  idle,

  /// Tutorial is actively showing steps.
  active,

  /// Tutorial was completed (all steps finished).
  completed,

  /// Tutorial was skipped by the user.
  skipped,
}
