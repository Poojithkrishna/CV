import 'package:flutter/material.dart';

import '../../core/widgets/app_icon_mark.dart';
import 'app_colors.dart';

/// The persistent dark-mode backdrop sitting behind every screen in the
/// app — a base gradient, two slowly "breathing" brand-colored glow orbs,
/// and a large, barely-there emblem watermark. Mounted once in
/// `DemonOriginApp`'s `MaterialApp.router` builder (outside the router's
/// Navigator), so it never rebuilds on navigation and every screen gets it
/// for free simply by having a transparent `scaffoldBackgroundColor` (see
/// `AppTheme`) — no per-screen wiring needed.
///
/// Light mode intentionally opts out (see call site) — the glow read as
/// murky rather than premium against a light surface, and this app's
/// daytime mode is meant to stay plain and easy to read.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF150C22), Color(0xFF07050B)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final double breathe = 0.75 + (_controller.value * 0.25);
            return Stack(
              children: [
                // A large, faint emblem watermark — the one piece of "the
                // app icon, inside the app" that's always present rather
                // than tucked into an app bar.
                Positioned(
                  right: -60,
                  bottom: 40,
                  child: Opacity(
                    opacity: 0.05,
                    child: AppIconMark(size: 320, gradient: false),
                  ),
                ),
                Positioned(
                  top: -120,
                  right: -80,
                  child: _GlowOrb(color: AppColors.brandBright, size: 320, intensity: breathe),
                ),
                Positioned(
                  bottom: -140,
                  left: -100,
                  child: _GlowOrb(
                      color: AppColors.brandMid, size: 360, intensity: 1.25 - breathe),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size, required this.intensity});

  final Color color;
  final double size;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.22 * intensity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
