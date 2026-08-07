import 'package:flutter/material.dart';

import '../../app/theme/app_gradients.dart';

/// Lets the user pick one of the app's preset gradients as an entity's
/// (account, category, workout plan, ...) color theme. Stores just the
/// ARGB value of the gradient's first stop, since that's all the domain
/// layer needs to reconstruct a solid accent color.
class ColorThemePicker extends StatelessWidget {
  const ColorThemePicker({
    super.key,
    required this.selectedColorValue,
    required this.onChanged,
  });

  final int selectedColorValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppGradients.palette.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final LinearGradient gradient = AppGradients.palette[index];
          final Color swatchColor = gradient.colors.first;
          final bool isSelected = swatchColor.value == selectedColorValue;

          return GestureDetector(
            onTap: () => onChanged(swatchColor.value),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
