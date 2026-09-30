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
  int _searchTab = 0;
  late final Future<List<Surah>> _surahsFuture;
  List<Surah>? _allSurahs;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _surahsFuture = widget.controller.loadSurahs();
    _surahsFuture.then((surahs) {
      if (mounted) {
        setState(() {
          _allSurahs = surahs;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ErrorStateView(message: _errorMessage!),
        ),
      );
    }

    if (_allSurahs == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LoadingView(),
        ),
      );
    }

    final allSurahs = _allSurahs!;
    final cleanQuery = _query.trim();
    final isSearching = cleanQuery.isNotEmpty;

            final surahs = allSurahs
                .where((surah) =>
                    !isSearching ||
                    ArabicTextUtils.contains(surah.name, cleanQuery) ||
                    (surah.englishName?.toLowerCase().contains(cleanQuery.toLowerCase()) ?? false) ||
                    surah.id.toString() == cleanQuery)
                .toList();

            final matchingAyahs = <_QuranTarget>[];
            if (isSearching) {
              final normalizedQuery = ArabicTextUtils.normalize(cleanQuery);
              for (final surah in allSurahs) {
                for (final ayah in surah.ayahs) {
                  if (ayah.matches(normalizedQuery)) {
                    matchingAyahs.add(_QuranTarget(surah: surah, ayah: ayah));
                  }
                }
              }
            }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
                ZekrniHeader(
                  title: 'المصحف الشريف',
                  subtitle: isSearching
                      ? 'نتائج البحث: ${matchingAyahs.length} آية • ${surahs.length} سورة'
                      : 'المصحف الكامل • ${allSurahs.length} سورة كريمة',
                  showSearch: true,
                  onSearchChanged: (value) => setState(() {
                    _query = value;
                    if (value.trim().isEmpty) {
                      _searchTab = 0;
                    }
                  }),
                ),
                if (isSearching) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FatimidTabPill(
                            label: 'الآيات (${matchingAyahs.length})',
                            selected: _searchTab == 0,
                            onTap: () => setState(() => _searchTab = 0),
                          ),
                        ),
                        Expanded(
                          child: _FatimidTabPill(
                            label: 'السور (${surahs.length})',
                            selected: _searchTab == 1,
                            onTap: () => setState(() => _searchTab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _searchTab == 0
                        ? _AyahSearchResultsList(
                            query: cleanQuery,
                            results: matchingAyahs,
                            surahMatchesCount: surahs.length,
                            onSwitchToSurahs: () => setState(() => _searchTab = 1),
                          )
                        : _SurahList(surahs: surahs),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
              ],
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

class _AyahSearchResultsList extends StatelessWidget {
  const _AyahSearchResultsList({
    required this.query,
    required this.results,
    this.surahMatchesCount = 0,
    this.onSwitchToSurahs,
  });

  final String query;
  final List<_QuranTarget> results;
  final int surahMatchesCount;
  final VoidCallback? onSwitchToSurahs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 54,
                color: FatimidColors.goldPrimary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد آيات مطابقة للبحث',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF2C3E35),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'جرّب البحث بكلمة أخرى أو تصفح السور',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              if (surahMatchesCount > 0 && onSwitchToSurahs != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onSwitchToSurahs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FatimidColors.goldPrimary.withValues(alpha: 0.18),
                    foregroundColor: isDark ? FatimidColors.goldLight : FatimidColors.goldDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text(
                    'عرض السور المطابقة ($surahMatchesCount)',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final surah = item.surah;
        final ayah = item.ayah;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? FatimidColors.obsidianCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.push('/quran/surah/${surah.id}?ayah=${ayah.number}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        FatimidStarBadge(
                          number: ayah.number,
                          size: 36,
                          isGold: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سورة ${surah.name}',
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'الآية ${ayah.number} • جزء ${ayah.juz ?? '-'} • صفحة ${ayah.page ?? '-'}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4E7062),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'فتح',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? FatimidColors.goldLight : FatimidColors.goldDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: isDark ? FatimidColors.goldLight : FatimidColors.goldDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.28)
                            : FatimidColors.parchmentLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.12 : 0.1),
                          width: 0.8,
                        ),
                      ),
                      child: _HighlightedAyahText(
                        text: ayah.text,
                        query: query,
                      ),
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

class _HighlightedAyahText extends StatelessWidget {
  const _HighlightedAyahText({
    required this.text,
    required this.query,
  });

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanQuery = ArabicTextUtils.normalize(query);

    final normalStyle = TextStyle(
      fontFamily: 'Amiri',
      fontSize: 16.5,
      height: 1.8,
      color: isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF1E2922),
    );

    final highlightStyle = TextStyle(
      fontFamily: 'Amiri',
      fontSize: 16.5,
      height: 1.8,
      fontWeight: FontWeight.bold,
      color: isDark ? const Color(0xFFFFDF7D) : const Color(0xFF8B5E00),
      backgroundColor: isDark
          ? FatimidColors.goldPrimary.withValues(alpha: 0.35)
          : FatimidColors.goldPrimary.withValues(alpha: 0.25),
    );

    if (cleanQuery.isEmpty) {
      return Text(
        text,
        style: normalStyle,
        textDirection: TextDirection.rtl,
      );
    }

    final words = text.split(' ');
    final queryWords = cleanQuery.split(' ').where((w) => w.isNotEmpty).toList();
    final spans = <TextSpan>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final isMatch = queryWords.any((qw) => ArabicTextUtils.contains(word, qw)) ||
          ArabicTextUtils.contains(word, cleanQuery);

      spans.add(
        TextSpan(
          text: word,
          style: isMatch ? highlightStyle : normalStyle,
        ),
      );

      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: normalStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
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
