import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class HabitsHomeScreen extends StatelessWidget {
  const HabitsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Habits',
      icon: Icons.local_fire_department_rounded,
      gradient: AppGradients.habits,
      description:
          'Daily/weekly/monthly habits, collection habits linked to other '
          'modules, streaks, heatmaps and correlation insights land here next.',
    );
  }
}
