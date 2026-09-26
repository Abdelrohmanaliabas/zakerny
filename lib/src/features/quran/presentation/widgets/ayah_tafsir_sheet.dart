import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../data/tafsir_service.dart';
import '../../domain/quran_models.dart';
import '../../domain/tafsir_models.dart';

class AyahTafsirSheet extends StatefulWidget {
  const AyahTafsirSheet({
    super.key,
    required this.surah,
    required this.ayah,
    required this.tafsirService,
    required this.displayText,
  });

  final Surah surah;
  final Ayah ayah;
  final TafsirService tafsirService;
  final String displayText;

  static Future<void> show(
    BuildContext context, {
    required Surah surah,
    required Ayah ayah,
    required TafsirService tafsirService,
    required String displayText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahTafsirSheet(
        surah: surah,
        ayah: ayah,
        tafsirService: tafsirService,
        displayText: displayText,
      ),
    );
  }

  @override
  State<AyahTafsirSheet> createState() => _AyahTafsirSheetState();
}

class _AyahTafsirSheetState extends State<AyahTafsirSheet> {
  late String _selectedEditionId;
  late Future<AyahTafsir> _tafsirFuture;
  double _fontSize = 16.5;

  @override
  void initState() {
    super.initState();
    _selectedEditionId = widget.tafsirService.getPreferredEdition();
    _loadTafsir();
  }

  void _loadTafsir() {
    setState(() {
      _tafsirFuture = widget.tafsirService.getAyahTafsir(
        surahId: widget.surah.id,
        surahName: widget.surah.name,
        ayahNumber: widget.ayah.number,
        ayahText: widget.displayText,
        editionId: _selectedEditionId,
      );
    });
  }

  void _changeEdition(String editionId) {
    if (_selectedEditionId == editionId) return;
    setState(() {
      _selectedEditionId = editionId;
    });
    widget.tafsirService.setPreferredEdition(editionId);
    _loadTafsir();
  }

  void _adjustFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(13.0, 26.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1914) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border(
                top: BorderSide(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag Handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: FatimidColors.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF332000),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفسير الآية الكريمة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            Text(
                              'سورة ${widget.surah.name} • آية ${widget.ayah.number}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? FatimidColors.goldLight
                                    : FatimidColors.emeraldPrimary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      // Ayah Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132720) : const Color(0xFFF9F7F1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: FatimidColors.goldPrimary.withValues(
                              alpha: isDark ? 0.35 : 0.25,
                            ),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.03,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.displayText,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20.5,
                                height: 2.1,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE6C875),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '﴿${widget.surah.name}: ${widget.ayah.number}﴾',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFA5C4B8)
                                    : const Color(0xFF5B7A6F),
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Tafsir Editions Tabs
                      Text(
                        'اختر كتاب التفسير:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: supportedTafsirs.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final ed = supportedTafsirs[index];
                            final isSelected = ed.id == _selectedEditionId;

                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _changeEdition(ed.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? FatimidColors.goldGradient
                                      : null,
                                  color: isSelected
                                      ? null
                                      : (isDark
                                          ? FatimidColors.obsidianCard
                                          : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? FatimidColors.goldLight
                                        : FatimidColors.goldPrimary.withValues(
                                            alpha: isDark ? 0.25 : 0.2,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  ed.name,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF332000)
                                        : (isDark
                                            ? const Color(0xFFA5C4B8)
                                            : const Color(0xFF375449)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Font size toolbar & actions
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF132720)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.remove, size: 16),
                                  tooltip: 'تصغير الخط',
                                  onPressed: () => _adjustFontSize(-1.5),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '${_fontSize.toInt()}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.add, size: 16),
                                  tooltip: 'تكبير الخط',
                                  onPressed: () => _adjustFontSize(1.5),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          FutureBuilder<AyahTafsir>(
                            future: _tafsirFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              final tafsir = snapshot.data!;
                              return Row(
                                children: [
                                  IconButton.filledTonal(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.copy_rounded, size: 18),
                                    tooltip: 'نسخ التفسير',
                                    onPressed: () {
                                      final copyText =
                                          '﴿${widget.displayText}﴾ [${widget.surah.name}: ${widget.ayah.number}]\n\n${tafsir.editionName}:\n${tafsir.text}\n\n[عبر تطبيق ذكرني]';
                                      Clipboard.setData(ClipboardData(text: copyText));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('تم نسخ نص التفسير بنجاح'),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Tafsir Text Card
                      FutureBuilder<AyahTafsir>(
                        future: _tafsirFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 180,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: FatimidColors.goldPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'جارٍ استحضار تفسير الآية الكريمة...',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF261212)
                                    : const Color(0xFFFDF2F2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    color: Colors.redAccent,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.error.toString().replaceAll('Exception: ', ''),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton.tonalIcon(
                                    onPressed: _loadTafsir,
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final tafsir = snapshot.data!;
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? FatimidColors.obsidianCard
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: FatimidColors.goldPrimary.withValues(
                                  alpha: isDark ? 0.28 : 0.2,
                                ),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        gradient: FatimidColors.goldGradient,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tafsir.editionName,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? FatimidColors.goldLight
                                            : FatimidColors.emeraldPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FatimidColors.emeraldPrimary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified_rounded,
                                            size: 13,
                                            color: FatimidColors.emeraldPrimary,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'معتمد',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: FatimidColors.emeraldPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  tafsir.text,
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: _fontSize,
                                    height: 1.85,
                                    color: isDark
                                        ? const Color(0xFFE2E8F0)
                                        : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
