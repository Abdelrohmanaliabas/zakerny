import 'package:flutter/material.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/lectures_controller.dart';
import '../domain/lecture_models.dart';
import 'widgets/lecture_card.dart';
import 'widgets/lecture_mini_player.dart';
import 'widgets/series_detail_view.dart';
import 'widgets/sheikh_chip_bar.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({
    super.key,
    required this.controller,
  });

  final LecturesController controller;

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      widget.controller.setSearchQuery(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final lectures = widget.controller.filteredLectures;
            final isSeriesTab = widget.controller.selectedCategory ==
                    LectureCategory.series &&
                widget.controller.searchQuery.isEmpty;
            final downloadsCount = widget.controller.allLectures
                .where((l) => widget.controller.isDownloaded(l.id))
                .length;

            return Column(
              children: [
                // Header
                ZekrniHeader(
                  title: 'الخطب والدروس',
                  subtitle:
                      'موسوعة الخطب والمواعظ والسلاسل العلمية لكبار الشيوخ',
                  showSearch: false,
                ),

                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? FatimidColors.obsidianCard.withValues(alpha: 0.9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            FatimidColors.goldPrimary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'ابحث عن درس، خطبة، سلسلة، أو اسم الشيخ (مثال: مصطفى سمير)...',
                        hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: FatimidColors.goldPrimary,
                          size: 22,
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  widget.controller.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quick Statistics Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF0F2C22), Color(0xFF061A14)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
                            ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'الدروس والخطب',
                          value: '${widget.controller.allLectures.length}',
                          icon: Icons.headphones_rounded,
                        ),
                        _StatDivider(isDark: isDark),
                        _StatItem(
                          label: 'السلاسل',
                          value: '${widget.controller.allSeries.length}',
                          icon: Icons.auto_stories_rounded,
                        ),
                        _StatDivider(isDark: isDark),
                        _StatItem(
                          label: 'كبار الشيوخ',
                          value: '${widget.controller.allSheikhs.length}',
                          icon: Icons.people_alt_rounded,
                        ),
                        _StatDivider(isDark: isDark),
                        _StatItem(
                          label: 'المحملة أوفلاين',
                          value: '$downloadsCount',
                          icon: Icons.download_done_rounded,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sheikh Filter Bar
                SheikhChipBar(controller: widget.controller),
                const SizedBox(height: 10),

                // Category Chips Filter
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: LectureCategory.values.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = LectureCategory.values[index];
                      final isSelected =
                          widget.controller.selectedCategory == cat;

                      return ChoiceChip(
                        label: Text(
                          cat.label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF261800)
                                : (isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF475569)),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: FatimidColors.goldLight,
                        backgroundColor: isDark
                            ? FatimidColors.obsidianCard
                            : const Color(0xFFF1F5F9),
                        side: BorderSide(
                          color: isSelected
                              ? FatimidColors.goldPrimary
                              : (isDark
                                  ? Colors.white12
                                  : const Color(0xFFE2E8F0)),
                        ),
                        onSelected: (_) =>
                            widget.controller.selectCategory(cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Active Filter Summary (if any)
                if (widget.controller.selectedSheikhId != null ||
                    widget.controller.searchQuery.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'نتائج التصفية (${lectures.length} درس)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: FatimidColors.goldPrimary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: widget.controller.resetFilters,
                          child: const Text(
                            'إلغاء التصفية ✕',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Content List: Series or Lectures
                Expanded(
                  child: isSeriesTab
                      ? _buildSeriesGrid(context, isDark)
                      : _buildLecturesList(lectures, isDark),
                ),

                // Docked Mini Player
                LectureMiniPlayer(controller: widget.controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeriesGrid(BuildContext context, bool isDark) {
    final seriesList = widget.controller.selectedSheikhId != null
        ? widget.controller.getSeriesForSheikh(widget.controller.selectedSheikhId!)
        : widget.controller.allSeries;

    if (seriesList.isEmpty) {
      return _buildEmptyState(
        'لا توجد سلاسل مطابقة لهذا الشيخ حالياً',
        Icons.auto_stories_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: seriesList.length,
      itemBuilder: (context, index) {
        final series = seriesList[index];
        final episodes = widget.controller.getLecturesForSeries(series.id);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? FatimidColors.obsidianCard.withValues(alpha: 0.9)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () =>
                  SeriesDetailView.show(context, series, widget.controller),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: FatimidColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: FatimidColors.goldPrimary
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF261800),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  series.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F2C22),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: FatimidColors.goldPrimary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${episodes.length} حلقة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: FatimidColors.goldPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            series.sheikhName,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: FatimidColors.goldPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            series.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLecturesList(List<LectureItem> lectures, bool isDark) {
    if (lectures.isEmpty) {
      if (widget.controller.selectedCategory == LectureCategory.downloaded ||
          widget.controller.onlyDownloaded) {
        return _buildEmptyState(
          'لا توجد دروس محملة في الذاكرة المحلية حالياً.\nيمكنك الضغط على أيقونة التنزيل بجانب أي درس للاستماع إليه بدون إنترنت!',
          Icons.cloud_download_outlined,
        );
      }
      return _buildEmptyState(
        'لم يتم العثور على نتائج تطابق بحثك',
        Icons.search_off_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        return LectureCard(
          lecture: lectures[index],
          controller: widget.controller,
        );
      },
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: FatimidColors.goldPrimary),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FatimidColors.goldPrimary,
                foregroundColor: const Color(0xFF261800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.controller.resetFilters,
              child: const Text(
                'عرض كافة الدروس',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? FatimidColors.goldPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: effectiveColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: effectiveColor,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
    );
  }
}
