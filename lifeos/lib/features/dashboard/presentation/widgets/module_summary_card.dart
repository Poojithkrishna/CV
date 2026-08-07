import 'package:flutter/material.dart';

import '../../../../core/widgets/gradient_card.dart';

/// One tile on the dashboard grid representing a module's current state.
/// [value] is the headline stat (e.g. "₹42,500", "5 day streak", "Ep. 4"),
/// with [subtitle] giving it context.
class ModuleSummaryCard extends StatelessWidget {
  const ModuleSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: gradient,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 22),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
