# Demon Origin

A premium, offline-first personal operating system for Android — Finance,
Fitness, Habits, Goals, a Gaming Creator Studio, an Entertainment library,
Journal, Calendar and a "Demon God Cultivation" gamification layer, all in
one Flutter app. (The Flutter project itself is still named `lifeos`
internally — see `pubspec.yaml` — since renaming the package would mean
rewriting every `package:lifeos/...` import across the codebase; only the
user-visible app name and icon changed.)

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
- ✅ **Finance → Investments, Assets & Analytics**: `Investment` (stocks/
  mutual funds/crypto/bonds/retirement/gold/other) tracks an invested
  amount against a manually-updated current value, so gain/loss is just
  `currentValue - investedAmount` — no live price feed, since this is an
  offline app. `Asset` (real estate/vehicle/jewelry/electronics/
  collectible/other) is simpler still: just a current value, with an
  optional purchase price kept for reference only. Both fold straight
  into net worth as pure assets alongside accounts/cards/loans.
  Analytics is a read-only view with no table of its own —
  `FinanceAnalytics` (pure, DB-free) aggregates the existing Transactions
  + Categories streams into a 6-month income-vs-expense trend and a
  this-month spending-by-category breakdown, rendered as a grouped bar
  chart and a donut chart (`fl_chart`, same charting dependency as the
  Fitness trend charts).
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
- ✅ **Fitness → Body Weight, Water, Measurements & Nutrition**: four
  small trackers rounding out the Fitness module, sharing a
  log-once-per-day-per-key upsert pattern (read-then-write in a
  transaction, keyed by date or by type+date) so re-logging the same day
  overwrites instead of duplicating.
  - **Body Weight**: one entry per day, a trend line (`TrendLineChart`,
    a shared `core/widgets` chart used again by Measurements) and
    `BodyWeightStats.changeOverDays` for 7-/30-day deltas.
  - **Water**: a daily running total (`WaterDao.logWater` accumulates a
    delta rather than replacing, floored at zero, exactly like
    `HabitsDao.logProgress`), quick-add buttons, a 7-day bar chart, and
    an editable daily goal stored in a single-row `WaterGoals` settings
    table.
  - **Measurements**: twelve body parts (waist, chest, biceps, thighs,
    etc.), each tracked as its own per-date entry so different parts
    don't need logging together; a list screen shows the latest value
    per part, tapping one opens its own trend + history.
  - **Nutrition**: a reusable `FoodItem` library (seeded with ~16 common
    foods) logged against by date + meal (breakfast/lunch/dinner/snack)
    via `FoodLogEntry`, which embeds the resolved food item — joined by
    `NutritionDao.watchLogEntriesForDate` — rather than just its id, so
    `NutritionStats.totalsFor` sums a day's calories/protein/carbs/fat
    without a second round-trip. A single-row `NutritionGoals` table
    holds an editable daily calorie target shown as a progress bar.
- ✅ **Fitness → Progress Photos, Supplements, Cardio, Recovery &
  Strength Progress**: the last Fitness pass, rounding out the module.
  - **Progress Photos**: a visual timeline (front/side/back/other),
    stored as files copied into the app's own documents directory
    (`core/utils/photo_storage.dart`) rather than referencing wherever
    the camera/gallery originally put them, via the new `image_picker`
    dependency — a grid gallery with category filter chips and a
    full-screen viewer.
  - **Supplements**: modeled as a boolean daily habit in miniature — a
    reusable `Supplement` (name + dosage label) with a per-day
    `SupplementLogEntry` toggled by `SupplementsDao.toggleTaken`, the
    exact same read-then-write upsert as `HabitsDao.toggleChecklistItem`.
  - **Cardio**: `CardioSession` (running/cycling/swimming/walking/
    rowing/elliptical/other) with duration, optional distance and
    calories; `CardioStats` computes a this-week summary.
  - **Recovery**: one entry per day (sleep hours, soreness 1-5, stress
    1-5), upserted by date like `BodyWeightEntries`. `RecoveryStats`
    averages whichever of the three were actually logged that day into
    a 0-100 score, rather than requiring all three.
  - **Strength Progress**: no new table — a new
    `WorkoutSessionsDao.watchAllSetsForExercise` query feeds
    `StrengthProgressStats`, which collapses same-day sets to that day's
    best estimated 1RM (Epley formula) for a per-exercise trend chart,
    plus a PR list drawn from the existing `LoggedSet.isPr` flag.
