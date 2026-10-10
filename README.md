# ChurchMate

An all-in-one mobile management system for church youth organizations — Faith (attendance + QR check-in), Library, and Finance modules, unified under one account system and dashboard.

## Tech stack

- **Frontend:** Flutter / Dart
- **Backend:** Firebase
  - Firebase Authentication — login + role-based access (Youth Leader / Youth Member)
  - Cloud Firestore — main database (users, events, attendance, books, transactions)
  - Firebase Cloud Storage — book cover images
  - Firebase Cloud Messaging — push notifications (event reminders, overdue alerts, budget alerts, task assignments)
  - Cloud Functions — server-side logic (e.g. expiring QR codes, computing budget balance)
- **State management:** Provider
- **QR codes:** `qr_flutter` (generate), `mobile_scanner` (scan)
- **Reports:** `pdf`, `csv` packages for PDF/CSV export

## Getting started

1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. Create the actual Flutter project shell (this scaffold only contains `lib/`, not the generated `android/`/`ios`/`web` folders):
   ```
   flutter create --org com.churchmate churchmate
   ```
3. Copy this scaffold's `lib/`, `pubspec.yaml`, `assets/`, and `test/` into the project `flutter create` generated, overwriting the defaults.
4. Set up a Firebase project at https://console.firebase.google.com, enable Authentication (Email/Password), Firestore, Storage, and Cloud Messaging.
5. Run `flutterfire configure` to connect your app to Firebase (installs `firebase_options.dart`).
6. `flutter pub get`
7. `flutter run`

## Folder structure

```
lib/
  app/                      # App-level setup: routes, theme, root widget
  core/
    services/                # Cross-cutting services (auth, firestore, notifications)
    constants/                # App-wide constants (colors, strings, roles)
    utils/                    # Helper functions (date formatting, validators)
  features/
    auth/                     # Login, registration, role assignment
      screens/
      models/
    dashboard/                # Unified home dashboard
      screens/
    faith/                    # Attendance, QR check-in, events, tasks
      screens/
      models/
      services/
    library/                  # Book catalog, borrowing, reservations
      screens/
      models/
      services/
    finance/                  # Donations, expenses, budget, reports
      screens/
      models/
      services/
  shared/
    widgets/                  # Reusable UI (buttons, cards, dashboard tiles)
    models/                   # Shared models (e.g. AppUser used across features)
test/                         # Widget/unit tests
assets/                       # Images, icons
docs/                         # Diagrams, ERD, notes for your defense
```

**Why feature-first, not layer-first:** each module (`faith/`, `library/`, `finance/`) is self-contained with its own screens/models/services. This matches your three-module system directly, makes it easy for group members to work on separate modules without touching each other's files, and keeps merge conflicts low.

## Branching convention (for a 2–3 person group)

- `main` — always stable/working. Never commit directly.
- `develop` — integration branch, merge finished features here first.
- `feature/<module>-<short-name>` — e.g. `feature/faith-qr-checkin`, `feature/library-catalog`, `feature/finance-approval`.

Workflow: branch off `develop` → build the feature → open a pull request back into `develop` → teammate reviews → merge. Merge `develop` into `main` at each milestone (midterm, finals).

## Task board

See `docs/TASKS.md` for the initial backlog, organized to match the Feature Checklist from your progress tracker. Recommended: recreate this as a GitHub Projects board (Kanban) so the whole group can see status live — setup steps are in that file.
