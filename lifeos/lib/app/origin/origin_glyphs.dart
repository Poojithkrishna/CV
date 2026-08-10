import 'package:flutter/material.dart';

/// The Origin Glyph family (spec §5) — one detailed emblem per domain,
/// replacing Material icons as Demon Origin's primary iconography.
///
/// These are the user-supplied "Version 5" reference emblems (temple for
/// Wealth, dumbbell-arm for Fitness, seated figure for Cultivation, summit
/// standard for Goals, camera for Creator, popcorn for Entertainment,
/// quill+inkwell for Chronicle, gear+compass for Settings) bundled as
/// pre-rendered art in `assets/icons/origin/`, each already keyed to a
/// transparent background and set inside a spiked medallion ring that
/// echoes the app icon's own emblem.
enum OriginGlyphType {
  sanctuary,
  wealth,
  fitness,
  cultivation,
  goals,
  creator,
  entertainment,
  chronicle,
  settings,
  quickAdd,
}

extension on OriginGlyphType {
  String get _asset {
    switch (this) {
      case OriginGlyphType.sanctuary:
        return 'sanctuary';
      case OriginGlyphType.wealth:
        return 'wealth';
      case OriginGlyphType.fitness:
        return 'fitness';
      case OriginGlyphType.cultivation:
        return 'cultivation';
      case OriginGlyphType.goals:
        return 'goals';
      case OriginGlyphType.creator:
        return 'creator';
      case OriginGlyphType.entertainment:
        return 'entertainment';
      case OriginGlyphType.chronicle:
        return 'chronicle';
      case OriginGlyphType.settings:
        return 'settings';
      case OriginGlyphType.quickAdd:
        return 'quick_add';
    }
  }
}

class OriginGlyph extends StatelessWidget {
  const OriginGlyph(
    this.type, {
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 1.7,
    this.filled = false,
  });

  final OriginGlyphType type;
  final double size;

  /// Unused by the bundled emblem art (it's full-color, not a tintable
  /// silhouette) — kept so existing call sites don't need to change.
  final Color? color;
  final double strokeWidth;

  /// The selected/active variant — full opacity, versus a dimmed resting
  /// state for unselected destinations (e.g. in RuneDock).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Opacity(
        opacity: filled ? 1.0 : 0.68,
        child: Image.asset(
          'assets/icons/origin/${type._asset}.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
