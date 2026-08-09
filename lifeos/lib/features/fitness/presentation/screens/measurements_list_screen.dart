import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../providers/measurement_providers.dart';

final Color _accentColor = AppGradients.fitness.colors.first;

class MeasurementsListScreen extends ConsumerWidget {
  const MeasurementsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<MeasurementType, MeasurementEntry>> latestAsync =
        ref.watch(latestMeasurementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Measurements')),
      body: latestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (Map<MeasurementType, MeasurementEntry> latest) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              for (final MeasurementType type in MeasurementType.values)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => context.push('/fitness/measurements/${type.name}'),
                    leading: CircleAvatar(
                      backgroundColor: _accentColor.withOpacity(0.18),
                      child: Icon(type.icon, color: _accentColor, size: 20),
                    ),
                    title: Text(type.label),
                    subtitle: latest[type] != null
                        ? Text('Last logged ${AppFormatters.relativeDay(latest[type]!.date)}')
                        : const Text('Not logged yet'),
                    trailing: latest[type] != null
                        ? Text(
                            '${latest[type]!.valueCm.toStringAsFixed(1)} cm',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
