import 'package:flutter/material.dart';

/// Corner treatment for panels — the spec explicitly moves away from the
/// 20–28dp "pill-like" cards toward 12–16dp panels, with an occasional
/// clipped corner for hero/ceremonial surfaces (spec §8).
class OriginShapes {
  OriginShapes._();

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 16;

  static RoundedRectangleBorder panel({double radius = radiusMd, BorderSide? side}) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: side ?? BorderSide.none,
      );

  /// A single clipped (chamfered) corner — top-right by default — for the
  /// rare hero surface that should read as an architectural plate rather
  /// than a rounded card. Used sparingly (spec: "occasional").
  static OutlinedBorder clippedCorner({
    double radius = radiusMd,
    double clip = 18,
  }) =>
      _ClippedCornerBorder(radius: radius, clip: clip);
}

class _ClippedCornerBorder extends OutlinedBorder {
  const _ClippedCornerBorder({required this.radius, required this.clip, super.side});

  final double radius;
  final double clip;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path()
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - clip, rect.top)
      ..lineTo(rect.right, rect.top + clip)
      ..lineTo(rect.right, rect.bottom - radius)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - radius, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - radius)
      ..lineTo(rect.left, rect.top + radius)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + radius, rect.top)
      ..close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(
      getOuterPath(rect, textDirection: textDirection),
      side.toPaint(),
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _ClippedCornerBorder(radius: radius, clip: clip, side: side ?? this.side);

  @override
  ShapeBorder scale(double t) => _ClippedCornerBorder(radius: radius * t, clip: clip * t);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);
}
