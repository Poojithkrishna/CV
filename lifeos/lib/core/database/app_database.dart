import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/calendar/data/daos/calendar_dao.dart';
import '../../features/calendar/data/tables/calendar_events_table.dart';
import '../../features/calendar/data/tables/calendar_tasks_table.dart';
import '../../features/creator_studio/data/daos/content_studio_dao.dart';
import '../../features/creator_studio/data/tables/clips_table.dart';
import '../../features/creator_studio/data/tables/content_goal_table.dart';
import '../../features/creator_studio/data/tables/content_projects_table.dart';
import '../../features/entertainment/data/daos/media_library_dao.dart';
import '../../features/entertainment/data/tables/media_items_table.dart';
import '../../features/finance/data/daos/accounts_dao.dart';
import '../../features/finance/data/daos/assets_dao.dart';
import '../../features/finance/data/daos/card_emis_dao.dart';
import '../../features/finance/data/daos/categories_dao.dart';
import '../../features/finance/data/daos/credit_cards_dao.dart';
import '../../features/finance/data/daos/investments_dao.dart';
import '../../features/finance/data/daos/loans_dao.dart';
import '../../features/finance/data/daos/recurring_payments_dao.dart';
import '../../features/finance/data/daos/transactions_dao.dart';
import '../../features/finance/data/tables/accounts_table.dart';
import '../../features/finance/data/tables/assets_table.dart';
import '../../features/finance/data/tables/card_emis_table.dart';
import '../../features/finance/data/tables/categories_table.dart';
import '../../features/finance/data/tables/credit_cards_table.dart';
import '../../features/finance/data/tables/investments_table.dart';
import '../../features/finance/data/tables/loan_payments_table.dart';
import '../../features/finance/data/tables/loans_table.dart';
import '../../features/finance/data/tables/recurring_payments_table.dart';
import '../../features/finance/data/tables/transactions_table.dart';
import '../../features/fitness/data/daos/body_weight_dao.dart';
import '../../features/fitness/data/daos/cardio_sessions_dao.dart';
import '../../features/fitness/data/daos/exercises_dao.dart';
import '../../features/fitness/data/daos/measurements_dao.dart';
import '../../features/fitness/data/daos/nutrition_dao.dart';
import '../../features/fitness/data/daos/progress_photos_dao.dart';
import '../../features/fitness/data/daos/recovery_dao.dart';
import '../../features/fitness/data/daos/supplements_dao.dart';
import '../../features/fitness/data/daos/water_dao.dart';
import '../../features/fitness/data/daos/workout_plans_dao.dart';
import '../../features/fitness/data/daos/workout_sessions_dao.dart';
import '../../features/fitness/data/tables/body_weight_entries_table.dart';
import '../../features/fitness/data/tables/cardio_sessions_table.dart';
import '../../features/fitness/data/tables/exercises_table.dart';
import '../../features/fitness/data/tables/food_items_table.dart';
import '../../features/fitness/data/tables/food_log_entries_table.dart';
import '../../features/fitness/data/tables/logged_sets_table.dart';
import '../../features/fitness/data/tables/measurement_entries_table.dart';
import '../../features/fitness/data/tables/nutrition_goal_table.dart';
import '../../features/fitness/data/tables/plan_exercises_table.dart';
import '../../features/fitness/data/tables/progress_photos_table.dart';
import '../../features/fitness/data/tables/recovery_entries_table.dart';
import '../../features/fitness/data/tables/supplement_log_entries_table.dart';
import '../../features/fitness/data/tables/supplements_table.dart';
import '../../features/fitness/data/tables/water_entries_table.dart';
import '../../features/fitness/data/tables/water_goal_table.dart';
import '../../features/fitness/data/tables/workout_days_table.dart';
import '../../features/fitness/data/tables/workout_plans_table.dart';
import '../../features/fitness/data/tables/workout_sessions_table.dart';
import '../../features/gamification/data/daos/gamification_dao.dart';
import '../../features/gamification/data/tables/gamification_achievements_table.dart';
import '../../features/goals/data/daos/goals_dao.dart';
import '../../features/goals/data/tables/goal_habit_links_table.dart';
import '../../features/goals/data/tables/goals_table.dart';
import '../../features/goals/data/tables/milestones_table.dart';
import '../../features/habits/data/daos/habits_dao.dart';
import '../../features/habits/data/tables/habit_entries_table.dart';
import '../../features/habits/data/tables/habits_table.dart';
import '../../features/journal/data/daos/journal_dao.dart';
import '../../features/journal/data/tables/journal_entries_table.dart';
import 'default_categories.dart';
import 'default_exercises.dart';
import 'default_foods.dart';

part 'app_database.g.dart';