- ✅ **Habits**: six habit types (Yes/No, Counter, Timer, Duration,
  Checklist, Collection) share one storage model — every type except
  Checklist is a numeric `progressValue` against a `targetValue` (Yes/No
  is just that pattern with an implicit target of 1), with a
  `HabitEntry` per habit per period (day/week/month, or custom weekdays)
  upserted atomically by `HabitsDao.logProgress`/`toggleChecklistItem` so
  rapid taps never create duplicate rows for the same period. Checklist
  habits track checked-item indices separately per period. `HabitStats`
  (pure, DB-free) computes current/longest streak — the in-progress
  current period never breaks a streak before it's actually missed, and
  unscheduled custom days are skipped rather than counted as misses —
  plus completion rate and a heatmap (partial credit for numeric types).
  The dashboard's "Habit completion" tile is wired to a real weekly
  average across active habits.
- ✅ **Goals**: a `Goal` optionally breaks down into ordered `Milestone`s;
  when any exist, `GoalStats.progress` is just the completed fraction,
  otherwise it falls back to the goal's own `progressValue`/`targetValue`
  (same numeric model as habits). Goals can link to any number of Habits
  via a `GoalHabitLink` join table (purely informational — logging the
  habit doesn't move the goal's progress, it's just surfaced together on
  the goal's detail screen) so a goal like "Run a marathon" can show its
  linked "Go for a run" habit alongside its own milestones. The
  dashboard's "Active goals" tile is wired to the real count.
- ✅ **Gaming Creator Studio**: the Idea → Recording → Editing → Thumbnail →
  Upload → Published pipeline, a Clip Library and upload Analytics.
  - **Pipeline**: `ContentProject` moves through six `ContentStage`s on a
    horizontally-scrolling kanban board, one column per stage; chevron
    buttons on each card call `MoveProjectToStage`, which stamps
    `publishedDate` the first time (and only the first time) a project
    reaches Published — moving it back out for edits never clears that
    original date. Views/likes/comments are plain manually-editable
    counters (no live YouTube/Twitch API — this is an offline app), and a
    thumbnail can be captured or picked via `image_picker`.
  - **Clip Library**: a separate `Clip` entity for raw highlights, each
    optionally linked to a pipeline project via a nullable
    `linkedProjectId` foreign key with `ON DELETE SET NULL` — deleting the
    project the clip came from unlinks it rather than destroying it,
    mirroring how Finance categories survive account deletion. A 2-column
    thumbnail grid, same picker as project thumbnails.
  - **Analytics**: weekly upload progress against an editable
    `ContentGoal` target (a singleton settings row, same pattern as the
    Fitness Water/Nutrition daily goals), total views/likes/comments,
    average views per published project, and a per-stage pipeline
    breakdown — all pure aggregation in `ContentPipelineStats` (no table
    of its own). The dashboard's "Weekly uploads" tile is wired to the
    real published-this-week count.
  - `core/utils/photo_storage.dart` was generalized from a Fitness-only
    `progress_photos` helper into a shared `saveImageFile(..., subdirectory:
    ...)`/`deleteImageFile(...)` utility, now reused by both Fitness
    progress photos and Creator Studio thumbnails.
- ✅ **Entertainment Library**: one `MediaItem` entity covers games,
  movies, series, anime, books, manga and courses — a `MediaType` tag on
  an otherwise-identical shape, same idea as Habits' one storage model
  for six habit types. Tracks a wishlist → in-progress → completed (or
  dropped) `MediaStatus`, a generic `currentProgress`/`totalProgress`
  pair (episode/chapter/page/whatever fits the type — null total means
  "not tracked", not zero), an optional 0-10 rating, and a cover image
  via the same `saveImageFile` utility Creator Studio uses.
  `UpdateMediaStatus` stamps `startedDate`/`completedDate` the first
  time (and only the first time) an item reaches In Progress/Completed —
  the same first-arrival-only pattern as `MoveProjectToStage`'s
  `publishedDate`, so dropping something and picking it back up never
  loses the original dates. A quick "+1" button on each library card
  calls `LogMediaProgress`, which nudges `currentProgress` via
  `MediaLibraryDao.adjustProgress` — an accumulate-delta transaction
  floored at zero like `WaterDao.logWater`, but also capped at
  `totalProgress` if one is set, since progress can't outrun a known
  total. The Library screen filters by status and type; the home hub
  surfaces what's in progress and recently completed. The dashboard's
  "Currently playing" tile shows the most recently touched in-progress
  item's title.
- ✅ **Journal**: one `JournalEntry` entity covers the morning journal,
  night reflection, gratitude and free-writing prompts — a
  `JournalEntryType` tag (label, icon and its own accent color, the same
  three-field-enum shape as `TransactionType`) on an otherwise-identical
  text entry, rather than four separate tables. Unlike the Fitness
  trackers, a day can have any number of entries — writing a morning
  entry doesn't stop you from adding a night reflection the same day —
  so entries are plain CRUD (ordered by date, then by creation time)
  instead of the one-row-per-day upsert Body Weight/Recovery use.
  Mood tracking is a simple optional 1-5 `Mood` enum attached to any
  entry rather than its own feature — `JournalStats.averageMood` folds
  it into the home hub. `JournalStats.currentStreak` counts consecutive
  days with at least one entry, giving today a pass if nothing's
  written yet, the same "current period never breaks a streak before
  it's actually missed" idea as `HabitStats.currentStreak`. Quick-add
  chips on the home hub jump straight to a prefilled entry type via
  `go_router`'s `extra` (the app's first use of it, since every earlier
  form screen only ever needed a path parameter). The dashboard's
  "Today's journal" tile shows whether anything's been written today.
