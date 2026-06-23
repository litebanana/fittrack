import 'package:uuid/uuid.dart';

class BodyMeasurement {
  final String id;
  final String userId;
  final double weight;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? arms;
  final double? legs;
  final double? neck;
  final String notes;
  final DateTime date;

  BodyMeasurement({
    String? id,
    required this.userId,
    required this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.arms,
    this.legs,
    this.neck,
    this.notes = '',
    DateTime? date,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'weight': weight,
        'bodyFat': bodyFat,
        'chest': chest,
        'waist': waist,
        'arms': arms,
        'legs': legs,
        'neck': neck,
        'notes': notes,
        'date': date.toIso8601String(),
      };

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) => BodyMeasurement(
        id: map['id'],
        userId: map['userId'] ?? '',
        weight: (map['weight'] ?? 0).toDouble(),
        bodyFat: map['bodyFat']?.toDouble(),
        chest: map['chest']?.toDouble(),
        waist: map['waist']?.toDouble(),
        arms: map['arms']?.toDouble(),
        legs: map['legs']?.toDouble(),
        neck: map['neck']?.toDouble(),
        notes: map['notes'] ?? '',
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      );
}

class ProgressPhoto {
  final String id;
  final String userId;
  final String type; // front, side, back
  final String photoUrl;
  final DateTime date;
  final String notes;

  ProgressPhoto({
    String? id,
    required this.userId,
    required this.type,
    required this.photoUrl,
    DateTime? date,
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'type': type,
        'photoUrl': photoUrl,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) => ProgressPhoto(
        id: map['id'],
        userId: map['userId'] ?? '',
        type: map['type'] ?? 'front',
        photoUrl: map['photoUrl'] ?? '',
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        notes: map['notes'] ?? '',
      );
}
