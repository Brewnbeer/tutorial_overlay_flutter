import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorial_overlay_flutter/tutorial_overlay_flutter.dart';

void main() {
  group('TutorialController', () {
    test('initializes in idle state', () {
      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Step 1'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
        ],
      );

      expect(controller.status, TutorialStatus.idle);
      expect(controller.isActive, false);
      expect(controller.totalSteps, 2);
    });

    test('start activates the controller', () {
      final controller = TutorialController(
        steps: [TutorialStep(targetKey: GlobalKey(), title: 'Step 1')],
      );

      controller.start();

      expect(controller.status, TutorialStatus.active);
      expect(controller.isActive, true);
      expect(controller.currentIndex, 0);
    });

    test('start with empty steps is a no-op', () {
      final controller = TutorialController(steps: const []);

      controller.start();

      expect(controller.status, TutorialStatus.idle);
    });

    test('next advances to the next step', () {
      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Step 1'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 3'),
        ],
      );

      controller.start();
      controller.next();

      expect(controller.currentIndex, 1);

      controller.next();

      expect(controller.currentIndex, 2);
    });

    test('next on last step completes the tutorial', () {
      bool finished = false;
      final controller = TutorialController(
        steps: [TutorialStep(targetKey: GlobalKey(), title: 'Only step')],
        onFinish: () => finished = true,
      );

      controller.start();
      controller.next();

      expect(controller.status, TutorialStatus.completed);
      expect(finished, true);
    });

    test('previous goes back one step', () {
      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Step 1'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
        ],
      );

      controller.start();
      controller.next();
      expect(controller.currentIndex, 1);

      controller.previous();
      expect(controller.currentIndex, 0);
    });

    test('previous on first step is a no-op', () {
      final controller = TutorialController(
        steps: [TutorialStep(targetKey: GlobalKey(), title: 'Step 1')],
      );

      controller.start();
      controller.previous();

      expect(controller.currentIndex, 0);
    });

    test('goToStep jumps to a specific step', () {
      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Step 1'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 3'),
        ],
      );

      controller.start();
      controller.goToStep(2);

      expect(controller.currentIndex, 2);
    });

    test('goToStep ignores invalid indices', () {
      final controller = TutorialController(
        steps: [TutorialStep(targetKey: GlobalKey(), title: 'Step 1')],
      );

      controller.start();
      controller.goToStep(-1);
      expect(controller.currentIndex, 0);

      controller.goToStep(5);
      expect(controller.currentIndex, 0);
    });

    test('skip sets skipped status and fires callback', () {
      bool skipped = false;
      final controller = TutorialController(
        steps: [TutorialStep(targetKey: GlobalKey(), title: 'Step 1')],
        onSkip: () => skipped = true,
      );

      controller.start();
      controller.skip();

      expect(controller.status, TutorialStatus.skipped);
      expect(skipped, true);
    });

    test('filters steps by showIf predicate', () {
      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Visible'),
          TutorialStep(
            targetKey: GlobalKey(),
            title: 'Hidden',
            showIf: () => false,
          ),
          TutorialStep(targetKey: GlobalKey(), title: 'Also visible'),
        ],
      );

      expect(controller.totalSteps, 2);
      expect(controller.steps[0].title, 'Visible');
      expect(controller.steps[1].title, 'Also visible');
    });

    test('onStepChanged fires with correct index', () {
      int? changedIndex;
      String? changedTitle;

      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Step 1'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
        ],
        onStepChanged: (index, step) {
          changedIndex = index;
          changedTitle = step.title;
        },
      );

      controller.start();
      controller.next();

      expect(changedIndex, 1);
      expect(changedTitle, 'Step 2');
    });

    test('onDismiss callback fires when moving away from a step', () {
      bool dismissed = false;
      final controller = TutorialController(
        steps: [
          TutorialStep(
            targetKey: GlobalKey(),
            title: 'Step 1',
            onDismiss: () => dismissed = true,
          ),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
        ],
      );

      controller.start();
      controller.next();

      expect(dismissed, true);
    });

    test('notifies listeners on state changes', () {
      int notifyCount = 0;
      final controller = TutorialController(
        steps: [
          TutorialStep(targetKey: GlobalKey(), title: 'Step 1'),
          TutorialStep(targetKey: GlobalKey(), title: 'Step 2'),
        ],
      );
      controller.addListener(() => notifyCount++);

      controller.start(); // +1
      controller.next(); // +1
      controller.previous(); // +1
      controller.skip(); // +1

      expect(notifyCount, 4);
    });
  });

  group('StepInfo', () {
    test('isFirst and isLast are correct', () {
      final first = StepInfo(
        currentIndex: 0,
        totalSteps: 3,
        next: () {},
        previous: () {},
        skip: () {},
        finish: () {},
      );

      expect(first.isFirst, true);
      expect(first.isLast, false);

      final last = StepInfo(
        currentIndex: 2,
        totalSteps: 3,
        next: () {},
        previous: () {},
        skip: () {},
        finish: () {},
      );

      expect(last.isFirst, false);
      expect(last.isLast, true);
    });

    test('progress is calculated correctly', () {
      final info = StepInfo(
        currentIndex: 1,
        totalSteps: 4,
        next: () {},
        previous: () {},
        skip: () {},
        finish: () {},
      );

      expect(info.progress, closeTo(0.5, 0.001));
    });

    test('progress handles zero total steps', () {
      final info = StepInfo(
        currentIndex: 0,
        totalSteps: 0,
        next: () {},
        previous: () {},
        skip: () {},
        finish: () {},
      );

      expect(info.progress, 1.0);
    });
  });

  group('TutorialConfig', () {
    test('has sensible defaults', () {
      const config = TutorialConfig();

      expect(config.enableAutoScroll, true);
      expect(config.dismissOnOverlayTap, true);
      expect(config.enablePulseAnimation, true);
      expect(config.showStepIndicator, true);
      expect(config.showNavigationButtons, true);
      expect(config.showSkipButton, true);
      expect(config.nextText, 'Next');
      expect(config.finishText, 'Done');
      expect(config.tooltipMaxWidth, 320.0);
    });

    test('copyWith replaces fields', () {
      const original = TutorialConfig(primaryColor: Color(0xFF000000));
      final copy = original.copyWith(primaryColor: const Color(0xFFFF0000));

      expect(copy.primaryColor, const Color(0xFFFF0000));
      expect(copy.tooltipMaxWidth, original.tooltipMaxWidth);
    });
  });

  group('InMemoryPersistence', () {
    test('tracks completion and reset', () async {
      final persistence = InMemoryPersistence();

      expect(await persistence.isCompleted('onboarding'), false);

      await persistence.markCompleted('onboarding');
      expect(await persistence.isCompleted('onboarding'), true);

      await persistence.reset('onboarding');
      expect(await persistence.isCompleted('onboarding'), false);
    });

    test('handles multiple tutorial IDs independently', () async {
      final persistence = InMemoryPersistence();

      await persistence.markCompleted('tutorial_a');

      expect(await persistence.isCompleted('tutorial_a'), true);
      expect(await persistence.isCompleted('tutorial_b'), false);
    });
  });
}
