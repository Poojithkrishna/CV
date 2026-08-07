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
- ✅ **Finance → Credit Cards & Loans**: standalone from the Accounts
  ledger (a credit card's usage and a loan's remaining balance don't need
  a full transaction history to make sense, so they're tracked directly).
  Credit cards track limit/usage/available credit, statement & due days,
  reward points, cashback, annual fee, and EMIs (equated monthly
  installments, tracked independently of usage since banks handle that
  accounting differently card to card) with a "mark month paid" action.
  Loans support either direction (money you lent vs. borrowed), a person/
  phone/due date/reminder flag, and atomic partial-payment recording
  (`LoansDao.recordPayment`/`deletePayment`, mirroring `TransactionsDao`'s
  pattern) with full payment history. Both fold into the dashboard's net
  worth via `net_worth_provider.dart`, which combines accounts, card usage
  (a liability) and loans (an asset when given, a liability when borrowed).
- ✅ **Finance → Bills & Recurring Payments**: one `RecurringPayment` entity
  covers both (a bill *is* a recurring payment) — name, expected amount,
  frequency (weekly/monthly/quarterly/yearly, with month arithmetic
  clamped to the target month's real length — 31 Jan → 28/29 Feb, not
  3 Mar), next due date, optional linked account/category, reminder-days-
  before and an auto-pay flag. "Mark as paid" doesn't run its own ledger —
  `MarkRecurringPaymentPaid` composes the existing `CreateTransaction` use
  case (logging a real expense against the linked account, if any) with
  advancing `nextDueDate`, then updates the schedule. Not folded into net
  worth (an upcoming bill is a forecast, not a balance-sheet liability —
  counting it would double-count against the cash sitting in the account
  that'll pay it). The list screen surfaces overdue items first.
- ✅ **Fitness → Exercise Library, Workout Plans & Workout Tracker**: the
  spec's core Fitness loop, built as one pass since each part depends on
  the last.
  - **Exercise Library**: muscle group + equipment, seeded with ~25
    common exercises across every muscle group.
  - **Workout Plans**: unlimited plans (Gym/Home/Dumbbells/Bodyweight/
    Resistance Bands/Travel), each with named days (e.g. "Push Day") and
    per-day exercise targets (sets/reps/weight/rest). Only one plan is
    ever active — `WorkoutPlansDao.setActivePlan` deactivates every other
    plan and activates the chosen one atomically, enforcing that
    "radio-button" invariant without a unique index. The active plan
    surfaces on both the Fitness home screen and the main dashboard.
  - **Workout Tracker**: starting a workout (from a plan day, or ad hoc)
    creates a `WorkoutSession`; logging a set calls `WorkoutSessionsDao
    .logSet`, which — atomically — checks the exercise's historical max
    weight (across every past session, warmups excluded) to flag a new
    PR before inserting. Each exercise card shows the last time it was
    trained and a suggested next weight (`WorkoutStats.suggestNextWeight`:
    nudge the weight up if the last set met the target reps, otherwise
    repeat it), a rest timer between working sets, and running session
    volume (`WorkoutStats.sessionVolume`). A finished session becomes a
    read-only history entry.
- 🚧 Every other module (Habits, Goals, Creator Studio, Entertainment,
  Journal, Calendar, Gamification) has a placeholder screen wired into
  navigation, ready for its own feature pass — see
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

Covers: use-case validation across Finance (`CreateAccount`/
`CreateTransaction`/`CreateCategory`/`CreateCreditCard`/`CreateLoan`/
`RecordLoanPayment`/`CreateRecurringPayment`) and Fitness (`LogSet`/
`CreateWorkoutPlan`/`AddExerciseToDay`); `RecurrenceFrequency`'s date math
(leap years, month-length clamping) and `MarkRecurringPaymentPaid`'s
orchestration; `WorkoutStats`'s volume and progression-suggestion math;
DAO behaviour against an in-memory SQLite database for `AccountsDao`/
`TransactionsDao`/`CreditCardsDao`/`CardEmisDao`/`LoansDao` (balance and
payment math, including edit/delete reverting the right effect) and for
`WorkoutSessionsDao`/`WorkoutPlansDao` (PR detection, active-plan
switching); and `AccountCard` widget rendering.

## Data & privacy

Everything is stored locally in a single SQLite database
(`<app documents dir>/lifeos.sqlite`) via Drift — there is no backend and
no network calls beyond what a future notifications/backup feature adds
explicitly. Biometric app-lock and local notifications are declared as
dependencies/permissions already (`local_auth`, `flutter_local_notifications`)
so wiring them up doesn't require another platform-config pass. A loan's
"remind me before it's due" toggle is stored already (`Loan.reminderEnabled`)
but doesn't schedule anything yet — actually firing local notifications for
it is part of that future notifications pass, not a half-built feature here.

## Next up

Suggested order for the next feature passes (say which one you want and
it'll get the same full treatment — models → repository → use cases →
providers → UI → widgets → validation → tests):

1. Finance: Investments & Assets, Analytics
2. Fitness: Progress Photos, Measurements, Nutrition, Water, Supplements,
   Cardio, Recovery, Body Weight & Strength Progress analytics
3. Habits & Goals
4. Gaming Creator Studio pipeline
5. Entertainment Library
6. Journal
7. Calendar & Tasks
8. Gamification (ranks, XP, attributes, achievements, Life Score) —
   wiring dashboard stats to real data from the modules above as they land
