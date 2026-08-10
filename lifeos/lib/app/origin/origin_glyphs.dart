import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Origin Glyph family (spec §5) — one small, monoline vector mark per
/// domain, replacing Material icons as Demon Origin's primary iconography.
/// Every glyph is drawn on the same normalized 24×24 grid with the same
/// stroke language (round caps/joins, no fill) so they read as one
/// designed set rather than icons pulled from a generic library.
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
  final Color? color;
  final double strokeWidth;

  /// The selected/active variant — slightly heavier stroke and a soft
  /// interior fill, used by RuneDock's engraved capsule state.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ?? DefaultTextStyle.of(context).style.color ?? Colors.white;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          type: type,
          color: resolved,
          strokeWidth: filled ? strokeWidth + 0.3 : strokeWidth,
          filled: filled,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.type,
    required this.color,
    required this.strokeWidth,
    required this.filled,
  });

  final OriginGlyphType type;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    // Every path below is authored against a 24x24 box, then scaled to fit.
    final double scale = size.width / 24;
    canvas.save();
    canvas.scale(scale, scale);

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fill = Paint()
      ..color = color.withOpacity(0.14)
      ..style = PaintingStyle.fill;

    switch (type) {
      case OriginGlyphType.sanctuary:
        _paintSanctuary(canvas, stroke, fill);
        break;
      case OriginGlyphType.wealth:
        _paintWealth(canvas, stroke, fill);
        break;
      case OriginGlyphType.fitness:
        _paintFitness(canvas, stroke, fill);
        break;
      case OriginGlyphType.cultivation:
        _paintCultivation(canvas, stroke, fill);
        break;
      case OriginGlyphType.goals:
        _paintGoals(canvas, stroke, fill);
        break;
      case OriginGlyphType.creator:
        _paintCreator(canvas, stroke, fill);
        break;
      case OriginGlyphType.entertainment:
        _paintEntertainment(canvas, stroke, fill);
        break;
      case OriginGlyphType.chronicle:
        _paintChronicle(canvas, stroke, fill);
        break;
      case OriginGlyphType.settings:
        _paintSettings(canvas, stroke, fill);
        break;
      case OriginGlyphType.quickAdd:
        _paintQuickAdd(canvas, stroke, fill);
        break;
    }
    canvas.restore();
  }

  // Four-point Origin star/seal — a compass-rose sigil, echoing the app
  // icon's spiked emblem without reproducing it.
  void _paintSanctuary(Canvas canvas, Paint stroke, Paint fill) {
    const Offset c = Offset(12, 12);
    Path star = Path();
    const double outer = 10, inner = 3.6;
    for (int i = 0; i < 8; i++) {
      final double angle = (math.pi / 4) * i - math.pi / 2;
      final double r = i.isEven ? outer : inner;
      final Offset p = c + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    if (filled) canvas.drawPath(star, fill);
    canvas.drawPath(star, stroke);
    canvas.drawCircle(c, 2, stroke);
  }

  // Heraldic coin + vault: a circle (coin) with a slot, orbited by a short
  // arc suggesting a vault door.
  void _paintWealth(Canvas canvas, Paint stroke, Paint fill) {
    const Offset c = Offset(12, 12.5);
    if (filled) canvas.drawCircle(c, 7.5, fill);
    canvas.drawCircle(c, 7.5, stroke);
    canvas.drawLine(const Offset(12, 7.5), const Offset(12, 17.5), stroke);
    canvas.drawLine(const Offset(9, 9.5), const Offset(9, 15.5), stroke);
    canvas.drawLine(const Offset(15, 9.5), const Offset(15, 15.5), stroke);
    final Rect vault = Rect.fromCircle(center: c, radius: 10.5);
    canvas.drawArc(vault, -math.pi * 0.85, math.pi * 0.3, false, stroke);
  }

  // Crossed relic blades — two tapered lines crossing at the center with a
  // small crossguard, evoking a stylized barbell/rune rather than swords.
  void _paintFitness(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawLine(const Offset(5, 5), const Offset(19, 19), stroke);
    canvas.drawLine(const Offset(19, 5), const Offset(5, 19), stroke);
    canvas.drawLine(const Offset(3.5, 3.5), const Offset(6.5, 6.5), stroke);
    canvas.drawLine(const Offset(17.5, 17.5), const Offset(20.5, 20.5), stroke);
    canvas.drawLine(const Offset(20.5, 3.5), const Offset(17.5, 6.5), stroke);
    canvas.drawLine(const Offset(6.5, 17.5), const Offset(3.5, 20.5), stroke);
    canvas.drawCircle(const Offset(12, 12), 2, filled ? fill : stroke);
  }

  // A flame contained inside a shield outline.
  void _paintCultivation(Canvas canvas, Paint stroke, Paint fill) {
    final Path shield = Path()
      ..moveTo(12, 3)
      ..lineTo(19, 6)
      ..lineTo(19, 12)
      ..cubicTo(19, 17, 15.5, 19.5, 12, 21)
      ..cubicTo(8.5, 19.5, 5, 17, 5, 12)
      ..lineTo(5, 6)
      ..close();
    if (filled) canvas.drawPath(shield, fill);
    canvas.drawPath(shield, stroke);

    final Path flame = Path()
      ..moveTo(12, 8)
      ..cubicTo(14, 10.5, 14.5, 12.5, 13, 14.5)
      ..cubicTo(14.5, 14, 15, 12.5, 14, 11)
      ..cubicTo(15.5, 12.5, 15.5, 15.5, 13.5, 17)
      ..cubicTo(11, 18.5, 8.5, 17, 9, 14.5)
      ..cubicTo(9.3, 16, 10.5, 16.3, 10.5, 15)
      ..cubicTo(9.5, 15, 9, 13.5, 9.7, 12)
      ..cubicTo(10, 13, 10.7, 13, 11, 12)
      ..cubicTo(10.5, 10.5, 11, 9, 12, 8)
      ..close();
    canvas.drawPath(flame, stroke);
  }

  // Ascending standard/banner — a pole with a pennant tapering upward.
  void _paintGoals(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawLine(const Offset(7, 4), const Offset(7, 21), stroke);
    final Path pennant = Path()
      ..moveTo(7, 5)
      ..lineTo(18, 8)
      ..lineTo(13.5, 11)
      ..lineTo(18, 14)
      ..lineTo(7, 11)
      ..close();
    if (filled) canvas.drawPath(pennant, fill);
    canvas.drawPath(pennant, stroke);
  }

  // A camera aperture (radiating blades) inside a seal ring.
  void _paintCreator(Canvas canvas, Paint stroke, Paint fill) {
    const Offset c = Offset(12, 12);
    canvas.drawCircle(c, 9.5, stroke);
    const int blades = 6;
    const double r1 = 2.2, r2 = 6.2;
    for (int i = 0; i < blades; i++) {
      final double a = (2 * math.pi / blades) * i;
      final double aNext = a + (2 * math.pi / blades) * 0.62;
      final Offset p1 = c + Offset(math.cos(a), math.sin(a)) * r1;
      final Offset p2 = c + Offset(math.cos(a), math.sin(a)) * r2;
      final Offset p3 = c + Offset(math.cos(aNext), math.sin(aNext)) * r1;
      final Path blade = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);
      canvas.drawPath(blade, stroke);
    }
    if (filled) canvas.drawCircle(c, r1, fill);
  }

  // Three-card/play sigil — overlapping card shapes with a small play mark.
  void _paintEntertainment(Canvas canvas, Paint stroke, Paint fill) {
    RRect card(double dx) => RRect.fromRectAndRadius(
          Rect.fromLTWH(4.5 + dx, 5 + dx * 0.6, 12, 15),
          const Radius.circular(2),
        );
    canvas.drawRRect(card(3), stroke);
    canvas.drawRRect(card(1.5), stroke);
    final RRect front = card(0);
    if (filled) canvas.drawRRect(front, fill);
    canvas.drawRRect(front, stroke);
    final Path play = Path()
      ..moveTo(9.5, 9.5)
      ..lineTo(9.5, 15.5)
      ..lineTo(14, 12.5)
      ..close();
    canvas.drawPath(play, stroke);
  }

  // An open grimoire with a small timeline tick beneath it.
  void _paintChronicle(Canvas canvas, Paint stroke, Paint fill) {
    final Path book = Path()
      ..moveTo(12, 6.5)
      ..cubicTo(10.3, 5.2, 6.5, 5, 4.5, 5.6)
      ..lineTo(4.5, 16.5)
      ..cubicTo(6.5, 15.8, 10.3, 16, 12, 17.3)
      ..cubicTo(13.7, 16, 17.5, 15.8, 19.5, 16.5)
      ..lineTo(19.5, 5.6)
      ..cubicTo(17.5, 5, 13.7, 5.2, 12, 6.5)
      ..close();
    if (filled) canvas.drawPath(book, fill);
    canvas.drawPath(book, stroke);
    canvas.drawLine(const Offset(12, 6.5), const Offset(12, 17.3), stroke);
    canvas.drawLine(const Offset(6, 19.5), const Offset(18, 19.5), stroke);
    canvas.drawCircle(const Offset(9, 19.5), 0.9, Paint()..color = color);
    canvas.drawCircle(const Offset(15, 19.5), 0.9, Paint()..color = color);
  }

  // A simplified arcane gear — six blunt teeth around a ring, one inner
  // circle. Deliberately less busy than a literal mechanical gear icon.
  void _paintSettings(Canvas canvas, Paint stroke, Paint fill) {
    const Offset c = Offset(12, 12);
    const double rOuter = 9, rInner = 6.4, toothLen = 2.4;
    const int teeth = 6;
    for (int i = 0; i < teeth; i++) {
      final double a = (2 * math.pi / teeth) * i;
      final Offset from = c + Offset(math.cos(a), math.sin(a)) * rInner;
      final Offset to = c + Offset(math.cos(a), math.sin(a)) * (rInner + toothLen);
      canvas.drawLine(from, to, stroke);
    }
    canvas.drawCircle(c, rOuter - toothLen, stroke);
    if (filled) canvas.drawCircle(c, 2.6, fill);
    canvas.drawCircle(c, 2.6, stroke);
  }

  // A small diamond Origin mark for branded quick-add actions.
  void _paintQuickAdd(Canvas canvas, Paint stroke, Paint fill) {
    final Path diamond = Path()
      ..moveTo(12, 3.5)
      ..lineTo(20.5, 12)
      ..lineTo(12, 20.5)
      ..lineTo(3.5, 12)
      ..close();
    if (filled) canvas.drawPath(diamond, fill);
    canvas.drawPath(diamond, stroke);
    canvas.drawLine(const Offset(12, 8.5), const Offset(12, 15.5), stroke);
    canvas.drawLine(const Offset(8.5, 12), const Offset(15.5, 12), stroke);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.filled != filled;
}
