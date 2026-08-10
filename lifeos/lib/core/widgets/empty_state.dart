import 'package:flutter/material.dart';
import '../../app/origin/origin_glyphs.dart';

/// Consistent "nothing here yet" placeholder, used across every module's
/// empty list state and for the not-yet-built module screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.glyph,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// When set, renders this module's Origin Glyph emblem instead of
  /// [icon] in the circle above the title — the generic Material icon
  /// otherwise leaves module empty-states looking untouched by the
  /// Origin redesign even after the nav and FABs were reworked.
  final OriginGlyphType? glyph;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: glyph != null
                  ? OriginGlyph(glyph!, size: 40)
                  : Icon(icon, size: 40, color: colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