- ✅ **Calendar & Tasks**: two related entities, one shared `CalendarDao`
  covering both tables — the same one-DAO-per-feature-group shape as
  `ContentStudioDao` covering Content Projects + Clips. `CalendarTask` is
  due-date-driven (an optional `dueDate`, plus an `isTimeBlocked` flag
  that makes the date's time-of-day meaningful for "time blocking" a
  task onto an hour rather than inventing a second date column) with a
  `TaskPriority` (low/medium/high, same label+icon+color enum shape as
  `TransactionType`/`JournalEntryType`) and a done/undone toggle —
  `CalendarDao.toggleTaskDone` is the same flip-an-existing-row
  transaction as `GoalsDao.toggleMilestone`. `CalendarEvent` is
  start/end-time-driven instead (with an all-day flag and optional
  location); `CreateEvent`/`UpdateEvent` reject an end time before the
  start. Both carry a `reminderEnabled` flag, now wired to a real local
  notification — see the Notifications section below. The home hub is a 7-day week-strip
  date picker over a merged events-then-tasks agenda for the selected
  day (`CalendarStats.tasksOnDate`/`eventsOnDate`), with a bottom-sheet
  chooser on the FAB for "New task" vs. "New event" — no calendar-grid
  package needed since a week strip plus day agenda covers the spec's
  "daily/weekly planner" without one. The dashboard's "Today's schedule"
  tile shows the combined count of today's tasks and events.
