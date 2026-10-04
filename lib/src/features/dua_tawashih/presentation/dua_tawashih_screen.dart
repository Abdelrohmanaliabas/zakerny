import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/dua_tawashih_controller.dart';
import '../data/duas_data.dart';
import '../data/tawashih_data.dart';
import '../domain/dua_models.dart';
import '../domain/ruqyah_models.dart';
import '../domain/tawashih_models.dart';

class DuaTawashihScreen extends StatefulWidget {
  const DuaTawashihScreen({
    super.key,
    required this.controller,
    this.initialTab = 0,
  });

  final DuaTawashihController controller;
  final int initialTab;

  @override
  State<DuaTawashihScreen> createState() => _DuaTawashihScreenState();
}

class _DuaTawashihScreenState extends State<DuaTawashihScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription? _playerSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    widget.controller.addListener(_onControllerUpdate);
    _playerSub = widget.controller.recitationService.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    _tabController.dispose();
    super.dispose();
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
              title: 'الأدعية والرقية والتواشيح',
              subtitle: 'موسوعة الأدعية المأثورة والرقية الشرعية ونفحات التواشيح',
              showSearch: false,
            ),

            // Tab bar with Fatimid Golden Styling
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.menu_book_rounded, size: 19),
                    text: 'الأدعية المأثورة',
                  ),
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.health_and_safety_rounded, size: 19),
                    text: 'الرقية الشرعية',
                  ),
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.headphones_rounded, size: 19),
                    text: 'التواشيح والابتهالات',
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DuasTabView(controller: widget.controller),
                  _RuqyahTabView(controller: widget.controller),
                  _TawashihTabView(controller: widget.controller),
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
// 1. قسم الأدعية المأثورة والجامعة
// ============================================================================
class _DuasTabView extends StatelessWidget {
  const _DuasTabView({required this.controller});

