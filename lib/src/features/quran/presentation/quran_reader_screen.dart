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
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _ayahChunks(surah.ayahs).map((ayahs) {
                      final firstAyah = ayahs.first;
                      final key = _ayahKeys.putIfAbsent(
                        firstAyah.number,
                        GlobalKey.new,
                      );
                      for (final ayah in ayahs) {
                        _ayahKeys[ayah.number] = key;
                      }
                      final highlighted = ayahs.any(
                        (ayah) => ayah.number == widget.initialAyahNumber,
                      );
                      return _AyahParagraph(
                        key: key,
                        ayahs: ayahs,
                        highlighted: highlighted,
                        onTap: () => widget.controller.saveLastRead(
                          surah,
                          highlighted
                              ? ayahs.firstWhere(
                                  (ayah) =>
                                      ayah.number == widget.initialAyahNumber,
                                  orElse: () => firstAyah,
                                )
                              : firstAyah,
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

  List<List<Ayah>> _ayahChunks(List<Ayah> ayahs) {
    const chunkSize = 8;
    final chunks = <List<Ayah>>[];
    for (var index = 0; index < ayahs.length; index += chunkSize) {
      chunks.add(
        ayahs.sublist(
          index,
          index + chunkSize > ayahs.length ? ayahs.length : index + chunkSize,
        ),
      );
    }
    return chunks;
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

class _AyahParagraph extends StatelessWidget {
  const _AyahParagraph({
    super.key,
    required this.ayahs,
    required this.highlighted,
    required this.onTap,
  });

  final List<Ayah> ayahs;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(height: 1.9, fontWeight: FontWeight.w500);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted
              ? color.secondary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              for (final ayah in ayahs) ...[
                TextSpan(text: ayah.text),
                TextSpan(
                  text: ' ﴿${_arabicDigits(ayah.number)}﴾ ',
                  style: TextStyle(
                    color: color.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
          style: textStyle,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  String _arabicDigits(int value) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return value
        .toString()
        .split('')
        .map((digit) => digits[int.parse(digit)])
        .join();
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
