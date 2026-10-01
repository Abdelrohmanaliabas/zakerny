import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/khatmah_controller.dart';
import '../domain/khatmah_model.dart';

class KhatmahScreen extends StatefulWidget {
  const KhatmahScreen({super.key, required this.controller});

  final KhatmahController controller;

  @override
  State<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends State<KhatmahScreen> {
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
    final plan = widget.controller.activePlan;
    final completed = widget.controller.completedPlans;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ZekrniHeader(
              title: 'متابع الختمات',
              subtitle: 'تنظيم ومتابعة ختمة القرآن الكريم',
              showSearch: false,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. البطاقة الرئيسية للختمة النشطة
                      _ActiveKhatmahHero(
                        plan: plan,
                        isDark: isDark,
                        onOpenQuran: () => context.go('/quran'),
                        onEditPlan: () => _showNewKhatmahModal(context),
                      ),
                      const SizedBox(height: 18),

                      // 2. شريط التحديث السريع للصفحة الحالية
                      _PageUpdaterCard(
                        currentPage: plan.currentPage,
                        isDark: isDark,
                        onIncrement: (delta) {
                          HapticFeedback.lightImpact();
                          widget.controller.incrementPages(delta);
                        },
                        onSetPage: (page) {
                          widget.controller.updateCurrentPage(page);
                        },
                      ),
                      const SizedBox(height: 18),

                      // 3. جدول توزيع الورد على أوقات الصلوات
                      _PrayerWardDistribution(
                        plan: plan,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),

                      // 4. أزرار أهداف الختمات السريعة
                      _QuickTargetsSelector(
                        onSelectTarget: (days, pages) {
                          HapticFeedback.selectionClick();
                          widget.controller.createNewKhatmah(
                            title: 'ختمة $days يوماً',
                            totalDays: days,
                            dailyTargetPages: pages,
                            startingPage: plan.currentPage,
                          );
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),

                      // 5. الأرشيف وسجل الختمات السابقة (إن وجد)
                      if (completed.isNotEmpty) ...[
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
                              'سجل الختمات المكتملة',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F2C22),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...completed.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _CompletedKhatmahCard(plan: c, isDark: isDark),
                          ),
                        ),
                      ],
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

  void _showNewKhatmahModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewKhatmahSheet(
        currentPlan: widget.controller.activePlan,
        onSave: (title, days, pages, startPage) {
          widget.controller.createNewKhatmah(
            title: title,
            totalDays: days,
            dailyTargetPages: pages,
            startingPage: startPage,
          );
        },
      ),
    );
  }
}

class _ActiveKhatmahHero extends StatelessWidget {
  const _ActiveKhatmahHero({
    required this.plan,
    required this.isDark,
    required this.onOpenQuran,
    required this.onEditPlan,
  });

  final KhatmahPlan plan;
  final bool isDark;
  final VoidCallback onOpenQuran;
  final VoidCallback onEditPlan;

