import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../domain/calendar_models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewType _viewType = CalendarViewType.hijri;
  late DateTime _selectedDate;
  late HijriCalendar _selectedHijri;

  // View state for Hijri month
  late int _viewHijriYear;
  late int _viewHijriMonth;

  // View state for Gregorian month
  late int _viewGregYear;
  late int _viewGregMonth;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    final now = DateTime.now();
    _selectedDate = now;
    _selectedHijri = HijriCalendar.fromDate(now);

    _viewHijriYear = _selectedHijri.hYear;
    _viewHijriMonth = _selectedHijri.hMonth;

    _viewGregYear = now.year;
    _viewGregMonth = now.month;
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _selectedHijri = HijriCalendar.fromDate(now);
      _viewHijriYear = _selectedHijri.hYear;
      _viewHijriMonth = _selectedHijri.hMonth;
      _viewGregYear = now.year;
      _viewGregMonth = now.month;
    });
  }

  void _nextMonth() {
    setState(() {
      if (_viewType == CalendarViewType.hijri) {
        if (_viewHijriMonth == 12) {
          _viewHijriMonth = 1;
          _viewHijriYear++;
        } else {
          _viewHijriMonth++;
        }
      } else {
        if (_viewGregMonth == 12) {
          _viewGregMonth = 1;
          _viewGregYear++;
        } else {
          _viewGregMonth++;
        }
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_viewType == CalendarViewType.hijri) {
        if (_viewHijriMonth == 1) {
          _viewHijriMonth = 12;
          _viewHijriYear--;
        } else {
          _viewHijriMonth--;
        }
      } else {
        if (_viewGregMonth == 1) {
          _viewGregMonth = 12;
          _viewGregYear--;
        } else {
          _viewGregMonth--;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ZekrniHeader(
              title: 'التقويم والتواريخ',
              subtitle: 'التقويم الهجري والميلادي المعتمد',
              showSearch: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. زر التبديل بين الهجري والميلادي (Hijri / Gregorian Switcher)
                  _buildCalendarToggle(isDark),
                  const SizedBox(height: 16),

                  // 2. بطاقة اليوم المختار المفصلة (Hero Card)
                  _buildSelectedDateHero(isDark),
                  const SizedBox(height: 18),

                  // 3. شريط التنقل بين الأشهر (Month & Year Navigator)
                  _buildMonthNavigator(isDark),
                  const SizedBox(height: 12),

                  // 4. شبكة أيام التقويم (Calendar Grid)
                  _buildCalendarGrid(isDark),
                  const SizedBox(height: 20),

                  // 5. محول التاريخ الذكي السريع (Quick Converter Box)
                  _buildQuickConverter(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// زر التبديل العصري بين التقويم الهجري والميلادي
  Widget _buildCalendarToggle(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E19) : const Color(0xFFE9F3EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              title: 'التقويم الهجري',
              subtitle: 'أم القرى والإسلامي',
              icon: Icons.nightlight_round,
              isSelected: _viewType == CalendarViewType.hijri,
              onTap: () => setState(() => _viewType = CalendarViewType.hijri),
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              title: 'التقويم الميلادي',
              subtitle: 'الشمسي والمستندي',
              icon: Icons.wb_sunny_rounded,
              isSelected: _viewType == CalendarViewType.gregorian,
              onTap: () => setState(() => _viewType = CalendarViewType.gregorian),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? FatimidColors.goldGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF0F2C22) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: isSelected ? const Color(0xFF0F2C22) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: isSelected
                        ? const Color(0xFF0F2C22).withValues(alpha: 0.8)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// البطاقة الرئيسية لليوم المحدد
  Widget _buildSelectedDateHero(bool isDark) {
    final hijriStr =
        '${_selectedHijri.hDay} ${_selectedHijri.longMonthName} ${_selectedHijri.hYear} هـ';
    final gregStr = DateFormat('d MMMM yyyy', 'ar').format(_selectedDate);
    final dayOfWeek = DateFormat('EEEE', 'ar').format(_selectedDate);
    final event = CalendarUtils.getEventForHijri(
      _selectedHijri.hMonth,
      _selectedHijri.hDay,
    );
    final isWhite = CalendarUtils.isWhiteDay(_selectedHijri.hDay);
    final isSunnahFast = CalendarUtils.isSunnahFastingDay(_selectedDate);

    return FatimidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dayOfWeek,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF0F2C22),
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _jumpToToday,
                icon: const Icon(Icons.my_location_rounded, size: 16),
                label: const Text('اليوم', style: TextStyle(fontFamily: 'Cairo')),
                style: TextButton.styleFrom(
                  foregroundColor: FatimidColors.goldPrimary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Primary Date Display
          Text(
            _viewType == CalendarViewType.hijri ? hijriStr : gregStr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? Colors.white : const Color(0xFF0F2C22),
            ),
          ),
          const SizedBox(height: 2),

          // Secondary Date Display
          Row(
            children: [
              Icon(
                _viewType == CalendarViewType.hijri
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_outlined,
                size: 14,
                color: FatimidColors.goldPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                'يوافقه: ${_viewType == CalendarViewType.hijri ? gregStr : hijriStr}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FatimidColors.goldPrimary,
                ),
              ),
            ],
          ),

          // Event & Fasting Badges
          if (event != null || isWhite || isSunnahFast) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (event != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD97706)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isWhite)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF059669)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.brightness_5_rounded, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text(
                          'من الأيام البيض (صيام مستحب)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isSunnahFast && !isWhite)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 4),
                        Text(
                          'صيام $dayOfWeek (سنة نبوية)',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// شريط التنقل بين الأشهر
  Widget _buildMonthNavigator(bool isDark) {
    final title = _viewType == CalendarViewType.hijri
        ? '${CalendarUtils.hijriMonthNames[_viewHijriMonth - 1]} $_viewHijriYear هـ'
        : '${CalendarUtils.gregorianMonthNames[_viewGregMonth - 1]} $_viewGregYear م';

    return Row(
      children: [
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          color: FatimidColors.goldPrimary,
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : const Color(0xFF0F2C22),
            ),
          ),
        ),
        IconButton(
          onPressed: _prevMonth,
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          color: FatimidColors.goldPrimary,
        ),
      ],
    );
  }

  /// شبكة التقويم التفاعلية
  Widget _buildCalendarGrid(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101713) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2E25) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // أسماء أيام الأسبوع
          Row(
            children: CalendarUtils.weekDayNames.map((name) {
              return Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: name == 'الجمعة'
                        ? FatimidColors.goldPrimary
                        : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 16),

          // شبكة الأيام
          _viewType == CalendarViewType.hijri
              ? _buildHijriGrid(isDark)
              : _buildGregorianGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildHijriGrid(bool isDark) {
    final hijriCalc = HijriCalendar();
    hijriCalc.hYear = _viewHijriYear;
    hijriCalc.hMonth = _viewHijriMonth;
    hijriCalc.hDay = 1;

    // Convert day 1 to Gregorian to know starting weekday
    final firstDayGreg = hijriCalc.hijriToGregorian(_viewHijriYear, _viewHijriMonth, 1);
    // Saturday = 0 in our index
    final startingOffset = (firstDayGreg.weekday + 1) % 7;
    final totalDays = hijriCalc.getDaysInMonth(_viewHijriYear, _viewHijriMonth);

    final cells = <Widget>[];

    // Empty spaces before first day
    for (int i = 0; i < startingOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Days of month
    final todayHijri = HijriCalendar.now();
    for (int day = 1; day <= totalDays; day++) {
      final isSelected = _selectedHijri.hYear == _viewHijriYear &&
          _selectedHijri.hMonth == _viewHijriMonth &&
          _selectedHijri.hDay == day;

      final isToday = todayHijri.hYear == _viewHijriYear &&
          todayHijri.hMonth == _viewHijriMonth &&
          todayHijri.hDay == day;

      final event = CalendarUtils.getEventForHijri(_viewHijriMonth, day);
      final isWhite = CalendarUtils.isWhiteDay(day);

      // Corresponding Gregorian day
      final gregDate = hijriCalc.hijriToGregorian(_viewHijriYear, _viewHijriMonth, day);
      final gregDayStr = gregDate.day.toString();

      cells.add(
        _buildDayCell(
          primaryNumber: day.toString(),
          subNumber: gregDayStr,
          isSelected: isSelected,
          isToday: isToday,
          hasEvent: event != null,
          isWhiteDay: isWhite,
          isDark: isDark,
          onTap: () {
            setState(() {
              _selectedDate = gregDate;
              _selectedHijri = HijriCalendar.fromDate(gregDate);
            });
          },
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 0.9,
      children: cells,
    );
  }

  Widget _buildGregorianGrid(bool isDark) {
    final firstDay = DateTime(_viewGregYear, _viewGregMonth, 1);
    final daysInMonth = DateTime(_viewGregYear, _viewGregMonth + 1, 0).day;
    final startingOffset = (firstDay.weekday + 1) % 7;

    final cells = <Widget>[];

    for (int i = 0; i < startingOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    final today = DateTime.now();

    for (int day = 1; day <= daysInMonth; day++) {
      final curDate = DateTime(_viewGregYear, _viewGregMonth, day);
      final curHijri = HijriCalendar.fromDate(curDate);

      final isSelected = _selectedDate.year == _viewGregYear &&
          _selectedDate.month == _viewGregMonth &&
          _selectedDate.day == day;

      final isToday = today.year == _viewGregYear &&
          today.month == _viewGregMonth &&
          today.day == day;

      final event = CalendarUtils.getEventForHijri(curHijri.hMonth, curHijri.hDay);
      final isWhite = CalendarUtils.isWhiteDay(curHijri.hDay);

      cells.add(
        _buildDayCell(
          primaryNumber: day.toString(),
          subNumber: curHijri.hDay.toString(),
          isSelected: isSelected,
          isToday: isToday,
          hasEvent: event != null,
          isWhiteDay: isWhite,
          isDark: isDark,
          onTap: () {
            setState(() {
              _selectedDate = curDate;
              _selectedHijri = curHijri;
            });
          },
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 0.9,
      children: cells,
    );
  }

  Widget _buildDayCell({
    required String primaryNumber,
    required String subNumber,
    required bool isSelected,
    required bool isToday,
    required bool hasEvent,
    required bool isWhiteDay,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? FatimidColors.goldGradient : null,
          color: isSelected
              ? null
              : isToday
                  ? FatimidColors.goldPrimary.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? FatimidColors.goldPrimary
                : isToday
                    ? FatimidColors.goldPrimary
                    : Colors.transparent,
            width: isSelected || isToday ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryNumber,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isSelected
                    ? const Color(0xFF0F2C22)
                    : isToday
                        ? FatimidColors.goldPrimary
                        : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
            Text(
              subNumber,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF0F2C22).withValues(alpha: 0.8)
                    : const Color(0xFF94A3B8),
              ),
            ),
            if (hasEvent || isWhiteDay)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasEvent
                      ? const Color(0xFFD97706)
                      : const Color(0xFF059669),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// محول التاريخ الذكي
  Widget _buildQuickConverter(bool isDark) {
    return FatimidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'محول التاريخ السريع',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F2C22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اختر تاريخاً من التقويم أعلاه لرؤية التحويل اللحظي الكامل بين الهجري والميلادي واليوم والمناسبات المقترنة به.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
