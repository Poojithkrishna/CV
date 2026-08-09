import 'package:flutter/material.dart';

import '../../app/theme/app_gradients.dart';

/// The Demon Origin emblem (the same skull/spike mark used for the Android
/// launcher icon) rendered as an in-app widget, for places the brand should
/// show up beyond just the home screen icon: the dashboard app bar, the
/// Settings About tile, and the ambient background watermark.
///
/// The source art (`assets/brand/emblem.png`) is a plain white/gray
/// silhouette, so it can be tinted to fit wherever it's used.
class AppIconMark extends StatelessWidget {
  const AppIconMark({
    super.key,
    this.size = 28,
    this.gradient = true,
    this.opacity = 1,
  });

  final double size;

  /// When true, the emblem is tinted with the brand crimson-to-violet
  /// gradient (matching [BrandWordmark]); otherwise it's plain white,
  /// for use on top of an already-colored surface.
  final bool gradient;

  final double opacity;

  static const String assetPath = 'assets/brand/emblem.png';

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      color: gradient ? null : Colors.white,
      colorBlendMode: gradient ? null : BlendMode.srcIn,
    );

    final Widget mark = gradient
        ? ShaderMask(
            shaderCallback: (bounds) => AppGradients.brand.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: image,
          )
        : image;

    return opacity == 1 ? mark : Opacity(opacity: opacity, child: mark);
  }
}
