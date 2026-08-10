import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../origin/origin_glyphs.dart';
import '../origin/origin_navigation.dart';

/// Rune Dock scaffold wrapping the seven primary destinations (spec §6).
/// Everything else (module detail screens, forms) pushes on top of this
/// shell so the dock stays put while drilling into a domain. There is no
/// "More" branch — every destination the spec names is reachable directly.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<RuneDockDestination> _destinations = [
    RuneDockDestination(glyph: OriginGlyphType.sanctuary, label: 'Sanctuary'),
    RuneDockDestination(glyph: OriginGlyphType.wealth, label: 'Wealth'),
    RuneDockDestination(glyph: OriginGlyphType.fitness, label: 'Fitness'),
    RuneDockDestination(glyph: OriginGlyphType.cultivation, label: 'Cultivation'),
    RuneDockDestination(glyph: OriginGlyphType.goals, label: 'Goals'),
    RuneDockDestination(glyph: OriginGlyphType.creator, label: 'Creator'),
    RuneDockDestination(glyph: OriginGlyphType.chronicle, label: 'Chronicle'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: RuneDock(
        destinations: _destinations,
        selectedIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
