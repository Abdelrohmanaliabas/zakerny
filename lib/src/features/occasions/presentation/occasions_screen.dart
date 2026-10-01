import 'package:flutter/material.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../domain/occasion_models.dart';

class OccasionsScreen extends StatefulWidget {
  const OccasionsScreen({super.key});

  @override
  State<OccasionsScreen> createState() => _OccasionsScreenState();
}

class _OccasionsScreenState extends State<OccasionsScreen> {
  OccasionCategory _selectedCategory = OccasionCategory.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items
    var items = OccasionsData.allOccasions.where((item) {
      if (_selectedCategory == OccasionCategory.islamic &&
          item.category != OccasionCategory.islamic) {
        return false;
      }
      if (_selectedCategory == OccasionCategory.officialHoliday &&
          !item.isOfficialHoliday) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.virtues.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    // Sort by remaining days
    items.sort((a, b) => a.estimatedDaysRemaining.compareTo(b.estimatedDaysRemaining));

    final nearest = OccasionsData.allOccasions
        .reduce((a, b) => a.estimatedDaysRemaining < b.estimatedDaysRemaining ? a : b);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ZekrniHeader(
              title: 'المناسبات والإجازات',
              subtitle: 'المواسم الدينية والعطلات الرسمية',
              showSearch: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. بطاقة أقرب مناسبة قادمة (Hero Banner)
                  _buildNearestHero(nearest, isDark),
                  const SizedBox(height: 16),

                  // 2. شريط البحث
                  _buildSearchBar(isDark),
                  const SizedBox(height: 12),

                  // 3. أزرار التصفية (Filter Chips)
                  _buildFilterChips(isDark),
                  const SizedBox(height: 16),

                  // 4. قائمة المناسبات
                  if (items.isEmpty)
                    _buildEmptyState(isDark)
                  else
                    ...items.map((item) => _buildOccasionCard(item, isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة أقرب مناسبة قادمة مع عداد الأيام
  Widget _buildNearestHero(OccasionItem item, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F2C22),
            const Color(0xFF1B4332),
            FatimidColors.goldPrimary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: FatimidColors.goldPrimary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: FatimidColors.goldPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFF0F2C22)),
                    SizedBox(width: 4),
                    Text(
                      'أقرب مناسبة قادمة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: Color(0xFF0F2C22),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FatimidColors.goldPrimary.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'متبقي ${ArabicTextUtils.toArabicDigits(item.estimatedDaysRemaining)} يوم',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            item.title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFFDE047)),
              const SizedBox(width: 6),
              Text(
                '${item.hijriDate} • ${item.gregorianDate}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFDE047),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E19) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1F3327) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(
          fontFamily: 'Cairo',
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن مناسبة، عيد، أو إجازة رسمية...',
          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: FatimidColors.goldPrimary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      _FilterOption(OccasionCategory.all, 'الكل'),
      _FilterOption(OccasionCategory.islamic, 'مناسبات إسلامية'),
      _FilterOption(OccasionCategory.officialHoliday, 'إجازات رسمية'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedCategory == f.category;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = f.category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? FatimidColors.goldGradient : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF141E19) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? FatimidColors.goldPrimary
                        : (isDark ? const Color(0xFF263A2D) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF0F2C22)
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOccasionCard(OccasionItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FatimidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.category == OccasionCategory.islamic
                        ? const Color(0xFF059669).withValues(alpha: 0.15)
                        : const Color(0xFFD97706).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.category == OccasionCategory.islamic
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.category == OccasionCategory.islamic
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF0F2C22),
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Days Remaining Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FatimidColors.goldPrimary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'بعد ${ArabicTextUtils.toArabicDigits(item.estimatedDaysRemaining)} يوم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: FatimidColors.goldPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Date & Holiday Row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildTag(
                  icon: Icons.nightlight_outlined,
                  text: item.hijriDate,
                  color: const Color(0xFF059669),
                ),
                _buildTag(
                  icon: Icons.wb_sunny_outlined,
                  text: item.gregorianDate,
                  color: const Color(0xFF3B82F6),
                ),
                if (item.isOfficialHoliday)
                  _buildTag(
                    icon: Icons.check_circle_outline_rounded,
                    text: item.holidayDuration ?? 'إجازة رسمية',
                    color: const Color(0xFFD97706),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Virtues & Sunnahs Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1510) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF1B281E) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: Color(0xFFEAB308),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.virtues,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        height: 1.5,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
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

  Widget _buildTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'لا توجد مناسبات مطابقة لبحثك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption {
  final OccasionCategory category;
  final String label;

  _FilterOption(this.category, this.label);
}
