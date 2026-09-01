import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            final surahs = allSurahs
                .where((surah) => surah.name.contains(_query))
                .toList();
            return Column(
              children: [
                ZekrniHeader(
                  title: 'قرآن',
                  subtitle: 'المصحف الكامل - ${allSurahs.length} سورة',
                  showSearch: true,
                  onSearchChanged: (value) => setState(() => _query = value),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabPill(
                          label: 'سورة',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                      ),
                      Expanded(
                        child: _TabPill(
                          label: 'جزء',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ),
                      Expanded(
                        child: _TabPill(
                          label: 'حزب',
                          selected: _tab == 2,
                          onTap: () => setState(() => _tab = 2),
                        ),
                      ),
                      Expanded(
                        child: _TabPill(
                          label: 'صفحة',
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
          return FloatingActionButton.extended(
            onPressed: () => context.push('/quran/surah/${last.surahId}'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('متابعة'),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: surahs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 7,
          ),
          leading: _SurahBadge(number: surah.id),
          title: Text(
            surah.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${surah.revelationLabel}، ${surah.ayahs.length} آيات',
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              Icon(
                Icons.library_books,
                color: Theme.of(context).colorScheme.primary,
              ),
              Icon(
                Icons.favorite_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          onTap: () => context.push('/quran/surah/${surah.id}'),
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
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final number = index + 1;
        final target = _findTarget(number);
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: target == null
              ? null
              : () => context.push(
                  '/quran/surah/${target.surah.id}?ayah=${target.ayah.number}',
                ),
          child: Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$label $number',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (target != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        target.surah.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.secondary : color.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black87 : color.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahBadge extends StatelessWidget {
  const _SurahBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
