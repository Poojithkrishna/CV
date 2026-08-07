import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/screens/calendar_home_screen.dart';
import '../../features/creator_studio/presentation/screens/creator_studio_home_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/entertainment/presentation/screens/entertainment_home_screen.dart';
import '../../features/finance/presentation/screens/account_detail_screen.dart';
import '../../features/finance/presentation/screens/account_form_screen.dart';
import '../../features/finance/presentation/screens/card_emi_form_screen.dart';
import '../../features/finance/presentation/screens/categories_screen.dart';
import '../../features/finance/presentation/screens/category_form_screen.dart';
import '../../features/finance/presentation/screens/credit_card_detail_screen.dart';
import '../../features/finance/presentation/screens/credit_card_form_screen.dart';
import '../../features/finance/presentation/screens/credit_cards_list_screen.dart';
import '../../features/finance/presentation/screens/finance_home_screen.dart';
import '../../features/finance/presentation/screens/loan_detail_screen.dart';
import '../../features/finance/presentation/screens/loan_form_screen.dart';
import '../../features/finance/presentation/screens/loans_list_screen.dart';
import '../../features/finance/presentation/screens/recurring_payment_detail_screen.dart';
import '../../features/finance/presentation/screens/recurring_payment_form_screen.dart';
import '../../features/finance/presentation/screens/recurring_payments_list_screen.dart';
import '../../features/finance/presentation/screens/transaction_form_screen.dart';
import '../../features/finance/presentation/screens/transactions_list_screen.dart';
import '../../features/fitness/domain/entities/plan_exercise.dart';
import '../../features/fitness/presentation/screens/exercise_form_screen.dart';
import '../../features/fitness/presentation/screens/exercise_library_screen.dart';
import '../../features/fitness/presentation/screens/fitness_home_screen.dart';
import '../../features/fitness/presentation/screens/plan_exercise_form_screen.dart';
import '../../features/fitness/presentation/screens/start_workout_screen.dart';
import '../../features/fitness/presentation/screens/workout_history_screen.dart';
import '../../features/fitness/presentation/screens/workout_plan_detail_screen.dart';
import '../../features/fitness/presentation/screens/workout_plan_form_screen.dart';
import '../../features/fitness/presentation/screens/workout_plans_list_screen.dart';
import '../../features/fitness/presentation/screens/workout_session_screen.dart';
import '../../features/gamification/presentation/screens/gamification_home_screen.dart';
import '../../features/goals/presentation/screens/goals_home_screen.dart';
import '../../features/habits/presentation/screens/habits_home_screen.dart';
import '../../features/journal/presentation/screens/journal_home_screen.dart';
import '../../features/more/presentation/screens/more_home_screen.dart';
import '../../features/settings/presentation/screens/settings_home_screen.dart';
import 'app_shell.dart';

