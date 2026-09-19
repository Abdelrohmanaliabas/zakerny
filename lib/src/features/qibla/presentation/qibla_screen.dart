import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _future = Future.value(widget.controller.savedLocationDirection());
  }

  void _useCurrentLocation() {
    setState(() {
      _future = widget.controller.currentLocationDirection();
    });
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
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return _QiblaError(
                      message: snapshot.error.toString(),
                      onRetry: _useCurrentLocation,
                    );
                  }
                  final direction = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // بوصلة الأسطرلاب الفاطمي
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
                          onPressed: _useCurrentLocation,
                          icon: const Icon(Icons.my_location_rounded, color: FatimidColors.goldLight),
                          label: const Text(
                            'تحديث الموقع الحالي للمعايرة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
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

/// بطاقة أسطرلاب القبلة الفاطمي المذهب (The Fatimid Astrolabe Card)
class _FatimidAstrolabeCard extends StatelessWidget {
  const _FatimidAstrolabeCard({required this.direction});

  final QiblaDirection direction;

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
          // Background rosette
          Positioned(
            child: FatimidRosette(
              size: 260,
              color: FatimidColors.goldPrimary,
              opacity: isDark ? 0.08 : 0.06,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            child: Column(
              children: [
                StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    final heading = snapshot.data?.heading;
                    final relativeBearing = heading == null
                        ? direction.bearing
                        : (direction.bearing - heading + 360) % 360;

                    return Column(
                      children: [
                        SizedBox.square(
                          dimension: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 1. الحلقة النحاسية الخارجية للأسطرلاب
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),

                              // 2. حلقة تدريج الدرجات الدائرية
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                              ),

                              // 3. اتجاهات البوصلة الأربعة الدوارة
                              Transform.rotate(
                                angle: -(heading ?? 0) * math.pi / 180,
                                child: const PositionedCompassLabels(),
                              ),

                              // 4. مؤشر الكعبة الفاطمي المذهب
                              Transform.rotate(
                                angle: relativeBearing * math.pi / 180,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.navigation_rounded,
                                        size: 78,
                                        color: FatimidColors.goldPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),

                              // 5. مركز الكعبة المشرفة الفاطمي
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  gradient: FatimidColors.goldGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF102820),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mosque,
                                      color: FatimidColors.goldLight,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            heading == null
                                ? 'حرك الهاتف لمعايرة البوصلة'
                                : 'اتجاه زاوية الهاتف: ${heading.round()}°',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  direction.bearingLabel,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: FatimidColors.goldPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'انحراف عن اتجاه الشمال الحقيقي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PositionedCompassLabels extends StatelessWidget {
  const PositionedCompassLabels({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'Cairo',
      color: FatimidColors.goldPrimary,
      fontWeight: FontWeight.w900,
      fontSize: 13,
    );

    return const SizedBox.square(
      dimension: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 2, child: Text('ش (N)', style: style)),
          Positioned(bottom: 2, child: Text('ج (S)', style: style)),
          Positioned(left: 2, child: Text('غ (W)', style: style)),
          Positioned(right: 2, child: Text('ق (E)', style: style)),
        ],
      ),
    );
  }
}

class _DirectionInfo extends StatelessWidget {
  const _DirectionInfo({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            leading: const Icon(Icons.place_rounded, color: FatimidColors.goldPrimary),
            title: const Text(
              'المدينة الحالية',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              direction.city,
              style: TextStyle(fontFamily: 'Cairo', color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F)),
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
              direction.distanceLabel,
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
              '${direction.latitude.toStringAsFixed(4)}° شمالاً، ${direction.longitude.toStringAsFixed(4)}° شرقاً',
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
