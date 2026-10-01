import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/qibla_controller.dart';
import '../domain/qibla_direction.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key, required this.controller});

  final QiblaController controller;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late Future<QiblaDirection> _future;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _future = _resolveDirection();
  }

  Future<QiblaDirection> _resolveDirection() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        return await widget.controller.currentLocationDirection();
      }
    } catch (_) {}
    return widget.controller.savedLocationDirection();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _future = widget.controller.currentLocationDirection();
    });
    try {
      await _future;
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const ZekrniHeader(
              title: 'اتجاه القبلة',
              subtitle: 'تحديد دقيق لاتجاه الكعبة المشرفة وفق الأسطرلاب الفاطمي',
            ),
            Expanded(
              child: FutureBuilder<QiblaDirection>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done && !_isLocating) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return _QiblaError(
                      message: snapshot.error.toString(),
                      onRetry: _useCurrentLocation,
                    );
                  }
                  final direction = snapshot.data ?? widget.controller.savedLocationDirection();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // بوصلة الأسطرلاب الفاطمي المطورة
                      _FatimidAstrolabeCard(direction: direction),
                      const SizedBox(height: 16),
                      _DirectionInfo(direction: direction),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: FatimidColors.emeraldGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: FatimidColors.emeraldPrimary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: FatimidColors.goldPrimary.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                          ),
                          onPressed: _isLocating ? null : _useCurrentLocation,
                          icon: _isLocating
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(FatimidColors.goldLight),
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded, color: FatimidColors.goldLight),
                          label: Text(
                            _isLocating ? 'جارٍ تحديد موقعك بدقة...' : 'تحديث الموقع الحالي للمعايرة',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة أسطرلاب القبلة الفاطمي المذهب ومعايرة البوصلة
class _FatimidAstrolabeCard extends StatefulWidget {
  const _FatimidAstrolabeCard({required this.direction});

  final QiblaDirection direction;

  @override
  State<_FatimidAstrolabeCard> createState() => _FatimidAstrolabeCardState();
}

class _FatimidAstrolabeCardState extends State<_FatimidAstrolabeCard> {
  bool _wasAligned = false;

  void _checkHaptic(bool isAligned) {
    if (isAligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
      _wasAligned = true;
    } else if (!isAligned) {
      _wasAligned = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: FatimidRosette(
              size: 280,
              color: FatimidColors.goldPrimary,
              opacity: isDark ? 0.07 : 0.05,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            child: StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final heading = snapshot.data?.heading;
                // Kaaba bearing relative to phone top
                final relativeBearing = heading == null
                    ? widget.direction.bearing
                    : (widget.direction.bearing - heading + 360) % 360;

                final diffFromTarget = (relativeBearing > 180)
                    ? 360 - relativeBearing
                    : relativeBearing;

                // Aligned when within 4.5 degrees
                final isAligned = heading != null && diffFromTarget <= 4.5;
                _checkHaptic(isAligned);

                final targetBearingAr = ArabicTextUtils.toArabicDigits(
                  widget.direction.bearing.round(),
                );
                final headingAr = heading == null
                    ? null
                    : ArabicTextUtils.toArabicDigits(heading.round());

                return Column(
                  children: [
                    // Dial & Needle Stack
                    SizedBox.square(
                      dimension: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Astrolabe Dial (rotates with phone heading)
                          Transform.rotate(
                            angle: -(heading ?? 0) * math.pi / 180,
                            child: CustomPaint(
                              size: const Size(260, 260),
                              painter: _AstrolabeDialPainter(
                                isDark: isDark,
                                isAligned: isAligned,
                                qiblaBearingDeg: widget.direction.bearing,
                              ),
                            ),
                          ),

                          // 2. Clear prominent Qibla Needle (points to Kaaba relative to phone)
                          Transform.rotate(
                            angle: relativeBearing * math.pi / 180,
                            child: _QiblaNeedleWidget(isAligned: isAligned),
                          ),

                          // 3. Center Medallion (compact, pivot point)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isAligned
                                  ? FatimidColors.emeraldGradient
                                  : FatimidColors.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: isAligned
                                      ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                      : FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isAligned ? const Color(0xFF042F2C) : const Color(0xFF102820),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAligned ? Icons.check_circle_rounded : Icons.mosque,
                                  color: isAligned ? const Color(0xFF34D399) : FatimidColors.goldLight,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guidance and Alignment Status Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : (isDark
                                ? FatimidColors.goldPrimary.withValues(alpha: 0.12)
                                : FatimidColors.goldPrimary.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAligned
                              ? const Color(0xFF10B981).withValues(alpha: 0.6)
                              : FatimidColors.goldPrimary.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAligned ? Icons.verified_rounded : Icons.explore_rounded,
                            size: 18,
                            color: isAligned ? const Color(0xFF10B981) : FatimidColors.goldPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAligned
                                ? 'أنت الآن في اتجاه القبلة الشريفة مباشرة'
                                : heading == null
                                    ? 'حرك هاتفك لمعايرة حساس البوصلة'
                                    : (relativeBearing <= 180
                                        ? 'أدِر الهاتف ${ArabicTextUtils.toArabicDigits(relativeBearing.round())}° لليمين ⟳'
                                        : 'أدِر الهاتف ${ArabicTextUtils.toArabicDigits((360 - relativeBearing).round())}° لليسار ⟲'),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isAligned
                                  ? const Color(0xFF10B981)
                                  : (isDark ? const Color(0xFFDCEFE6) : const Color(0xFF1E3A2F)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Angle summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$targetBearingAr°',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: isAligned ? const Color(0xFF10B981) : FatimidColors.goldPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'زاوية انحراف القبلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F),
                          ),
                        ),
                        if (headingAr != null) ...[
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الهاتف: $headingAr°',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The custom Needle widget extending out to the rim
class _QiblaNeedleWidget extends StatelessWidget {
  const _QiblaNeedleWidget({required this.isAligned});

  final bool isAligned;

  @override
  Widget build(BuildContext context) {
    final activeColor = isAligned ? const Color(0xFF10B981) : FatimidColors.goldPrimary;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Upper pointer stem and Kaaba head
          Positioned(
            top: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Kaaba emblem & arrowhead
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.navigation_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                // Arrow stem leading down to center
                Container(
                  width: 3.5,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        activeColor,
                        activeColor.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // Bottom counter-fin
          Positioned(
            bottom: 24,
            child: Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the Astrolabe dial markings & cardinal directions
class _AstrolabeDialPainter extends CustomPainter {
  _AstrolabeDialPainter({
    required this.isDark,
    required this.isAligned,
    required this.qiblaBearingDeg,
  });

  final bool isDark;
  final bool isAligned;
  final double qiblaBearingDeg;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerRingPaint = Paint()
      ..color = (isAligned ? const Color(0xFF10B981) : FatimidColors.goldPrimary).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final innerRingPaint = Paint()
      ..color = FatimidColors.goldPrimary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 4, outerRingPaint);
    canvas.drawCircle(center, radius - 26, innerRingPaint);

    final tickPaint = Paint()
      ..color = FatimidColors.goldPrimary.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = FatimidColors.goldPrimary.withValues(alpha: 0.6)
      ..strokeWidth = 1.6;

    // Draw degree tick marks around the rim
    for (int deg = 0; deg < 360; deg += 6) {
      final isMajor = deg % 30 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      final rad = deg * math.pi / 180;

      final startX = center.dx + (radius - 6) * math.sin(rad);
      final startY = center.dy - (radius - 6) * math.cos(rad);
      final endX = center.dx + (radius - 6 - tickLength) * math.sin(rad);
      final endY = center.dy - (radius - 6 - tickLength) * math.cos(rad);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    // Draw Cardinal Labels: North(0°), East(90°), South(180°), West(270°)
    _drawLabel(canvas, center, radius - 38, 0, 'ش');
    _drawLabel(canvas, center, radius - 38, 90, 'ق');
    _drawLabel(canvas, center, radius - 38, 180, 'ج');
    _drawLabel(canvas, center, radius - 38, 270, 'غ');
  }

  void _drawLabel(Canvas canvas, Offset center, double dist, double angleDeg, String text) {
    final rad = angleDeg * math.pi / 180;
    final x = center.dx + dist * math.sin(rad);
    final y = center.dy - dist * math.cos(rad);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: angleDeg == 0
            ? const Color(0xFFEF4444) // North marked in warm red
            : FatimidColors.goldPrimary,
      ),
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    )..layout();

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _AstrolabeDialPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.isAligned != isAligned ||
        oldDelegate.qiblaBearingDeg != qiblaBearingDeg;
  }
}

class _DirectionInfo extends StatelessWidget {
  const _DirectionInfo({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final latAr = ArabicTextUtils.toArabicDigits(direction.latitude.toStringAsFixed(4));
    final lonAr = ArabicTextUtils.toArabicDigits(direction.longitude.toStringAsFixed(4));
    final distanceAr = ArabicTextUtils.toArabicDigits(direction.distanceKm.round());

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.18),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.location_city_rounded, color: FatimidColors.goldPrimary),
            title: const Text(
              'المدينة الحالية',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              direction.city,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF335C4D),
              ),
            ),
          ),
          Divider(height: 1, color: FatimidColors.goldPrimary.withValues(alpha: 0.15)),
          ListTile(
            leading: const Icon(Icons.straighten_rounded, color: FatimidColors.goldPrimary),
            title: const Text(
              'المسافة إلى الكعبة المشرفة',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '$distanceAr كم تقريباً',
              style: TextStyle(fontFamily: 'Cairo', color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F)),
            ),
          ),
          Divider(height: 1, color: FatimidColors.goldPrimary.withValues(alpha: 0.15)),
          ListTile(
            leading: const Icon(Icons.explore_outlined, color: FatimidColors.goldPrimary),
            title: const Text(
              'الإحداثيات الجغرافية',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '$latAr° شمالاً، $lonAr° شرقاً',
              style: TextStyle(fontFamily: 'Cairo', color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaError extends StatelessWidget {
  const _QiblaError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ErrorStateView(message: message),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
