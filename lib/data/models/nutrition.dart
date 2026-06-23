import 'package:uuid/uuid.dart';

class FoodEntry {
  final String id;
  final String userId;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double servingSize;
  final String servingUnit;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack

  FoodEntry({
    String? id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.servingSize = 100,
    this.servingUnit = 'g',
    DateTime? date,
    this.mealType = 'Other',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'servingSize': servingSize,
        'servingUnit': servingUnit,
        'date': date.toIso8601String(),
        'mealType': mealType,
      };

  factory FoodEntry.fromMap(Map<String, dynamic> map) => FoodEntry(
        id: map['id'],
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        calories: map['calories'] ?? 0,
        protein: (map['protein'] ?? 0).toDouble(),
        carbs: (map['carbs'] ?? 0).toDouble(),
        fats: (map['fats'] ?? 0).toDouble(),
        servingSize: (map['servingSize'] ?? 100).toDouble(),
        servingUnit: map['servingUnit'] ?? 'g',
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        mealType: map['mealType'] ?? 'Other',
      );

  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Pre-workout',
    'Post-workout',
    'Other',
  ];
}

class DailyNutrition {
  final DateTime date;
  final List<FoodEntry> entries;
  final int calorieGoal;
  final int proteinGoal;
  final int carbGoal;
  final int fatGoal;

  DailyNutrition({
    required this.date,
    required this.entries,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbGoal,
    required this.fatGoal,
  });

  int get totalCalories => entries.fold(0, (sum, e) => sum + e.calories);
  double get totalProtein => entries.fold(0.0, (sum, e) => sum + e.protein);
  double get totalCarbs => entries.fold(0.0, (sum, e) => sum + e.carbs);
  double get totalFats => entries.fold(0.0, (sum, e) => sum + e.fats);

  double get calorieProgress =>
      calorieGoal > 0 ? totalCalories / calorieGoal : 0;
  double get proteinProgress =>
      proteinGoal > 0 ? totalProtein / proteinGoal : 0;
  double get carbProgress => carbGoal > 0 ? totalCarbs / carbGoal : 0;
  double get fatProgress => fatGoal > 0 ? totalFats / fatGoal : 0;

  int get remainingCalories => calorieGoal - totalCalories;
}
