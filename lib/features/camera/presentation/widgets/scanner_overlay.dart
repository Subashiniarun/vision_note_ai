import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isScanning;

  ScannerOverlayPainter({required this.animation, this.isScanning = true}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3 * animation.value)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Document bounds
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    const cornerLength = 40.0;

    void drawCorner(Offset p1, Offset p2, Offset p3) {
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);
      
      if (isScanning) canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Top left
    drawCorner(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
    );

    // Top right
    drawCorner(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
    );

    // Bottom right
    drawCorner(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLength, rect.bottom),
    );

    // Bottom left
    drawCorner(
      Offset(rect.left + cornerLength, rect.bottom),
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLength),
    );

    // Scanning line
    if (isScanning) {
      final lineY = rect.top + (rect.height * animation.value);
      final linePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.5)
        ..strokeWidth = 2.0;
      canvas.drawLine(
        Offset(rect.left + 10, lineY),
        Offset(rect.right - 10, lineY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) => true;
}

class AnimatedScannerOverlay extends StatefulWidget {
  const AnimatedScannerOverlay({super.key});

  @override
  State<AnimatedScannerOverlay> createState() => _AnimatedScannerOverlayState();
}

class _AnimatedScannerOverlayState extends State<AnimatedScannerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScannerOverlayPainter(animation: _animation),
      size: Size.infinite,
    );
  }
}
