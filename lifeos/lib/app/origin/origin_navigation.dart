import 'package:flutter/material.dart';

import 'origin_colors.dart';
import 'origin_glyphs.dart';
import 'origin_motion.dart';

class RuneDockDestination {
  const RuneDockDestination({required this.glyph, required this.label});

  final OriginGlyphType glyph;
  final String label;
}

/// The Rune Dock (spec §6) — a custom bottom navigation rail, deliberately
/// not a stock `NavigationBar`. Exactly one destination at a time carries
/// the "engraved capsule" plate; every other destination is glyph-only and
/// quiet. Labels exist for semantics/tooltips but never paint, matching
/// the spec's "one carved navigation rail," not seven equally loud pills.
class RuneDock extends StatelessWidget {
  const RuneDock({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<RuneDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: OriginColors.surface,
        border: Border(top: BorderSide(color: OriginColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < destinations.length; i++)
                    _RuneDockItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RuneDockItem extends StatelessWidget {
  const _RuneDockItem({required this.destination, required this.selected, required this.onTap});

  final RuneDockDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: destination.label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: OriginMotion.pressResponse,
          curve: OriginMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? OriginColors.surfaceSecondary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? OriginColors.violet.withOpacity(0.55) : Colors.transparent,
            ),
          ),
          child: OriginGlyph(
            destination.glyph,
            size: 22,
            color: selected ? OriginColors.textPrimary : OriginColors.textSecondary,
            filled: selected,
          ),
        ),
      ),
    );
  }
}