  @override
  Widget build(BuildContext context) {
    final progress = plan.progressPercentage / 100.0;
    final diff = plan.pagesAheadOrBehind;

    String statusText;
    Color statusColor;
    if (diff > 0) {
      statusText = 'متقدم بـ ${ArabicTextUtils.toArabicDigits(diff)} صفحات 🚀';
      statusColor = const Color(0xFF10B981);
    } else if (diff < 0) {
      statusText = 'متأخر بـ ${ArabicTextUtils.toArabicDigits(diff.abs())} صفحات ⏳';
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusText = 'على المسار الصحيح تماماً ✨';
      statusColor = FatimidColors.goldPrimary;
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  plan.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10281E),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                color: FatimidColors.goldPrimary,
                tooltip: 'تعديل الخطة',
                onPressed: onEditPlan,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Central circular progress & stats
          Row(
            children: [
              SizedBox(
                width: 105,
                height: 105,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 105,
                      height: 105,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(FatimidColors.goldPrimary),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${ArabicTextUtils.toArabicDigits(plan.progressPercentage.toStringAsFixed(1))}%',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'إنجاز الختمة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatBadge(
                      label: 'الصفحة الحالية',
                      value: '${ArabicTextUtils.toArabicDigits(plan.currentPage)} من ٦٠٤',
                      icon: Icons.menu_book_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _StatBadge(
                      label: 'الجزء الحالي',
                      value: 'الجزء ${ArabicTextUtils.toArabicDigits(plan.currentJuz)}',
                      icon: Icons.bookmark_added_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _StatBadge(
                      label: 'المتبقي لإنهاء الختمة',
                      value: '${ArabicTextUtils.toArabicDigits(plan.remainingPages)} صفحة • ${ArabicTextUtils.toArabicDigits(plan.daysRemaining)} يوماً',
                      icon: Icons.hourglass_top_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status bar & Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onOpenQuran,
                  child: Row(
                    children: [
                      Text(
                        'اقرأ الآن',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: FatimidColors.goldPrimary),
                    ],
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

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: FatimidColors.goldPrimary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PageUpdaterCard extends StatelessWidget {
  const _PageUpdaterCard({
    required this.currentPage,
    required this.isDark,
    required this.onIncrement,
    required this.onSetPage,
  });

  final int currentPage;
  final bool isDark;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onSetPage;

  @override
  Widget build(BuildContext context) {
    return FatimidCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_calendar_rounded, size: 18, color: FatimidColors.goldPrimary),
              const SizedBox(width: 8),
              const Text(
                'تسجيل وتحديث موضع القراءة اليوم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'ص ${ArabicTextUtils.toArabicDigits(currentPage)}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: FatimidColors.goldPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickIncrementButton(
                  label: '+١ صفحة',
                  onTap: () => onIncrement(1),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickIncrementButton(
                  label: '+٥ صفحات',
                  onTap: () => onIncrement(5),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickIncrementButton(
                  label: '+٢٠ صفحة (جزء)',
                  onTap: () => onIncrement(20),
                  isDark: isDark,
                  isHighlighted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickIncrementButton extends StatelessWidget {
  const _QuickIncrementButton({
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isHighlighted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: isHighlighted ? FatimidColors.goldGradient : null,
          color: isHighlighted
              ? null
              : (isDark ? const Color(0xFF1E2822) : const Color(0xFFF1EDE0)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: FatimidColors.goldPrimary.withValues(alpha: isHighlighted ? 0.6 : 0.25),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? const Color(0xFF13281E)
                  : (isDark ? Colors.white : const Color(0xFF1A382C)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerWardDistribution extends StatelessWidget {
  const _PrayerWardDistribution({
    required this.plan,
    required this.isDark,
  });

  final KhatmahPlan plan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final perPrayer = plan.pagesPerPrayer;

    final prayers = [
      ('الفجر', Icons.wb_twilight_rounded),
      ('الظهر', Icons.wb_sunny_rounded),
      ('العصر', Icons.wb_sunny_outlined),
      ('المغرب', Icons.nightlight_round),
      ('العشاء', Icons.nights_stay_rounded),
    ];

    return FatimidCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18, color: FatimidColors.goldPrimary),
              const SizedBox(width: 8),
              const Text(
                'توزيع الورد اليومي على الصلوات الخمس',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${ArabicTextUtils.toArabicDigits(plan.dailyTargetPages)} صفحة/يوم',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: FatimidColors.goldPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: prayers.map((p) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF19231D) : const Color(0xFFF6F3E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(p.$2, size: 16, color: FatimidColors.goldPrimary),
                      const SizedBox(height: 4),
                      Text(
                        p.$1,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ArabicTextUtils.toArabicDigits(perPrayer)} ص',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickTargetsSelector extends StatelessWidget {
  const _QuickTargetsSelector({
    required this.onSelectTarget,
    required this.isDark,
  });

  final Function(int days, int pages) onSelectTarget;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              'تغيير الخطة والهدف',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F2C22),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TargetPresetCard(
                title: 'ختمة في شهر',
                days: '٣٠ يوماً',
                rate: 'جزء (٢٠ ص) يومياً',
                onTap: () => onSelectTarget(30, 20),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TargetPresetCard(
                title: 'ختمة في ٤٠ يوماً',
                days: '٤٠ يوماً',
                rate: '١٥ صفحة يومياً',
                onTap: () => onSelectTarget(40, 15),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TargetPresetCard(
                title: 'ختمة في شهرين',
                days: '٦٠ يوماً',
                rate: 'نصف جزء (١٠ ص)',
                onTap: () => onSelectTarget(60, 10),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TargetPresetCard extends StatelessWidget {
  const _TargetPresetCard({
    required this.title,
    required this.days,
    required this.rate,
    required this.onTap,
    required this.isDark,
  });

  final String title;
  final String days;
  final String rate;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16211B) : const Color(0xFFF9F6ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              days,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: FatimidColors.goldPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              rate,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9.5,
                color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedKhatmahCard extends StatelessWidget {
  const _CompletedKhatmahCard({required this.plan, required this.isDark});

  final KhatmahPlan plan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16221B) : const Color(0xFFF7F4EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'تم إتمام ٦٠٤ صفحة بنجاح • تقبل الله',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: FatimidColors.goldPrimary, size: 20),
        ],
      ),
    );
  }
}

class _NewKhatmahSheet extends StatefulWidget {
  const _NewKhatmahSheet({required this.currentPlan, required this.onSave});

  final KhatmahPlan currentPlan;
  final Function(String title, int days, int pages, int startPage) onSave;

  @override
  State<_NewKhatmahSheet> createState() => _NewKhatmahSheetState();
}

class _NewKhatmahSheetState extends State<_NewKhatmahSheet> {
  late TextEditingController _titleController;
  int _selectedDays = 30;
  int _dailyPages = 20;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentPlan.title);
    _selectedDays = widget.currentPlan.totalDays;
    _dailyPages = widget.currentPlan.dailyTargetPages;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D18) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'تحديد خطة ختمة جديدة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'اسم الختمة',
              labelStyle: const TextStyle(fontFamily: 'Cairo'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'مدة الختمة المستهدفة:',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [30, 40, 60, 90].map((d) {
              final isSel = _selectedDays == d;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$d يوم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedDays = d;
                          _dailyPages = (604 / d).ceil();
                        });
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'الورد اليومي المطلوب: ${ArabicTextUtils.toArabicDigits(_dailyPages)} صفحة يومياً (حوالي ${ArabicTextUtils.toArabicDigits((_dailyPages / 5).ceil())} صفحات بعد كل صلاة)',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: FatimidColors.goldPrimary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FatimidColors.goldPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final title = _titleController.text.trim().isEmpty ? 'ختمة القرآن الكريم' : _titleController.text.trim();
                widget.onSave(title, _selectedDays, _dailyPages, 1);
                Navigator.of(context).pop();
              },
              child: const Text(
                'بدء الختمة المباركة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
