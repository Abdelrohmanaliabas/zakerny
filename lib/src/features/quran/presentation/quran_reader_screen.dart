import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';
import '../application/quran_controller.dart';
import '../domain/quran_models.dart';

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.controller,
    required this.surahId,
    this.initialAyahNumber,
  });

  final QuranController controller;
  final int surahId;
  final int? initialAyahNumber;

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _didScrollToInitialAyah = false;

  @override
  void didUpdateWidget(covariant QuranReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAyahNumber != widget.initialAyahNumber ||
        oldWidget.surahId != widget.surahId) {
      _didScrollToInitialAyah = false;
      _ayahKeys.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah?>(
      future: widget.controller.findSurah(widget.surahId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: LoadingView());
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorStateView(message: snapshot.error.toString()),
          );
        }
        final surah = snapshot.data;
        if (surah == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyView(message: 'السورة غير موجودة'),
          );
        }
        _scheduleInitialAyahScroll();
        return Scaffold(
          appBar: AppBar(title: Text(surah.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 88),
            children: [
              _SurahHeader(surah: surah),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    children: surah.ayahs.map((ayah) {
                      final key = _ayahKeys.putIfAbsent(
                        ayah.number,
                        GlobalKey.new,
                      );
                      final highlighted =
                          ayah.number == widget.initialAyahNumber;
                      return Container(
                        key: key,
                        decoration: BoxDecoration(
                          color: highlighted
                              ? Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.16)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              widget.controller.saveLastRead(surah, ayah),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 4,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: ayah.text,
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: _AyahBadge(number: ayah.number),
                                  ),
                                ],
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    height: 1.72,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            tooltip: 'حفظ علامة',
            onPressed: () async {
              final ayah = widget.initialAyahNumber == null
                  ? surah.ayahs.first
                  : surah.ayahs.firstWhere(
                      (item) => item.number == widget.initialAyahNumber,
                      orElse: () => surah.ayahs.first,
                    );
              await widget.controller.bookmark(surah, ayah);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حفظ العلامة عند آية ${ayah.number}'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.bookmark_add),
            label: const Text('علامة'),
          ),
        );
      },
    );
  }

  void _scheduleInitialAyahScroll() {
    if (_didScrollToInitialAyah || widget.initialAyahNumber == null) {
      return;
    }
    _didScrollToInitialAyah = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[widget.initialAyahNumber];
      final context = key?.currentContext;
      if (context == null) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    });
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final firstAyah = surah.ayahs.firstOrNull;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _MetaPill(label: surah.revelationLabel),
              _MetaPill(label: '${surah.ayahs.length} آيات'),
              if (firstAyah?.juz != null)
                _MetaPill(label: 'جزء ${firstAyah!.juz}'),
              if (firstAyah?.page != null)
                _MetaPill(label: 'صفحة ${firstAyah!.page}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _AyahBadge extends StatelessWidget {
  const _AyahBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
