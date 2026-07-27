import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredFadeList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const StaggeredFadeList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 1,
    this.spacing = 12,
    this.runSpacing = 12,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount > 1) {
      return GridView.builder(
        padding: padding ?? const EdgeInsets.all(12),
        physics: physics,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: runSpacing,
          childAspectRatio: 0.75,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => itemBuilder(context, index)
            .animate()
            .fadeIn(
              duration: 350.ms,
              delay: (50 * index).ms,
              curve: Curves.easeOut,
            )
            .slideX(
              begin: 0.08,
              end: 0,
              duration: 350.ms,
              delay: (50 * index).ms,
              curve: Curves.easeOutCubic,
            ),
      );
    }

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(12),
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(context, index)
          .animate()
          .fadeIn(
            duration: 300.ms,
            delay: (40 * index).ms,
            curve: Curves.easeOut,
          )
          .slideX(
            begin: 0.05,
            end: 0,
            duration: 300.ms,
            delay: (40 * index).ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class FadeInContainer extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const FadeInContainer({super.key, required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: delayMs.ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 400.ms,
          delay: delayMs.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.black12,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: isDark ? Colors.white10 : Colors.black12,
        );
  }
}
