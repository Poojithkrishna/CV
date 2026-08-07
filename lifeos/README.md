# LifeOS

A premium, offline-first personal operating system for Android — Finance,
Fitness, Habits, Goals, a Gaming Creator Studio, an Entertainment library,
Journal, Calendar and a "Demon God Cultivation" gamification layer, all in
one Flutter app.

This is a personal, single-user app — it prioritizes depth over
simplicity and is not intended for public distribution.

## Status

Built feature by feature. So far:

- ✅ App shell: Material 3 theme (light/dark), bottom navigation, routing
  (`go_router`), Riverpod state management, Drift/SQLite database wiring.
- ✅ **Finance → Accounts**: full vertical slice (database table + DAO,
  domain entity + repository + use cases, Riverpod providers, list/detail/
  form UI, validation, unit + widget tests). Net worth on the dashboard is
  computed live from this.
- ✅ **Finance → Categories & Transactions**: income/expense/transfer
  entries, each atomically adjusting its account's (or, for a transfer,
  both accounts') balance in a single Drift `transaction()` — see
  `TransactionsDao` in `lib/features/finance/data/daos/transactions_dao.dart`.
  Categories are seeded with sensible defaults on first run (`ON DELETE SET
  NULL`, so deleting a category never destroys transaction history), while
  deleting an account cascades to its transactions. Finance home now shows
  recent transactions with a "See all" list, and every account links to its
  own transaction history.
- 🚧 Every other module (Fitness, Habits, Goals, Creator Studio,
  Entertainment, Journal, Calendar, Gamification) has a placeholder screen
  wired into navigation, ready for its own feature pass — see
  `lib/features/<module>/presentation/screens/*_home_screen.dart`.

## Architecture

Feature-first, clean-architecture layout:

```
lib/
  app/                 # theme, router, app shell (bottom nav)
  core/                # cross-feature: database, error types, Result,
                        # formatters/validators, shared widgets, providers
  features/
    finance/
      data/            # Drift tables + DAOs, repository implementation, mappers
      domain/           # entities, repository interfaces, use cases
      presentation/     # Riverpod providers, screens, feature-local widgets
    fitness/ habits/ goals/ creator_studio/ entertainment/
    journal/ calendar/ gamification/ dashboard/ more/ settings/
```

Every module follows the same `data / domain / presentation` split as
Finance once it gets built out. `core/database/app_database.dart` is the
single source of truth for the schema — each module's tables get added to
its `@DriftDatabase(tables: [...])` list, and cross-module foreign keys
(e.g. a habit linking to a Finance account) become possible because
everything lives in one SQLite database.

## Getting started

Prerequisites: Flutter 3.22+ / Dart 3.4+, Android Studio or the Android
SDK command-line tools, a device or emulator running Android 6.0 (API 23)
or newer.

This repo's `lib/`, `pubspec.yaml` and `android/*.gradle` files were
hand-authored (this environment doesn't have the Flutter SDK installed to
run `flutter create`/`flutter pub get`/`build_runner` itself), so a few
one-time steps are needed on a machine that does have Flutter:

```bash
cd lifeos

# 1. Fill in the Android Gradle wrapper (gradlew, gradlew.bat and the
#    wrapper jar aren't committed — see .gitignore). This also fixes up
#    any platform-folder gaps without touching lib/ or pubspec.yaml.
flutter create --project-name lifeos --org com.lifeos .

# 2. Get packages
flutter pub get

# 3. Generate Drift's *.g.dart (database) code — required before the app
#    will compile, since AccountsDao/AppDatabase reference generated
#    mixins.
dart run build_runner build --delete-conflicting-outputs

# 4. Run it
flutter run
```

Re-run step 3 (`build_runner build`) any time you add or change a Drift
table/DAO. Use `dart run build_runner watch --delete-conflicting-outputs`
during active development to regenerate on save.

### Running tests

```bash
flutter test
```

Covers: `CreateAccount`/`CreateTransaction`/`CreateCategory` use-case
validation, `AccountsDao` and `TransactionsDao` behaviour (including the
income/expense/transfer/edit/delete balance math) against an in-memory
SQLite database, and `AccountCard` widget rendering.

## Data & privacy

Everything is stored locally in a single SQLite database
(`<app documents dir>/lifeos.sqlite`) via Drift — there is no backend and
no network calls beyond what a future notifications/backup feature adds
explicitly. Biometric app-lock and local notifications are declared as
dependencies/permissions already (`local_auth`, `flutter_local_notifications`)
so wiring them up doesn't require another platform-config pass.

## Next up

Suggested order for the next feature passes (say which one you want and
it'll get the same full treatment — models → repository → use cases →
providers → UI → widgets → validation → tests):

1. Finance: Credit Cards, Loans, Bills/Recurring payments, Analytics
2. Fitness: Workout Plans + Workout Tracker
3. Habits & Goals
4. Gaming Creator Studio pipeline
5. Entertainment Library
6. Journal
7. Calendar & Tasks
8. Gamification (ranks, XP, attributes, achievements, Life Score) —
   wiring dashboard stats to real data from the modules above as they land