- ✅ **Gamification — Demon God Cultivation**: the capstone module,
  read-only and cross-cutting — it has no forms of its own, just a pure
  aggregation over every other module's already-loaded data, the same
  "compute over already-loaded lists" shape as every other Stats
  service, just spanning all eight of them at once
  (`gamificationSnapshotProvider` watches all eight and waits for every
  one to load before computing, mirroring `netWorthSummaryProvider`'s
  watch-and-wait pattern). Eight attributes map 1:1 to the eight built
  modules — Wealth (net worth, ₹1,00,000 = 100 points), Vitality (workout
  sessions logged), Discipline (habit weekly completion rate), Willpower
  (average active-goal progress), Creativity (published content),
  Culture (completed media), Wisdom (journal streak) and Order (task
  completion rate) — each scaled and clamped to 0-100. Total XP is the
  attribute sum ×10 (max 8000), mapped to nine ranks from Mortal to
  Demon God (`Rank.minXp` thresholds), each with a flavor title so there
  was no need for a separate user-selectable "titles" feature. Life
  Score is the plain average of the eight attributes — "how balanced is
  your life right now," distinct from XP's cumulative "how far you've
  progressed." Achievements are a static in-code catalog (like the
  seeded default categories/exercises, but as a catalog rather than
  seeded rows) whose unlock status is the one thing this module actually
  persists — a single `GamificationAchievements` table recording which
  keys have been earned, since achievements must never un-unlock even if
  the triggering stat later regresses (e.g. net worth dropping back
  down). Getting a true "total workout sessions" count required one
  small additive method on Fitness's already-shipped
  `WorkoutSessionsDao` (`watchSessionCount`) — the only other module
  touched this round, and only with a new, non-breaking method. The
  dashboard's cultivation card (previously a hardcoded "Mortal / 0 XP")
  now shows the real rank, XP and progress bar to the next rank.
- ✅ **Local notifications**: every `reminderEnabled`/`reminderDaysBefore`
  flag across the app (Loans, Recurring Payments, Calendar tasks and
  events) now actually schedules a device notification, through a single
  `core/notifications/NotificationService` wrapping
  `flutter_local_notifications` — channel setup, permission requests
  (`POST_NOTIFICATIONS`, exact-alarm) and timezone resolution
  (`flutter_timezone` + `timezone`, since `zonedSchedule` needs an IANA
  zone) all happen once, in `main()`, before `runApp` (via a pre-built
  `ProviderContainer` + `UncontrolledProviderScope`, so nothing can try
  to schedule a reminder before the plugin's ready). Reminder *timing*
  per entity is a small pure function per module
  (`loanReminderTime`/`recurringPaymentReminderTime`/`taskReminderTime`/
  `eventReminderTime`) — Loans fire 1 day before their due date (no
  per-loan lead-time field to configure), Recurring Payments fire
  `reminderDaysBefore` days before `nextDueDate`, Calendar tasks fire at
  their exact time-block if one's set (else 9 AM that day), and Calendar
  events fire 30 minutes before a timed start (else 9 AM day-of for an
  all-day event) — kept separate from the plugin-calling orchestration
  around them so the date math is unit-testable without mocking a
  platform channel, the same "pure logic, thin orchestration" split
  every other module's Stats service already uses. Notification ids are
  `Object.hash(entityId, moduleSalt)` masked positive (flutter_local_-
  notifications needs a plain int), so a loan and a calendar task can
  never collide and cancel each other's reminder. Reminders are
  (re)synced from the four form screens' save/delete, from "record
  payment"/"mark as paid" (a loan reminder cancels once a payment
  settles it; a bill's reminder reschedules against its new due date),
  and from the Calendar home screen's done-checkbox toggle (a completed
  task's reminder cancels) — every place these four entities actually
  get created, changed or removed in the app.
- ✅ **Biometric App Lock**: an opt-in `AppLockService` wrapping
  `local_auth`'s biometric/device-credential prompt (fingerprint, face,
  or whatever PIN/pattern the phone already falls back to — never
  biometric-only, so a bad fingerprint-sensor day can't lock anyone out
  for good). Whether it's on is the one preference in the app that
  can't use `ThemeModeController`'s async-load-after-a-default pattern,
  since a security toggle showing the app unlocked for even one frame
  while the real value loads would defeat the feature — so
  `AppLockEnabledController` starts `null` and `loadInitial()` is
  awaited in `main()` before `runApp`, same timing discipline as the
  notification service's own pre-`runApp` init. `AppLockGate` wraps
  `MaterialApp.router`'s `builder`, showing a lock screen instead of the
  app whenever enabled and the current session hasn't unlocked yet, and
  a `WidgetsBindingObserver` re-locks the moment the app is backgrounded
  — switching away and back always re-prompts. The Settings toggle
  requires a successful authentication to flip in *either* direction:
  to enable, so no one can turn it on and lock the real owner out of
  their own phone, and to disable, so grabbing an already-unlocked phone
  isn't enough to permanently switch the lock off. `MainActivity` had to
  change from `FlutterActivity` to `FlutterFragmentActivity` —
  `local_auth`'s biometric prompt requires a `FragmentActivity` host and
  won't work on the stock template's default. No unit tests for this
  one (consistent with `ThemeModeController`, which has none either) —
  there's no pure logic to extract here, just a persisted bool and a
  platform plugin call, and this project's tests are for domain/data
  logic, not for mocking platform channels.
