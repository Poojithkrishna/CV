import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Calendar & Tasks',
      icon: Icons.calendar_month_rounded,
      gradient: LinearGradient(
        colors: [AppColors.calendar, Color(0xFF164E63)],
      ),
      description:
          'Daily/weekly planner, tasks, events, time blocking and reminders '
          'land here next.',
    );
  }
}
