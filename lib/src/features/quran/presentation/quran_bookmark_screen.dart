import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../application/quran_controller.dart';

class QuranBookmarkScreen extends StatelessWidget {
  const QuranBookmarkScreen({super.key, required this.controller});
  final QuranController controller;

  @override
  Widget build(BuildContext context) {
    final bookmarks = controller.bookmarks();
    return Scaffold(
      appBar: AppBar(title: const Text('علامات المصحف')),
      body: bookmarks.isEmpty
          ? const EmptyView(
              message: 'لا توجد علامات محفوظة بعد',
              icon: Icons.bookmark_border,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(bookmark.surahName),
                    subtitle: Text('آية ${bookmark.ayahNumber}'),
                    onTap: () => context.go('/quran/surah/${bookmark.surahId}'),
                  ),
                );
              },
            ),
    );
  }
}