- ✅ **Backup & Restore**: raw SQLite file operations rather than a
  hand-rolled JSON export of every table — a straight file copy is a
  full-fidelity backup by construction, and since Drift tracks its own
  schema version *inside* the database file (the standard SQLite
  `user_version` pragma), restoring an older backup into a newer app
  build just upgrades in place through the normal migration path the
  next time it's opened, with no separate backup-versioning scheme
  needed. Export runs SQLite's own `VACUUM INTO` — a consistent,
  compacted snapshot taken safely even while the live database is open,
  unlike copying the raw file out from under an active connection —
  then hands the result to `share_plus` so the user can save it
  anywhere (Drive, email, Files, wherever). Restore validates the
  chosen file's first 16 bytes against the real SQLite3 header before
  going anywhere near the live database (refusing to silently clobber
  everything with an arbitrary file), then closes the live connection
  and overwrites its file — deliberately *not* attempting to hot-swap
  the running `AppDatabase` back to life afterward, since that would
  mean either racing Riverpod's provider-invalidation timing or relying
  on a database connection tolerating being closed twice, neither of
  which is worth the risk for an operation this rare and this
  destructive. Instead Demon Origin closes itself (`SystemNavigator.pop()`)
  and picks the restored file up fresh on next launch, the same way
  every ordinary launch already opens the database. `BackupService`'s
  file-header validation and the `VACUUM INTO` export/reopen round-trip
  are unit tested (the latter against a real `AppDatabase.forTesting`,
  the same in-memory-database pattern every DAO test already uses); the
  `path_provider`-dependent path resolution isn't, consistent with how
  every other platform-plugin call in this app is left untested.
- ✅ **Home screen widget**: a real Android App Widget (`home_widget`
  package + a native `LifeOsWidgetProvider`), not just an in-app
  feature — cultivation rank/XP, net worth, habit completion and
  today's schedule at a glance without opening Demon Origin at all. The
  mapping from live app data to the five strings the widget actually
  displays is one small pure function, `buildHomeWidgetData` — kept
  separate from `HomeWidgetSyncService`'s actual plugin calls for the
  same reason the notification reminder-time functions are split from
  `NotificationService`: so the mapping is unit-testable without a
  platform channel. `DashboardScreen` pushes a fresh set of values via
  `WidgetsBinding.instance.addPostFrameCallback` on every rebuild — the
  same "freshness means whenever the app's open" honesty as every other
  on-device-only piece of this app, since there's no background refresh
  wired up (`lifeos_widget_info.xml` sets `updatePeriodMillis="0"` for
  exactly that reason, rather than declaring a refresh cadence nothing
  actually honors). The native side is a `RemoteViews`-based
  `AppWidgetProvider` subclass reading the shared preferences the
  plugin already writes to, a gradient-background layout matching the
  Gamification module's own color, and a tap target that launches
  `MainActivity` via `HomeWidgetLaunchIntent` — no deep link into a
  specific screen, just the same as tapping the app icon. `buildHomeWidgetData`
  is unit tested (the loaded and not-yet-loaded gamification-snapshot
  cases, and that it always emits exactly its five keys); the Kotlin
  provider and XML resources aren't — there's no Dart test harness for
  native Android widget code, the same boundary every other
  platform-plugin integration in this app draws.
