import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class EntertainmentHomeScreen extends StatelessWidget {
  const EntertainmentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      gradient: LinearGradient(
        colors: [AppColors.entertainment, Color(0xFF4C1D95)],
      ),
      description:
          'Games, movies, series, anime, books, manga and courses with '
          'wishlist/currently-watching/completed tracking land here next.',
    );
  }
}
