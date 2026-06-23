import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';
import '../../core/constants/app_constants.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _workoutsRef(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.workoutsCollection);

  CollectionReference _prsRef(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.personalRecordsCollection);

  // Workouts
  Future<String> saveWorkout(Workout workout) async {
    await _workoutsRef(workout.userId).doc(workout.id).set(workout.toMap());
    await _checkAndUpdatePRs(workout);
    return workout.id;
  }

  Future<void> updateWorkout(Workout workout) async {
    await _workoutsRef(workout.userId).doc(workout.id).update(workout.toMap());
  }

  Future<void> deleteWorkout(String userId, String workoutId) async {
    await _workoutsRef(userId).doc(workoutId).delete();
  }

  Stream<List<Workout>> getWorkoutsStream(String userId) {
    return _workoutsRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Workout.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<Workout>> getWorkouts(String userId, {int limit = 20}) async {
    final snap = await _workoutsRef(userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((doc) => Workout.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Workout?> getWorkout(String userId, String workoutId) async {
    final doc = await _workoutsRef(userId).doc(workoutId).get();
    if (doc.exists) {
      return Workout.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<int> getWorkoutCount(String userId) async {
    final snap = await _workoutsRef(userId).count().get();
    return snap.count ?? 0;
  }

  // Personal Records
  Future<void> _checkAndUpdatePRs(Workout workout) async {
    for (final exercise in workout.exercises) {
      if (exercise.sets.isEmpty) continue;
      final maxSet = exercise.sets.reduce(
        (a, b) => a.weight > b.weight ? a : b,
      );

      final existingPR = await _getPR(workout.userId, exercise.name);

      if (existingPR == null || maxSet.weight > existingPR.weight) {
        final pr = PersonalRecord(
          userId: workout.userId,
          exerciseName: exercise.name,
          weight: maxSet.weight,
          reps: maxSet.reps,
          date: workout.date,
          previousWeight: existingPR?.weight ?? 0,
          previousReps: existingPR?.reps ?? 0,
        );
        await _prsRef(workout.userId).doc(exercise.name).set(pr.toMap());
      }
    }
  }

  Future<PersonalRecord?> _getPR(String userId, String exerciseName) async {
    final doc = await _prsRef(userId).doc(exerciseName).get();
    if (doc.exists) {
      return PersonalRecord.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<PersonalRecord>> getPRsStream(String userId) {
    return _prsRef(userId).snapshots().map((snap) => snap.docs
        .map((doc) =>
            PersonalRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<PersonalRecord?> getLatestPR(String userId) async {
    final snap = await _prsRef(userId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return PersonalRecord.fromMap(
          snap.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Workout>> getWorkoutsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _workoutsRef(userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((doc) => Workout.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
