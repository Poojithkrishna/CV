import 'package:flutter/material.dart';

import 'origin_colors.dart';
import 'origin_typography.dart';

/// A ceremonial screen header — Cinzel title, optional eyebrow above it,
/// optional trailing action (Sanctuary's settings gear lives here). Used
/// in place of a plain AppBar title where a screen deserves the display
/// face (spec §4: "Use sparingly").
class OriginHeader extends StatelessWidget {
  const OriginHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow!.toUpperCase(),
                  style: OriginTypography.eyebrow(),
                ),
              Text(
                title,
                style: OriginTypography.heading(size: 24, color: OriginColors.textPrimary),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
