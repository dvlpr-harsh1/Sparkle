# Sparkle — Health Journey Manager

A cross-platform Flutter MVP that helps a user manage their own and a dependent's health journey in one place.

---

## Quick Setup

```bash
# 1. Clone the repo
git clone https://github.com/dvlpr-harsh1/Sparkle.git
cd sparkle

# 2. Install dependencies
flutter pub get

# 3. Firebase is already configured via FlutterFire CLI
#    firebase_options.dart is included in the repo for easy setup

# 4. Run
flutter run
```

**Requirements:** Flutter 3.x, Dart 3.x, iOS 13+ / Android 6+

---

## Architecture

### Feature-first Clean Architecture

Every feature is a self-contained module with three layers:

```
lib/
├── core/                        # Shared across all features
│   ├── constants/               # Firestore collection names, app-wide constants
│   ├── errors/                  # Sealed error classes (AuthError, NetworkError, UnknownError)
│   ├── routers/                 # GoRouter with ShellRoute and auth redirect guard
│   └── themes/                  # Material 3 theme, colors, input styles
│
├── features/
│   ├── auth/
│   │   ├── data/                # AuthRepository — wraps FirebaseAuth
│   │   ├── domain/              # User entity
│   │   └── presentation/
│   │       ├── bloc/            # AuthBloc (events, states, bloc)
│   │       ├── login_page.dart
│   │       └── sign_up_page.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   ├── model/           # UserProfile, DependentModel
│   │   │   └── repository/      # ProfileRepository — Firestore streams
│   │   └── presentation/
│   │       ├── bloc/            # ProfileBloc
│   │       ├── profile_page.dart
│   │       └── add_dependent_page.dart
│   │
│   ├── records/
│   │   ├── data/
│   │   │   ├── model/           # HealthRecord, RecordCategory enum
│   │   │   └── repository/      # RecordRepository — Firestore streams
│   │   └── presentation/
│   │       ├── bloc/            # RecordBloc
│   │       ├── record_page.dart
│   │       └── add_record_page.dart
│   │
│   ├── reminders/
│   │   ├── data/
│   │   │   ├── model/           # ReminderModel, ReminderType enum
│   │   │   └── repository/      # ReminderRepository — Firestore streams
│   │   └── presentation/
│   │       ├── bloc/            # ReminderBloc
│   │       ├── reminder_page.dart
│   │       └── add_reminder_page.dart
│   │
│   ├── dashboard/
│   │   └── presentation/
│   │       └── dashboard_page.dart  # Aggregates all three BLoCs
│   │
│   └── insights/
│       └── data/
│           ├── insight_model.dart   # InsightModel with type enum
│           └── insights_engine.dart # Pure Dart rule engine
│
├── shared/
│   └── widgets/                 # SparkleTextField, RecordCard, DependentListTile
│
└── main.dart
```

### State Management — BLoC

BLoC (Business Logic Component) was chosen over Provider or Riverpod for three reasons:

1. **Explicit state transitions** — every state change goes through a typed event. In a health app where data accuracy matters, you want to know exactly what triggered every state change.
2. **Parallel streams** — profile, records, and reminders run as simultaneous Firestore streams. BLoC handles this cleanly via `emit.forEach` and `rxdart`'s `combineLatest2`.
3. **Testability** — BLoC events and states are pure Dart. Business logic can be unit tested without Firebase or Flutter.

### Data Flow

```
UI fires Event
    ↓
BLoC receives event, calls Repository method
    ↓
Repository talks to Firestore
    ↓
Firestore returns Map<String, dynamic>
    ↓
Repository converts to typed Dart model (fromMap)
    ↓
BLoC emits new State
    ↓
UI rebuilds via BlocBuilder / BlocConsumer
```

---

## Data Model

### Firestore Structure

```
users/
  {userId}/
    name, email, dateOfBirth, gender, bloodGroup
    │
    ├── dependents/
    │     {dependentId}/
    │       name, relation, dateOfBirth, gender, bloodGroup
    │
    ├── records/
    │     {recordId}/
    │       userId, dependentId (nullable), category, date,
    │       provider, notes, details (map), isShared, sharedWith (list)
    │
    └── reminders/
          {reminderId}/
            userId, dependentId (nullable), title, type,
            dateTime (Timestamp), isDone, notes
```

