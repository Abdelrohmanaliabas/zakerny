import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/adhkar_controller.dart';
import '../domain/dhikr_models.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key, required this.controller});

  final AdhkarController controller;

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late Future<List<DhikrCategory>> _future;
  String? _selectedCategoryId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.controller.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ZekrniHeader(
              title: 'الأذكار',
              subtitle: 'ورد يومي محفوظ بدون إنترنت',
              showSearch: true,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: FutureBuilder<List<DhikrCategory>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorStateView(message: snapshot.error.toString());
                  }
                  final categories = snapshot.data ?? const [];
                  if (categories.isEmpty) {
                    return const EmptyView(message: 'لا توجد أذكار محلية');
                  }
                  final selected = _selectedCategoryId ?? categories.first.id;
                  final items = _filterItems(categories, selected);
                  return Column(
                    children: [
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return ChoiceChip(
                              selected: category.id == selected,
                              label: Text(category.title),
                              onSelected: (_) => setState(
                                () => _selectedCategoryId = category.id,
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? const EmptyView(message: 'لا توجد نتائج')
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, index) => _DhikrCard(
                                  item: items[index],
                                  controller: widget.controller,
                                  onChanged: () => setState(() {}),
                                ),
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

  List<DhikrItem> _filterItems(
    List<DhikrCategory> categories,
    String selectedCategoryId,
  ) {
    final selected = categories.firstWhere(
      (category) => category.id == selectedCategoryId,
      orElse: () => categories.first,
    );
    final query = _query.trim();
    if (query.isEmpty) {
      return selected.items;
    }
    return selected.items
        .where(
          (item) => item.title.contains(query) || item.text.contains(query),
        )
        .toList();
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.item,
    required this.controller,
    required this.onChanged,
  });

  final DhikrItem item;
  final AdhkarController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final count = controller.countFor(item.id);
    final progress = (count / item.targetCount).clamp(0.0, 1.0);
    final isDone = count >= item.targetCount;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await controller.reset(item.id);
                    onChanged();
                  },
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'إعادة',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.text,
              style: const TextStyle(fontSize: 18, height: 1.75),
              textAlign: TextAlign.start,
            ),
            if (item.source != null) ...[
              const SizedBox(height: 10),
              Text(
                item.source!,
                style: TextStyle(color: color.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '$count / ${item.targetCount}',
                  style: TextStyle(
                    color: isDone ? color.primary : color.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: isDone
                      ? null
                      : () async {
                          await controller.increment(item);
                          onChanged();
                        },
                  icon: Icon(isDone ? Icons.check : Icons.add),
                  label: Text(isDone ? 'تم' : 'تسبيح'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
