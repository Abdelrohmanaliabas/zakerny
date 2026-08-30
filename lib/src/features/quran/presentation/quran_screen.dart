import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../application/quran_controller.dart';
import '../domain/quran_models.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key, required this.controller});
  final QuranController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف'),
        actions: [
          IconButton(
            tooltip: 'العلامات',
            onPressed: () => context.go('/quran/bookmarks'),
            icon: const Icon(Icons.bookmark_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<Surah>>(
        future: controller.loadSurahs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorStateView(message: snapshot.error.toString());
          }
          final surahs = snapshot.data ?? const [];
          if (surahs.isEmpty) {
            return const EmptyView(message: 'لا توجد سور في ملف المصحف المحلي');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: surahs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${surah.id}')),
                  title: Text(surah.name),
                  subtitle: Text('${surah.ayahs.length} آيات'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => context.go('/quran/surah/${surah.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final last = controller.lastRead();
          if (last == null) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => context.go('/quran/surah/${last.surahId}'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('متابعة القراءة'),
          );
        },
      ),
    );
  }
}