- ✅ **Richer Gamification content**: the achievement catalog grew from
  9 to 25, now grouped into three sections (`AchievementCategory`:
  Milestones, Rank Ascension, Mastery) so the grid stays scannable
  instead of one long undifferentiated wall of cards. Rank Ascension
  adds one achievement per rung of the ladder (Qi Refining through
  Immortal Ascension, plus the existing Demon God "Ascended") —
  evaluated with a plain `rank.index >= milestone.index` comparison,
  since reaching a higher rank always implies every lower XP threshold
  was already crossed, so all the lower tiers unlock simultaneously
  with the highest one reached rather than needing their own
  historical tracking. Mastery adds a tier-2 milestone for each of the
  six per-module achievements (e.g. Iron Body II at 50 workout
  sessions, vs. the original 10) plus three whole-life balance
  achievements — Renaissance (every attribute ≥ 50), Peak of a Path
  (any attribute maxed at 100) and True Sovereign (Life Score ≥ 90) —
  which needed `evaluateAchievementKeys` to accept the attribute map
  and Life Score the caller had already computed, rather than
  re-deriving them redundantly inside the method. Unlocking now gives
  actual feedback instead of silently writing a row: a `SnackBar`
  ("Achievement unlocked: …") for each newly-satisfied key, queued
  automatically if several unlock at once, plus a one-time celebration
  dialog the first time each rank is reached. That last part needed one
  small new piece of persisted state, `LastSeenRankController` (mirrors
  `ThemeModeController`'s async-self-load pattern — a wrong value for
  one frame here is cosmetic, not security-critical, unlike App Lock's
  `AppLockEnabledController`), living in the Gamification feature's own
  `presentation/providers/` rather than `core/providers/` since it's
  UI state specific to this module, not cross-cutting infrastructure.
