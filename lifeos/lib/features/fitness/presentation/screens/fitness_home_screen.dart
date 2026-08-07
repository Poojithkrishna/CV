import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class FitnessHomeScreen extends StatelessWidget {
  const FitnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Fitness',
      icon: Icons.fitness_center_rounded,
      gradient: AppGradients.fitness,
      description:
          'Workout plans, exercise library, progress photos, measurements, '
          'nutrition, recovery and strength progress land here next.',
    );
  }
}
