import 'package:flutter/material.dart';

import 'origin_colors.dart';
import 'origin_typography.dart';

/// A single numbered line in Sanctuary's "Today's Rite" list — compact,
/// no card wrapper, just a number glyph and a label (spec §7 mockup).
class RitualRow extends StatelessWidget {
  const RitualRow({
    super.key,
    required this.index,
    required this.label,
    this.done = false,
    this.onTap,
  });

  final int index;
  final String label;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: OriginTypography.figure(
                  size: 14,
                  color: OriginColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: OriginTypography.body,
                  fontSize: 15,
                  color: done ? OriginColors.textSecondary : OriginColors.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Icon(
              done ? Icons.check_circle_outline : Icons.chevron_right_rounded,
              size: 18,
              color: OriginColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact ledger-style row — label left, figure right, hairline below.
/// Reused across Wealth (accounts/transactions) and anywhere else a plain
/// list-of-values reads better than another panel.
class TreasuryRow extends StatelessWidget {
  const TreasuryRow({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.leading,
    this.onTap,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: OriginTypography.body,
                      fontSize: 15,
                      color: OriginColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: OriginTypography.body,
                        fontSize: 12,
                        color: OriginColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              value,
              style: OriginTypography.figure(size: 16, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
