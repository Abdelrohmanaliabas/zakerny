import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class AdhanOverlayManager {
  static Future<bool> isPermissionGranted() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (_) {
      return false;
    }
  }

  static Future<bool?> requestPermission() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      return await FlutterOverlayWindow.requestPermission();
    } catch (_) {
      return false;
    }
  }

  static Future<void> showAdhanOverlay({
    required String prayerName,
    required String time,
    String city = 'مدينتك',
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final granted = await isPermissionGranted();
      if (!granted) return;

      final isOpen = await FlutterOverlayWindow.isActive();
      if (isOpen) {
        await FlutterOverlayWindow.closeOverlay();
      }

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'أذان صلاة $prayerName',
        overlayContent: 'حان الآن موعد أذان $prayerName بتوقيت $city',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: 520,
        width: WindowSize.matchParent,
      );

      final data = jsonEncode({
        'type': 'adhan',
        'prayerName': prayerName,
        'time': time,
        'city': city,
      });
      await FlutterOverlayWindow.shareData(data);
    } catch (_) {}
  }

  static Future<void> showDhikrOverlay({
    required String title,
    required String text,
    String? virtue,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final granted = await isPermissionGranted();
      if (!granted) return;

      final isOpen = await FlutterOverlayWindow.isActive();
      if (isOpen) {
        await FlutterOverlayWindow.closeOverlay();
      }

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: title,
        overlayContent: text,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: 390,
        width: WindowSize.matchParent,
      );

      final data = jsonEncode({
        'type': 'dhikr',
        'title': title,
        'text': text,
        'virtue': virtue ?? '',
      });
      await FlutterOverlayWindow.shareData(data);
    } catch (_) {}
  }

  static Future<void> closeOverlay() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await FlutterOverlayWindow.closeOverlay();
    } catch (_) {}
  }
}

class AdhanOverlayWidget extends StatefulWidget {
  const AdhanOverlayWidget({super.key});

  @override
  State<AdhanOverlayWidget> createState() => _AdhanOverlayWidgetState();
}

class _AdhanOverlayWidgetState extends State<AdhanOverlayWidget>
    with SingleTickerProviderStateMixin {
  String _type = 'adhan';
  String _prayerName = 'الصلاة';
  String _time = '';
  String _city = 'مدينتك';

  String _dhikrTitle = 'تذكير بذكر الله';
  String _dhikrText = 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ';
  String _dhikrVirtue = '«مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللهُ عَلَيْهِ بِهَا عَشْرًا»';

  Timer? _autoCloseTimer;
  StreamSubscription? _listenerSubscription;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _listenerSubscription = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null && mounted) {
        _parseData(event);
      }
    });

    _resetTimer(const Duration(minutes: 3));
  }

  void _resetTimer(Duration duration) {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(duration, () {
      AdhanOverlayManager.closeOverlay();
    });
  }

  void _parseData(dynamic data) {
    try {
      Map<String, dynamic> map;
      if (data is String) {
        map = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map) {
        map = Map<String, dynamic>.from(data);
      } else {
        return;
      }
      setState(() {
        if (map['type'] != null) {
          _type = map['type'].toString();
        }
        if (_type == 'dhikr') {
          if (map['title'] != null) _dhikrTitle = map['title'].toString();
          if (map['text'] != null) _dhikrText = map['text'].toString();
          if (map['virtue'] != null) _dhikrVirtue = map['virtue'].toString();
          _resetTimer(const Duration(seconds: 14));
        } else {
          if (map['prayerName'] != null) {
            _prayerName = map['prayerName'].toString();
          }
          if (map['time'] != null) {
            _time = map['time'].toString();
          }
          if (map['city'] != null) {
            _city = map['city'].toString();
          }
          _resetTimer(const Duration(minutes: 3));
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _listenerSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: _type == 'dhikr'
              ? _buildDhikrOverlayContent()
              : _buildAdhanOverlayContent(),
        ),
      ),
    );
  }

  Widget _buildDhikrOverlayContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xF5062822),
            Color(0xF50A3831),
            Color(0xF5041C18),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.35),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF34D399),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dhikrTitle,
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 20,
                ),
                tooltip: 'إغلاق',
                onPressed: () => AdhanOverlayManager.closeOverlay(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dhikr Text Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              _dhikrText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                height: 1.6,
              ),
            ),
          ),

          if (_dhikrVirtue.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _dhikrVirtue,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF9AE6B4).withValues(alpha: 0.9),
                fontSize: 11.5,
                fontFamily: 'Cairo',
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => AdhanOverlayManager.closeOverlay(),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'تم الذكر • إغلاق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanOverlayContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: emotionsGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mosque,
                      color: Color(0xFF34D399),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'تطبيق ذكرني • موعد الأذان',
                    style: TextStyle(
                      color: Color(0xFF9AE6B4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 22,
                ),
                tooltip: 'إغلاق الشاشة',
                onPressed: () => AdhanOverlayManager.closeOverlay(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pulsing Center Icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.35),
                    const Color(0xFF0F766E).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFFBBF24),
                size: 52,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Title
          const Text(
            'الله أكبر • الله أكبر',
            style: TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          // Prayer Name
          Text(
            'حان الآن موعد أذان $_prayerName',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),

          if (_time.isNotEmpty || _city.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '$_time ${_city.isNotEmpty ? "• حسب توقيت $_city" : ""}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Subtle Hadith / Dua Card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: const Text(
              '«حي على الصلاة • حي على الفلاح»\n«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ القَائِمَةِ...»',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                fontFamily: 'Amiri',
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => AdhanOverlayManager.closeOverlay(),
                  icon: const Icon(Icons.volume_off, size: 18),
                  label: const Text(
                    'كتم / إغلاق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => AdhanOverlayManager.closeOverlay(),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(
                    'تطبيق ذكرني',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const LinearGradient emotionsGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xF0062822),
      Color(0xF00A3831),
      Color(0xF0041C18),
    ],
  );
}
