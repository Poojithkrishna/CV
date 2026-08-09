import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/screens/calendar_home_screen.dart';
import '../../features/creator_studio/presentation/screens/clip_form_screen.dart';
import '../../features/creator_studio/presentation/screens/clip_library_screen.dart';
import '../../features/creator_studio/presentation/screens/content_analytics_screen.dart';
import '../../features/creator_studio/presentation/screens/content_pipeline_screen.dart';
import '../../features/creator_studio/presentation/screens/content_project_form_screen.dart';
import '../../features/creator_studio/presentation/screens/creator_studio_home_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/entertainment/presentation/screens/entertainment_home_screen.dart';
import '../../features/entertainment/presentation/screens/entertainment_library_screen.dart';
import '../../features/entertainment/presentation/screens/media_item_form_screen.dart';
import '../../features/finance/presentation/screens/account_detail_screen.dart';
import '../../features/finance/presentation/screens/account_form_screen.dart';
import '../../features/finance/presentation/screens/asset_form_screen.dart';
import '../../features/finance/presentation/screens/assets_list_screen.dart';
import '../../features/finance/presentation/screens/card_emi_form_screen.dart';
import '../../features/finance/presentation/screens/categories_screen.dart';
import '../../features/finance/presentation/screens/category_form_screen.dart';
import '../../features/finance/presentation/screens/credit_card_detail_screen.dart';
import '../../features/finance/presentation/screens/credit_card_form_screen.dart';
import '../../features/finance/presentation/screens/credit_cards_list_screen.dart';
import '../../features/finance/presentation/screens/finance_analytics_screen.dart';
import '../../features/finance/presentation/screens/finance_home_screen.dart';
import '../../features/finance/presentation/screens/investment_form_screen.dart';
import '../../features/finance/presentation/screens/investments_list_screen.dart';
import '../../features/finance/presentation/screens/loan_detail_screen.dart';
import '../../features/finance/presentation/screens/loan_form_screen.dart';
import '../../features/finance/presentation/screens/loans_list_screen.dart';
import '../../features/finance/presentation/screens/recurring_payment_detail_screen.dart';
import '../../features/finance/presentation/screens/recurring_payment_form_screen.dart';
import '../../features/finance/presentation/screens/recurring_payments_list_screen.dart';
import '../../features/finance/presentation/screens/transaction_form_screen.dart';
import '../../features/finance/presentation/screens/transactions_list_screen.dart';
import '../../features/fitness/domain/entities/measurement_type.dart';
import '../../features/fitness/domain/entities/plan_exercise.dart';
import '../../features/fitness/domain/entities/progress_photo.dart';
import '../../features/fitness/presentation/screens/body_weight_screen.dart';
import '../../features/fitness/presentation/screens/cardio_form_screen.dart';
import '../../features/fitness/presentation/screens/cardio_list_screen.dart';
import '../../features/fitness/presentation/screens/exercise_form_screen.dart';
import '../../features/fitness/presentation/screens/exercise_library_screen.dart';
import '../../features/fitness/presentation/screens/fitness_home_screen.dart';
import '../../features/fitness/presentation/screens/food_item_form_screen.dart';
import '../../features/fitness/presentation/screens/food_library_screen.dart';
import '../../features/fitness/presentation/screens/measurement_detail_screen.dart';
import '../../features/fitness/presentation/screens/measurements_list_screen.dart';
import '../../features/fitness/presentation/screens/nutrition_screen.dart';
import '../../features/fitness/presentation/screens/photo_viewer_screen.dart';
import '../../features/fitness/presentation/screens/plan_exercise_form_screen.dart';
import '../../features/fitness/presentation/screens/progress_photos_screen.dart';
import '../../features/fitness/presentation/screens/recovery_screen.dart';
import '../../features/fitness/presentation/screens/start_workout_screen.dart';
import '../../features/fitness/presentation/screens/strength_progress_screen.dart';
import '../../features/fitness/presentation/screens/supplement_form_screen.dart';
import '../../features/fitness/presentation/screens/supplements_screen.dart';
import '../../features/fitness/presentation/screens/water_screen.dart';
import '../../features/fitness/presentation/screens/workout_history_screen.dart';
import '../../features/fitness/presentation/screens/workout_plan_detail_screen.dart';
import '../../features/fitness/presentation/screens/workout_plan_form_screen.dart';
import '../../features/fitness/presentation/screens/workout_plans_list_screen.dart';
import '../../features/fitness/presentation/screens/workout_session_screen.dart';
import '../../features/gamification/presentation/screens/gamification_home_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/goals/presentation/screens/goal_form_screen.dart';
import '../../features/goals/presentation/screens/goals_list_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/presentation/screens/habit_form_screen.dart';
import '../../features/habits/presentation/screens/habits_list_screen.dart';
import '../../features/journal/domain/entities/journal_entry_type.dart';
import '../../features/journal/presentation/screens/journal_entry_form_screen.dart';
import '../../features/journal/presentation/screens/journal_history_screen.dart';
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
                GoRoute(
                  path: 'investments',
                  builder: (context, state) => const InvestmentsListScreen(),
                ),
                GoRoute(
                  path: 'investments/new',
                  builder: (context, state) => const InvestmentFormScreen(),
                ),
                GoRoute(
                  path: 'investments/:id/edit',
                  builder: (context, state) => InvestmentFormScreen(
                    investmentId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'assets',
                  builder: (context, state) => const AssetsListScreen(),
                ),
                GoRoute(
                  path: 'assets/new',
                  builder: (context, state) => const AssetFormScreen(),
                ),
                GoRoute(
                  path: 'assets/:id/edit',
                  builder: (context, state) => AssetFormScreen(
                    assetId: state.pathParameters['id'],
                  ),
                ),
                GoRoute(
                  path: 'analytics',
                  builder: (context, state) => const FinanceAnalyticsScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/habits',
              builder: (context, state) => const HabitsListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const HabitFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => HabitDetailScreen(
                    habitId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) => HabitFormScreen(
                    habitId: state.pathParameters['id'],
                  ),
                ),
              ],
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
                GoRoute(
                  path: 'body-weight',
                  builder: (context, state) => const BodyWeightScreen(),
                ),
                GoRoute(
                  path: 'water',
                  builder: (context, state) => const WaterScreen(),
                ),
                GoRoute(
                  path: 'measurements',
                  builder: (context, state) => const MeasurementsListScreen(),
                  routes: [
                    GoRoute(
                      path: ':type',
                      builder: (context, state) => MeasurementDetailScreen(
                        type: MeasurementType.values.byName(state.pathParameters['type']!),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'nutrition',
                  builder: (context, state) => const NutritionScreen(),
                  routes: [
                    GoRoute(
                      path: 'foods',
                      builder: (context, state) => const FoodLibraryScreen(),
                    ),
                    GoRoute(
                      path: 'foods/new',
                      builder: (context, state) => const FoodItemFormScreen(),
                    ),
                    GoRoute(
                      path: 'foods/:id/edit',
                      builder: (context, state) => FoodItemFormScreen(
                        foodItemId: state.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'progress-photos',
                  builder: (context, state) => const ProgressPhotosScreen(),
                  routes: [
                    GoRoute(
                      path: 'view',
                      builder: (context, state) => PhotoViewerScreen(
                        photo: state.extra as ProgressPhoto,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'supplements',
                  builder: (context, state) => const SupplementsScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const SupplementFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) => SupplementFormScreen(
                        supplementId: state.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'cardio',
                  builder: (context, state) => const CardioListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const CardioFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) => CardioFormScreen(
                        sessionId: state.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'recovery',
                  builder: (context, state) => const RecoveryScreen(),
                ),
                GoRoute(
                  path: 'strength-progress',
                  builder: (context, state) => const StrengthProgressScreen(),
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
      builder: (context, state) => const GoalsListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const GoalFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => GoalDetailScreen(
            goalId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => GoalFormScreen(
            goalId: state.pathParameters['id'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/creator-studio',
      builder: (context, state) => const CreatorStudioHomeScreen(),
      routes: [
        GoRoute(
          path: 'pipeline',
          builder: (context, state) => const ContentPipelineScreen(),
        ),
        GoRoute(
          path: 'projects/new',
          builder: (context, state) => const ContentProjectFormScreen(),
        ),
        GoRoute(
          path: 'projects/:id/edit',
          builder: (context, state) => ContentProjectFormScreen(
            projectId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: 'clips',
          builder: (context, state) => const ClipLibraryScreen(),
        ),
        GoRoute(
          path: 'clips/new',
          builder: (context, state) => const ClipFormScreen(),
        ),
        GoRoute(
          path: 'clips/:id/edit',
          builder: (context, state) => ClipFormScreen(
            clipId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: 'analytics',
          builder: (context, state) => const ContentAnalyticsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/entertainment',
      builder: (context, state) => const EntertainmentHomeScreen(),
      routes: [
        GoRoute(
          path: 'library',
          builder: (context, state) => const EntertainmentLibraryScreen(),
        ),
        GoRoute(
          path: 'items/new',
          builder: (context, state) => const MediaItemFormScreen(),
        ),
        GoRoute(
          path: 'items/:id/edit',
          builder: (context, state) => MediaItemFormScreen(
            itemId: state.pathParameters['id'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/journal',
      builder: (context, state) => const JournalHomeScreen(),
      routes: [
        GoRoute(
          path: 'history',
          builder: (context, state) => const JournalHistoryScreen(),
        ),
        GoRoute(
          path: 'entries/new',
          builder: (context, state) => JournalEntryFormScreen(
            initialType: state.extra as JournalEntryType?,
          ),
        ),
        GoRoute(
          path: 'entries/:id/edit',
          builder: (context, state) => JournalEntryFormScreen(
            entryId: state.pathParameters['id'],
          ),
        ),
      ],
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
