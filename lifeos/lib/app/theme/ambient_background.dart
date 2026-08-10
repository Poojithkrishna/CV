import 'package:flutter/material.dart';

import '../origin/origin_colors.dart';

/// The persistent dark-mode backdrop sitting behind every screen in the
/// app — obsidian base plus a single, near-invisible vignette. Mounted
/// once in `DemonOriginApp`'s `MaterialApp.router` builder (outside the
/// router's Navigator), so it never rebuilds on navigation and every
/// screen gets it for free simply by having a transparent
/// `scaffoldBackgroundColor` (see `AppTheme`) — no per-screen wiring
/// needed.
///
/// Deliberately restrained per the Arcane Futurism spec: no watermark
/// (the emblem belongs in specific brand moments — the app bar, Settings —
/// not as universal wallpaper), no colored glow blobs, no busy gradients.
/// The background stays subordinate to content.
///
/// Light mode intentionally opts out (see call site) — this app's daytime
/// mode is meant to stay plain and easy to read.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.3,
            colors: [Color(0xFF141219), OriginColors.background],
          ),
        ),
      ),
    );
  }
}
