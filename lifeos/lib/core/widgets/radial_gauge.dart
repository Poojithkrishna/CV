import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular "reactor core" progress ring — used in place of a flat
/// `LinearProgressIndicator` for the one or two readouts per screen that
/// should feel like a HUD instrument rather than a loading bar (the
/// dashboard's rank/XP ring). Draws a thin track plus a bright arc for
/// [value] (0–1), starting at 12 o'clock.
class RadialGauge extends StatelessWidget {
  const RadialGauge({
    super.key,
    required this.value,
    required this.child,
    this.size = 96,
    this.strokeWidth = 6,
    this.trackColor,
    this.valueColor,
  });

  final double value;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadialGaugePainter(
          value: value.clamp(0, 1),
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? Colors.white.withOpacity(0.15),
          valueColor: valueColor ?? Colors.white,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  _RadialGaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.valueColor,
  });

  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color valueColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double start = -math.pi / 2;

    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (value > 0) {
      final Paint arc = Paint()
        ..color = valueColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, 2 * math.pi * value, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.valueColor != valueColor;
}
