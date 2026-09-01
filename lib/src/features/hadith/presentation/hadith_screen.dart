import 'package:flutter/material.dart';

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
              title: 'الأحاديث',
              subtitle: 'قراءة وبحث محلي بدون إنترنت',
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
                        height: 56,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: collections.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final collection = collections[index];
                            return ChoiceChip(
                              selected: collection == _selectedCollection,
                              label: Text(collection),
                              onSelected: (_) => setState(
                                () => _selectedCollection = collection,
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
          hadith.title.contains(query) ||
          hadith.text.contains(query) ||
          hadith.collection.contains(query);
      return matchesCollection && matchesQuery;
    }).toList();
  }

  Future<void> _openHadith(Hadith hadith) async {
    await widget.controller.saveLastHadith(hadith.id);
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              hadith.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              hadith.collection,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              hadith.text,
              style: const TextStyle(fontSize: 19, height: 1.8),
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
    final color = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.article_outlined, color: color.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hadith.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hadith.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.55),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Chip(
                  label: Text(hadith.collection),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
