import 'package:flutter/material.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/qadaa_controller.dart';
import '../domain/qadaa_models.dart';

class QadaaTrackerScreen extends StatefulWidget {
  const QadaaTrackerScreen({
    super.key,
    required this.controller,
    this.initialTab = 0,
  });

  final QadaaController controller;
  final int initialTab;

  @override
  State<QadaaTrackerScreen> createState() => _QadaaTrackerScreenState();
}

class _QadaaTrackerScreenState extends State<QadaaTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    widget.controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            ZekrniHeader(
              title: 'سجل قضاء الصلوات والصيام',
              subtitle: 'متابعة وتوثيق الفروض الفائتة وأيام القضاء باحتساب ويقين',
              showSearch: false,
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? FatimidColors.obsidianCard.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF261800),
                unselectedLabelColor: isDark ? const Color(0xFF90A49C) : const Color(0xFF5D756C),
                labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.access_time_filled_rounded, size: 20),
                    text: 'قضاء الصلوات المفروضة',
                  ),
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.brightness_3_rounded, size: 20),
                    text: 'قضاء أيام الصيام',
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PrayersQadaaView(controller: widget.controller),
                  _FastingQadaaView(controller: widget.controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// تبويب قضاء الصلوات المفروضة
// ============================================================================
class _PrayersQadaaView extends StatelessWidget {
  const _PrayersQadaaView({required this.controller});

  final QadaaController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final total = controller.totalObligatoryTotal;
    final completed = controller.totalObligatoryCompleted;
    final remaining = controller.totalObligatoryRemaining;
    final progress = controller.totalObligatoryProgress;
    final percentInt = (progress * 100).toInt();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            // Overall Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF143026), FatimidColors.obsidianCard]
                      : [const Color(0xFFE8F3ED), Colors.white],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 7,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : FatimidColors.goldPrimary.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                FatimidColors.goldPrimary,
                              ),
                            ),
                            Text(
                              '$percentInt%',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF16382C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Overall Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نسبة إنجاز قضاء الصلوات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF16382C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              total > 0
                                  ? 'تم قضاء $completed فريضة من إجمالي $total (متبقي $remaining)'
                                  : 'اضغط على "حاسبة التقدير" لتحديد عدد أيام الفوائت',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.5,
                                color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF4C6A5E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Quick Action Buttons Row
                  Row(
                    children: [
                      // Full Day Qadaa (+5 Prayers)
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmFullDayQadaa(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FatimidColors.goldPrimary,
                            foregroundColor: const Color(0xFF261800),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 20),
                          label: const Text(
                            'قضاء يوم كامل (٥ صلوات)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Calculator Tool
                      IconButton(
                        tooltip: 'حاسبة تقدير الفوائت',
                        icon: const Icon(Icons.calculate_outlined),
                        color: FatimidColors.goldPrimary,
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : const Color(0xFFF3EFE0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        onPressed: () => _showDurationCalculator(context),
                      ),
                      const SizedBox(width: 6),
                      // Edit Totals
                      IconButton(
                        tooltip: 'تعديل الفوائت يدوياً',
                        icon: const Icon(Icons.edit_note_rounded),
                        color: isDark ? Colors.white70 : const Color(0xFF335547),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : const Color(0xFFF3EFE0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        onPressed: () => _showManualEditDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header for Individual Prayers
            Row(
              children: [
                const Icon(Icons.format_list_bulleted_rounded, size: 18, color: FatimidColors.goldPrimary),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الصلوات المفروضة والسنن',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF16382C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Prayers list
            ...QadaaPrayerType.values.map((type) {
              final progress = controller.getPrayer(type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PrayerCard(
                  progress: progress,
                  controller: controller,
                  isDark: isDark,
                ),
              );
            }),

            const SizedBox(height: 14),

            // Jurisprudence Rules Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F221B) : const Color(0xFFFAF8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: FatimidColors.goldPrimary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فائدة وفتاوى قضاء الصلوات الفائتة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF16382C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• اتفق الأئمة الأربعة على وجوب قضاء ما فات من الصلوات المفروضة لقوله ﷺ: «مَن نَسِيَ صَلَاةً، أَوْ نَامَ عَنْهَا، فَكَفَّارَتُهَا أَنْ يُصَلِّيَهَا إِذَا ذَكَرَهَا» (صحيح مسلم).\n• يُستحب للمسلم أن يقضي مع كل فريضة فريضة مماثلة لها أو يقضي ما تيسر من صلوات الأيام في أوقات الفراغ دون مشقة، ودين الله أحق أن يُقضى.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            height: 1.7,
                            color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF4C6A5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmFullDayQadaa(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('قضاء صلوات يوم كامل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text(
          'سيتم زيادة صلاة مقضية واحدة لكل من (الفجر، الظهر، العصر، المغرب، والعشاء). هل أتممت صلوات هذا اليوم؟',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FatimidColors.goldPrimary),
            onPressed: () {
              Navigator.pop(ctx);
              controller.completeFullDayObligatoryPrayers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تقبل الله منك! تم توثيق قضاء صلوات يوم كامل بنجاح 🤲', style: TextStyle(fontFamily: 'Cairo')),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('تأكيد القضاء', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF261800), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDurationCalculator(BuildContext context) {
    int years = 0;
    int months = 0;
    int days = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final calculatedDays = (years * 365) + (months * 30) + days;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: BoxDecoration(
              color: isDark ? FatimidColors.obsidianCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: FatimidColors.goldPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: FatimidColors.goldPrimary, size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'حاسبة تقدير الفوائت الإجمالية',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'حدد المدة التقريبية التي ترغب في قضائها، وسيقوم التطبيق بحساب عدد الصلوات المفروضة تلقائياً:',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Sliders / Pickers for Years, Months, Days
                _buildNumberPickerRow('السنوات:', years, (val) => setSheetState(() => years = val), 30),
                const SizedBox(height: 10),
                _buildNumberPickerRow('الشهور:', months, (val) => setSheetState(() => months = val), 11),
                const SizedBox(height: 10),
                _buildNumberPickerRow('الأيام:', days, (val) => setSheetState(() => days = val), 29),
                const SizedBox(height: 16),

                // Calculated result box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: FatimidColors.goldPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي الأيام المحسوبة:',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$calculatedDays يوم ($calculatedDays صلاة لكل فريضة)',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FatimidColors.goldPrimary,
                    foregroundColor: const Color(0xFF261800),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: calculatedDays <= 0
                      ? null
                      : () {
                          controller.setAllObligatoryTotals(calculatedDays);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم ضبط الفوائت لكل فريضة على $calculatedDays صلاة 🤲', style: const TextStyle(fontFamily: 'Cairo')),
                            ),
                          );
                        },
                  child: const Text(
                    'اعتماد وتحديث الفوائت للصلوات الخمس',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberPickerRow(String label, int value, ValueChanged<int> onChanged, int max) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text('$value', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
        Expanded(
          child: Slider(
            value: value.toDouble().clamp(0.0, max.toDouble()),
            min: 0,
            max: max.toDouble(),
            divisions: max > 0 ? max : 1,
            activeColor: FatimidColors.goldPrimary,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
      ],
    );
  }

  void _showManualEditDialog(BuildContext context) {
    final controllers = <QadaaPrayerType, TextEditingController>{};
    for (final type in QadaaPrayerType.values) {
      controllers[type] = TextEditingController(text: controller.getPrayer(type).total.toString());
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل إجمالي الفوائت يدوياً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: QadaaPrayerType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: controllers[type],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: type.title,
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    prefixIcon: Icon(type.icon, color: type.color),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FatimidColors.goldPrimary),
            onPressed: () {
              for (final type in QadaaPrayerType.values) {
                final count = int.tryParse(controllers[type]?.text.trim() ?? '0') ?? 0;
                controller.setPrayerTotal(type, count);
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF261800), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// بطاقة الصلاة الفردية
// ============================================================================
class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.progress,
    required this.controller,
    required this.isDark,
  });

  final QadaaPrayerProgress progress;
  final QadaaController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final type = progress.prayerType;
    final pct = (progress.progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: progress.isCompleted
              ? Colors.green.withValues(alpha: 0.6)
              : FatimidColors.goldPrimary.withValues(alpha: 0.3),
          width: progress.isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: type.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF16382C),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${type.rakats} ركعات)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: progress.isCompleted ? Colors.green : FatimidColors.goldPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تم قضاء ${progress.completed} من ${progress.total} (المتبقي: ${progress.remaining})',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF5D756C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.progress,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white12 : const Color(0xFFEFEBD9),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.isCompleted ? Colors.green : type.color,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Undo Button
              IconButton(
                tooltip: 'تراجع عن صلاة',
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                color: progress.completed > 0
                    ? (isDark ? Colors.white70 : const Color(0xFF5D756C))
                    : Colors.grey.withValues(alpha: 0.3),
                onPressed: progress.completed > 0
                    ? () => controller.undoPrayer(type)
                    : null,
              ),

              // Completed Badge or Big +1 Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: progress.isCompleted
                          ? Colors.green
                          : (isDark ? const Color(0xFF16382C) : const Color(0xFFE8F2EC)),
                      foregroundColor: progress.isCompleted
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0F3628)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: progress.isCompleted
                              ? Colors.green
                              : FatimidColors.goldPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: Icon(
                      progress.isCompleted ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      progress.isCompleted ? 'اكتمل القضاء بحمد الله' : '+١ قضاء صلاة',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => controller.completePrayer(type),
                  ),
                ),
              ),

              // Edit count single
              IconButton(
                tooltip: 'تعديل هذا الفرض',
                icon: const Icon(Icons.tune_rounded, size: 19),
                color: isDark ? Colors.white60 : Colors.black45,
                onPressed: () => _editSinglePrayer(context, type),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editSinglePrayer(BuildContext context, QadaaPrayerType type) {
    final totalCtrl = TextEditingController(text: progress.total.toString());
    final doneCtrl = TextEditingController(text: progress.completed.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل ${type.title}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: totalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'إجمالي الفوائت المطلوبة', labelStyle: TextStyle(fontFamily: 'Cairo')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: doneCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'تم قضاؤها بالفعل', labelStyle: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FatimidColors.goldPrimary),
            onPressed: () {
              final t = int.tryParse(totalCtrl.text) ?? progress.total;
              final d = int.tryParse(doneCtrl.text) ?? progress.completed;
              controller.setPrayerTotal(type, t);
              controller.completePrayer(type, d - progress.completed);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF261800), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// تبويب قضاء أيام الصيام
// ============================================================================
class _FastingQadaaView extends StatelessWidget {
  const _FastingQadaaView({required this.controller});

  final QadaaController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final target = controller.fastingTarget;
    final completed = controller.fastingCompleted;
    final remaining = controller.fastingRemaining;
    final progress = controller.fastingProgress;
    final percentInt = (progress * 100).toInt();
    final history = controller.fastingHistory;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            // Fasting Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF16382C), FatimidColors.obsidianCard]
                      : [const Color(0xFFE8F5EF), Colors.white],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Circular Gauge
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 7,
                              backgroundColor: isDark ? Colors.white12 : const Color(0xFFD1FAE5),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            ),
                            Text(
                              '$percentInt%',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF16382C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سجل صيام أيام القضاء والكفارات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF16382C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              target > 0
                                  ? 'تم صيام $completed أيام من إجمالي $target يوماً مطلوباً (المتبقي: $remaining)'
                                  : 'حدد إجمالي أيام القضاء المطلوبة للبدء في تتبع الصيام',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.5,
                                color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF4C6A5E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      // Log Day Button
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogFastingDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.brightness_3_rounded, size: 20),
                          label: const Text(
                            'صمتُ يوماً اليوم 🌙 (+١ تسجيل)',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Edit Target
                      IconButton(
                        tooltip: 'تحديد إجمالي الأيام المطلوبة',
                        icon: const Icon(Icons.edit_calendar_rounded),
                        color: const Color(0xFF10B981),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : const Color(0xFFD1FAE5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                        ),
                        onPressed: () => _showEditTargetDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // History Header
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 18, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  'سجل الأيام التي تم قضاؤها (${history.length})',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF16382C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (history.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? FatimidColors.obsidianCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 40, color: isDark ? Colors.white30 : Colors.black26),
                    const SizedBox(height: 10),
                    Text(
                      'لم يتم تسجيل أي أيام قضاء بعد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'اضغط على "صمت يوماً اليوم" لتوثيق الأيام التي صمتها ونوعها',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...history.map((record) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? FatimidColors.obsidianCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: record.type.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: record.type.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(record.type.icon, color: record.type.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.type.title,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF16382C),
                                ),
                              ),
                              Text(
                                '${record.date.year}/${record.date.month.toString().padLeft(2, '0')}/${record.date.day.toString().padLeft(2, '0')}${record.note != null && record.note!.isNotEmpty ? ' • ${record.note}' : ''}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF5D756C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          color: Colors.redAccent.withValues(alpha: 0.7),
                          onPressed: () => controller.removeFastingRecord(record.id),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Fasting Rules Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F221B) : const Color(0xFFFAF8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_border_rounded, color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تنبيهات فقهية في قضاء الصيام',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF16382C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• قضاء رمضان واجب موسع حتى يدخل رمضان القابل، والأفضل والمستحب المبادرة بالقضاء إبراءً للذمة ونيل الأجر.\n• يجوز صيام القضاء متتابعاً أو متفرقاً كما تيسر للعبد لقوله تعالى: ﴿فَعِدَّةٌ مِّنْ أَيَّامٍ أُخَرَ﴾ ولم يشترط التتابع.\n• من أخّر القضاء حتى دخل رمضان التالي بلا عذر شرعي صام الحاضر وقضى ما عليه بعده مع إطعام مسكين عن كل يوم عند جمهور أهل العلم.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            height: 1.7,
                            color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF4C6A5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogFastingDialog(BuildContext context) {
    QadaaFastingType selectedType = QadaaFastingType.ramadan;
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: BoxDecoration(
              color: isDark ? FatimidColors.obsidianCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.brightness_3_rounded, color: Color(0xFF10B981), size: 24),
                    const SizedBox(width: 10),
                    const Text('تسجيل يوم صيام مقضي', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('اختر نوع الصيام الذي أتممته اليوم:', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 10),

                // Types chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: QadaaFastingType.values.map((type) {
                    final isSel = selectedType == type;
                    return ChoiceChip(
                      selected: isSel,
                      onSelected: (_) => setSheetState(() => selectedType = type),
                      avatar: Icon(type.icon, size: 16, color: isSel ? Colors.white : type.color),
                      label: Text(type.title),
                      labelStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF16382C)),
                      ),
                      selectedColor: type.color,
                      backgroundColor: isDark ? Colors.white10 : const Color(0xFFF3EFE0),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Note
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'ملاحظة اختيارية (مثلاً: يوم الإثنين أو الخميس)',
                    hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                    prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 18),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    controller.logFastingDay(
                      type: selectedType,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تقبل الله صيامك وطاعتك وجعلها في ميزان حسناتك 🤲', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    );
                  },
                  child: const Text('تأكيد تسجيل الصيام', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditTargetDialog(BuildContext context) {
    final ctrl = TextEditingController(text: controller.fastingTarget.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تحديد أيام الصيام المطلوبة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'كم يوماً واجباً عليك قضاؤه من رمضان أو الكفارات؟',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'عدد الأيام المطلوبة',
                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                suffixText: 'يوم',
                suffixStyle: const TextStyle(fontFamily: 'Cairo'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              final val = int.tryParse(ctrl.text.trim()) ?? controller.fastingTarget;
              controller.setFastingTarget(val);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
