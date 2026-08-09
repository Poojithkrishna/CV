import 'package:flutter/material.dart';

/// Wraps [child] with four short corner brackets — the "targeting reticle"
/// detail sci-fi HUD panels use instead of (or on top of) a plain rounded
/// border, so emphasis surfaces read as an instrument panel rather than a
/// generic card. Purely decorative chrome; doesn't affect layout/padding.
class HudFrame extends StatelessWidget {
  const HudFrame({
    super.key,
    required this.child,
    this.color,
    this.length = 18,
    this.thickness = 2,
    this.inset = 10,
  });

  final Widget child;
  final Color? color;
  final double length;
  final double thickness;
  final double inset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _CornerBracketPainter(
        color: color ?? Colors.white.withOpacity(0.55),
        length: length,
        thickness: thickness,
        inset: inset,
      ),
      child: child,
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  _CornerBracketPainter({
    required this.color,
    required this.length,
    required this.thickness,
    required this.inset,
  });

  final Color color;
  final double length;
  final double thickness;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    void bracket(Offset corner, Offset horizontal, Offset vertical) {
      canvas.drawLine(corner, corner + horizontal, paint);
      canvas.drawLine(corner, corner + vertical, paint);
    }

    final double x0 = inset, y0 = inset;
    final double x1 = size.width - inset, y1 = size.height - inset;

    bracket(Offset(x0, y0), Offset(length, 0), Offset(0, length));
    bracket(Offset(x1, y0), Offset(-length, 0), Offset(0, length));
    bracket(Offset(x0, y1), Offset(length, 0), Offset(0, -length));
    bracket(Offset(x1, y1), Offset(-length, 0), Offset(0, -length));
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.length != length ||
      oldDelegate.thickness != thickness ||
      oldDelegate.inset != inset;
}
