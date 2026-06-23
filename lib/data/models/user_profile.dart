class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double height; // cm
  final double weight; // kg
  final String fitnessGoal;
  final String gender;
  final String activityLevel;
  final int calorieGoal;
  final int proteinGoal;
  final int carbGoal;
  final int fatGoal;
  final String? photoUrl;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    this.gender = 'Male',
    this.activityLevel = 'Moderately Active',
    this.calorieGoal = 2500,
    this.proteinGoal = 150,
    this.carbGoal = 300,
    this.fatGoal = 80,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'gender': gender,
      'activityLevel': activityLevel,
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbGoal': carbGoal,
      'fatGoal': fatGoal,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      height: (map['height'] ?? 170).toDouble(),
      weight: (map['weight'] ?? 70).toDouble(),
      fitnessGoal: map['fitnessGoal'] ?? 'Build Muscle',
      gender: map['gender'] ?? 'Male',
      activityLevel: map['activityLevel'] ?? 'Moderately Active',
      calorieGoal: map['calorieGoal'] ?? 2500,
      proteinGoal: map['proteinGoal'] ?? 150,
      carbGoal: map['carbGoal'] ?? 300,
      fatGoal: map['fatGoal'] ?? 80,
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? gender,
    String? activityLevel,
    int? calorieGoal,
    int? proteinGoal,
    int? carbGoal,
    int? fatGoal,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbGoal: carbGoal ?? this.carbGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
