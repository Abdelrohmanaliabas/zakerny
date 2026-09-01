import 'package:flutter/material.dart';

class IslamicBackground extends StatelessWidget {
  const IslamicBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0D1714), Color(0xFF132620)]
              : const [Color(0xFFF9FBF8), Color(0xFFEFF8F4)],
        ),
      ),
      child: CustomPaint(
        painter: _PatternPainter(
          color: isDark ? Colors.white : const Color(0xFF2B5C4D),
          opacity: isDark ? 0.035 : 0.055,
        ),
        child: child,
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 48.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final center = Offset(x, y);
        canvas.drawCircle(center, 20, paint);
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 28, height: 28),
          paint,
        );
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(0.785398);
        canvas.translate(-x, -y);
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 28, height: 28),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}
