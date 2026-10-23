# FitTrack – Fitness Tracker App

Flutter fitness tracker built for the **CodeAlpha App Development Internship (Task 3)**.

## Features
- Log workouts manually: exercise type, duration, calories, steps, date, notes
- Dashboard with daily progress ring and progress bars
- Weekly bar and line charts (steps, calories, active minutes)
- Insights: week navigation, best day, goal streaks, activity mix
- History with filters, swipe-to-delete and undo
- Custom daily goals, light and dark theme
- Offline local storage with SQLite

## Tech stack
Flutter · Dart · Provider · sqflite · shared_preferences · fl_chart · intl

## Project structure
```
lib/
  core/        theme, constants
  models/      ActivityEntry, Goals, DaySummary
  services/    SQLite + goal storage
  providers/   ActivityProvider (state)
  screens/     splash, dashboard, history, insights, goals, add/edit
  widgets/     reusable UI components and charts
  utils/       date and format helpers
```

## Run
```
flutter pub get
flutter run
```
Run on Android/iOS emulator or device (SQLite is not supported on web).

## Build APK
```
flutter build apk --release
```

## Author
Mahir Ahamed Rohan