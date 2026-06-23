import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/nutrition.dart';
import '../../core/constants/app_constants.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _nutritionRef(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.nutritionCollection);

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> saveFoodEntry(FoodEntry entry) async {
    await _nutritionRef(entry.userId).doc(entry.id).set(entry.toMap());
  }

  Future<void> deleteFoodEntry(String userId, String entryId) async {
    await _nutritionRef(userId).doc(entryId).delete();
  }

  Stream<List<FoodEntry>> getDailyEntriesStream(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _nutritionRef(userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                FoodEntry.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<FoodEntry>> getDailyEntries(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _nutritionRef(userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .get();

    return snap.docs
        .map((doc) => FoodEntry.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<FoodEntry>> getWeeklyEntries(String userId) async {
    final start = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _nutritionRef(userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .orderBy('date', descending: true)
        .get();

    return snap.docs
        .map((doc) => FoodEntry.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
