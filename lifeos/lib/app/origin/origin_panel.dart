import 'package:flutter/material.dart';

import 'origin_colors.dart';
import 'origin_motion.dart';
import 'origin_shapes.dart';
import 'origin_spacing.dart';

/// The architectural panel that replaces "rounded card for everything"
/// (spec §8): a flat surface, a low-contrast hairline border, minimal
/// shadow. Only [hero] surfaces get the subtle ambient glow and the
/// clipped top-right corner — ordinary panels stay quiet rectangles.
class OriginPanel extends StatelessWidget {
  const OriginPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(OriginSpacing.lg),
    this.hero = false,
    this.onTap,
    this.secondary = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Hero panels (one per screen, at most) get a clipped corner and a
  /// faint violet ambient glow — the spec's "only hero surfaces may have a
  /// very subtle Aether/Violet ambient glow."
  final bool hero;

  /// Uses the slightly-lighter secondary surface tone instead of the
  /// primary one — for a panel nested inside another panel.
  final bool secondary;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final OutlinedBorder shape =
        hero ? OriginShapes.clippedCorner() : OriginShapes.panel();
    final Color fill = secondary ? OriginColors.surfaceSecondary : OriginColors.surface;

    final Widget surface = Material(
      color: fill,
      shape: shape.copyWith(
        side: BorderSide(
          color: hero ? OriginColors.hairlineStrong : OriginColors.hairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: OriginColors.accent.withOpacity(0.06),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (!hero) return surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OriginShapes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: OriginColors.accent.withOpacity(0.16),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      child: surface,
    );
  }
}

/// A thin horizontal rule between sections within a panel — used instead
/// of separate cards to group related rows (spec §8: "internal dividers").
class OriginDivider extends StatelessWidget {
  const OriginDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(
        color: OriginColors.hairline,
        height: OriginSpacing.xxl,
        thickness: 1,
      );
}

/// A restrained fade+rise entrance used for panels appearing on first
/// build — the spec's 180–260ms transition, not a bounce.
class OriginReveal extends StatelessWidget {
  const OriginReveal({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: OriginMotion.transition,
      curve: OriginMotion.curve,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
      ),
      child: child,
    );
  }
}