/// The single, app-wide SQLite database. Every module's tables live here
/// so the database can enforce cross-module foreign keys (e.g. a habit
/// linking to a Finance account, or a task linking to a Creator Studio
/// project) as those modules are built out.
///
/// Bump [schemaVersion] and add a migration step whenever a table changes
/// shape — never edit an already-released table in place.
@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    CreditCards,
    CardEmis,
    Loans,
    LoanPayments,
    RecurringPayments,
    Exercises,
    WorkoutPlans,
    WorkoutDays,
    PlanExercises,
    WorkoutSessions,
    LoggedSets,
    Habits,
    HabitEntries,
    Goals,
    Milestones,
    GoalHabitLinks,
    BodyWeightEntries,
    WaterEntries,
    WaterGoals,
    MeasurementEntries,
    FoodItems,
    FoodLogEntries,
    NutritionGoals,
    Investments,
    Assets,
    ProgressPhotos,
    Supplements,
    SupplementLogEntries,
    CardioSessions,
    RecoveryEntries,
    ContentProjects,
    Clips,
    ContentGoals,
    MediaItems,
    JournalEntries,
    CalendarTasks,
    CalendarEvents,
    GamificationAchievements,
  ],
  daos: [
    AccountsDao,
    CategoriesDao,
    TransactionsDao,
    CreditCardsDao,
    CardEmisDao,
    LoansDao,
    RecurringPaymentsDao,
    ExercisesDao,
    WorkoutPlansDao,
    WorkoutSessionsDao,
    HabitsDao,
    GoalsDao,
    BodyWeightDao,
    WaterDao,
    MeasurementsDao,
    NutritionDao,
    InvestmentsDao,
    AssetsDao,
    ProgressPhotosDao,
    SupplementsDao,
    CardioSessionsDao,
    RecoveryDao,
    ContentStudioDao,
    MediaLibraryDao,
    JournalDao,
    CalendarDao,
    GamificationDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory constructor so features can be unit tested without
  /// touching the filesystem.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultCategories();
          await _seedDefaultExercises();
          await _seedDefaultFoods();
          await _seedDefaultGoalRows();
          await _seedDefaultContentGoal();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(categories);
            await m.createTable(transactions);
            await _seedDefaultCategories();
          }
          if (from < 3) {
            await m.createTable(creditCards);
            await m.createTable(cardEmis);
          }
          if (from < 4) {
            await m.createTable(loans);
            await m.createTable(loanPayments);
          }
          if (from < 5) {
            await m.createTable(recurringPayments);
          }
          if (from < 6) {
            await m.createTable(exercises);
            await _seedDefaultExercises();
          }
          if (from < 7) {
            await m.createTable(workoutPlans);
            await m.createTable(workoutDays);
            await m.createTable(planExercises);
          }
          if (from < 8) {
            await m.createTable(workoutSessions);
            await m.createTable(loggedSets);
          }
          if (from < 9) {
            await m.createTable(habits);
            await m.createTable(habitEntries);
          }
          if (from < 10) {
            await m.createTable(goals);
            await m.createTable(milestones);
            await m.createTable(goalHabitLinks);
          }
          if (from < 11) {
            await m.createTable(bodyWeightEntries);
            await m.createTable(waterEntries);
            await m.createTable(waterGoals);
            await m.createTable(measurementEntries);
            await m.createTable(foodItems);
            await m.createTable(foodLogEntries);
            await m.createTable(nutritionGoals);
            await _seedDefaultFoods();
            await _seedDefaultGoalRows();
          }
          if (from < 12) {
            await m.createTable(investments);
            await m.createTable(assets);
          }
          if (from < 13) {
            await m.createTable(progressPhotos);
            await m.createTable(supplements);
            await m.createTable(supplementLogEntries);
            await m.createTable(cardioSessions);
            await m.createTable(recoveryEntries);
          }
          if (from < 14) {
            await m.createTable(contentProjects);
            await m.createTable(clips);
            await m.createTable(contentGoals);
            await _seedDefaultContentGoal();
          }
          if (from < 15) {
            await m.createTable(mediaItems);
          }
          if (from < 16) {
            await m.createTable(journalEntries);
          }
          if (from < 17) {
            await m.createTable(calendarTasks);
            await m.createTable(calendarEvents);
          }
          if (from < 18) {
            await m.createTable(gamificationAchievements);
          }
        },
      );

  Future<void> _seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(categories, buildDefaultCategorySeed(DateTime.now()));
    });
  }

  Future<void> _seedDefaultExercises() async {
    await batch((b) {
      b.insertAll(exercises, buildDefaultExerciseSeed(DateTime.now()));
    });
  }

  Future<void> _seedDefaultFoods() async {
    await batch((b) {
      b.insertAll(foodItems, buildDefaultFoodSeed(DateTime.now()));
    });
  }

  /// Seeds the single-row Water and Nutrition goal settings tables so the
  /// app has a sensible default target from the very first launch.
  Future<void> _seedDefaultGoalRows() async {
    final DateTime now = DateTime.now();
    await into(waterGoals).insert(
      WaterGoalsCompanion.insert(id: kDefaultWaterGoalId, updatedAt: now),
    );
    await into(nutritionGoals).insert(
      NutritionGoalsCompanion.insert(id: kDefaultNutritionGoalId, updatedAt: now),
    );
  }

  /// Seeds the single-row Creator Studio weekly-upload goal settings
  /// table so the app has a sensible default target from the very first
  /// launch.
  Future<void> _seedDefaultContentGoal() async {
    await into(contentGoals).insert(
      ContentGoalsCompanion.insert(id: kDefaultContentGoalId, updatedAt: DateTime.now()),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'lifeos.sqlite'));
    return NativeDatabase.createInBackground(file, setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON;');
    });
  });
}
