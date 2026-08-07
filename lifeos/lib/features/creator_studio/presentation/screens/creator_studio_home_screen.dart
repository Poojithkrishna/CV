import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_screen.dart';

class CreatorStudioHomeScreen extends StatelessWidget {
  const CreatorStudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Creator Studio',
      icon: Icons.videocam_rounded,
      gradient: LinearGradient(
        colors: [AppColors.creatorStudio, Color(0xFF831843)],
      ),
      description:
          'The Idea → Recording → Editing → Thumbnail → Upload → Published '
          'pipeline, clip library and upload analytics land here next.',
    );
  }
}
