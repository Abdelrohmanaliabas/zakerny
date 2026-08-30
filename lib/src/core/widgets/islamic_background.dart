import 'package:flutter/material.dart';

class IslamicBackground extends StatelessWidget {
  const IslamicBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PatternPainter(Theme.of(context).colorScheme.primary),
      child: child,
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 64.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: 34,
          height: 34,
        );
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(0.785398);
        canvas.translate(-x, -y);
        canvas.drawRect(rect, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
