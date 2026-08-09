import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/food_log_entry.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/entities/nutrition_totals.dart';
import '../../domain/services/nutrition_stats.dart';
import '../providers/nutrition_providers.dart';

final Uuid _uuid = Uuid();
final Color _accentColor = AppGradients.fitness.colors.first;

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();

  DateTime get _normalized =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  Future<String?> _pickFoodId(BuildContext context, List<FoodItem> items) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a food'),
        content: SizedBox(
          width: double.maxFinite,
          child: items.isEmpty
              ? const Text('Your food library is empty — add one first.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final FoodItem item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.caloriesPerServing.toStringAsFixed(0)} kcal per ${item.servingLabel}'),
                      onTap: () => Navigator.of(context).pop(item.id),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _logToMeal(
    BuildContext context,
    WidgetRef ref,
    MealType mealType,
    List<FoodItem> foodItems,
  ) async {
    final String? foodItemId = await _pickFoodId(context, foodItems);
    if (foodItemId == null) return;
    final FoodItem foodItem = foodItems.firstWhere((f) => f.id == foodItemId);

    if (!context.mounted) return;
    final double? servings = await showAmountInputDialog(
      context,
      title: 'Servings of ${foodItem.name}',
      label: 'Servings',
      initialValue: 1,
    );
    if (servings == null) return;

    final FoodLogEntry entry = FoodLogEntry(
      id: _uuid.v4(),
      foodItem: foodItem,
      date: _normalized,
      mealType: mealType,
      servings: servings,
      createdAt: DateTime.now(),
    );
    final result = await ref.read(logFoodUseCaseProvider).call(entry);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, WidgetRef ref, String id) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Remove entry?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;
    await ref.read(deleteFoodLogEntryUseCaseProvider).call(id);
  }

  Future<void> _editCalorieGoal(BuildContext context, WidgetRef ref, NutritionGoal? current) async {
    final double? calories = await showAmountInputDialog(
      context,
      title: 'Daily calorie goal',
      label: 'Calories (kcal)',
      initialValue: current?.dailyCalories ?? 2000,
    );
    if (calories == null) return;

    final DateTime now = DateTime.now();
    final NutritionGoal goal = (current ?? NutritionGoal(
          dailyCalories: 2000,
          proteinG: 150,
          carbsG: 250,
          fatG: 65,
          updatedAt: now,
        ))
        .copyWith(dailyCalories: calories, updatedAt: now);

    final result = await ref.read(updateNutritionGoalUseCaseProvider).call(goal);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<FoodLogEntry>> entriesAsync =
        ref.watch(logEntriesForDateProvider(_normalized));
    final AsyncValue<List<FoodItem>> foodItemsAsync = ref.watch(activeFoodItemsProvider);
    final AsyncValue<NutritionGoal?> goalAsync = ref.watch(nutritionGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Calorie goal',
            onPressed: () => _editCalorieGoal(context, ref, goalAsync.valueOrNull),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Food library',
            onPressed: () => context.push('/fitness/nutrition/foods'),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<FoodLogEntry> entries) {
          final NutritionTotals totals = NutritionStats.totalsFor(entries);
          final Map<MealType, List<FoodLogEntry>> byMeal = NutritionStats.groupByMeal(entries);
          final NutritionGoal? goal = goalAsync.valueOrNull;
          final double calorieGoal = goal?.dailyCalories ?? 2000;
          final double progress =
              calorieGoal <= 0 ? 0 : (totals.calories / calorieGoal).clamp(0, 1).toDouble();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => setState(
                      () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
                    ),
                  ),
                  Text(
                    AppFormatters.relativeDay(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => setState(
                      () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totals.calories.toStringAsFixed(0)} / ${calorieGoal.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    LabeledProgressBar(
                      progress: progress,
                      leadingLabel: '${(progress * 100).toStringAsFixed(0)}%',
                      trailingLabel: '${(calorieGoal - totals.calories).toStringAsFixed(0)} kcal left',
                      color: _accentColor,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MacroStat(label: 'Protein', grams: totals.proteinG),
                        _MacroStat(label: 'Carbs', grams: totals.carbsG),
                        _MacroStat(label: 'Fat', grams: totals.fatG),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (final MealType mealType in MealType.values)
                _MealSection(
                  mealType: mealType,
                  entries: byMeal[mealType] ?? const [],
                  onAdd: () => _logToMeal(
                    context,
                    ref,
                    mealType,
                    foodItemsAsync.valueOrNull ?? const [],
                  ),
                  onDeleteEntry: (id) => _deleteEntry(context, ref, id),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({required this.label, required this.grams});

  final String label;
  final double grams;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${grams.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.mealType,
    required this.entries,
    required this.onAdd,
    required this.onDeleteEntry,
  });

  final MealType mealType;
  final List<FoodLogEntry> entries;
  final VoidCallback onAdd;
  final void Function(String id) onDeleteEntry;

  @override
  Widget build(BuildContext context) {
    final double mealCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(mealType.icon, color: _accentColor),
              title: Text(mealType.label),
              subtitle: Text('${mealCalories.toStringAsFixed(0)} kcal'),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAdd,
              ),
            ),
            for (final FoodLogEntry entry in entries)
              ListTile(
                dense: true,
                title: Text(entry.foodItem.name),
                subtitle: Text(
                  '${entry.servings.toStringAsFixed(entry.servings.truncateToDouble() == entry.servings ? 0 : 1)}'
                  ' × ${entry.foodItem.servingLabel} · ${entry.calories.toStringAsFixed(0)} kcal',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => onDeleteEntry(entry.id),
                ),
              ),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Nothing logged yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
