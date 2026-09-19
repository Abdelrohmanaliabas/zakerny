import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'fatimid_decorations.dart';

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
              ? const [
                  Color(0xFF081310),
                  Color(0xFF0C1D18),
                  Color(0xFF102620),
                ]
              : const [
                  Color(0xFFFAF7F0),
                  Color(0xFFF5F0E5),
                  Color(0xFFEFE8D8),
                ],
        ),
      ),
      child: CustomPaint(
        painter: _FatimidLatticePainter(
          color: isDark ? FatimidColors.goldLight : FatimidColors.emeraldMedium,
          opacity: isDark ? 0.035 : 0.045,
          goldAccentColor: FatimidColors.goldPrimary,
          goldOpacity: isDark ? 0.025 : 0.035,
        ),
        child: child,
      ),
    );
  }
}

class _FatimidLatticePainter extends CustomPainter {
  _FatimidLatticePainter({
    required this.color,
    required this.opacity,
    required this.goldAccentColor,
    required this.goldOpacity,
  });

  final Color color;
  final double opacity;
  final Color goldAccentColor;
  final double goldOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final latticePaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final goldPaint = Paint()
      ..color = goldAccentColor.withValues(alpha: goldOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 64.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final center = Offset(x, y);

        // 1. Concentric decorative circles
        canvas.drawCircle(center, 22, latticePaint);

        // 2. Intersecting squares at 45 deg (forming the 8-point Fatimid star)
        _drawRotatedRect(canvas, center, 32, 32, 0, latticePaint);
        _drawRotatedRect(canvas, center, 32, 32, math.pi / 4, latticePaint);

        // 3. Central golden rosette core
        canvas.drawCircle(center, 6, goldPaint);

        // 4. Connecting diagonal interlaced lines
        canvas.drawLine(
          center + const Offset(-16, -16),
          center + const Offset(16, 16),
          latticePaint,
        );
        canvas.drawLine(
          center + const Offset(16, -16),
          center + const Offset(-16, 16),
          latticePaint,
        );
      }
    }
  }

  void _drawRotatedRect(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0) {
      canvas.rotate(angle);
    }
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FatimidLatticePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.goldAccentColor != goldAccentColor ||
        oldDelegate.goldOpacity != goldOpacity;
  }
}
