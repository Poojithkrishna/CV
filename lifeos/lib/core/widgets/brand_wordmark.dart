import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_theme.dart';
import 'app_icon_mark.dart';

/// The "DEMON ORIGIN" brand lockup — angular display type in the brand's
/// crimson-to-violet gradient, with a faint ambient glow behind it. This is
/// the one piece of text in the app that's allowed to look decorative
/// rather than purely functional; used sparingly (dashboard app bar,
/// Settings' About tile, rank-up celebrations), never for body/list text.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.fontSize = 20,
    this.glow = true,
  });

  final double fontSize;

  /// Whether to draw the soft violet glow behind the wordmark. Turn off
  /// when it's already sitting on a colored/gradient surface where an
  /// extra glow would just muddy the background.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontFamily: AppTheme.displayFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      height: 1,
    );

    final Widget text = ShaderMask(
      shaderCallback: (bounds) => AppGradients.brand.createShader(bounds),
      child: Text('DEMON ORIGIN', style: style.copyWith(color: Colors.white)),
    );

    if (!glow) return text;

    return Stack(
      alignment: Alignment.center,
      children: [
        // A blurred copy of the same text behind the crisp one fakes a
        // glow without needing an image asset.
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Text(
            'DEMON ORIGIN',
            style: style.copyWith(
              color: AppColors.brandMid.withOpacity(0.65),
            ),
          ),
        ),
        text,
      ],
    );
  }
}

/// The full brand lockup — emblem + wordmark side by side — for the handful
/// of spots where the app icon itself should show up inside the app, not
/// just on the home screen (the dashboard app bar, Settings' About tile).
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.fontSize = 18, this.iconSize = 22});

  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconMark(size: iconSize),
        const SizedBox(width: 8),
        BrandWordmark(fontSize: fontSize),
      ],
    );
  }
}
