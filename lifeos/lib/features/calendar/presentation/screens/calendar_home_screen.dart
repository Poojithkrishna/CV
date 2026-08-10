import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_task.dart';
import '../../domain/services/calendar_stats.dart';
import '../notifications/calendar_reminders.dart';
import '../providers/calendar_providers.dart';
import '../widgets/calendar_event_tile.dart';
import '../widgets/calendar_task_tile.dart';

const int _weekStripDays = 7;
const LinearGradient _gradient = LinearGradient(
  colors: [AppColors.calendar, Color(0xFF1A1A1A)],
);

/// The task-vs-event choice sheet for "add something new" — a top-level
/// function (not tied to any widget's State) so both [CalendarHomeScreen]'s
/// own FAB and Chronicle's shared FAB (when the Calendar section is active)
/// can trigger the exact same menu.
Future<void> showAddCalendarItemMenu(BuildContext context) async {
  final String? choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_box_outlined),
            title: const Text('New task'),
            onTap: () => Navigator.of(context).pop('task'),
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('New event'),
            onTap: () => Navigator.of(context).pop('event'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  if (choice == 'task') {
    context.push('/calendar/tasks/new');
  } else {
    context.push('/calendar/events/new');
  }
}

/// Entry point for the Calendar & Tasks module: a week-strip day picker,
/// today's pending count, and the selected day's merged agenda of tasks
/// and events. Reachable both as its own route (deep links, widget taps)
/// and embedded as Chronicle's Calendar section (see [CalendarHomeBody]).
class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar & Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddCalendarItemMenu(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: const CalendarHomeBody(),
    );
  }
}

class CalendarHomeBody extends ConsumerStatefulWidget {
  const CalendarHomeBody({super.key});

  @override
  ConsumerState<CalendarHomeBody> createState() => _CalendarHomeBodyState();
}

class _CalendarHomeBodyState extends ConsumerState<CalendarHomeBody> {
  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  late DateTime _selectedDate = _dateOnly(DateTime.now());

  Future<void> _toggleTaskDone(CalendarTask task) async {
    await ref.read(toggleTaskDoneUseCaseProvider).call(task.id);
    await syncTaskReminder(
      ref.read(notificationServiceProvider),
      task.copyWith(isDone: !task.isDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CalendarTask>> tasksAsync = ref.watch(allTasksProvider);
    final AsyncValue<List<CalendarEvent>> eventsAsync = ref.watch(allEventsProvider);

    final bool isLoading = tasksAsync.isLoading || eventsAsync.isLoading;
    final Object? error = tasksAsync.hasError
        ? tasksAsync.error
        : eventsAsync.hasError
            ? eventsAsync.error
            : null;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text('Something went wrong: $error'));
    return _buildBody(context, tasksAsync.value!, eventsAsync.value!);
  }

  Widget _buildBody(BuildContext context, List<CalendarTask> tasks, List<CalendarEvent> events) {
    final int pending = CalendarStats.pendingCount(tasks);
    final DateTime today = _dateOnly(DateTime.now());

    final List<CalendarEvent> dayEvents = CalendarStats.eventsOnDate(events, _selectedDate)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final List<CalendarTask> dayTasks = CalendarStats.tasksOnDate(tasks, _selectedDate);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        GradientCard(
          gradient: _gradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pending == 1 ? '1 pending task' : '$pending pending tasks',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _weekStripDays,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final DateTime day = today.subtract(const Duration(days: 3)).add(Duration(days: index));
              final bool isSelected = day == _selectedDate;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.calendar
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(day),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white70 : null,
                        ),
                      ),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        if (dayEvents.isEmpty && dayTasks.isEmpty)
          EmptyState(
            icon: Icons.event_available_outlined,
            title: 'Nothing scheduled',
            message: 'Add a task or event for this day.',
            actionLabel: 'Add something',
            onAction: () => showAddCalendarItemMenu(context),
          )
        else ...[
          if (dayEvents.isNotEmpty) ...[
            Text('Events', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final CalendarEvent event in dayEvents)
              CalendarEventTile(
                event: event,
                onTap: () => context.push('/calendar/events/${event.id}/edit'),
              ),
            const SizedBox(height: 12),
          ],
          if (dayTasks.isNotEmpty) ...[
            Text('Tasks', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final CalendarTask task in dayTasks)
              CalendarTaskTile(
                task: task,
                onTap: () => context.push('/calendar/tasks/${task.id}/edit'),
                onToggleDone: () => _toggleTaskDone(task),
              ),
          ],
        ],
      ],
    );
  }
}
