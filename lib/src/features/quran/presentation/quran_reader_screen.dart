import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';
import '../application/quran_controller.dart';
import '../domain/quran_models.dart';

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({
    super.key,
    required this.controller,
    required this.surahId,
  });
  final QuranController controller;
  final int surahId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah?>(
      future: controller.findSurah(surahId),
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
        return Scaffold(
          appBar: AppBar(title: Text(surah.name)),
          body: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: surah.ayahs.length,
            itemBuilder: (context, index) {
              final ayah = surah.ayahs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.saveLastRead(surah, ayah),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text.rich(
                      TextSpan(
                        text: ayah.text,
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${ayah.number}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 24, height: 1.9),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'حفظ علامة',
            onPressed: () async {
              final ayah = surah.ayahs.first;
              await controller.bookmark(surah, ayah);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ العلامة عند بداية السورة'),
                  ),
                );
              }
            },
            child: const Icon(Icons.bookmark_add),
          ),
        );
      },
    );
  }
}
