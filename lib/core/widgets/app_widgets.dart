import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';

export 'shimmer_loading.dart';

enum VNAButtonVariant { primary, secondary, text }

class VNAButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final double? width;
  final VNAButtonVariant variant;

  const VNAButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.variant = VNAButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == VNAButtonVariant.primary ? Colors.white : AppColors.primary,
        ),
      );
    } else {
      Widget row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.sm)],
          Text(label, style: AppTypography.labelLg),
          if (trailingIcon != null) ...[const SizedBox(width: AppSpacing.sm), Icon(trailingIcon, size: 20)],
        ],
      );
      child = row;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: switch (variant) {
        VNAButtonVariant.primary => _GradientButton(
          onPressed: onPressed,
          child: child,
        ),
        VNAButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: AppRadius.mdShape,
            side: BorderSide(color: isDark ? AppColors.darkOutline : AppColors.outline, width: 1),
            foregroundColor: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: child,
        ),
        VNAButtonVariant.text => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: AppRadius.mdShape,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: child,
        ),
      },
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _GradientButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: disabled ? AppColors.outline.withValues(alpha: 0.3) : null,
        boxShadow: disabled ? null : AppElevation.level1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.mdBorder,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class VNAOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const VNAOutlinedButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return VNAButton(label: label, onPressed: onPressed, icon: icon, variant: VNAButtonVariant.secondary);
  }
}

class VNAIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const VNAIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = IconButton(
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

class VNALoadingOverlay extends StatelessWidget {
  final String message;

  const VNALoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            boxShadow: AppElevation.level5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text(message, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class VNAEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const VNAEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.xlBorder,
              ),
              child: Icon(icon, size: 48, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Text(description,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              VNAButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class VNAErrorState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const VNAErrorState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.3),
                borderRadius: AppRadius.xlBorder,
              ),
              child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(message,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              VNAButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class VNACard extends StatelessWidget {
  final Widget? thumbnail;
  final String title;
  final String? subtitle;
  final List<String>? tags;
  final VoidCallback? onTap;
  final bool isAi;

  const VNACard({
    super.key,
    this.thumbnail,
    required this.title,
    this.subtitle,
    this.tags,
    this.onTap,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgBorder,
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surface,
        boxShadow: AppElevation.level1,
        border: isAi
            ? Border.all(width: 1.5, color: Colors.transparent)
            : null,
      ),
      foregroundDecoration: isAi
          ? ShapeDecoration(
              shape: AppRadius.lgShape,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnail != null)
              AspectRatio(aspectRatio: 16 / 9, child: thumbnail!),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle!, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: tags!.map((t) => VNATagChip(label: t)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VNASearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const VNASearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.mdBorder,
        boxShadow: AppElevation.level3,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyMd,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        ),
      ),
    );
  }
}

class VNATagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;

  const VNATagChip({super.key, required this.label, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2D3E) : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.labelMd.copyWith(color: isDark ? AppColors.darkOnSurface : AppColors.onSurfaceVariant)),
          if (onDelete != null) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 14, color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class VNAGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double height;

  const VNAGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(title, style: AppTypography.headlineMd.copyWith(color: Colors.white)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: AppTypography.bodyMd.copyWith(color: Colors.white70)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VNAAICard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;

  const VNAAICard({super.key, required this.title, required this.content, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgBorder,
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surface,
        boxShadow: AppElevation.level1,
        border: Border.all(
          width: 1.5,
          color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: AppSpacing.sm)],
              Text(title, style: AppTypography.labelLg.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkOnSurface : AppColors.onSurface)),
        ],
      ),
    );
  }
}
