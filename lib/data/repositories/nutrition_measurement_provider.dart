import 'package:flutter/foundation.dart';
import '../models/nutrition.dart';
import '../models/measurement.dart';
import '../services/nutrition_service.dart';
import '../services/measurement_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class NutritionProvider extends ChangeNotifier {
  final NutritionService _service = NutritionService();

  List<FoodEntry> _todayEntries = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  List<FoodEntry> get todayEntries => _todayEntries;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCalories => _todayEntries.fold(0, (sum, e) => sum + e.calories);
  double get totalProtein =>
      _todayEntries.fold(0.0, (sum, e) => sum + e.protein);
  double get totalCarbs => _todayEntries.fold(0.0, (sum, e) => sum + e.carbs);
  double get totalFats => _todayEntries.fold(0.0, (sum, e) => sum + e.fats);

  Map<String, List<FoodEntry>> get entriesByMeal {
    final Map<String, List<FoodEntry>> result = {};
    for (final entry in _todayEntries) {
      result.putIfAbsent(entry.mealType, () => []).add(entry);
    }
    return result;
  }

  void loadTodayEntries(String userId) {
    _service.getDailyEntriesStream(userId, _selectedDate).listen((entries) {
      _todayEntries = entries;
      notifyListeners();
    });
  }

  void setDate(String userId, DateTime date) {
    _selectedDate = date;
    loadTodayEntries(userId);
    notifyListeners();
  }

  Future<bool> addFoodEntry(FoodEntry entry) async {
    try {
      await _service.saveFoodEntry(entry);
      return true;
    } catch (e) {
      _error = 'Failed to add food entry';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFoodEntry(String userId, String entryId) async {
    try {
      await _service.deleteFoodEntry(userId, entryId);
      _todayEntries.removeWhere((e) => e.id == entryId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete entry';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class MeasurementProvider extends ChangeNotifier {
  final MeasurementService _measurementService = MeasurementService();
  final StorageService _storageService = StorageService();

  List<BodyMeasurement> _measurements = [];
  List<ProgressPhoto> _progressPhotos = [];
  bool _isLoading = false;
  String? _error;

  List<BodyMeasurement> get measurements => _measurements;
  List<ProgressPhoto> get progressPhotos => _progressPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BodyMeasurement? get latestMeasurement =>
      _measurements.isNotEmpty ? _measurements.first : null;

  double? get weightChange {
    if (_measurements.length < 2) return null;
    return _measurements.first.weight - _measurements.last.weight;
  }

  void loadMeasurements(String userId) {
    _measurementService.getMeasurementsStream(userId).listen((measurements) {
      _measurements = measurements;
      notifyListeners();
    });

    _measurementService.getProgressPhotosStream(userId).listen((photos) {
      _progressPhotos = photos;
      notifyListeners();
    });
  }

  Future<bool> saveMeasurement(BodyMeasurement measurement) async {
    try {
      await _measurementService.saveMeasurement(measurement);
      return true;
    } catch (e) {
      _error = 'Failed to save measurement';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeasurement(String userId, String measurementId) async {
    try {
      await _measurementService.deleteMeasurement(userId, measurementId);
      _measurements.removeWhere((m) => m.id == measurementId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete measurement';
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProgressPhoto({
    required String userId,
    required File file,
    required String photoType,
    required String photoId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = await _storageService.uploadProgressPhoto(
        userId: userId,
        file: file,
        photoType: photoType,
        photoId: photoId,
      );

      final photo = ProgressPhoto(
        id: photoId,
        userId: userId,
        type: photoType,
        photoUrl: url,
      );

      await _measurementService.saveProgressPhoto(photo);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to upload photo';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProgressPhoto(
      String userId, String photoId, String photoUrl) async {
    try {
      await _storageService.deleteFile(photoUrl);
      await _measurementService.deleteProgressPhoto(userId, photoId);
      _progressPhotos.removeWhere((p) => p.id == photoId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete photo';
      notifyListeners();
      return false;
    }
  }

  List<BodyMeasurement> getWeightHistory({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _measurements.where((m) => m.date.isAfter(cutoff)).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
