import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/adhkar_controller.dart';
import '../domain/dhikr_models.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key, required this.controller});

  final AdhkarController controller;

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late Future<List<DhikrCategory>> _future;
  String? _selectedCategoryId;
  String _query = '';
  double _fontSize = 21.0;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.loadCategories();
  }

  IconData _categoryIcon(String id) {
    return switch (id) {
      'morning' => Icons.wb_sunny_rounded,
      'evening' => Icons.nights_stay_rounded,
      'after_prayer' => Icons.mosque_rounded,
      'sleep_wake' => Icons.bedtime_rounded,
      'tasbeeh_istighfar' => Icons.fingerprint_rounded,
      _ => Icons.auto_awesome,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            ZekrniHeader(
              title: 'الأذكار والتسبيح',
              subtitle: 'ورد يومي مبارك ومحفوظ بدون إنترنت',
              showSearch: true,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: FutureBuilder<List<DhikrCategory>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorStateView(message: snapshot.error.toString());
                  }
                  final categories = snapshot.data ?? const [];
                  if (categories.isEmpty) {
                    return const EmptyView(message: 'لا توجد أذكار محلية');
                  }
                  final selectedId = _selectedCategoryId ?? categories.first.id;
                  final currentCategory = categories.firstWhere(
                    (c) => c.id == selectedId,
                    orElse: () => categories.first,
                  );
                  final items = _filterItems(categories, selectedId);

                  final totalInCategory = currentCategory.items.length;
                  final completedInCategory = currentCategory.items
                      .where((item) => widget.controller.countFor(item.id) >= item.targetCount)
                      .length;
                  final categoryProgress = totalInCategory > 0
                      ? (completedInCategory / totalInCategory).clamp(0.0, 1.0)
                      : 0.0;

                  return Column(
                    children: [
                      const SizedBox(height: 14),

                      // شريط تبويبات تصنيفات الأذكار الفاطمي
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category.id == selectedId;
                            final catCompleted = category.items
                                .where((it) => widget.controller.countFor(it.id) >= it.targetCount)
                                .length;

                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => setState(
                                () => _selectedCategoryId = category.id,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? FatimidColors.goldGradient : null,
                                  color: isSelected
                                      ? null
                                      : (isDark ? FatimidColors.obsidianCard : Colors.white),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? FatimidColors.goldLight
                                        : FatimidColors.goldPrimary.withValues(
                                            alpha: isDark ? 0.25 : 0.2,
                                          ),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _categoryIcon(category.id),
                                      size: 16,
                                      color: isSelected
                                          ? const Color(0xFF332000)
                                          : (isDark
                                              ? const Color(0xFFA5C4B8)
                                              : const Color(0xFF375449)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.title,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        fontSize: 12.5,
                                        color: isSelected
                                            ? const Color(0xFF332000)
                                            : (isDark
                                                ? const Color(0xFFA5C4B8)
                                                : const Color(0xFF375449)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF332000).withValues(alpha: 0.15)
                                            : (isDark
                                                ? const Color(0xFF1E3A30)
                                                : const Color(0xFFE8F2ED)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$catCompleted/${category.items.length}',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF332000)
                                              : (isDark
                                                  ? const Color(0xFF7A998E)
                                                  : const Color(0xFF2A5949)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // لوحة إحصاءات الورد وأزرار التحكم بالخط وإعادة التعيين
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? FatimidColors.obsidianCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.2 : 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              // نسبة الإنجاز
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'المكتمل: $completedInCategory من $totalInCategory',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFFE8E5DF) : const Color(0xFF143026),
                                          ),
                                        ),
                                        if (completedInCategory == totalInCategory && totalInCategory > 0) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 14),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: categoryProgress,
                                        minHeight: 5,
                                        backgroundColor: isDark
                                            ? const Color(0xFF1B382D)
                                            : FatimidColors.goldPrimary.withValues(alpha: 0.15),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          completedInCategory == totalInCategory
                                              ? FatimidColors.goldPrimary
                                              : FatimidColors.emeraldMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // زر تصغير / تكبير الخط
                              IconButton(
                                tooltip: 'تصغير الخط',
                                icon: const Icon(Icons.text_decrease_rounded, size: 18),
                                color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF375449),
                                visualDensity: VisualDensity.compact,
                                onPressed: _fontSize > 17
                                    ? () => setState(() => _fontSize -= 2)
                                    : null,
                              ),
                              IconButton(
                                tooltip: 'تكبير الخط',
                                icon: const Icon(Icons.text_increase_rounded, size: 18),
                                color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF375449),
                                visualDensity: VisualDensity.compact,
                                onPressed: _fontSize < 28
                                    ? () => setState(() => _fontSize += 2)
                                    : null,
                              ),

                              // زر إعادة تعيين الورد الحالي
                              IconButton(
                                tooltip: 'إعادة تعيين ورد هذا القسم',
                                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                                color: FatimidColors.goldPrimary,
                                visualDensity: VisualDensity.compact,
                                onPressed: completedInCategory > 0
                                    ? () async {
                                        await widget.controller.resetAll(currentCategory.items);
                                        setState(() {});
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // قائمة بطاقات الأذكار
                      Expanded(
                        child: items.isEmpty
                            ? const EmptyView(message: 'لا توجد نتائج مطابقة للبحث')
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                                itemCount: items.length,
                                itemBuilder: (context, index) => _FatimidDhikrCard(
                                  item: items[index],
                                  fontSize: _fontSize,
                                  controller: widget.controller,
                                  onChanged: () => setState(() {}),
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

  List<DhikrItem> _filterItems(
    List<DhikrCategory> categories,
    String selectedCategoryId,
  ) {
    final selected = categories.firstWhere(
      (category) => category.id == selectedCategoryId,
      orElse: () => categories.first,
    );
    final query = _query.trim();
    if (query.isEmpty) {
      return selected.items;
    }
    return selected.items
        .where(
          (item) =>
              ArabicTextUtils.contains(item.title, query) ||
              ArabicTextUtils.contains(item.text, query),
        )
        .toList();
  }
}

/// بطاقة الذكر الفاطمية المزودة بسبحة دائرية مذهبة وزر تسبيح تفاعلي ودعم النقر على البطاقة بالكامل
class _FatimidDhikrCard extends StatelessWidget {
  const _FatimidDhikrCard({
    required this.item,
    required this.fontSize,
    required this.controller,
    required this.onChanged,
  });

  final DhikrItem item;
  final double fontSize;
  final AdhkarController controller;
  final VoidCallback onChanged;

  Future<void> _handleIncrement() async {
    HapticFeedback.lightImpact();
    await controller.increment(item);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final count = controller.countFor(item.id);
    final progress = (count / item.targetCount).clamp(0.0, 1.0);
    final isDone = count >= item.targetCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDone
              ? FatimidColors.goldPrimary
              : FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.28 : 0.2),
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? FatimidColors.goldPrimary.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: isDone ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isDone ? null : _handleIncrement,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان مع مؤشر الحالة وزر إعادة التعيين الفردي
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: isDone ? FatimidColors.goldPrimary : FatimidColors.emeraldMedium,
                        shape: BoxShape.circle,
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0D2B20),
                        ),
                      ),
                    ),
                    if (count > 0)
                      IconButton(
                        onPressed: () async {
                          await controller.reset(item.id);
                          onChanged();
                        },
                        icon: const Icon(Icons.restart_alt_rounded),
                        color: FatimidColors.goldPrimary,
                        tooltip: 'إعادة العداد',
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // نص الذكر الشريف
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1713) : const Color(0xFFFBF8F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDone
                          ? FatimidColors.goldPrimary.withValues(alpha: 0.3)
                          : FatimidColors.goldPrimary.withValues(alpha: 0.18),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: fontSize,
                      height: 1.85,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF9F5EC) : const Color(0xFF143026),
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                ),

                if (item.source != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          size: 14,
                          color: FatimidColors.goldPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.source!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF638378),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // شريط التقدم الفاطمي ومحور التسبيح
                Row(
                  children: [
                    // دائرة السبحة الفاطمية
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3.5,
                            backgroundColor: isDark
                                ? const Color(0xFF1B382D)
                                : FatimidColors.goldPrimary.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDone ? FatimidColors.goldPrimary : FatimidColors.emeraldMedium,
                            ),
                          ),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDone ? FatimidColors.goldPrimary : (isDark ? Colors.white : const Color(0xFF102820)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDone ? 'اكتمل الورد المبارك' : 'الهدف: ${item.targetCount} مرة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? FatimidColors.goldPrimary
                                : (isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F)),
                          ),
                        ),
                        Text(
                          '$count / ${item.targetCount}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: isDark ? const Color(0xFF7A998E) : const Color(0xFF869E96),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // زر التسبيح الفاطمي التفاعلي
                    InkWell(
                      onTap: isDone ? null : _handleIncrement,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isDone
                              ? null
                              : FatimidColors.emeraldGradient,
                          color: isDone
                              ? (isDark ? const Color(0xFF1E3A30) : const Color(0xFFE8F2ED))
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDone
                                ? FatimidColors.goldPrimary.withValues(alpha: 0.5)
                                : FatimidColors.goldPrimary,
                            width: 1.2,
                          ),
                          boxShadow: [
                            if (!isDone)
                              BoxShadow(
                                color: FatimidColors.emeraldPrimary.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDone ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                              size: 18,
                              color: isDone ? FatimidColors.goldPrimary : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDone ? 'تم الورد' : 'تسبيح',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDone ? FatimidColors.goldPrimary : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
