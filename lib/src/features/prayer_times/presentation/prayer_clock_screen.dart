import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../application/prayer_controller.dart';
import '../domain/prayer_day.dart';

/// Screen replicating the physical AL-FAJIA luxury Islamic Azan Wall/Desk Clock
/// (ساعة الفجر والحرمين الرقمية الفاخرة ذات القبة والأعمدة الجانبية)
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
              'ساعة الحرمين • AL - FAJIA',
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Physical Clock Outer Shell (Pointed Arch + Pillars + Pedestal Base)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF090D12),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(160),
                        topRight: Radius.circular(160),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 4.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.9),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Pointed Islamic Dome Arch Header
                        _buildDomeArchHeader(prefs.city),

                        // 2. Middle Body with Left & Right 3D Cylindrical Golden Columns
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left 3D Golden Pillar
                            _build3DPillar(isLeft: true),

                            // Center Dial with Displays & Prayer Rows
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Column(
                                  children: [
                                    // Temp and Iqamah Gauges
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildMiniGauge(
                                          labelTop: 'TEMP',
                                          labelBottom: 'الحرارة',
                                          value: _isCelsius ? '22°C' : '72°F',
                                          onTap: () => setState(() => _isCelsius = !_isCelsius),
                                        ),
                                        // Center small logo
                                        Text(
                                          'AL - FAJIA®',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                            color: const Color(0xFFD4AF37).withValues(alpha: 0.85),
                                          ),
                                        ),
                                        _buildMiniGauge(
                                          labelTop: 'IQAMAH',
                                          labelBottom: 'متابعة الإقامة',
                                          value: '21°F',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Main Red LED Digital Clock
                                    _buildMainDigitalClock(
                                      hours: hours,
                                      minutes: minutes,
                                      seconds: seconds,
                                      amPm: amPm,
                                      nextPrayer: next,
                                    ),
                                    const SizedBox(height: 10),

                                    // Red LED Matrix Date Display
                                    _buildDateMatrixBar(hijri),
                                    const SizedBox(height: 12),

                                    // Prayers Table with Haram Background
                                    _buildPrayersTable(day, next.key),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),

                            // Right 3D Golden Pillar
                            _build3DPillar(isLeft: false),
                          ],
                        ),

                        // 3. Bottom Golden Pedestal Base with Physical Buttons
                        _buildPhysicalButtonsBase(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top pointed arch dome header with ornate gold moulding
  Widget _buildDomeArchHeader(String city) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF241908),
            Color(0xFF140F04),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD4AF37), width: 1.8),
        ),
      ),
      child: Column(
        children: [
          // Golden Crescent and AL-FAJIA Emblem
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 1, width: 36, color: const Color(0xFFD4AF37)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.nights_stay_rounded,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              Container(height: 1, width: 36, color: const Color(0xFFD4AF37)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'AL - FAJIA®',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 2.5,
              color: Color(0xFFE5C068),
            ),
          ),
          Text(
            'ساعة الحرمين الشريفين • $city',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC4A252),
            ),
          ),
        ],
      ),
    );
  }

  /// 3D Cylindrical Architectural Pillar with capital and base
  Widget _build3DPillar({required bool isLeft}) {
    return Container(
      width: 20,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: const [
            Color(0xFF523B0D),
            Color(0xFF997321),
            Color(0xFFF5DE88),
            Color(0xFFD4AF37),
            Color(0xFF5E420E),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: Offset(isLeft ? 2 : -2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Capital molding (top)
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFF0D57A),
              border: Border.all(color: const Color(0xFF5A410E)),
            ),
          ),
          const SizedBox(height: 440),
          // Base pedestal molding (bottom)
          Container(
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFF0D57A),
              border: Border.all(color: const Color(0xFF5A410E)),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$labelTop $labelBottom',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF334155), width: 1.2),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF2222),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3648), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF2222),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // AM / PM Dot Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B0B0B),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF5A1414)),
                ),
                child: Text(
                  amPm,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF2222),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Hours
              Text(
                hours,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 42,
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
                    fontSize: 38,
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
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF2222),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 6),

              // Seconds
              Text(
                seconds,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF2222).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Next Prayer Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF161C26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFD4AF37),
                  size: 13,
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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF263140)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFF2E2E), size: 13),
              const SizedBox(width: 6),
              Text(
                hijriFormat,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF2E2E),
                ),
              ),
            ],
          ),
          Container(
            height: 14,
            width: 1,
            color: const Color(0xFF334155),
          ),
          Text(
            gregFormat,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5,
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
            ? DateFormat('hh:mm', 'en').format(item.time!)
            : '--:--';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2.8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1B2418) : const Color(0xFF0F151E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFFD4AF37) : const Color(0xFF222C3A),
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // English Name
              SizedBox(
                width: 72,
                child: Text(
                  item.englishName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: isActive ? const Color(0xFFFDE047) : const Color(0xFF94A3B8),
                  ),
                ),
              ),

              const Spacer(),

              // Black Beveled Time Display Box
              Container(
                width: 74,
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? const Color(0xFFFF2222) : const Color(0xFF2A3648),
                  ),
                ),
                child: Center(
                  child: Text(
                    timeStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF2222),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Glowing Red LED Dot Indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? const Color(0xFFFF1E1E) : const Color(0xFF2D0E0E),
                  border: Border.all(
                    color: isActive ? const Color(0xFFFF8888) : const Color(0xFF451515),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF1E1E).withValues(alpha: 0.9),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),

              const SizedBox(width: 10),

              // Arabic Name
              SizedBox(
                width: 54,
                child: Text(
                  item.arabicName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isActive ? const Color(0xFFF59E0B) : const Color(0xFFE2C068),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Bottom horizontal pedestal base with physical control push-buttons
  Widget _buildPhysicalButtonsBase() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD4AF37),
            Color(0xFF9E7B26),
            Color(0xFF6B4E12),
          ],
        ),
        border: Border(
          top: BorderSide(color: Color(0xFFF0D57A), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Push buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPushButton('A'),
              const SizedBox(width: 6),
              _buildPushButton('UP'),
              const SizedBox(width: 6),
              _buildPushButton('DOWN'),
              const SizedBox(width: 6),
              _buildPushButton('SELECT'),
              const SizedBox(width: 6),
              _buildPushButton('BACK'),
              const SizedBox(width: 6),
              _buildPushButton('ALARM'),
              const SizedBox(width: 6),
              _buildPushButton('LIGHT'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '{ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا }',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFF4D0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPushButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1F08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF0D57A), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 1.5),
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          color: Color(0xFFF5DE88),
        ),
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
