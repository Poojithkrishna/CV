import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/finance/data/daos/accounts_dao.dart';
import '../../features/finance/data/daos/card_emis_dao.dart';
import '../../features/finance/data/daos/categories_dao.dart';
import '../../features/finance/data/daos/credit_cards_dao.dart';
import '../../features/finance/data/daos/loans_dao.dart';
import '../../features/finance/data/daos/recurring_payments_dao.dart';
import '../../features/finance/data/daos/transactions_dao.dart';
import '../../features/finance/data/tables/accounts_table.dart';
import '../../features/finance/data/tables/card_emis_table.dart';
import '../../features/finance/data/tables/categories_table.dart';
import '../../features/finance/data/tables/credit_cards_table.dart';
import '../../features/finance/data/tables/loan_payments_table.dart';
import '../../features/finance/data/tables/loans_table.dart';
import '../../features/finance/data/tables/recurring_payments_table.dart';
import '../../features/finance/data/tables/transactions_table.dart';
import '../../features/fitness/data/daos/exercises_dao.dart';
import '../../features/fitness/data/daos/workout_plans_dao.dart';
import '../../features/fitness/data/daos/workout_sessions_dao.dart';
import '../../features/fitness/data/tables/exercises_table.dart';
import '../../features/fitness/data/tables/logged_sets_table.dart';
import '../../features/fitness/data/tables/plan_exercises_table.dart';
import '../../features/fitness/data/tables/workout_days_table.dart';
import '../../features/fitness/data/tables/workout_plans_table.dart';
import '../../features/fitness/data/tables/workout_sessions_table.dart';
import 'default_categories.dart';
import 'default_exercises.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory constructor so features can be unit tested without
  /// touching the filesystem.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultCategories();
          await _seedDefaultExercises();
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