  final DuaTawashihController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = controller.filteredDuas;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            // Search & Favorites Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? FatimidColors.obsidianCard.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      onChanged: controller.setDuaQuery,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث في الأدعية ومصادرها وفضائلها...',
                        hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: FatimidColors.goldPrimary,
                          size: 20,
                        ),
                        suffixIcon: controller.duaQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => controller.setDuaQuery(''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite filter button
                InkWell(
                  onTap: controller.toggleOnlyFavoriteDuas,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: controller.onlyFavoriteDuas ? FatimidColors.goldGradient : null,
                      color: controller.onlyFavoriteDuas
                          ? null
                          : (isDark ? FatimidColors.obsidianCard : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(
                          alpha: controller.onlyFavoriteDuas ? 0.8 : 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.onlyFavoriteDuas
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: controller.onlyFavoriteDuas
                              ? const Color(0xFF261800)
                              : Colors.redAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'المفضلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: controller.onlyFavoriteDuas
                                ? const Color(0xFF261800)
                                : (isDark ? Colors.white70 : const Color(0xFF1E3A2F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'الكل (${DuasData.allDuas.length})',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: controller.selectedCategory == null,
                    onTap: () => controller.selectCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...DuaCategoryType.values.map((cat) {
                    final isSel = controller.selectedCategory == cat;
                    final count = DuasData.allDuas.where((d) => d.category == cat).length;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: '${cat.title} ($count)',
                        icon: cat.icon,
                        isSelected: isSel,
                        onTap: () => controller.selectCategory(isSel ? null : cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of Duas
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.onlyFavoriteDuas
                            ? 'لا توجد أدعية في المفضلة حالياً'
                            : 'لا توجد نتائج مطابقة لبحثك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : const Color(0xFF2A4A3E),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _DuaCard(
                    dua: items[index],
                    controller: controller,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? FatimidColors.goldGradient : null,
          color: isSelected
              ? null
              : (isDark
                  ? FatimidColors.obsidianCard.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FatimidColors.goldPrimary.withValues(alpha: isSelected ? 0.8 : 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFF261800)
                  : (isDark ? FatimidColors.goldLight : FatimidColors.emeraldPrimary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF261800)
                    : (isDark ? Colors.white : const Color(0xFF1E3A2F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  const _DuaCard({
    required this.dua,
    required this.controller,
  });

  final DuaItem dua;
  final DuaTawashihController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = controller.isDuaFavorite(dua.id);
    final count = controller.getDuaCount(dua.id);
    final isCompleted = dua.targetRepeat > 1 && count >= dua.targetRepeat;

    return FatimidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Badge + Title + Favorite Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      dua.category.icon,
                      size: 13,
                      color: FatimidColors.goldPrimary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      dua.category.title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: FatimidColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Favorite button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : Colors.grey,
                  size: 22,
                ),
                onPressed: () => controller.toggleDuaFavorite(dua.id),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            dua.title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? FatimidColors.goldLight : const Color(0xFF0F3225),
            ),
          ),
          const SizedBox(height: 12),

          // Dua Arabic Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0B1B15).withValues(alpha: 0.6)
                  : const Color(0xFFF9F7EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              dua.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 21,
                height: 1.95,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF143026),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Source and Reference
          Row(
            children: [
              const Icon(
                Icons.bookmark_added_outlined,
                size: 14,
                color: FatimidColors.goldPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dua.source,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : const Color(0xFF4C665C),
                  ),
                ),
              ),
            ],
          ),

          // Virtue (الفضل) if available
          if (dua.virtue != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? FatimidColors.emeraldDark.withValues(alpha: 0.3)
                    : FatimidColors.emeraldPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FatimidColors.emeraldPrimary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 13,
                    color: FatimidColors.goldPrimary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dua.virtue!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFC7DFD6) : const Color(0xFF1D4A3A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Bottom Action Row (Counter + Copy + Share + Open Card Designer)
          Row(
            children: [
              // Repeat / Counter Button
              if (dua.targetRepeat > 1) ...[
                InkWell(
                  onTap: () => controller.incrementDuaCount(dua.id),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isCompleted ? FatimidColors.goldGradient : null,
                      color: isCompleted
                          ? null
                          : (isDark
                              ? FatimidColors.obsidianCard
                              : FatimidColors.goldPrimary.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                          size: 16,
                          color: isCompleted ? const Color(0xFF261800) : FatimidColors.goldPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تكرار: $count / ${dua.targetRepeat}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? const Color(0xFF261800)
                                : (isDark ? Colors.white : const Color(0xFF19382C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (count > 0)
                  IconButton(
                    iconSize: 18,
                    tooltip: 'تصفير العداد',
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () => controller.resetDuaCount(dua.id),
                  ),
                const Spacer(),
              ] else
                const Spacer(),

              // Copy Button
              IconButton(
                tooltip: 'نسخ الدعاء',
                icon: const Icon(Icons.copy_rounded, size: 19),
                color: isDark ? Colors.white70 : const Color(0xFF335547),
                onPressed: () {
                  final formatted = '${dua.title}\n\n${dua.text}\n\n[المصدر: ${dua.source}]\n— تطبيق ذكرني';
                  Clipboard.setData(ClipboardData(text: formatted));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: isDark ? const Color(0xFF122820) : const Color(0xFF0F3628),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: FatimidColors.goldPrimary, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'تم نسخ الدعاء إلى الحافظة بنجاح',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Share Button
              IconButton(
                tooltip: 'مشاركة الدعاء',
                icon: const Icon(Icons.share_rounded, size: 19),
                color: isDark ? Colors.white70 : const Color(0xFF335547),
                onPressed: () async {
                  final formatted = '${dua.title}\n\n${dua.text}\n\n[المصدر: ${dua.source}]\n— تطبيق ذكرني';
                  // ignore: deprecated_member_use
                  await Share.share(formatted, subject: dua.title);
                },
              ),

              // Design Card (صانع البطاقات)
              IconButton(
                tooltip: 'تصميم بطاقة دعاء إسلامية',
                icon: const Icon(Icons.palette_outlined, size: 20),
                color: FatimidColors.goldPrimary,
                onPressed: () {
                  context.push(
                    '/card-designer',
                    extra: {
                      'text': dua.text,
                      'reference': dua.source,
                      'isQuran': dua.category == DuaCategoryType.quranic,
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. قسم التواشيح والابتهالات الدينية
// ============================================================================
class _TawashihTabView extends StatelessWidget {
  const _TawashihTabView({required this.controller});

  final DuaTawashihController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = controller.filteredTawashih;
    final munshidin = controller.munshidin;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? FatimidColors.obsidianCard.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: controller.setTawashihQuery,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن ابتهال أو منشد أو كلمات قصيدة...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: FatimidColors.goldPrimary,
                    size: 20,
                  ),
                  suffixIcon: controller.tawashihQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => controller.setTawashihQuery(''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Munshidin Selector Horizontal List
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'كل المبتهلين (${TawashihData.allTawashih.length})',
                    icon: Icons.groups_rounded,
                    isSelected: controller.selectedMunshidId == null,
                    onTap: () => controller.selectMunshid(null),
                  ),
                  const SizedBox(width: 8),
                  ...munshidin.map((m) {
                    final isSel = controller.selectedMunshidId == m.id;
                    final count = TawashihData.allTawashih.where((t) => t.munshidId == m.id).length;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: '${m.name} ($count)',
                        icon: Icons.mic_external_on_rounded,
                        isSelected: isSel,
                        onTap: () => controller.selectMunshid(isSel ? null : m.id),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Munshid Bio Header if a single Munshid is selected
            if (controller.selectedMunshidId != null) ...[
              _MunshidBioBanner(
                munshid: munshidin.firstWhere((m) => m.id == controller.selectedMunshidId),
              ),
              const SizedBox(height: 16),
            ],

            // List of Tawashih
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_off_rounded,
                        size: 48,
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد ابتهالات مطابقة للبحث',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : const Color(0xFF2A4A3E),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _TawashihCard(
                    item: items[index],
                    controller: controller,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MunshidBioBanner extends StatelessWidget {
  const _MunshidBioBanner({required this.munshid});

  final Munshid munshid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? FatimidColors.emeraldDark.withValues(alpha: 0.4)
            : FatimidColors.emeraldPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: FatimidColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mic_rounded, color: Color(0xFF2E1C00), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      munshid.name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F3225),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        munshid.epithet,
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
                const SizedBox(height: 4),
                Text(
                  munshid.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    height: 1.4,
                    color: isDark ? Colors.white70 : const Color(0xFF38574B),
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

class _TawashihCard extends StatelessWidget {
  const _TawashihCard({
    required this.item,
    required this.controller,
  });

  final TawashihItem item;
  final DuaTawashihController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = controller.isTawashihPlaying(item.id);
    final isActive = controller.isTawashihActive(item.id);
    final isFav = controller.isTawashihFavorite(item.id);

    return FatimidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: FatimidColors.goldPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isPlaying ? 'يعمل الآن 🎶' : 'متوقف مؤقتاً ⏸️',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: FatimidColors.goldPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Play / Pause Circle
              InkWell(
                onTap: () => controller.pauseOrResume(item),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isPlaying ? FatimidColors.goldGradient : null,
                    color: isPlaying
                        ? null
                        : (isDark
                            ? FatimidColors.obsidianCard
                            : FatimidColors.emeraldPrimary.withValues(alpha: 0.1)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FatimidColors.goldPrimary.withValues(alpha: isPlaying ? 0.9 : 0.4),
                      width: 1.5,
                    ),
                    boxShadow: isPlaying
                        ? [
                            BoxShadow(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isPlaying ? const Color(0xFF261800) : FatimidColors.goldPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Munshid Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: isPlaying
                            ? FatimidColors.goldPrimary
                            : (isDark ? Colors.white : const Color(0xFF103024)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          item.munshidName,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF9FBDB2) : const Color(0xFF4A685D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${item.durationText}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : Colors.grey,
                  size: 20,
                ),
                onPressed: () => controller.toggleTawashihFavorite(item.id),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges: Theme + Maqam
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? FatimidColors.obsidianCard
                      : FatimidColors.emeraldPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.label_outline, size: 12, color: FatimidColors.goldPrimary),
                    const SizedBox(width: 4),
                    Text(
                      item.theme,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: isDark ? Colors.white70 : const Color(0xFF2C4E40),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.maqam != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note_rounded, size: 12, color: FatimidColors.goldPrimary),
                      const SizedBox(width: 4),
                      Text(
                        item.maqam!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Lyrics Preview Snippet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0C1914).withValues(alpha: 0.6)
                  : const Color(0xFFF9F7F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              item.lyrics.split('\n\n').first,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16.5,
                height: 1.8,
                color: isDark ? const Color(0xFFE2EBE7) : const Color(0xFF234438),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Action Buttons: "قراءة الكلمات كاملة" + Share + Copy
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  backgroundColor: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.article_outlined, size: 16, color: FatimidColors.goldPrimary),
                label: const Text(
                  'قراءة الكلمات كاملة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: FatimidColors.goldPrimary,
                  ),
                ),
                onPressed: () {
                  _showLyricsModal(context, item, isDark);
                },
              ),
              const Spacer(),
              IconButton(
                tooltip: 'نسخ الكلمات',
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: isDark ? Colors.white60 : const Color(0xFF4C6A5E),
                onPressed: () {
                  final text = '«${item.title}» - ${item.munshidName}\n\n${item.lyrics}\n\n— تطبيق ذكرني';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ كلمات التواشيح إلى الحافظة', style: TextStyle(fontFamily: 'Cairo')),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'مشاركة الابتهال',
                icon: const Icon(Icons.share_rounded, size: 18),
                color: isDark ? Colors.white60 : const Color(0xFF4C6A5E),
                onPressed: () async {
                  final text = '«${item.title}»\nبصوت: ${item.munshidName}\n\n${item.lyrics}\n\nاستمع الآن عبر تطبيق ذكرني';
                  // ignore: deprecated_member_use
                  await Share.share(text, subject: item.title);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLyricsModal(BuildContext context, TawashihItem item, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1E19) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Grab handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? FatimidColors.goldLight : const Color(0xFF103024),
                            ),
                          ),
                          Text(
                            '${item.munshidName} • ${item.theme}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF55776A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),

              // Full Lyrics
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0B1713).withValues(alpha: 0.7)
                            : const Color(0xFFF9F7EE),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.lyrics,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          height: 2.1,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF16382C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// 3. قسم الرقية الشرعية الشاملة (قرآن وسنة وتسجيلات صوتية)
// ============================================================================
class _RuqyahTabView extends StatelessWidget {
  const _RuqyahTabView({required this.controller});

  final DuaTawashihController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = controller.filteredRuqyahItems;
    final audios = controller.ruqyahAudios;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Welcome & Explanatory Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isDark
                          ? [
                              const Color(0xFF143026),
                              FatimidColors.obsidianCard,
                            ]
                          : [
                              const Color(0xFFE8F2EC),
                              const Color(0xFFF9F7EE),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: FatimidColors.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          size: 28,
                          color: Color(0xFF261800),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الرقية الشرعية من الكتاب والسنة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF16382C),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'حصن المسلم والشفاء التام من العين والحسد والمس والسحر والأوجاع بركة وتوكلاً',
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
                ),
              ),
            ),

            // Ruqyah Audio Streams Section (كبار القراء)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up_rounded, size: 18, color: FatimidColors.goldPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'استماع للرقية الشرعية كاملة (تلاوات خاشعة)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF16382C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 122,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: audios.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final audio = audios[index];
                          return _RuqyahAudioCard(
                            audio: audio,
                            controller: controller,
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? FatimidColors.obsidianCard.withValues(alpha: 0.7)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    onChanged: controller.setRuqyahQuery,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'ابحث في آيات وأدعية الرقية الشرعية...',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: FatimidColors.goldPrimary),
                      suffixIcon: controller.ruqyahQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => controller.setRuqyahQuery(''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
            ),

            // Section Filter Chips (الكل، القرآن، السنة، الإرشادات)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: RuqyahSection.values.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final section = RuqyahSection.values[index];
                    final isSelected = controller.selectedRuqyahSection == section;

                    return ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) => controller.selectRuqyahSection(section),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            section.icon,
                            size: 15,
                            color: isSelected
                                ? const Color(0xFF261800)
                                : (isDark ? const Color(0xFF90A49C) : const Color(0xFF4C6A5E)),
                          ),
                          const SizedBox(width: 6),
                          Text(section.title),
                        ],
                      ),
                      labelStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF261800)
                            : (isDark ? Colors.white70 : const Color(0xFF2C483D)),
                      ),
                      selectedColor: FatimidColors.goldPrimary,
                      backgroundColor: isDark
                          ? FatimidColors.obsidianCard.withValues(alpha: 0.6)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? FatimidColors.goldPrimary
                              : (isDark
                                  ? Colors.white12
                                  : FatimidColors.goldPrimary.withValues(alpha: 0.2)),
                          width: 1,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),

            // Purpose Filter Chips (العلل: العين، السحر، الشفاء، الأطفال)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: RuqyahPurpose.values.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final purpose = RuqyahPurpose.values[index];
                      final isSelected = controller.selectedRuqyahPurpose == purpose;

                      return ActionChip(
                        onPressed: () => controller.selectRuqyahPurpose(purpose),
                        backgroundColor: isSelected
                            ? (isDark
                                ? FatimidColors.emeraldDark
                                : const Color(0xFFD4E8DD))
                            : (isDark
                                ? FatimidColors.obsidianCard.withValues(alpha: 0.4)
                                : const Color(0xFFF3EFE0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? FatimidColors.goldPrimary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        label: Text(
                          purpose.title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? Colors.white : const Color(0xFF0F3628))
                                : (isDark ? Colors.white60 : const Color(0xFF4C6A5E)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Items Count Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'المعروض: ${items.length} من نصوص وإرشادات الرقية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF5D756C),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content List
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد نتائج مطابقة لبحثك في الرقية الشرعية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RuqyahItemCard(
                          item: item,
                          controller: controller,
                          isDark: isDark,
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// بطاقة الرقية الشرعية الصوتية (Audio Card)
// ============================================================================
class _RuqyahAudioCard extends StatelessWidget {
  const _RuqyahAudioCard({
    required this.audio,
    required this.controller,
    required this.isDark,
  });

  final RuqyahAudioItem audio;
  final DuaTawashihController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.isRuqyahAudioPlaying(audio.id);
    final isActive = controller.isRuqyahAudioActive(audio.id);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? FatimidColors.goldPrimary
              : (isDark
                  ? Colors.white12
                  : FatimidColors.goldPrimary.withValues(alpha: 0.25)),
          width: isActive ? 1.5 : 1,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: isActive ? FatimidColors.goldGradient : null,
                  color: isActive
                      ? null
                      : (isDark
                          ? const Color(0xFF143026)
                          : const Color(0xFFE8F2EC)),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 22,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: isActive
                        ? const Color(0xFF261800)
                        : (isDark ? FatimidColors.goldPrimary : const Color(0xFF0F3628)),
                  ),
                  onPressed: () => controller.pauseOrResumeRuqyah(audio),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audio.reciterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF16382C),
                      ),
                    ),
                    Text(
                      audio.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF4C6A5E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black38 : const Color(0xFFF3EFE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF5D756C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      audio.duration,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF2C483D),
                      ),
                    ),
                  ],
                ),
              ),
              if (isPlaying)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'جاري التشغيل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// بطاقة نص الرقية الشرعية الفاطمية التفاعلية
// ============================================================================
class _RuqyahItemCard extends StatelessWidget {
  const _RuqyahItemCard({
    required this.item,
    required this.controller,
    required this.isDark,
  });

  final RuqyahItem item;
  final DuaTawashihController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final count = controller.getRuqyahCount(item.id);
    final isCompleted = item.targetRepeat > 1 && count >= item.targetRepeat;

    Color badgeColor;
    String badgeText;
    if (item.section == RuqyahSection.quran) {
      badgeColor = const Color(0xFF1B6B4D);
      badgeText = 'آيات من القرآن الكريم';
    } else if (item.section == RuqyahSection.sunnah) {
      badgeColor = const Color(0xFFB58428);
      badgeText = 'دعاء من السنة النبوية';
    } else {
      badgeColor = const Color(0xFF33557A);
      badgeText = 'إرشاد وضوابط الرقية';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.6)
              : FatimidColors.goldPrimary.withValues(alpha: 0.35),
          width: isCompleted ? 1.5 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badges & Purpose
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : badgeColor,
                  ),
                ),
              ),
              if (item.purpose != RuqyahPurpose.all)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black45 : const Color(0xFFF3EFE0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.purpose.title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFADC4BA) : const Color(0xFF4C6A5E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF16382C),
            ),
          ),
          const SizedBox(height: 12),

          // Arabic Text container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F221B).withValues(alpha: 0.7)
                  : const Color(0xFFFAF8F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              item.arabicText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: item.section == RuqyahSection.guidance ? 'Cairo' : 'Amiri',
                fontSize: item.section == RuqyahSection.guidance ? 14.5 : 20.5,
                height: item.section == RuqyahSection.guidance ? 1.8 : 2.0,
                fontWeight: item.section == RuqyahSection.guidance ? FontWeight.w600 : FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF16382C),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Source
          Text(
            'المصدر: ${item.source}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8BA59B) : const Color(0xFF5D756C),
            ),
          ),

          // Practical Instructions
          if (item.instructions != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B382D).withValues(alpha: 0.5)
                    : const Color(0xFFE9F5EF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF267D5B).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 16,
                    color: Color(0xFF267D5B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'كيفية العمل: ${item.instructions}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFC7E6D7) : const Color(0xFF1A583E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Benefit / Virtue
          if (item.benefit != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? FatimidColors.goldPrimary.withValues(alpha: 0.1)
                    : const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: FatimidColors.goldPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الفضل والأثر: ${item.benefit}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: isDark ? const Color(0xFFE6D6B0) : const Color(0xFF6B5115),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Bottom Action Controls
          Row(
            children: [
              // Repeat / Counter Button
              if (item.targetRepeat > 1) ...[
                InkWell(
                  onTap: () => controller.incrementRuqyahCount(item.id),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isCompleted ? FatimidColors.goldGradient : null,
                      color: isCompleted
                          ? null
                          : (isDark
                              ? FatimidColors.obsidianCard
                              : FatimidColors.goldPrimary.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                          size: 16,
                          color: isCompleted ? const Color(0xFF261800) : FatimidColors.goldPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تكرار: $count / ${item.targetRepeat}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? const Color(0xFF261800)
                                : (isDark ? Colors.white : const Color(0xFF19382C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (count > 0)
                  IconButton(
                    iconSize: 18,
                    tooltip: 'تصفير العداد',
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () => controller.resetRuqyahCount(item.id),
                  ),
                const Spacer(),
              ] else
                const Spacer(),

              // Copy Button
              IconButton(
                tooltip: 'نسخ النص',
                icon: const Icon(Icons.copy_rounded, size: 19),
                color: isDark ? Colors.white70 : const Color(0xFF335547),
                onPressed: () {
                  final formatted = '${item.title}\n\n${item.arabicText}\n\n[المصدر: ${item.source}]\n— تطبيق ذكرني';
                  Clipboard.setData(ClipboardData(text: formatted));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: isDark ? const Color(0xFF122820) : const Color(0xFF0F3628),
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: FatimidColors.goldPrimary, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'تم نسخ نص الرقية إلى الحافظة بنجاح',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Share Button
              IconButton(
                tooltip: 'مشاركة الرقية',
                icon: const Icon(Icons.share_rounded, size: 19),
                color: isDark ? Colors.white70 : const Color(0xFF335547),
                onPressed: () async {
                  final formatted = '«${item.title}»\n\n${item.arabicText}\n\nالمصدر: ${item.source}\n${item.instructions != null ? 'كيفية الرقية: ${item.instructions}\n' : ''}— تمت المشاركة عبر تطبيق ذكرني';
                  // ignore: deprecated_member_use
                  await Share.share(formatted, subject: item.title);
                },
              ),

              // Design Card (صانع البطاقات)
              if (item.section != RuqyahSection.guidance)
                IconButton(
                  tooltip: 'تصميم بطاقة رقية شريفة',
                  icon: const Icon(Icons.palette_outlined, size: 20),
                  color: FatimidColors.goldPrimary,
                  onPressed: () {
                    context.push(
                      '/card-designer',
                      extra: {
                        'text': item.arabicText,
                        'reference': item.source,
                        'isQuran': item.section == RuqyahSection.quran,
                      },
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

