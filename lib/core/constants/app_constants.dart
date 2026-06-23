class AppConstants {
  // App
  static const String appName = 'FitTrack';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String measurementsCollection = 'measurements';
  static const String nutritionCollection = 'nutrition';
  static const String progressPhotosCollection = 'progressPhotos';
  static const String personalRecordsCollection = 'personalRecords';

  // Storage Paths
  static const String progressPhotosPath = 'progress_photos';

  // Muscle Groups
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
    'Full Body',
  ];

  // Fitness Goals
  static const List<String> fitnessGoals = [
    'Build Muscle',
    'Lose Weight',
    'Improve Endurance',
    'Increase Strength',
    'Maintain Fitness',
    'Improve Flexibility',
  ];

  // Default Daily Nutrition Goals
  static const int defaultCalorieGoal = 2500;
  static const int defaultProteinGoal = 150;
  static const int defaultCarbGoal = 300;
  static const int defaultFatGoal = 80;
}

class ExerciseDatabase {
  static const Map<String, List<String>> exercises = {
    'Chest': [
      'Bench Press',
      'Incline Bench Press',
      'Decline Bench Press',
      'Dumbbell Fly',
      'Cable Fly',
      'Push Up',
      'Chest Dip',
    ],
    'Back': [
      'Pull Ups',
      'Chin Ups',
      'Lat Pulldown',
      'Barbell Row',
      'Dumbbell Row',
      'Cable Row',
      'Deadlift',
      'Face Pull',
    ],
    'Legs': [
      'Squat',
      'Front Squat',
      'Leg Press',
      'Romanian Deadlift',
      'Leg Curl',
      'Leg Extension',
      'Calf Raise',
      'Lunges',
      'Bulgarian Split Squat',
    ],
    'Shoulders': [
      'Shoulder Press',
      'Arnold Press',
      'Lateral Raise',
      'Front Raise',
      'Rear Delt Fly',
      'Upright Row',
      'Shrugs',
    ],
    'Arms': [
      'Bicep Curl',
      'Hammer Curl',
      'Preacher Curl',
      'Tricep Pushdown',
      'Skull Crushers',
      'Tricep Dip',
      'Close Grip Bench Press',
      'Concentration Curl',
    ],
    'Core': [
      'Plank',
      'Crunches',
      'Leg Raises',
      'Russian Twist',
      'Cable Crunch',
      'Ab Wheel',
      'Mountain Climbers',
    ],
    'Cardio': [
      'Running',
      'Cycling',
      'Jump Rope',
      'Rowing',
      'Stair Climber',
      'Elliptical',
      'Swimming',
    ],
    'Full Body': [
      'Burpees',
      'Clean and Jerk',
      'Snatch',
      'Thruster',
      'Kettlebell Swing',
    ],
  };
}
