import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/measurement.dart';
import '../../core/constants/app_constants.dart';

class MeasurementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _measurementsRef(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.measurementsCollection);

  CollectionReference _photosRef(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.progressPhotosCollection);

  Future<void> saveMeasurement(BodyMeasurement measurement) async {
    await _measurementsRef(measurement.userId)
        .doc(measurement.id)
        .set(measurement.toMap());
  }

  Future<void> deleteMeasurement(String userId, String measurementId) async {
    await _measurementsRef(userId).doc(measurementId).delete();
  }

  Stream<List<BodyMeasurement>> getMeasurementsStream(String userId) {
    return _measurementsRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                BodyMeasurement.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<BodyMeasurement>> getMeasurements(String userId) async {
    final snap = await _measurementsRef(userId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((doc) =>
            BodyMeasurement.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<BodyMeasurement?> getLatestMeasurement(String userId) async {
    final snap = await _measurementsRef(userId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return BodyMeasurement.fromMap(
          snap.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Progress Photos
  Future<void> saveProgressPhoto(ProgressPhoto photo) async {
    await _photosRef(photo.userId).doc(photo.id).set(photo.toMap());
  }

  Future<void> deleteProgressPhoto(String userId, String photoId) async {
    await _photosRef(userId).doc(photoId).delete();
  }

  Stream<List<ProgressPhoto>> getProgressPhotosStream(String userId) {
    return _photosRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                ProgressPhoto.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<ProgressPhoto>> getProgressPhotos(String userId) async {
    final snap =
        await _photosRef(userId).orderBy('date', descending: true).get();
    return snap.docs
        .map((doc) => ProgressPhoto.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
