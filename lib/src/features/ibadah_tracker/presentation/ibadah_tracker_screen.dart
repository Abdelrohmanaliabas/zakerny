import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/ibadah_controller.dart';
import '../domain/ibadah_model.dart';

class IbadahTrackerScreen extends StatefulWidget {
  const IbadahTrackerScreen({super.key, required this.controller});

  final IbadahController controller;

  @override
  State<IbadahTrackerScreen> createState() => _IbadahTrackerScreenState();
}

class _IbadahTrackerScreenState extends State<IbadahTrackerScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final record = widget.controller.currentRecord;
    final selectedDate = widget.controller.selectedDate;
    final past7Days = widget.controller.past7Days;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ZekrniHeader(
              title: 'سجل المحاسبة',
              subtitle: 'متابعة العبادات والطاعات اليومية',
              showSearch: false,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. شريط اختيار الأيام السبعة
                      _DateSelectorRibbon(
                        selectedDate: selectedDate,
                        onSelectDate: (d) {
                          HapticFeedback.selectionClick();
                          widget.controller.selectDate(d);
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),

                      // 2. بطاقة ملخص الإنجاز اليومي
                      _DailyScoreCard(
                        record: record,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // 3. الصلوات المفروضة الخمس
                      _SectionTitle(
                        title: 'الصلوات المفروضة الخمس',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _FardPrayersList(
                        record: record,
                        isDark: isDark,
                        onChanged: (key, status) {
                          HapticFeedback.lightImpact();
                          widget.controller.setPrayerStatus(key, status);
                        },
                      ),
                      const SizedBox(height: 22),

                      // 4. السنن والنوافل
                      _SectionTitle(
                        title: 'السنن والنوافل',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _SunnahChecklist(
                        record: record,
                        isDark: isDark,
                        onToggle: (key) {
                          HapticFeedback.lightImpact();
                          widget.controller.toggleSunnah(key);
                        },
                      ),
                      const SizedBox(height: 22),

                      // 5. الأذكار والقرآن وأعمال البر
                      _SectionTitle(
                        title: 'القرآن والأذكار وأعمال البر',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _DeedsChecklist(
                        record: record,
                        isDark: isDark,
                        onToggle: (key) {
                          HapticFeedback.lightImpact();
                          widget.controller.toggleSunnah(key);
                        },
                      ),
                      const SizedBox(height: 24),

                      // 6. شريط الإنجاز والالتزام الأسبوعي
                      _SectionTitle(
                        title: 'الالتزام خلال الأسبوع الماضي',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _WeeklyStreakChart(
                        records: past7Days,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectorRibbon extends StatelessWidget {
  const _DateSelectorRibbon({
    required this.selectedDate,
    required this.onSelectDate,
    required this.isDark,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((d) {
          final isSameDay = d.year == selectedDate.year &&
              d.month == selectedDate.month &&
              d.day == selectedDate.day;
          final isToday = d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
          final dayName = isToday ? 'اليوم' : DateFormat('EEEE', 'ar').format(d);
          final dayNum = ArabicTextUtils.toArabicDigits(d.day);

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () => onSelectDate(d),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 68,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSameDay ? FatimidColors.goldGradient : null,
                  color: isSameDay
                      ? null
                      : (isDark ? const Color(0xFF141D17) : const Color(0xFFFAF7EE)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSameDay
                        ? FatimidColors.goldPrimary
                        : Colors.grey.withValues(alpha: 0.25),
                  ),
                  boxShadow: isSameDay
                      ? [
                          BoxShadow(
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSameDay
                            ? const Color(0xFF13281E)
                            : (isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isSameDay
                            ? const Color(0xFF13281E)
                            : (isDark ? Colors.white : const Color(0xFF0F2C22)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DailyScoreCard extends StatelessWidget {
  const _DailyScoreCard({required this.record, required this.isDark});

  final DailyIbadahRecord record;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final score = record.completionScore;
    final progress = score / 100.0;

    String statusMsg;
    if (score >= 90) {
      statusMsg = 'ما شاء الله! يوم عامر بالطاعات والبركة 🌟';
    } else if (score >= 60) {
      statusMsg = 'إنجاز مبارك، استمر في المحافظة على النوافل ✨';
    } else if (score >= 30) {
      statusMsg = 'بداية طيبة، حافظ على الصلوات في أوقاتها 🤲';
    } else {
      statusMsg = '«حَاسِبُوا أَنْفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا» 🌿';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D18) : const Color(0xFFFBF8EF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.4),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(FatimidColors.goldPrimary),
                  ),
                ),
                Text(
                  '${ArabicTextUtils.toArabicDigits(score.toInt())}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نسبة الالتزام بالطاعات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMsg,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: FatimidColors.goldPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniBadge(
                      label: 'الفرائض',
                      value: '${ArabicTextUtils.toArabicDigits(record.fardPrayersDoneCount)}/٥',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _MiniBadge(
                      label: 'جماعة',
                      value: ArabicTextUtils.toArabicDigits(record.jamaahPrayersCount),
                      color: FatimidColors.goldPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _FardPrayersList extends StatelessWidget {
  const _FardPrayersList({
    required this.record,
    required this.isDark,
    required this.onChanged,
  });

  final DailyIbadahRecord record;
  final bool isDark;
  final Function(String key, PrayerStatus status) onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('fajr', 'صلاة الفجر', record.fajr, Icons.wb_twilight_rounded),
      ('dhuhr', 'صلاة الظهر', record.dhuhr, Icons.wb_sunny_rounded),
      ('asr', 'صلاة العصر', record.asr, Icons.wb_sunny_outlined),
      ('maghrib', 'صلاة المغرب', record.maghrib, Icons.nightlight_round),
      ('isha', 'صلاة العشاء', record.isha, Icons.nights_stay_rounded),
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF15211B) : const Color(0xFFF9F6ED),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FatimidColors.goldPrimary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(item.$4, color: FatimidColors.goldPrimary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.$2,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _PrayerStatusChips(
                status: item.$3,
                onChanged: (s) => onChanged(item.$1, s),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PrayerStatusChips extends StatelessWidget {
  const _PrayerStatusChips({required this.status, required this.onChanged});

  final PrayerStatus status;
  final ValueChanged<PrayerStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusButton(
          label: 'لم أصلي',
          isSelected: status == PrayerStatus.notDone,
          color: Colors.grey,
          onTap: () => onChanged(PrayerStatus.notDone),
        ),
        const SizedBox(width: 5),
        _StatusButton(
          label: 'صليت',
          isSelected: status == PrayerStatus.done,
          color: const Color(0xFF10B981),
          onTap: () => onChanged(PrayerStatus.done),
        ),
        const SizedBox(width: 5),
        _StatusButton(
          label: 'جماعة',
          isSelected: status == PrayerStatus.inJamaah,
          color: FatimidColors.goldPrimary,
          onTap: () => onChanged(PrayerStatus.inJamaah),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
            color: isSelected ? color : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _SunnahChecklist extends StatelessWidget {
  const _SunnahChecklist({
    required this.record,
    required this.isDark,
    required this.onToggle,
  });

  final DailyIbadahRecord record;
  final bool isDark;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChecklistTile(
          title: 'صلاة الضحى',
          subtitle: 'ركعتين أو أكثر • صلاة الأوابين',
          isChecked: record.duha,
          isDark: isDark,
          onTap: () => onToggle('duha'),
        ),
        _ChecklistTile(
          title: 'قيام الليل والوتر',
          subtitle: 'ركعة أو أكثر قبل الفجر • شرف المؤمن',
          isChecked: record.witr,
          isDark: isDark,
          onTap: () => onToggle('witr'),
        ),
        _ChecklistTile(
          title: 'السنن الرواتب',
          subtitle: '١٢ ركعة في اليوم والليلة (بنى الله له بيتاً في الجنة)',
          isChecked: record.rawatib,
          isDark: isDark,
          onTap: () => onToggle('rawatib'),
        ),
      ],
    );
  }
}

class _DeedsChecklist extends StatelessWidget {
  const _DeedsChecklist({
    required this.record,
    required this.isDark,
    required this.onToggle,
  });

  final DailyIbadahRecord record;
  final bool isDark;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChecklistTile(
          title: 'قراءة الورد القرآني',
          subtitle: 'جزء أو صفحات محددة من كتاب الله',
          isChecked: record.quranWard,
          isDark: isDark,
          onTap: () => onToggle('quranWard'),
        ),
        _ChecklistTile(
          title: 'أذكار الصباح والمساء',
          subtitle: 'الحصن الحصين وطمأنينة القلب',
          isChecked: record.morningDhikr && record.eveningDhikr,
          isDark: isDark,
          onTap: () {
            if (!record.morningDhikr) {
              onToggle('morningDhikr');
            } else if (!record.eveningDhikr) {
              onToggle('eveningDhikr');
            } else {
              onToggle('morningDhikr');
              onToggle('eveningDhikr');
            }
          },
        ),
        _ChecklistTile(
          title: 'صيام نافلة',
          subtitle: 'إثنين أو خميس أو الأيام البيض',
          isChecked: record.fasting,
          isDark: isDark,
          onTap: () => onToggle('fasting'),
        ),
        _ChecklistTile(
          title: 'صدقة أو عمل صالح',
          subtitle: 'تفريج كربة، إطعام طعام، أو كلمة طيبة',
          isChecked: record.sadaqah,
          isDark: isDark,
          onTap: () => onToggle('sadaqah'),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.title,
    required this.subtitle,
    required this.isChecked,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isChecked;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14201A) : const Color(0xFFFAF7EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isChecked
                  ? const Color(0xFF10B981)
                  : FatimidColors.goldPrimary.withValues(alpha: 0.2),
              width: isChecked ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  border: Border.all(
                    color: isChecked
                        ? const Color(0xFF10B981)
                        : Colors.grey.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isChecked
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white : const Color(0xFF0F2C22)),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyStreakChart extends StatelessWidget {
  const _WeeklyStreakChart({required this.records, required this.isDark});

  final List<DailyIbadahRecord> records;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D18) : const Color(0xFFFAF8EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FatimidColors.goldPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: records.map((r) {
              final score = r.completionScore;
              final height = (score / 100.0) * 70.0;
              final clampedHeight = height < 6 ? 6.0 : height;
              final dayParts = r.dateStr.split('-');
              final dayStr = dayParts.length == 3 ? dayParts[2] : '';

              return Column(
                children: [
                  Text(
                    '${score.toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: FatimidColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: clampedHeight,
                    decoration: BoxDecoration(
                      gradient: score >= 60
                          ? FatimidColors.goldGradient
                          : const LinearGradient(
                              colors: [Color(0xFF64748B), Color(0xFF475569)],
                            ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ArabicTextUtils.toArabicDigits(dayStr),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F2C22),
              ),
        ),
      ],
    );
  }
}
