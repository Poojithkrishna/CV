import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

/// One tile on the dashboard grid representing a module's current state.
/// [value] is the headline stat (e.g. "₹42,500", "5 day streak", "Ep. 4"),
/// with [subtitle] giving it context.
///
/// Deliberately monochrome — a thin silver ring around the icon rather than
/// a solid module color fill, so the grid reads as one coherent panel of
/// glass tiles (matching the app's black/grey/white identity) instead of a
/// row of differently-colored blocks; each module is told apart by its
/// icon and label, not by a hue.
class ModuleSummaryCard extends StatelessWidget {
  const ModuleSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white.withOpacity(0.5)),
            ],
          ),
          const Spacer(),
          Text(
            subtitle.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTheme.hudFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
