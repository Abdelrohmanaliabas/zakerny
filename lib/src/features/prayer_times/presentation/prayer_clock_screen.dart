import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../application/prayer_controller.dart';
import '../domain/prayer_day.dart';

/// Screen replicating the classic Golden Islamic Azan Wall/Desk Clock
/// (ساعة المسجد / ساعة الفجر والحرمين الرقمية)
class PrayerClockScreen extends StatefulWidget {
  const PrayerClockScreen({super.key, required this.controller});

  final PrayerController controller;

  @override
  State<PrayerClockScreen> createState() => _PrayerClockScreenState();
}

class _PrayerClockScreenState extends State<PrayerClockScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _isCelsius = true;
  bool _showHijriDate = true;
  bool _blinkColon = true;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          _blinkColon = !_blinkColon;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.controller.loadPreferences();
    final day = widget.controller.today(prefs);
    final tomorrow = widget.controller.tomorrow(prefs);
    final next = day.nextPrayer(_now, tomorrow: tomorrow);
    final hijri = HijriCalendar.fromDate(_now);

    final hours = DateFormat('hh', 'en').format(_now);
    final minutes = DateFormat('mm', 'en').format(_now);
    final seconds = DateFormat('ss', 'en').format(_now);
    final amPm = DateFormat('a', 'en').format(_now).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF070A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F141C),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_alarm_rounded, color: Color(0xFFD4AF37), size: 20),
            SizedBox(width: 8),
            Text(
              'ساعة الحرمين الرقمية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFE2C068),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تبديل التاريخ',
            icon: Icon(
              _showHijriDate ? Icons.calendar_month_rounded : Icons.today_rounded,
              color: const Color(0xFFD4AF37),
            ),
            onPressed: () {
              setState(() {
                _showHijriDate = !_showHijriDate;
              });
            },
          ),
          IconButton(
            tooltip: 'تبديل وحدة الحرارة',
            icon: const Icon(Icons.thermostat_rounded, color: Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                _isCelsius = !_isCelsius;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0F15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. القبة الفاطمية / الإطار العلوي الذهبي
                    _buildArchHeader(prefs.city),

                    // 2. شاشات الحرارة والوقت الحالي الرقمي
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // صف المقاييس العلوية (الحرارة / الإقامة)
                          Row(
                            children: [
                              _buildMiniGauge(
                                labelTop: 'TEMP',
                                labelBottom: 'الحرارة',
                                value: _isCelsius ? '28°C' : '82°F',
                                onTap: () => setState(() => _isCelsius = !_isCelsius),
                              ),
                              const Spacer(),
                              // شعار الفجر الذهبي
                              Column(
                                children: [
                                  const Icon(
                                    Icons.nights_stay_rounded,
                                    color: Color(0xFFD4AF37),
                                    size: 26,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'AL - FAJIA',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              _buildMiniGauge(
                                labelTop: 'IQAMAH',
                                labelBottom: 'متابعة الإقامة',
                                value: '15 MIN',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // شاشة الساعة الرقمية الرئيسية (Main Red LED Display)
                          _buildMainDigitalClock(
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                            amPm: amPm,
                            nextPrayer: next,
                          ),
                          const SizedBox(height: 12),

                          // شاشة التاريخ الرقمي (LED Matrix Date)
                          _buildDateMatrixBar(hijri),
                          const SizedBox(height: 14),

                          // 3. جدول الصلوات الست (All 6 Prayers)
                          _buildPrayersTable(day, next.key),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // 4. القاعدة الذهبية السفلية
                    _buildBottomConsole(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArchHeader(String city) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF141922),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF263140), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 1,
                width: 40,
                color: const Color(0xFFD4AF37),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.mosque_rounded,
                  color: Color(0xFFD4AF37),
                  size: 22,
                ),
              ),
              Container(
                height: 1,
                width: 40,
                color: const Color(0xFFD4AF37),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ساعة المواقيت والأذان الفاخرة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: const Color(0xFFE2C068),
              shadows: [
                Shadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          Text(
            'مواقيت الصلاة الدقيقة • $city',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGauge({
    required String labelTop,
    required String labelBottom,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$labelTop $labelBottom',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF263140)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF2E2E),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDigitalClock({
    required String hours,
    required String minutes,
    required String seconds,
    required String amPm,
    required PrayerMoment nextPrayer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263140), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF2E2E),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // AM / PM Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B0B0B),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF4A1010)),
                ),
                child: Text(
                  amPm,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF2E2E),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Hours
              Text(
                hours,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF2222),
                  letterSpacing: 2,
                ),
              ),
              // Colon
              Opacity(
                opacity: _blinkColon ? 1.0 : 0.2,
                child: const Text(
                  ':',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF2222),
                  ),
                ),
              ),
              // Minutes
              Text(
                minutes,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF2222),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),

              // Seconds
              Text(
                seconds,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF2222).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Next Prayer Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF141922),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFD4AF37),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'الأذان القادم: صلاة ${nextPrayer.name}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2C068),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateMatrixBar(HijriCalendar hijri) {
    final gregFormat = DateFormat('dd MMMM yyyy', 'ar').format(_now);
    final hijriFormat = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF263140)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
              const SizedBox(width: 6),
              Text(
                hijriFormat,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          Container(
            height: 16,
            width: 1,
            color: const Color(0xFF334155),
          ),
          Text(
            gregFormat,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayersTable(PrayerDay day, String activeKey) {
    PrayerMoment? find(String key) {
      try {
        return day.prayers.firstWhere((p) => p.key == key);
      } catch (_) {
        return null;
      }
    }

    final items = [
      _ClockPrayerRow('AL FAJR', 'الفجر', 'fajr', find('fajr')?.time),
      _ClockPrayerRow('SHUROQ', 'الشروق', 'sunrise', find('sunrise')?.time),
      _ClockPrayerRow('AL ZUHR', 'الظهر', 'dhuhr', find('dhuhr')?.time),
      _ClockPrayerRow('AL ASR', 'العصر', 'asr', find('asr')?.time),
      _ClockPrayerRow('MAGRIB', 'المغرب', 'maghrib', find('maghrib')?.time),
      _ClockPrayerRow('AL ISHA', 'العشاء', 'isha', find('isha')?.time),
    ];

    return Column(
      children: items.map((item) {
        final isActive = item.key.toLowerCase() == activeKey.toLowerCase();
        final timeStr = item.time != null
            ? DateFormat('hh:mm a', 'ar').format(item.time!)
            : '--:--';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3.5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF16221A) : const Color(0xFF0F141D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF1F2937),
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // English Name
              SizedBox(
                width: 76,
                child: Text(
                  item.englishName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: isActive ? const Color(0xFFFDE047) : const Color(0xFF94A3B8),
                  ),
                ),
              ),

              const Spacer(),

              // Sunken Black LED Display Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFFF2E2E).withValues(alpha: 0.6)
                        : const Color(0xFF263140),
                  ),
                  boxShadow: isActive
                      ? [
                          const BoxShadow(
                            color: Color(0x33FF2E2E),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  timeStr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isActive ? const Color(0xFFFF2222) : const Color(0xFFEF4444),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Glowing Red LED Lamp
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? const Color(0xFFFF1A1A) : const Color(0xFF2A1010),
                  border: Border.all(
                    color: isActive ? const Color(0xFFFF6B6B) : const Color(0xFF3D1616),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF1A1A).withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // Arabic Name
              SizedBox(
                width: 58,
                child: Text(
                  item.arabicName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isActive
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2C068),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomConsole() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF141922),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF263140), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '{ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا }',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سورة النساء: الآية 103',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockPrayerRow {
  final String englishName;
  final String arabicName;
  final String key;
  final DateTime? time;

  _ClockPrayerRow(this.englishName, this.arabicName, this.key, this.time);
}
