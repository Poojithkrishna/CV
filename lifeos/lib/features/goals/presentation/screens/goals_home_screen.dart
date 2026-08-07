import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class GoalsHomeScreen extends StatelessWidget {
  const GoalsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Goals',
      icon: Icons.flag_rounded,
      gradient: AppGradients.goals,
      description:
          'Milestones, deadlines, progress bars and habit-linked goals land here next.',
    );
  }
}
