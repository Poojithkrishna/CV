import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Origin Glyph family (spec §5) — one small vector mark per domain,
/// replacing Material icons as Demon Origin's primary iconography.
///
/// Style: a solid silhouette pictogram (temple, blade-arm, seated figure,
/// summit-and-standard, camera, popcorn, quill, gear) set inside a spiked
/// medallion ring — echoing the app icon's own radiating-spike emblem.
/// Colors always come from the caller (never hardcoded here) so the whole
/// family stays inside the app's black/white/grey palette.
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

  /// The selected/active variant — a heavier medallion ring, used by
  /// RuneDock's engraved capsule state. The pictogram itself is always a
  /// solid silhouette regardless of this flag.
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

  static const Offset _c = Offset(12, 12);

  @override
  void paint(Canvas canvas, Size size) {
    // Every path below is authored against a 24x24 box, then scaled to fit.
    final double scale = size.width / 24;
    canvas.save();
    canvas.scale(scale, scale);

    final Paint solid = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (filled ? strokeWidth * 0.85 : strokeWidth * 0.7) / scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case OriginGlyphType.sanctuary:
        _paintSanctuary(canvas, solid);
        break;
      case OriginGlyphType.wealth:
        _drawMedallion(canvas, ring);
        _paintWealth(canvas, solid);
        break;
      case OriginGlyphType.fitness:
        _drawMedallion(canvas, ring);
        _paintFitness(canvas, solid);
        break;
      case OriginGlyphType.cultivation:
        _drawMedallion(canvas, ring);
        _paintCultivation(canvas, solid);
        break;
      case OriginGlyphType.goals:
        _drawMedallion(canvas, ring);
        _paintGoals(canvas, solid);
        break;
      case OriginGlyphType.creator:
        _drawMedallion(canvas, ring);
        _paintCreator(canvas, solid);
        break;
      case OriginGlyphType.entertainment:
        _drawMedallion(canvas, ring);
        _paintEntertainment(canvas, solid);
        break;
      case OriginGlyphType.chronicle:
        _drawMedallion(canvas, ring);
        _paintChronicle(canvas, solid);
        break;
      case OriginGlyphType.settings:
        _paintSettings(canvas, solid, ring);
        break;
      case OriginGlyphType.quickAdd:
        _drawMedallion(canvas, ring);
        _paintQuickAdd(canvas, solid);
        break;
    }
    canvas.restore();
  }

  // A closed star polygon alternating between an outer spike radius and an
  // inner valley radius — used both for the Sanctuary sigil and as the
  // shared spiked-medallion ring frame around every other pictogram.
  static Path _spikeRing(Offset c, double outer, double inner, int spikes) {
    final Path path = Path();
    final int total = spikes * 2;
    for (int i = 0; i < total; i++) {
      final double angle = (math.pi / spikes) * i - math.pi / 2;
      final double r = i.isEven ? outer : inner;
      final Offset p = c + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  void _drawMedallion(Canvas canvas, Paint ring) {
    canvas.drawPath(_spikeRing(_c, 11.2, 9.5, 14), ring);
  }

  // The brand sigil — a spiked compass star with a center eye, standing on
  // its own (no separate medallion; the star's own spikes are the frame).
  void _paintSanctuary(Canvas canvas, Paint solid) {
    final Path star = _spikeRing(_c, 10, 3.8, 8);
    // Punch a small center eye out of the solid star so it doesn't read as
    // a plain blob at a glance.
    final Path withEye = Path.combine(
      PathOperation.difference,
      star,
      Path()..addOval(Rect.fromCircle(center: _c, radius: 1.8)),
    );
    canvas.drawPath(withEye, solid);
    canvas.drawCircle(_c, 0.75, solid);
  }

  // A temple facade — pediment, entablature, three columns, a stepped
  // plinth. Reads instantly as "treasury/wealth" the way a bank does.
  void _paintWealth(Canvas canvas, Paint solid) {
    final Path roof = Path()
      ..moveTo(6.3, 10)
      ..lineTo(12, 5.6)
      ..lineTo(17.7, 10)
      ..close();
    canvas.drawPath(roof, solid);

    canvas.drawRect(const Rect.fromLTWH(6.3, 10, 11.4, 1.3), solid);

    for (final double x in [7.9, 11.35, 14.8]) {
      canvas.drawRect(Rect.fromLTWH(x, 11.5, 1.5, 4.7), solid);
    }

    canvas.drawRect(const Rect.fromLTWH(6, 16.2, 12, 1.1), solid);
    canvas.drawRect(const Rect.fromLTWH(5.4, 17.3, 13.2, 1, ), solid);
  }

  // A dumbbell — two weight plates joined by a bar, unambiguous at small
  // sizes where the previous flexed-arm silhouette read as a blob.
  void _paintFitness(Canvas canvas, Paint solid) {
    final RRect leftPlate = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.6, 8.6, 3.2, 6.8),
      const Radius.circular(1.1),
    );
    final RRect rightPlate = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15.2, 8.6, 3.2, 6.8),
      const Radius.circular(1.1),
    );
    canvas.drawRRect(leftPlate, solid);
    canvas.drawRRect(rightPlate, solid);
    canvas.drawRect(const Rect.fromLTWH(6.6, 7, 1.2, 10), solid);
    canvas.drawRect(const Rect.fromLTWH(16.2, 7, 1.2, 10), solid);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8.8, 10.7, 6.4, 2.6), const Radius.circular(1)),
      solid,
    );
  }

  // A seated, robed figure in meditation — round head, small topknot, a
  // crossed-leg base. Reads as "cultivation/practice," not a chart icon.
  void _paintCultivation(Canvas canvas, Paint solid) {
    canvas.drawCircle(const Offset(12, 8.1), 1.9, solid);
    canvas.drawCircle(const Offset(12, 5.9), 0.7, solid);

    final Path robe = Path()
      ..moveTo(9.4, 11)
      ..cubicTo(9.4, 9.9, 14.6, 9.9, 14.6, 11)
      ..lineTo(16.6, 16.3)
      ..cubicTo(16.7, 17.4, 15, 17.8, 13.3, 17)
      ..cubicTo(12, 17.6, 12, 17.6, 10.7, 17)
      ..cubicTo(9, 17.8, 7.3, 17.4, 7.4, 16.3)
      ..close();
    canvas.drawPath(robe, solid);
  }

  // A twin-peak summit with a standard planted on the highest point.
  void _paintGoals(Canvas canvas, Paint solid) {
    final Path summit = Path()
      ..moveTo(5.3, 18.2)
      ..lineTo(9.8, 9.6)
      ..lineTo(12.4, 13.2)
      ..lineTo(15.4, 7.6)
      ..lineTo(18.7, 18.2)
      ..close();
    canvas.drawPath(summit, solid);

    canvas.drawRect(const Rect.fromLTWH(15.1, 3.4, 0.7, 4.6), solid);
    final Path pennant = Path()
      ..moveTo(15.8, 3.5)
      ..lineTo(19.6, 5.1)
      ..lineTo(15.8, 6.8)
      ..close();
    canvas.drawPath(pennant, solid);
  }

  // A camera — body, viewfinder hump, and a lens punched out as a ring +
  // center dot via a boolean cutout (not a stroke drawn over a fill).
  void _paintCreator(Canvas canvas, Paint solid) {
    final Path body = Path()
      ..addRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(6.3, 10, 11.4, 7.2),
        const Radius.circular(1.4),
      ));
    final Path viewfinder = Path()
      ..moveTo(9.4, 10)
      ..lineTo(9.7, 8)
      ..lineTo(13.3, 8)
      ..lineTo(13.6, 10)
      ..close();
    final Path camera = Path.combine(PathOperation.union, body, viewfinder);
    final Path lensHole = Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, 13.7), radius: 2.5));
    final Path cut = Path.combine(PathOperation.difference, camera, lensHole);
    canvas.drawPath(cut, solid);
    canvas.drawCircle(const Offset(12, 13.7), 0.9, solid);
  }

  // A popcorn bucket — striped body (via boolean-cut vertical gaps) with
  // three kernel bumps cresting the rim.
  void _paintEntertainment(Canvas canvas, Paint solid) {
    final Path bucket = Path()
      ..moveTo(8.3, 11)
      ..lineTo(15.7, 11)
      ..lineTo(14.6, 18.3)
      ..lineTo(9.4, 18.3)
      ..close();
    final Path stripes = Path.combine(
      PathOperation.union,
      Path()..addRect(const Rect.fromLTWH(10.5, 11, 1, 7.3)),
      Path()..addRect(const Rect.fromLTWH(13, 11, 1, 7.3)),
    );
    canvas.drawPath(Path.combine(PathOperation.difference, bucket, stripes), solid);

    canvas.drawCircle(const Offset(9.6, 9.9), 1.5, solid);
    canvas.drawCircle(const Offset(12, 8.6), 1.7, solid);
    canvas.drawCircle(const Offset(14.4, 9.9), 1.5, solid);
  }

  // A quill above an inkwell — the feather as a single tapered silhouette,
  // the well as a small squat pot with a rim.
  void _paintChronicle(Canvas canvas, Paint solid) {
    canvas.drawOval(const Rect.fromLTWH(8.1, 15.1, 4.6, 1.4), solid);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8.4, 15.9, 4, 2.3),
        const Radius.circular(0.6),
      ),
      solid,
    );

    final Path quill = Path()
      ..moveTo(17.6, 5.7)
      ..cubicTo(14, 9, 10.6, 13, 10.3, 16.4)
      ..lineTo(11.7, 15.1)
      ..cubicTo(12.6, 11.4, 15.6, 7.9, 18.1, 6)
      ..close();
    canvas.drawPath(quill, solid);
  }

  // An arcane gear — blocky rectangular teeth around a ring, a compass
  // tick at each cardinal point, reading as gear+compass together.
  void _paintSettings(Canvas canvas, Paint solid, Paint ring) {
    const double ringR = 6.4;
    const int teeth = 8;
    canvas.drawCircle(_c, ringR, ring);
    for (int i = 0; i < teeth; i++) {
      final double angle = (2 * math.pi / teeth) * i;
      canvas.save();
      canvas.translate(_c.dx, _c.dy);
      canvas.rotate(angle);
      canvas.drawRect(const Rect.fromLTWH(ringR - 0.5, -1.5, 2.6, 3), solid);
      canvas.restore();
    }
    canvas.drawCircle(_c, 2.4, solid);
    for (int i = 0; i < 4; i++) {
      final double angle = (math.pi / 2) * i - math.pi / 2;
      final Offset tickOuter = _c + Offset(math.cos(angle), math.sin(angle)) * (ringR - 1.4);
      final Offset tickInner = _c + Offset(math.cos(angle), math.sin(angle)) * (ringR - 3.2);
      canvas.drawLine(tickOuter, tickInner, ring);
    }
  }

  // A plus mark set inside the shared medallion — used for the branded
  // quick-add action.
  void _paintQuickAdd(Canvas canvas, Paint solid) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(11, 6.8, 2, 10.4), const Radius.circular(1)),
      solid,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(6.8, 11, 10.4, 2), const Radius.circular(1)),
      solid,
    );
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.filled != filled;
}
