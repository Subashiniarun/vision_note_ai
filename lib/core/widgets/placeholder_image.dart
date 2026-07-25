import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;

  const PlaceholderImage({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