### Key model decisions

**`dependentId` on records and reminders** — nullable field. `null` means the record belongs to the primary user. A non-null value links it to a specific dependent. This keeps all data under one user document while supporting family health management.

**`details: Map<String, dynamic>` on HealthRecord** — stores category-specific data without creating separate Firestore collections. Prescription stores `medicineName` and `dosage`. Lab stores `labName`. Vaccine stores `vaccineName`. Visit stores `diagnosis`.

**`Timestamp` for reminder dateTime** — Firestore's native `Timestamp` type is used instead of storing dates as strings. This allows proper ordering queries and accurate overdue calculations.

---

## Features Implemented

| Feature | Status | Notes |
|---|---|---|
| Sign up / log in / log out | Implemented | Firebase Auth, email + password |
| Primary profile | Implemented | Name, DOB, gender, blood group, completion % |
| Add dependents | Implemented | Name, relation, DOB, gender — linked to primary account |
| Health record vault | Implemented | Prescription, lab, vaccine, visit with category-specific fields |
| Record sharing | Implemented | `isShared` flag + `sharedWith` list, Firestore rules enforce access |
| Dashboard | Implemented | Greeting, status snapshot, upcoming reminders, recent records |
| Reminders | Implemented | Medication, appointment, follow-up with date/time picker |
| Mark reminder complete | Implemented | Checkbox toggle, persists to Firestore |
| Sparkle Insights | Implemented | 6 rule-based insights, clearly labelled informational only |
| Push notifications | Not implemented | Data model ready, UI shows overdue badge — see trade-offs |

---

## Sparkle Insights — Rule Engine

`InsightsEngine` is a pure Dart static class. Zero Flutter dependencies. Takes profile, records, and reminders as input and returns a list of `InsightModel` objects.

Rules implemented:
1. Profile completion below 100% → tip to complete profile
2. No records at all → prompt to start health vault
3. No vaccination record → warning, or if last vaccination was over 12 months ago
4. No visit/checkup record → annual checkup due, or if last visit was over 12 months ago
5. Overdue reminders exist → count shown with warning
6. All rules pass → positive "everything looks good" insight

**Important:** Every insight card displays "Informational only — not medical advice" as a subtitle. No diagnosis, treatment plan, or clinical language is used anywhere in the app.

---

## Security and Privacy Decisions

### Decision 1 — Firestore Security Rules (most important)

Firestore is locked at the rules level, not just in the app code. App-level checks alone are not enough because anyone with network access can call Firestore directly.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      // Dependents — same, only the owner
      match /dependents/{dependentId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }

      // Records — owner can read/write
      // Caregiver can read only if their uid is in sharedWith
      match /records/{recordId} {
        allow write: if request.auth != null
                     && request.auth.uid == userId;
        allow read: if request.auth != null
                    && (request.auth.uid == userId
                        || request.auth.uid in resource.data.sharedWith);
      }

      // Reminders — owner only
      match /reminders/{reminderId} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

**Why this matters:** Even if someone bypasses the Flutter app, Firestore rejects the request at the server level.

### Decision 2 — Sharing is opt-in by default

Every health record is created with `isShared: false` and `sharedWith: []`. Users must explicitly tap the share icon on a specific record to share it. There is no "share all records" option. This follows the privacy principle of minimal disclosure.

### Decision 3 — Session clears on logout

`FirebaseAuth.signOut()` clears the local auth token. GoRouter's redirect guard immediately detects `AuthUnauthenticated` state and pushes to login. No health data persists in memory after logout.

### Decision 4 — No sensitive data in logs

Error messages shown to users are mapped from Firebase error codes to human-readable strings in `app_errors.dart`. Raw Firebase error codes and stack traces are never displayed in the UI.

---

## Assumptions and Shortcuts

**Date stored as String (DD/MM/YYYY)** — records store date as a formatted string instead of a Timestamp. This simplified the add record form (plain text field vs date picker). `InsightsEngine._mostRecentDate()` parses this string back to `DateTime` for rule evaluation. In production this would be a Timestamp field with a proper date picker.

