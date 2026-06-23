import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _service = WorkoutService();

  List<Workout> _workouts = [];
  List<PersonalRecord> _personalRecords = [];
  Workout? _activeWorkout;
  bool _isLoading = false;
  String? _error;

  List<Workout> get workouts => _workouts;
  List<PersonalRecord> get personalRecords => _personalRecords;
  Workout? get activeWorkout => _activeWorkout;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalWorkouts => _workouts.length;

  PersonalRecord? get latestPR => _personalRecords.isNotEmpty
      ? (_personalRecords..sort((a, b) => b.date.compareTo(a.date))).first
      : null;

  void loadWorkouts(String userId) {
    _service.getWorkoutsStream(userId).listen((workouts) {
      _workouts = workouts;
      notifyListeners();
    });

    _service.getPRsStream(userId).listen((prs) {
      _personalRecords = prs;
      notifyListeners();
    });
  }

  void startNewWorkout(String userId) {
    _activeWorkout = Workout(
      userId: userId,
      name: 'New Workout',
    );
    notifyListeners();
  }

  void setActiveWorkout(Workout workout) {
    _activeWorkout = workout;
    notifyListeners();
  }

  void updateWorkoutName(String name) {
    _activeWorkout?.name = name;
    notifyListeners();
  }

  void updateWorkoutNotes(String notes) {
    _activeWorkout?.notes = notes;
    notifyListeners();
  }

  void addExercise(WorkoutExercise exercise) {
    _activeWorkout?.exercises.add(exercise);
    notifyListeners();
  }

  void removeExercise(String exerciseId) {
    _activeWorkout?.exercises.removeWhere((e) => e.id == exerciseId);
    notifyListeners();
  }

  void addSet(String exerciseId, ExerciseSet set) {
    final exercise =
        _activeWorkout?.exercises.firstWhere((e) => e.id == exerciseId);
    exercise?.sets.add(set);
    notifyListeners();
  }

  void updateSet(String exerciseId, String setId, ExerciseSet updatedSet) {
    final exercise =
        _activeWorkout?.exercises.firstWhere((e) => e.id == exerciseId);
    if (exercise != null) {
      final index = exercise.sets.indexWhere((s) => s.id == setId);
      if (index >= 0) {
        exercise.sets[index] = updatedSet;
        notifyListeners();
      }
    }
  }

  void removeSet(String exerciseId, String setId) {
    final exercise =
        _activeWorkout?.exercises.firstWhere((e) => e.id == exerciseId);
    exercise?.sets.removeWhere((s) => s.id == setId);
    notifyListeners();
  }

  void toggleSetCompleted(String exerciseId, String setId) {
    final exercise =
        _activeWorkout?.exercises.firstWhere((e) => e.id == exerciseId);
    if (exercise != null) {
      final index = exercise.sets.indexWhere((s) => s.id == setId);
      if (index >= 0) {
        final set = exercise.sets[index];
        exercise.sets[index] = set.copyWith(isCompleted: !set.isCompleted);
        notifyListeners();
      }
    }
  }

  Future<bool> saveWorkout() async {
    if (_activeWorkout == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeWorkout!.isCompleted = true;
      await _service.saveWorkout(_activeWorkout!);
      _activeWorkout = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save workout';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkout(String userId, String workoutId) async {
    try {
      await _service.deleteWorkout(userId, workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete workout';
      notifyListeners();
      return false;
    }
  }

  void cancelWorkout() {
    _activeWorkout = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Workout> getRecentWorkouts({int count = 5}) {
    final sorted = List<Workout>.from(_workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  Map<String, int> getWorkoutsPerWeek() {
    final Map<String, int> result = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.month}/${day.day}';
      result[key] = _workouts
          .where((w) =>
              w.date.year == day.year &&
              w.date.month == day.month &&
              w.date.day == day.day)
          .length;
    }
    return result;
  }
}
