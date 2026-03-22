import 'package:flutter/widgets.dart';

import 'step_info.dart';
import 'tutorial_config.dart';

/// The built-in tooltip widget used when no custom [tooltipBuilder] is provided.
///
/// Shows title, description, navigation buttons, step indicator, and a
/// progress bar -- all controlled by [TutorialConfig] settings.
class DefaultTooltip extends StatelessWidget {
  /// Current step information and navigation callbacks.
  final StepInfo info;

  /// Configuration controlling appearance and visible elements.
  final TutorialConfig config;

  const DefaultTooltip({
    super.key,
    required this.info,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: config.tooltipPadding,
      decoration: BoxDecoration(
        color: config.tooltipBackgroundColor,
        borderRadius: BorderRadius.circular(config.tooltipBorderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          if (config.showStepIndicator)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Step ${info.currentIndex + 1} of ${info.totalSteps}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: config.primaryColor,
                ),
              ),
            ),

          // Title
          if (info.title != null)
            Padding(
              padding:
                  EdgeInsets.only(bottom: info.description != null ? 8 : 0),
              child: Text(
                info.title!,
                style: config.titleStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                      height: 1.3,
                    ),
              ),
            ),

          // Description
          if (info.description != null)
            Text(
              info.description!,
              style: config.descriptionStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xB3FFFFFF),
                    height: 1.5,
                  ),
            ),

          // Navigation buttons
          if (config.showNavigationButtons) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                // Skip
                if (config.showSkipButton && !info.isLast)
                  GestureDetector(
                    onTap: info.skip,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Text(
                        config.skipText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                    ),
                  ),

                const Spacer(),

                // Previous
                if (!info.isFirst)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: info.previous,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0x33FFFFFF),
                          ),
                        ),
                        child: Text(
                          config.previousText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Next / Finish
                GestureDetector(
                  onTap: info.isLast ? info.finish : info.next,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: config.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      info.isLast ? config.finishText : config.nextText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Progress bar
          if (config.showStepIndicator) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: Stack(
                  children: [
                    // Track
                    Container(color: const Color(0x1AFFFFFF)),
                    // Fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: info.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: config.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
