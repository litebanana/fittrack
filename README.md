# FitTrack 💪

A full-stack personal fitness tracking app built with **Flutter** and **Firebase**.

---

## Features

- 🔐 **Authentication** — Register, login, forgot password, profile management
- 🏠 **Dashboard** — Weight, workouts completed, latest PR, daily nutrition ring
- 🏋️ **Workout Tracking** — Log workouts, add exercises by muscle group, track sets/reps/weight
- 📈 **Progressive Overload** — Auto-detects personal records and shows improvements
- 📊 **Progress Charts** — Weight history line chart (fl_chart)
- 📏 **Body Measurements** — Weight, body fat %, chest, waist, arms, legs
- 📸 **Progress Photos** — Front, side, back photos stored in Firebase Storage
- 🥗 **Nutrition Tracker** — Log meals with calories, protein, carbs, fats
- 👤 **Profile** — BMI calculator, edit personal info, daily nutrition goals

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| State | Provider |
| Charts | fl_chart |
| Fonts | Google Fonts (Inter) |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/     app_constants.dart, exercise_database
│   ├── theme/         app_theme.dart (dark theme, colors, gradients)
│   └── utils/         validators, formatters, helpers
├── data/
│   ├── models/        user_profile, workout, measurement, nutrition
│   ├── repositories/  auth_provider, workout_provider, nutrition/measurement_provider
│   └── services/      auth_service, workout_service, measurement_service,
│                      nutrition_service, storage_service
└── presentation/
    ├── screens/
    │   ├── auth/      login, register, forgot_password
    │   ├── home/      home_screen (dashboard)
    │   ├── workout/   workout_screen, active_workout, add_exercise, detail
    │   ├── progress/  progress_screen (measurements, charts, photos)
    │   ├── nutrition/ nutrition_screen
    │   └── profile/   profile_screen
    └── widgets/
        └── common/    stat_card, gradient_card, circular_progress, empty_state, ...
```

---

## Getting Started

### 1. Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Firebase account
- `flutterfire_cli` installed:
  ```bash
  dart pub global activate flutterfire_cli
  ```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication** → Email/Password
4. Create a **Firestore Database** (start in test mode, then apply security rules)
5. Enable **Firebase Storage**

### 3. Configure Firebase in Flutter

```bash
cd fittrack
flutterfire configure
```

This replaces `lib/firebase_options.dart` with your project config automatically.

### 4. Apply Security Rules

In Firebase Console → Firestore → Rules, paste the contents of `firestore.rules`.
In Firebase Console → Storage → Rules, paste the contents of `storage.rules`.

### 5. Install Dependencies & Run

```bash
flutter pub get
flutter run
```

---

## Firestore Data Structure

```
users/
  {userId}/
    (profile fields)
    workouts/
      {workoutId}/
        name, date, exercises[], notes, isCompleted
    measurements/
      {measurementId}/
        weight, bodyFat, chest, waist, arms, legs, date
    nutrition/
      {entryId}/
        name, calories, protein, carbs, fats, mealType, date
    progressPhotos/
      {photoId}/
        type (front/side/back), photoUrl, date
    personalRecords/
      {exerciseName}/
        weight, reps, date, previousWeight
```

---

## Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

Ensure `minSdkVersion 21` in `android/app/build.gradle`.

## iOS Setup

Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>FitTrack needs photo library access to upload progress photos</string>
<key>NSCameraUsageDescription</key>
<string>FitTrack needs camera access to take progress photos</string>
```

---

## Screenshots

| Dashboard | Workout | Nutrition | Progress |
|-----------|---------|-----------|---------|
| Dark home with nutrition ring | Active workout with set logging | Macro tracking | Weight chart |

---

## License

MIT — free to use for portfolio, personal, or commercial projects.
