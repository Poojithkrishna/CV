import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/supplement.dart';
import '../../domain/entities/supplement_log_entry.dart';
import '../providers/supplement_providers.dart';

class SupplementTile extends ConsumerWidget {
  const SupplementTile({super.key, required this.supplement, required this.date, this.onTap});

  final Supplement supplement;
  final DateTime date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SupplementLogEntry?> logAsync = ref.watch(
      supplementLogForDateProvider((supplementId: supplement.id, date: date)),
    );
    final bool taken = logAsync.valueOrNull?.taken ?? false;
    final Color color = Color(supplement.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: taken,
        onChanged: (_) => ref
            .read(toggleSupplementTakenUseCaseProvider)
            .call(supplement.id, date),
        activeColor: color,
        title: Text(supplement.name),
        subtitle: supplement.dosageLabel.isEmpty ? null : Text(supplement.dosageLabel),
        secondary: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: onTap,
        ),
      ),
    );
  }
}
