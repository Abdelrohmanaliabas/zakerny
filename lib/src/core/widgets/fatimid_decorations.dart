import 'dart:math' as math;
import 'package:flutter/material.dart';

/// الألوان الفاطمية التأسيسية
class FatimidColors {
  static const Color emeraldDark = Color(0xFF07382B);
  static const Color emeraldPrimary = Color(0xFF0A4D3C);
  static const Color emeraldMedium = Color(0xFF0E634E);
  static const Color emeraldLight = Color(0xFF147A60);
  static const Color emeraldGlow = Color(0xFF10B981);

  static const Color goldDark = Color(0xFF996515);
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldChampagne = Color(0xFFFAF0D7);

  static const Color parchmentLight = Color(0xFFFAF7F0);
  static const Color parchmentBorder = Color(0xFFEADBCE);

  static const Color obsidianDark = Color(0xFF091411);
  static const Color obsidianCard = Color(0xFF11231E);
  static const Color obsidianBorder = Color(0xFF1D3931);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFECC87A), Color(0xFFD4AF37), Color(0xFFBF953F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF0A4D3C), Color(0xFF0E634E), Color(0xFF07382B)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF132822), Color(0xFF0E1F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// كليبر العقد الفاطمي المنكسر (Fatimid Keel Arch Clipper)
/// يتميز برأس مدبب رشيق في الأعلى مع انحناءات انسيابية متقابلة كأقواس جامع الأزهر والأقمر
class FatimidKeelArchClipper extends CustomClipper<Path> {
  const FatimidKeelArchClipper({
    this.archHeightFraction = 0.22,
    this.archApexRise = 14.0,
    this.bottomCornerRadius = 20.0,
  });

  final double archHeightFraction;
  final double archApexRise;
  final double bottomCornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final archH = h * archHeightFraction;
    final r = bottomCornerRadius;

    // Start at top apex point (القمة المدببة للعقد الفاطمي)
    final midX = w / 2;
    path.moveTo(midX, 0);

    // Right curve of the keel arch: S-like curve out to right spring point
    path.cubicTo(
      midX + w * 0.22, archApexRise * 0.2,
      w * 0.82, archH * 0.45,
      w, archH,
    );

    // Right vertical wall
    path.lineTo(w, h - r);
    // Bottom-right corner
    path.quadraticBezierTo(w, h, w - r, h);
    // Bottom edge
    path.lineTo(r, h);
    // Bottom-left corner
    path.quadraticBezierTo(0, h, 0, h - r);
    // Left vertical wall up to left spring point
    path.lineTo(0, archH);

    // Left curve of the keel arch: back up to apex
    path.cubicTo(
      w * 0.18, archH * 0.45,
      midX - w * 0.22, archApexRise * 0.2,
      midX, 0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant FatimidKeelArchClipper oldClipper) =>
      oldClipper.archHeightFraction != archHeightFraction ||
      oldClipper.archApexRise != archApexRise ||
      oldClipper.bottomCornerRadius != bottomCornerRadius;
}

/// رسام الإطار الذهبي والفصوص للعقد الفاطمي
class FatimidKeelArchBorderPainter extends CustomPainter {
  FatimidKeelArchBorderPainter({
    this.color = FatimidColors.goldPrimary,
    this.strokeWidth = 1.6,
    this.archHeightFraction = 0.22,
    this.archApexRise = 14.0,
    this.bottomCornerRadius = 20.0,
  });

  final Color color;
  final double strokeWidth;
  final double archHeightFraction;
  final double archApexRise;
  final double bottomCornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = FatimidKeelArchClipper(
      archHeightFraction: archHeightFraction,
      archApexRise: archApexRise,
      bottomCornerRadius: bottomCornerRadius,
    );
    final path = clipper.getClip(size);

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);

    // Draw little gilded pearl at apex
    final apexPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 4), 3.0, apexPaint);
  }

  @override
  bool shouldRepaint(covariant FatimidKeelArchBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// الشميسة الفاطمية المشعة (Fatimid Fluted Rosette)
/// مستوحاة من طاقية المحاريب الفاطمية الشهيرة بـ 16 أو 24 تضليعاً مع قلب نجمي
class FatimidRosette extends StatelessWidget {
  const FatimidRosette({
    super.key,
    this.size = 120,
    this.color = FatimidColors.goldPrimary,
    this.opacity = 0.16,
    this.petalCount = 16,
    this.child,
  });

  final double size;
  final Color color;
  final double opacity;
  final int petalCount;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FatimidRosettePainter(
        color: color,
        opacity: opacity,
        petalCount: petalCount,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: child),
      ),
    );
  }
}

class _FatimidRosettePainter extends CustomPainter {
  _FatimidRosettePainter({
    required this.color,
    required this.opacity,
    required this.petalCount,
  });

