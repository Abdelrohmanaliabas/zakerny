import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';
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

  @override
  void initState() {
    super.initState();
    _future = widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأحاديث')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'بحث في الأحاديث',
              ),
              onChanged: (value) =>
                  setState(() => _future = widget.controller.search(value)),
            ),
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
                final hadiths = snapshot.data ?? const [];
                if (hadiths.isEmpty) {
                  return const EmptyView(message: 'لا توجد نتائج');
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = hadiths[index];
                    return Card(
                      child: ListTile(
                        title: Text(hadith.title),
                        subtitle: Text(hadith.collection),
                        onTap: () async {
                          await widget.controller.saveLastHadith(hadith.id);
                          if (!context.mounted) return;
                          showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hadith.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      hadith.collection,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      hadith.text,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
