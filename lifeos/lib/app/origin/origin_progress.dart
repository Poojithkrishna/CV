import 'package:flutter/material.dart';

import 'origin_colors.dart';
import 'origin_motion.dart';

/// A thin engraved-looking progress bar — used for the rank-progress ring's
/// linear cousin and the Sanctuary "Origin Balance" attribute bands. Draws
/// as a track of small ticks rather than a single smooth Material bar, to
/// read as an instrument gauge rather than a loading indicator.
class OriginProgress extends StatelessWidget {
  const OriginProgress({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.animate = true,
  });

  final double value;
  final double height;
  final Color? color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = color ?? OriginColors.accent;
    final Widget bar = LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: OriginColors.hairline,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!animate) return bar;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: OriginMotion.chartReveal,
      curve: OriginMotion.curve,
      builder: (context, animatedValue, _) => OriginProgress(
        value: animatedValue,
        height: height,
        color: color,
        animate: false,
      ),
    );
  }
}