/// Root navigation graph. The five bottom-nav tabs (Home, Finance, Habits,
/// Fitness, More) are [StatefulShellRoute] branches so each keeps its own
/// back stack and scroll position when switching tabs; every other screen
/// (module detail pages, forms) is a plain top-level route pushed on top.
final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinanceHomeScreen(),
              routes: [
                GoRoute(
                  path: 'accounts/new',
                  builder: (context, state) => const AccountFormScreen(),
                ),
                GoRoute(
                  path: 'accounts/:id',
                  builder: (context, state) => AccountDetailScreen(
                    accountId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'accounts/:id/edit',
                  builder: (context, state) => AccountFormScreen(
                    accountId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'accounts/:id/transactions',
                  builder: (context, state) => TransactionsListScreen(
                    accountId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'transactions',
                  builder: (context, state) => const TransactionsListScreen(),
                ),
                GoRoute(
                  path: 'transactions/new',
                  builder: (context, state) => TransactionFormScreen(
                    initialAccountId: state.uri.queryParameters['accountId'],
                  ),
                ),
                GoRoute(
                  path: 'transactions/:id/edit',
                  builder: (context, state) => TransactionFormScreen(
                    transactionId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const CategoriesScreen(),
                ),
                GoRoute(
                  path: 'categories/new',
                  builder: (context, state) => const CategoryFormScreen(),
                ),
                GoRoute(
                  path: 'categories/:id/edit',
                  builder: (context, state) => CategoryFormScreen(
                    categoryId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'credit-cards',
                  builder: (context, state) => const CreditCardsListScreen(),
                ),
                GoRoute(
                  path: 'credit-cards/new',
                  builder: (context, state) => const CreditCardFormScreen(),
                ),
                GoRoute(
                  path: 'credit-cards/:id',
                  builder: (context, state) => CreditCardDetailScreen(
                    cardId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'credit-cards/:id/edit',
                  builder: (context, state) => CreditCardFormScreen(
                    cardId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'credit-cards/:id/emis/new',
                  builder: (context, state) => CardEmiFormScreen(
                    cardId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'loans',
                  builder: (context, state) => const LoansListScreen(),
                ),
                GoRoute(
                  path: 'loans/new',
                  builder: (context, state) => const LoanFormScreen(),
                ),
                GoRoute(
                  path: 'loans/:id',
                  builder: (context, state) => LoanDetailScreen(
                    loanId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'loans/:id/edit',
                  builder: (context, state) => LoanFormScreen(
                    loanId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'recurring-payments',
                  builder: (context, state) => const RecurringPaymentsListScreen(),
                ),
                GoRoute(
                  path: 'recurring-payments/new',
                  builder: (context, state) => const RecurringPaymentFormScreen(),
                ),
                GoRoute(
                  path: 'recurring-payments/:id',
                  builder: (context, state) => RecurringPaymentDetailScreen(
                    paymentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'recurring-payments/:id/edit',
                  builder: (context, state) => RecurringPaymentFormScreen(
                    paymentId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/habits',
              builder: (context, state) => const HabitsHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fitness',
              builder: (context, state) => const FitnessHomeScreen(),
              routes: [
                GoRoute(
                  path: 'exercises',
                  builder: (context, state) => const ExerciseLibraryScreen(),
                ),
                GoRoute(
                  path: 'exercises/new',
                  builder: (context, state) => const ExerciseFormScreen(),
                ),
                GoRoute(
                  path: 'exercises/:id/edit',
                  builder: (context, state) => ExerciseFormScreen(
                    exerciseId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'plans',
                  builder: (context, state) => const WorkoutPlansListScreen(),
                ),
                GoRoute(
                  path: 'plans/new',
                  builder: (context, state) => const WorkoutPlanFormScreen(),
                ),
                GoRoute(
                  path: 'plans/:id',
                  builder: (context, state) => WorkoutPlanDetailScreen(
                    planId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'plans/:id/edit',
                  builder: (context, state) => WorkoutPlanFormScreen(
                    planId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'days/:dayId/exercises/new',
                  builder: (context, state) => PlanExerciseFormScreen(
                    dayId: state.pathParameters['dayId']!,
                  ),
                ),
                GoRoute(
                  path: 'days/:dayId/exercises/:id/edit',
                  builder: (context, state) => PlanExerciseFormScreen(
                    dayId: state.pathParameters['dayId']!,
                    planExercise: state.extra as PlanExercise?,
                  ),
                ),
                GoRoute(
                  path: 'workouts',
                  builder: (context, state) => const WorkoutHistoryScreen(),
                ),
                GoRoute(
                  path: 'workouts/start',
                  builder: (context, state) => StartWorkoutScreen(
                    planId: state.uri.queryParameters['planId'],
                    dayId: state.uri.queryParameters['dayId'],
                  ),
                ),
                GoRoute(
                  path: 'workouts/:sessionId',
                  builder: (context, state) => WorkoutSessionScreen(
                    sessionId: state.pathParameters['sessionId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreHomeScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalsHomeScreen(),
    ),
    GoRoute(
      path: '/creator-studio',
      builder: (context, state) => const CreatorStudioHomeScreen(),
    ),
    GoRoute(
      path: '/entertainment',
      builder: (context, state) => const EntertainmentHomeScreen(),
    ),
    GoRoute(
      path: '/journal',
      builder: (context, state) => const JournalHomeScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarHomeScreen(),
    ),
    GoRoute(
      path: '/gamification',
      builder: (context, state) => const GamificationHomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsHomeScreen(),
    ),
  ],
);
