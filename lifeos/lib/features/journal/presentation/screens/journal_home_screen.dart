import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class JournalHomeScreen extends StatelessWidget {
  const JournalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Journal',
      icon: Icons.menu_book_rounded,
      gradient: LinearGradient(
        colors: [AppColors.journal, Color(0xFF115E59)],
      ),
      description:
          'Morning journal, night reflection, gratitude, mood tracking and '
          'free writing land here next.',
    );
  }
}
