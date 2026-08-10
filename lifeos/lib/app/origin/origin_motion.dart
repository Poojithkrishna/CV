import 'package:flutter/material.dart';

/// Motion constants (spec §10) — restrained on purpose. No bouncy/elastic
/// curves anywhere; `Curves.easeOutCubic` reads as precise rather than
/// playful, which is the point.
class OriginMotion {
  OriginMotion._();

  static const Duration transition = Duration(milliseconds: 220);
  static const Duration pressResponse = Duration(milliseconds: 150);
  static const Duration chartReveal = Duration(milliseconds: 600);

  /// The one ceremonial exception — a rank-up or achievement pulse.
  static const Duration ceremonial = Duration(milliseconds: 550);

  static const Curve curve = Curves.easeOutCubic;
}
