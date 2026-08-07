import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class GamificationHomeScreen extends StatelessWidget {
  const GamificationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Demon God Cultivation',
      icon: Icons.local_fire_department_rounded,
      gradient: AppGradients.gamification,
      description:
          'Ranks from Mortal to Demon God, the eight attributes, XP, '
          'achievements, titles and Life Score land here next.',
    );
  }
}
