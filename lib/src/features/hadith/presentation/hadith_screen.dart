import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/arabic_text_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/hadith_controller.dart';
import '../domain/hadith_models.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key, required this.controller});
  final HadithController controller;

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late Future<List<Hadith>> _future;
  String _query = '';
  String _selectedCollection = 'الكل';

  @override
  void initState() {
    super.initState();
    _future = widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ZekrniHeader(
              title: 'الأحاديث النبوية',
              subtitle: 'أحاديث صحيحة موثقة بالأسانيد والرواة',
              showSearch: true,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: FutureBuilder<List<Hadith>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorStateView(message: snapshot.error.toString());
                  }
                  final allHadiths = snapshot.data ?? const [];
                  final collections = [
                    'الكل',
                    ...allHadiths.map((hadith) => hadith.collection).toSet(),
                  ];
                  final hadiths = _filterHadiths(allHadiths);
                  return Column(
                    children: [
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: collections.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final collection = collections[index];
                            final isSelected = collection == _selectedCollection;
                            final isDark = Theme.of(context).brightness == Brightness.dark;

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => _selectedCollection = collection),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? FatimidColors.goldGradient : null,
                                  color: isSelected
                                      ? null
                                      : (isDark ? FatimidColors.obsidianCard : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
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
                                child: Text(
                                  collection,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 12.5,
                                    color: isSelected
                                        ? const Color(0xFF332000)
                                        : (isDark ? const Color(0xFFA5C4B8) : const Color(0xFF375449)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: hadiths.isEmpty
                            ? const EmptyView(message: 'لا توجد نتائج')
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: hadiths.length,
                                itemBuilder: (context, index) {
                                  final hadith = hadiths[index];
                                  return _HadithCard(
                                    hadith: hadith,
                                    onTap: () => _openHadith(hadith),
                                  );
                                },
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

  List<Hadith> _filterHadiths(List<Hadith> hadiths) {
    final query = _query.trim();
    return hadiths.where((hadith) {
      final matchesCollection =
          _selectedCollection == 'الكل' ||
          hadith.collection == _selectedCollection;
      final matchesQuery =
          query.isEmpty ||
          ArabicTextUtils.contains(hadith.title, query) ||
          ArabicTextUtils.contains(hadith.text, query) ||
          ArabicTextUtils.contains(hadith.collection, query) ||
          (hadith.narrator != null && ArabicTextUtils.contains(hadith.narrator!, query));
      return matchesCollection && matchesQuery;
    }).toList();
  }

  Future<void> _openHadith(Hadith hadith) async {
    await widget.controller.saveLastHadith(hadith.id);
    if (!mounted) return;
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    hadith.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'صحيح 100%',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hadith.collection,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                  ),
                ),
                if (hadith.narrator != null && hadith.narrator!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hadith.narrator!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color.secondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                hadith.text,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  height: 2.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    final shareText =
                        '${hadith.title}\n\n${hadith.text}\n\n[${hadith.narrator ?? hadith.collection}]';
                    Clipboard.setData(ClipboardData(text: shareText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الحديث الشريف إلى الحافظة'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('نسخ الحديث'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.hadith, required this.onTap});

  final Hadith hadith;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? FatimidColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.28 : 0.2),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: color.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hadith.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'صحيح',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                hadith.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hadith.collection,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (hadith.narrator != null && hadith.narrator!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.primary.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        hadith.narrator!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
