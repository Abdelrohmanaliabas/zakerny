import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/quran_controller.dart';
import '../domain/quran_models.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key, required this.controller});

  final QuranController controller;

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _query = '';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FutureBuilder<List<Surah>>(
          future: widget.controller.loadSurahs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ErrorStateView(message: snapshot.error.toString());
            }
            final allSurahs = snapshot.data ?? const [];
            final cleanQuery = _query.trim();
            final surahs = allSurahs
                .where((surah) =>
                    cleanQuery.isEmpty ||
                    ArabicTextUtils.contains(surah.name, cleanQuery) ||
                    (surah.englishName?.toLowerCase().contains(cleanQuery.toLowerCase()) ?? false) ||
                    surah.id.toString() == cleanQuery)
                .toList();

            return Column(
              children: [
                ZekrniHeader(
                  title: 'المصحف الشريف',
                  subtitle: 'المصحف الكامل • ${allSurahs.length} سورة كريمة',
                  showSearch: true,
                  onSearchChanged: (value) => setState(() => _query = value),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FatimidTabPill(
                          label: 'السور',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                      ),
                      Expanded(
                        child: _FatimidTabPill(
                          label: 'الأجزاء',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ),
                      Expanded(
                        child: _FatimidTabPill(
                          label: 'الأحزاب',
                          selected: _tab == 2,
                          onTap: () => setState(() => _tab = 2),
                        ),
                      ),
                      Expanded(
                        child: _FatimidTabPill(
                          label: 'الصفحات',
                          selected: _tab == 3,
                          onTap: () => setState(() => _tab = 3),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (_tab) {
                    0 => _SurahList(surahs: surahs),
                    1 => _NumberGrid(
                        surahs: allSurahs,
                        count: 30,
                        label: 'جزء',
                        type: _QuranIndexType.juz,
                      ),
                    2 => _NumberGrid(
                        surahs: allSurahs,
                        count: 60,
                        label: 'حزب',
                        type: _QuranIndexType.hizb,
                      ),
                    _ => _NumberGrid(
                        surahs: allSurahs,
                        count: 604,
                        label: 'صفحة',
                        type: _QuranIndexType.page,
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final last = widget.controller.lastRead();
          if (last == null) {
            return const SizedBox.shrink();
          }
          return Container(
            decoration: BoxDecoration(
              gradient: FatimidColors.goldGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              foregroundColor: const Color(0xFF332000),
              onPressed: () => context.push('/quran/surah/${last.surahId}'),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text(
                'متابعة: ${last.surahName}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList({required this.surahs});

  final List<Surah> surahs;

  @override
  Widget build(BuildContext context) {
    if (surahs.isEmpty) {
      return const EmptyView(message: 'لا توجد نتائج في المصحف');
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final isMakki = (surah.revelationType?.toLowerCase().contains('makk') ?? false) ||
            surah.revelationLabel.contains('مك');

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? FatimidColors.obsidianCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.push('/quran/surah/${surah.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // النجمة الثمانية الفاطمية لرقم السورة
                    FatimidStarBadge(
                      number: surah.id,
                      size: 44,
                      isGold: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                surah.name,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isMakki
                                          ? const Color(0xFFD97706)
                                          : FatimidColors.emeraldPrimary)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (isMakki
                                            ? const Color(0xFFD97706)
                                            : FatimidColors.emeraldPrimary)
                                        .withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  surah.revelationLabel,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: isMakki
                                        ? const Color(0xFFD97706)
                                        : (isDark ? const Color(0xFF6EE7B7) : FatimidColors.emeraldPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${surah.ayahs.length} آية كريمة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F),
                            ),
                          ),
                        ],
                      ),
                    ),
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
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({
    required this.surahs,
    required this.count,
    required this.label,
    required this.type,
  });

  final List<Surah> surahs;
  final int count;
  final String label;
  final _QuranIndexType type;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final number = index + 1;
        final target = _findTarget(number);
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: target == null
              ? null
              : () => context.push(
                  '/quran/surah/${target.surah.id}?ayah=${target.ayah.number}',
                ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? FatimidColors.obsidianCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.3 : 0.22),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$label $number',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    if (target != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        target.surah.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _QuranTarget? _findTarget(int number) {
    for (final surah in surahs) {
      for (final ayah in surah.ayahs) {
        final matches = switch (type) {
          _QuranIndexType.juz => ayah.juz == number,
          _QuranIndexType.page => ayah.page == number,
          _QuranIndexType.hizb =>
            ayah.hizbQuarter != null &&
                ayah.hizbQuarter! >= ((number - 1) * 4) + 1,
        };
        if (matches) {
          return _QuranTarget(surah: surah, ayah: ayah);
        }
      }
    }
    return null;
  }
}

enum _QuranIndexType { juz, hizb, page }

class _QuranTarget {
  const _QuranTarget({required this.surah, required this.ayah});

  final Surah surah;
  final Ayah ayah;
}

class _FatimidTabPill extends StatelessWidget {
  const _FatimidTabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? FatimidColors.goldGradient : null,
            color: selected
                ? null
                : (isDark ? FatimidColors.obsidianCard : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? FatimidColors.goldLight
                  : FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
              width: 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected
                  ? const Color(0xFF332000)
                  : (isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4B6B5E)),
            ),
          ),
        ),
      ),
    );
  }
}
