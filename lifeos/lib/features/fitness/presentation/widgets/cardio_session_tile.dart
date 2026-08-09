import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cardio_session.dart';

final Color _accentColor = AppGradients.fitness.colors.first;

class CardioSessionTile extends StatelessWidget {
  const CardioSessionTile({super.key, required this.session, this.onTap});

  final CardioSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final List<String> details = [
      '${session.durationMinutes.toStringAsFixed(0)} min',
      if (session.distanceKm != null) '${session.distanceKm!.toStringAsFixed(1)} km',
      if (session.caloriesBurned != null) '${session.caloriesBurned!.toStringAsFixed(0)} kcal',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _accentColor.withOpacity(0.18),
          child: Icon(session.type.icon, color: _accentColor, size: 20),
        ),
        title: Text(session.type.label),
        subtitle: Text('${AppFormatters.shortDate(session.date)} · ${details.join(' · ')}'),
      ),
    );
  }
}
