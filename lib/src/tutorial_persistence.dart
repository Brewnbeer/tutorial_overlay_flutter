/// Interface for persisting tutorial completion state.
///
/// Implement this to integrate with your preferred storage solution
/// (SharedPreferences, Hive, SQLite, etc.).
///
/// ```dart
/// class SharedPrefsPersistence implements TutorialPersistence {
///   @override
///   Future<bool> isCompleted(String id) async {
///     final prefs = await SharedPreferences.getInstance();
///     return prefs.getBool('tutorial_$id') ?? false;
///   }
///
///   @override
///   Future<void> markCompleted(String id) async {
///     final prefs = await SharedPreferences.getInstance();
///     await prefs.setBool('tutorial_$id', true);
///   }
///
///   @override
///   Future<void> reset(String id) async {
///     final prefs = await SharedPreferences.getInstance();
///     await prefs.remove('tutorial_$id');
///   }
/// }
/// ```
abstract class TutorialPersistence {
  /// Returns `true` if the tutorial with [tutorialId] has been completed.
  Future<bool> isCompleted(String tutorialId);

  /// Marks the tutorial with [tutorialId] as completed.
  Future<void> markCompleted(String tutorialId);

  /// Resets completion state so the tutorial will show again.
  Future<void> reset(String tutorialId);
}

/// Simple in-memory persistence that resets when the app restarts.
///
/// Useful for development and testing.
class InMemoryPersistence implements TutorialPersistence {
  final Set<String> _completed = {};

  @override
  Future<bool> isCompleted(String tutorialId) async =>
      _completed.contains(tutorialId);

  @override
  Future<void> markCompleted(String tutorialId) async =>
      _completed.add(tutorialId);

  @override
  Future<void> reset(String tutorialId) async =>
      _completed.remove(tutorialId);
}
