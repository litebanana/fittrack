import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  static String? number(String? value, [String field = 'Value']) {
    if (value == null || value.isEmpty) return '$field is required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Value']) {
    final err = number(value, field);
    if (err != null) return err;
    if (double.parse(value!) <= 0) return '$field must be greater than 0';
    return null;
  }
}

class AppFormatters {
  static String date(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
  static String shortDate(DateTime date) => DateFormat('MMM dd').format(date);
  static String time(DateTime date) => DateFormat('HH:mm').format(date);
  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
  static String dayMonth(DateTime date) => DateFormat('dd MMM').format(date);

  static String weight(double w, [String unit = 'kg']) => '${w.toStringAsFixed(1)} $unit';
  static String calories(int cal) => '${NumberFormat.compact().format(cal)} kcal';

  static String duration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}

class AppHelpers {
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDestructive
                ? ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252))
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static double calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static Color bmiColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF2196F3);
    if (bmi < 25) return const Color(0xFF4CAF50);
    if (bmi < 30) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }

  static int calculateTDEE(double weight, double height, int age, String gender, String activityLevel) {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'Male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double multiplier;
    switch (activityLevel) {
      case 'Sedentary':
        multiplier = 1.2;
        break;
      case 'Lightly Active':
        multiplier = 1.375;
        break;
      case 'Moderately Active':
        multiplier = 1.55;
        break;
      case 'Very Active':
        multiplier = 1.725;
        break;
      default:
        multiplier = 1.55;
    }
    return (bmr * multiplier).round();
  }
}
