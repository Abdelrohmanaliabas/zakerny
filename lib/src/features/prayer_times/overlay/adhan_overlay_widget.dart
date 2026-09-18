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
        enableDrag: false,
        overlayTitle: 'أذان صلاة $prayerName',
        overlayContent: 'حان الآن موعد أذان $prayerName بتوقيت $city',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: WindowSize.matchParent,
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
        enableDrag: false,
        overlayTitle: title,
        overlayContent: text,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: WindowSize.matchParent,
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
        child: Stack(
          children: [
            // Tap outside backdrop to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => AdhanOverlayManager.closeOverlay(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _type == 'dhikr'
                        ? _buildDhikrOverlayContent()
                        : _buildAdhanOverlayContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrOverlayContent() {
    return GestureDetector(
      onTap: () {}, // Prevent tap inside card from dismissing
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xF8062822),
              Color(0xF80A3831),
              Color(0xF8041C18),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF34D399),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _dhikrTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 18,
                  ),
                  tooltip: 'إغلاق',
                  onPressed: () => AdhanOverlayManager.closeOverlay(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dhikr Text Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  height: 1.5,
                ),
              ),
            ),

            if (_dhikrVirtue.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _dhikrVirtue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF9AE6B4).withValues(alpha: 0.9),
                  fontSize: 11,
                  fontFamily: 'Cairo',
                  height: 1.3,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Actions
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () => AdhanOverlayManager.closeOverlay(),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text(
                'تم الذكر • إغلاق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhanOverlayContent() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(18),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Color(0xFF34D399),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'تطبيق ذكرني • موعد الأذان',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF9AE6B4),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                  tooltip: 'إغلاق الشاشة',
                  onPressed: () => AdhanOverlayManager.closeOverlay(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Pulsing Center Icon
            Center(
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                    size: 42,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Title
            const Text(
              'الله أكبر • الله أكبر',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 4),

            // Prayer Name
            Text(
              'حان الآن موعد أذان $_prayerName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),

            if (_time.isNotEmpty || _city.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                '$_time ${_city.isNotEmpty ? "• حسب توقيت $_city" : ""}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Subtle Hadith / Dua Card
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: const Text(
                '«حي على الصلاة • حي على الفلاح»\n«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ القَائِمَةِ...»',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 11.5,
                  fontFamily: 'Amiri',
                  height: 1.35,
                ),
              ),
            ),

            const SizedBox(height: 14),

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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => AdhanOverlayManager.closeOverlay(),
                    icon: const Icon(Icons.volume_off, size: 16),
                    label: const Text(
                      'كتم / إغلاق',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text(
                      'تطبيق ذكرني',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
