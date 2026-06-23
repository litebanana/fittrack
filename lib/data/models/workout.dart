import 'package:uuid/uuid.dart';

class ExerciseSet {
  final String id;
  double weight;
  int reps;
  bool isCompleted;

  ExerciseSet({
    String? id,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'isCompleted': isCompleted,
      };

  factory ExerciseSet.fromMap(Map<String, dynamic> map) => ExerciseSet(
        id: map['id'],
        weight: (map['weight'] ?? 0).toDouble(),
        reps: map['reps'] ?? 0,
        isCompleted: map['isCompleted'] ?? false,
      );

  ExerciseSet copyWith({double? weight, int? reps, bool? isCompleted}) =>
      ExerciseSet(
        id: id,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  double get volume => weight * reps;

  String get display => '${weight.toStringAsFixed(1)}kg × $reps reps';
}

class WorkoutExercise {
  final String id;
  final String name;
  final String muscleGroup;
  List<ExerciseSet> sets;
  int restSeconds;
  String notes;

  WorkoutExercise({
    String? id,
    required this.name,
    required this.muscleGroup,
    List<ExerciseSet>? sets,
    this.restSeconds = 90,
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        sets = sets ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets.map((s) => s.toMap()).toList(),
        'restSeconds': restSeconds,
        'notes': notes,
      };

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) => WorkoutExercise(
        id: map['id'],
        name: map['name'] ?? '',
        muscleGroup: map['muscleGroup'] ?? '',
        sets: (map['sets'] as List<dynamic>?)
                ?.map((s) => ExerciseSet.fromMap(s as Map<String, dynamic>))
                .toList() ??
            [],
        restSeconds: map['restSeconds'] ?? 90,
        notes: map['notes'] ?? '',
      );

  double get totalVolume =>
      sets.fold(0, (sum, s) => sum + s.volume);

  int get totalReps => sets.fold(0, (sum, s) => sum + s.reps);

  double get maxWeight =>
      sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  int get completedSets => sets.where((s) => s.isCompleted).length;
}

class Workout {
  final String id;
  final String userId;
  String name;
  DateTime date;
  List<WorkoutExercise> exercises;
  String notes;
  int? durationMinutes;
  bool isCompleted;
  DateTime createdAt;

  Workout({
    String? id,
    required this.userId,
    required this.name,
    DateTime? date,
    List<WorkoutExercise>? exercises,
    this.notes = '',
    this.durationMinutes,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        exercises = exercises ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'date': date.toIso8601String(),
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'notes': notes,
        'durationMinutes': durationMinutes,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'],
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        exercises: (map['exercises'] as List<dynamic>?)
                ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        notes: map['notes'] ?? '',
        durationMinutes: map['durationMinutes'],
        isCompleted: map['isCompleted'] ?? false,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
      );

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets.length);

  double get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.totalVolume);

  List<String> get muscleGroups =>
      exercises.map((e) => e.muscleGroup).toSet().toList();
}

class PersonalRecord {
  final String id;
  final String userId;
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime date;
  final double previousWeight;
  final int previousReps;

  PersonalRecord({
    String? id,
    required this.userId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    DateTime? date,
    this.previousWeight = 0,
    this.previousReps = 0,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  double get improvement => weight - previousWeight;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'exerciseName': exerciseName,
        'weight': weight,
        'reps': reps,
        'date': date.toIso8601String(),
        'previousWeight': previousWeight,
        'previousReps': previousReps,
      };

  factory PersonalRecord.fromMap(Map<String, dynamic> map) => PersonalRecord(
        id: map['id'],
        userId: map['userId'] ?? '',
        exerciseName: map['exerciseName'] ?? '',
        weight: (map['weight'] ?? 0).toDouble(),
        reps: map['reps'] ?? 0,
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        previousWeight: (map['previousWeight'] ?? 0).toDouble(),
        previousReps: map['previousReps'] ?? 0,
      );
}