  final Color color;
  final double opacity;
  final int petalCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rayPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final ringPaint = Paint()
      ..color = color.withValues(alpha: opacity * 1.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer and inner concentric rings
    canvas.drawCircle(center, radius * 0.95, ringPaint);
    canvas.drawCircle(center, radius * 0.65, ringPaint);
    canvas.drawCircle(center, radius * 0.35, ringPaint);

    // Radiating flutes (تضليعات الشميسة الفاطمية)
    final angleStep = (2 * math.pi) / petalCount;
    for (int i = 0; i < petalCount; i++) {
      final angle = i * angleStep;
      final p1 = center + Offset(math.cos(angle) * (radius * 0.35), math.sin(angle) * (radius * 0.35));
      final p2 = center + Offset(math.cos(angle) * (radius * 0.95), math.sin(angle) * (radius * 0.95));
      canvas.drawLine(p1, p2, rayPaint);

      // Fluted scalloped arc at the edge of each ray
      final nextAngle = (i + 1) * angleStep;
      final midAngle = angle + angleStep / 2;
      final cuspPoint = center + Offset(math.cos(midAngle) * (radius * 0.98), math.sin(midAngle) * (radius * 0.98));
      final endPoint = center + Offset(math.cos(nextAngle) * (radius * 0.95), math.sin(nextAngle) * (radius * 0.95));

      final scallopPath = Path()
        ..moveTo(p2.dx, p2.dy)
        ..quadraticBezierTo(cuspPoint.dx, cuspPoint.dy, endPoint.dx, endPoint.dy);
      canvas.drawPath(scallopPath, rayPaint);
    }

    // Inner 8-pointed star in the center medallion
    final starPaint = Paint()
      ..color = color.withValues(alpha: opacity * 1.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    _drawStar(canvas, center, radius * 0.28, radius * 0.16, 8, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double outerR, double innerR, int points, Paint paint) {
    final path = Path();
    final step = math.pi / points;
    for (int i = 0; i < 2 * points; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = i * step - math.pi / 2;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FatimidRosettePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.petalCount != petalCount;
}

/// شارة النجمة الإسلامية الثمانية (Fatimid 8-Point Star Badge)
/// تستخدم لأرقام السور والآيات والأجزاء مع إطار ذهبي وتأثير بارز
class FatimidStarBadge extends StatelessWidget {
  const FatimidStarBadge({
    super.key,
    required this.number,
    this.size = 42,
    this.isGold = true,
    this.label,
  });

  final int number;
  final double size;
  final bool isGold;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryGold = FatimidColors.goldPrimary;
    final borderColor = isGold
        ? primaryGold
        : (isDark ? const Color(0xFF326353) : const Color(0xFF789D90));

    final textColor = isGold
        ? (isDark ? FatimidColors.goldLight : const Color(0xFF63460A))
        : (isDark ? Colors.white : const Color(0xFF0F3A2E));

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _EightPointStarPainter(
              fillColor: isDark
                  ? const Color(0xFF132821)
                  : (isGold ? const Color(0xFFFFFDF5) : Colors.white),
              borderColor: borderColor,
              glow: isGold,
            ),
          ),
          Text(
            label ?? '$number',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: size * 0.38,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EightPointStarPainter extends CustomPainter {
  _EightPointStarPainter({
    required this.fillColor,
    required this.borderColor,
    this.glow = false,
  });

  final Color fillColor;
  final Color borderColor;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfSide = (size.width * 0.86) / 2;

    // Draw two intersecting rounded squares at 45 degrees
    final rect = Rect.fromCenter(center: center, width: halfSide * 2, height: halfSide * 2);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // First square
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Second square rotated 45 deg
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);
    canvas.restore();

    // Inner gold ring for extra luxury
    final innerRingPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, halfSide * 0.68, innerRingPaint);
  }

  @override
  bool shouldRepaint(covariant _EightPointStarPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor || oldDelegate.borderColor != borderColor;
}

/// بطاقة فاطمية ملكية مؤطرة بزخارف الأركان والتذهيب (FatimidCard)
class FatimidCard extends StatelessWidget {
  const FatimidCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isEmerald = false,
    this.showGoldBorder = true,
    this.elevation = 3,
    this.borderRadius = 20,
    this.decoration,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isEmerald;
  final bool showGoldBorder;
  final double elevation;
  final double borderRadius;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isEmerald
        ? FatimidColors.emeraldGradient
        : (isDark
            ? FatimidColors.darkCardGradient
            : const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFBF8F2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ));

    final borderColor = isEmerald
        ? FatimidColors.goldPrimary.withValues(alpha: 0.45)
        : (showGoldBorder
            ? FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28)
            : (isDark ? FatimidColors.obsidianBorder : FatimidColors.parchmentBorder));

    final content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: (decoration ?? BoxDecoration()).copyWith(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isEmerald
                ? FatimidColors.emeraldPrimary.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle corner arabesque accent
          Positioned(
            top: 2,
            right: 2,
            child: _CornerArabesque(
              color: isEmerald
                  ? FatimidColors.goldLight.withValues(alpha: 0.25)
                  : FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
            ),
          ),
          child,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// حلية ركنية منمنمة (Corner Arabesque Ornament)
class _CornerArabesque extends StatelessWidget {
  const _CornerArabesque({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _CornerPainter(color: color),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.4, 0)
      ..quadraticBezierTo(size.width * 0.2, 0, size.width * 0.2, size.height * 0.2)
      ..lineTo(0, size.height * 0.2)
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.4)
      ..quadraticBezierTo(size.width, size.height * 0.6, size.width * 0.8, size.height * 0.6)
      ..lineTo(size.width * 0.8, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => oldDelegate.color != color;
}
