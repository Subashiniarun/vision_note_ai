import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';

class PremiumSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final IconData? icon;

  const PremiumSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
            const Spacer(),
            Text('${(value * 100).toInt()}', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 12,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.outlineVariant.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