- ✅ **Rebrand: Demon Origin + real launcher icon**: the app's
  user-visible name changed from "LifeOS" to "Demon Origin" — the
  Android manifest `android:label`, the `MaterialApp` title, every
  AppBar/dialog/SnackBar string that named the app (App Lock's
  authenticate-reason and lock screen, Backup & Restore's export/
  restore copy, Settings' About tile) — while deliberately leaving the
  underlying Flutter package name (`lifeos` in `pubspec.yaml`, the
  `package:lifeos/...` import prefix on every file) untouched, since
  renaming *that* would mean rewriting every import across the entire
  codebase for a purely internal identifier nobody but the developer
  ever sees. The app previously had no real launcher icon at all — the
  manifest referenced `@mipmap/ic_launcher` but no such resource
  existed, because this Android scaffold was hand-built rather than
  generated by `flutter create` (there's no Flutter SDK in this
  environment). It's now a real icon set generated from the supplied
  skull-and-chaos-star emblem via Pillow (no ImageMagick available
  either): a full-bleed `ic_launcher.png` at all five legacy densities
  for pre-Android-8 devices, plus a proper adaptive icon
  (`mipmap-anydpi-v26/ic_launcher.xml`) for API 26+ — a solid
  `#1A1A1A` background color (sampled from the artwork's own backdrop)
  behind a foreground layer that's alpha-matted off the source image's
  luminance (the artwork is white-on-near-black, so thresholding
  luminance into an alpha channel cleanly separates the emblem from its
  backdrop without needing a separate cutout asset) and scaled to ~60%
  of the adaptive canvas so no launcher mask shape (circle, squircle,
  rounded square) clips the spike tips, which the source art uses right
  out to its own edges.
- ✅ **Life Score history/trend chart**: the one piece of Gamification
  state that isn't purely a live computation. Life Score itself has no
  history to chart — it's derived fresh every time from other modules'
  current data, and those modules don't keep their own historical
  snapshots either (net worth, workout counts, etc. are all "as of
  right now"). So this needed a new table, `LifeScoreSnapshots`
  (schema bump 18→19), recording whatever Life Score/XP/rank were live
  the last time the app was opened that calendar day — opening the app
  again later the same day updates that day's row instead of adding a
  second one, the exact same "upsert by date" shape as
  `BodyWeightDao.upsertForDate`. There's deliberately no background job
  filling in days the app wasn't opened, the same on-device-only
  honesty as the home screen widget's freshness — a sparse chart
  legitimately means sparse app usage, not a bug. The Gamification home
  screen now has a "Life Score History" card right below the existing
  Life Score summary, reusing the same `TrendLineChart` widget Body
  Weight and Measurements already use rather than writing a new chart
  from scratch, with a plain-language nudge ("open the app on a few
  different days...") in place of the chart until there are at least
  two points to draw a line between.

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
`RecordLoanPayment`/`CreateRecurringPayment`/`CreateInvestment`/
`CreateAsset`), Fitness (`LogSet`/`CreateWorkoutPlan`/
`AddExerciseToDay`/`LogBodyWeight`/`CreateFoodItem`/`LogFood`/
`LogCardioSession`/`LogRecovery`/`CreateSupplement`/
`ToggleSupplementTaken`/`AddProgressPhoto`), Habits (`CreateHabit`),
Goals (`CreateGoal`/`AddMilestone`), Creator Studio
(`CreateContentProject`/`CreateClip`/`UpdateContentGoal`/
`MoveProjectToStage`, including the first-publish-only `publishedDate`
stamping), Entertainment (`CreateMediaItem`/`UpdateMediaStatus`,
including the first-arrival-only `startedDate`/`completedDate`
stamping, and `LogMediaProgress`), Journal (`CreateJournalEntry`/
`UpdateJournalEntry`/`DeleteJournalEntry`), Calendar (`CreateTask`/
`ToggleTaskDone`, and `CreateEvent`'s end-before-start rejection) and
Gamification (`UnlockAchievement`); `RecurrenceFrequency`'s date math
(leap years, month-length clamping) and `MarkRecurringPaymentPaid`'s
orchestration; `WorkoutStats`'s volume and progression-suggestion math,
`StrengthProgressStats`'s Epley 1RM estimate and same-day-best
collapsing; `HabitStats`'s streak/completion-rate/heatmap math
(including custom weekday schedules), `GoalStats`'s milestone-vs-numeric
progress fallback, `BodyWeightStats`/`MeasurementStats`'s N-day trend
deltas, `CardioStats`'s weekly totals, `RecoveryStats`'s
logged-components-only score average, `NutritionStats`'s macro
totaling/meal grouping, `FinanceAnalytics`'s category totals/monthly
income-vs-expense bucketing (including transfer exclusion and
empty-month buckets), `ContentPipelineStats`'s stage counts/
published-since filtering/view-like-comment totals/average views and
`MediaLibraryStats`'s status/type counts, completed-since filtering,
progress-fraction clamping (including the no-total-set and zero-total
null cases) and average-rating-of-the-rated-only math, and
`JournalStats`'s current-streak math (today's pass-if-unwritten rule,
multiple same-day entries counting once, breaking on the first prior
gap) and mood/type aggregation, `CalendarStats`'s same-day task/
event filtering, pending count and overdue-excludes-done-and-dateless
filtering, and `GamificationStats`'s eight attribute formulas (scaling
and clamping, including the zero-goals/zero-tasks empty cases), XP
totaling, rank lookup at and around every threshold (including the
above-max-XP case), next-rank progress fractions and every achievement
criterion (including the exact-threshold and just-below-threshold
boundary for a perfect habit week); DAO behaviour against an in-memory SQLite
database for `AccountsDao`/`TransactionsDao`/`CreditCardsDao`/
`CardEmisDao`/`LoansDao` (balance and payment math, including
edit/delete reverting the right effect), `InvestmentsDao`/`AssetsDao`
(archived-filtering CRUD), `WorkoutSessionsDao`/`WorkoutPlansDao` (PR
detection, active-plan switching), `HabitsDao` (atomic period upserts,
floored at zero, checklist toggling), `GoalsDao` (milestone toggling,
habit linking, cascading deletes), `BodyWeightDao`/`MeasurementsDao`/
`RecoveryDao` (upsert-by-date/type overwrites same-day re-logs),
`WaterDao` (accumulating daily total floored at zero, goal upsert),
`SupplementsDao` (the same toggle-upsert as habit checklist items),
`CardioSessionsDao`/`ProgressPhotosDao` (straightforward CRUD, category
filtering), `NutritionDao` (the food-item join query, seeded starter
library, cascading deletes), `ContentStudioDao` (sort-ordered/
captured-at-ordered streams, deleting a linked project setting a clip's
`linkedProjectId` to null rather than cascading, and the singleton goal
row's upsert never crashing on a re-save), `MediaLibraryDao`
(alphabetical ordering, and `adjustProgress`'s accumulate-delta math —
floored at zero, capped at `totalProgress`, a no-op for a missing id),
`JournalDao` (date-then-creation-time ordering, a null mood
round-tripping as null), `CalendarDao` (due-date/start-time ordering
across its two tables, `toggleTaskDone`'s flip-and-idempotent behavior
including a no-op for a missing id) and `GamificationDao`
(`unlockAchievement` never re-unlocking or overwriting an already-earned
achievement's timestamp); the notification id helpers' determinism,
cross-module non-collision and always-non-negative range, and each
module's pure reminder-time function — `loanReminderTime`,
`recurringPaymentReminderTime`, `taskReminderTime` and
`eventReminderTime` — kept deliberately separate from the
`NotificationService` orchestration around them so this math is
unit-testable without mocking a platform channel; `BackupService`'s
SQLite-header validation (a real file, plain text, a too-short file, a
missing file) and its `VACUUM INTO` export round-tripping back through
a fresh `AppDatabase` with the exported data intact; `buildHomeWidgetData`'s
mapping (both the loaded and not-yet-loaded gamification-snapshot cases,
and that it always emits exactly its five widget keys); `GamificationDao`'s
`upsertTodaysSnapshot` (a new date inserts, the same date updates in place
rather than duplicating, distinct dates are kept and ordered ascending);
and `AccountCard` widget rendering.

## Data & privacy

Everything is stored locally in a single SQLite database
(`<app documents dir>/lifeos.sqlite`) via Drift — there is no backend and
no network calls, period. Local notifications are on-device only
(`flutter_local_notifications`, no push service, no server round-trip).
App Lock authenticates entirely on-device too (`local_auth` —
biometrics or the phone's own device credential), so there's nothing to
configure server-side and no account/password of ours to manage.
Backup export hands the file to whatever the user picks from Android's
own share sheet (Drive, email, a file manager, anything already
installed) — Demon Origin itself never uploads it anywhere; restoring reads
only the single file the user explicitly chose. Backup files are plain
database files with no encryption of their own layered on top, so they
carry the same sensitivity as everything else in the app and are worth
sharing with the same care. The home screen widget doesn't call out
either — its values are written to local Android shared preferences by
the app itself and read back by the widget's own code, all on-device.

## Next up

Every module from the original spec — Finance, Fitness, Habits, Goals,
Creator Studio, Entertainment, Journal, Calendar & Tasks and
Gamification — has now had its full feature pass (models → repository →
use cases → providers → UI → widgets → validation → tests), and the
dashboard's every tile is wired to real, live data.

Local notifications, biometric App Lock, Backup & Restore and a real
Android home screen widget are all wired up too — every
`reminderEnabled`/`reminderDaysBefore` flag (Loans, Recurring Payments,
Calendar tasks and events) actually schedules a device notification,
Settings has a real App Lock toggle, Settings → Backup & Restore can
export everything to a file (shared however the user likes) or replace
everything from a previously exported one, and a widget can be added to
the home screen showing cultivation rank/XP, net worth, habit
completion and today's schedule without opening the app (see the five
sections above).

Gamification itself has also had a second, deeper pass: 25 achievements
across three grouped categories, one achievement per rank, tier-2
module milestones and whole-life balance achievements, plus actual
unlock/rank-up celebration instead of silent state changes (see the
"Richer Gamification content" section above).

The app has also been rebranded from "LifeOS" to "Demon Origin" with a
real launcher icon generated from a supplied emblem — both the legacy
full-bleed icon and a proper Android 12+ adaptive icon with a safe-zone-
scaled foreground (see "Rebrand" above).

Gamification also now tracks its own history: a "Life Score History"
card on the Gamification home screen charts Life Score day by day,
backed by a new `LifeScoreSnapshots` table recorded each time the app
is opened (see "Life Score history/trend chart" above).

There's no outstanding polish item left from the original spec or from
any pass since. Future work is open-ended from here: say what you'd
like next (deep-linking the widget to a specific screen, or anything
else) and it'll get the same full treatment.
