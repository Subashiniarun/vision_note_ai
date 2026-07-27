import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';

class VNAFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const VNAFAB({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        elevation: 0,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppElevation.level5,
            ),
            child: const Center(
              child: Icon(Icons.document_scanner, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
