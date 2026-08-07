import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_gradients.dart';

/// A frosted "glassmorphism" container: blurred, semi-transparent, with a
/// subtle border. Used for dashboard tiles and overlays sitting on top of
/// gradient backgrounds.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: AppGradients.glass(brightness),
                borderRadius: radius,
                border: Border.all(
                  color: brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(0.6),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