**File upload is not implemented** — the PDF mentions "upload records." The data model has a `fileUrl` field ready for this. In production this would use Firebase Storage. For the MVP, users type in the record details manually.

**Push notifications are not implemented** — reminders store a `dateTime` in Firestore. The app shows overdue reminders in red and a badge count on the tab. Actual device notifications would require `flutter_local_notifications` with a background service. This is listed as an optional stretch in the brief.

**No offline mode** — Firestore's default local cache provides some offline reading. Writes will queue and sync when connectivity returns. Explicit offline indicators are not implemented in the MVP.

**Single-level dependents** — dependents are one level deep (primary user's family). Nested dependents (e.g., managing a dependent's dependents) are out of scope.

**Name collision in dependent selector** — if two dependents have the same name, the dropdown lookup by name could return the wrong one. In production, lookup would use `dependentId` directly.

---

## Trade-offs

| Decision | What I chose | What I'd do in production |
|---|---|---|
| Date format | String DD/MM/YYYY | Firestore Timestamp + DatePicker |
| File upload | Skipped, field ready | Firebase Storage + image/PDF picker |
| Push notifications | Skipped, data model ready | flutter_local_notifications + background fetch |
| Offline mode | Firestore default cache | Explicit sync state + offline indicators |
| Security rules | Basic owner + sharedWith | Field-level validation + audit logging |
| Error handling | User-friendly messages | Crash reporting (Sentry/Firebase Crashlytics) |

---

## What I Would Improve for Production

**Priority 1 — Security**
- Complete Firestore security rules with field-level validation
- End-to-end encryption for `notes` and `diagnosis` fields (AES-256)
- Biometric app lock (Face ID / fingerprint) before viewing records
- Certificate pinning on all API calls

**Priority 2 — Compliance**
- Audit log collection — every record read/write stamped with timestamp and user ID
- DPDP Act alignment for Indian users (the company is Indian-based)
- Data deletion flow — user can request full account and data deletion

**Priority 3 — Features**
- Push notifications for reminders using `flutter_local_notifications`
- File upload for actual prescription images and lab PDFs via Firebase Storage
- Search and filter within the health record vault
- Granular sharing controls — share with specific provider for a time-limited period

**Priority 4 — Reliability**
- Comprehensive widget tests for all core screens
- Integration tests for auth and record CRUD flows
- CI/CD pipeline with GitHub Actions running tests on every PR

---

## Testing

Unit tests cover the core business logic that is most critical in a health app:

```
test/
├── insights/
│   └── insights_engine_test.dart    # All 6 insight rules tested in isolation
├── auth/
│   └── auth_bloc_test.dart          # SignIn, SignUp, SignOut state transitions
└── records/
    └── record_bloc_test.dart        # Add, delete, sharing state transitions
```

Run tests:
```bash
flutter test
```

InsightsEngine is pure Dart — tests run instantly without Firebase or Flutter setup.

---

## Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter 3.x | Cross-platform, preferred by brief |
| State management | flutter_bloc 8.x | Explicit event-state, testable, scales to parallel streams |
| Backend | Firebase | Auth + Firestore + Security Rules in one SDK |
| Navigation | go_router | Declarative routing, ShellRoute for persistent bottom nav |
| Stream combining | rxdart | combineLatest2 for profile + dependents simultaneous streams |
| Date formatting | intl | DateFormat for reminder display |
| ID generation | uuid | Client-side IDs for offline-ready record creation |

---

## Demo Checklist

The demo video covers this user journey in order:

1. Sign up with email and password
2. Profile completion — add DOB, gender, blood group
3. Add a dependent (family member)
4. Add a health record (prescription) for myself
5. Add a health record (vaccination) for the dependent
6. Share a record with a caregiver — toggle isShared
7. Add a medication reminder with date and time
8. Mark reminder as complete
9. Dashboard — show insights, upcoming reminders, recent records, status snapshot
10. Sign out

---

*Built by Harsh Rajput — Sparkle MVP for Zoom My Life engineering exercise*