import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';
import '../application/recitations_controller.dart';
import '../domain/recitation_models.dart';

class RecitationsScreen extends StatefulWidget {
  const RecitationsScreen({super.key, required this.controller});
  final RecitationsController controller;

  @override
  State<RecitationsScreen> createState() => _RecitationsScreenState();
}

class _RecitationsScreenState extends State<RecitationsScreen> {
  late Future<List<Reciter>> _future;
  String? _busyKey;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.loadReciters();
  }

  Future<void> _run(String key, Future<void> Function() action) async {
    setState(() => _busyKey = key);
    try {
      await action();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التلاوات')),
      body: FutureBuilder<List<Reciter>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorStateView(message: snapshot.error.toString());
          }
          final reciters = snapshot.data ?? const [];
          if (reciters.isEmpty) {
            return const EmptyView(message: 'لا توجد قائمة شيوخ');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(reciter.name),
                  children: reciter.surahs.map((surah) {
                    final download = widget.controller.findDownload(
                      reciter.id,
                      surah.id,
                    );
                    final key = '${reciter.id}-${surah.id}';
                    final busy = _busyKey == key;
                    return ListTile(
                      title: Text(surah.name),
                      subtitle: Text(
                        download == null
                            ? 'Streaming عند توفر الرابط'
                            : 'محملة وتعمل بدون إنترنت',
                      ),
                      leading: busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.music_note),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'تشغيل',
                            onPressed: busy
                                ? null
                                : () => _run(
                                    key,
                                    () =>
                                        widget.controller.play(reciter, surah),
                                  ),
                            icon: const Icon(Icons.play_arrow),
                          ),
                          if (download == null)
                            IconButton(
                              tooltip: 'تحميل',
                              onPressed: busy
                                  ? null
                                  : () => _run(
                                      key,
                                      () => widget.controller.download(
                                        reciter,
                                        surah,
                                      ),
                                    ),
                              icon: const Icon(Icons.download),
                            )
                          else
                            IconButton(
                              tooltip: 'حذف التحميل',
                              onPressed: busy
                                  ? null
                                  : () => _run(
                                      key,
                                      () => widget.controller.deleteDownload(
                                        download,
                                      ),
                                    ),
                              icon: const Icon(Icons.delete_outline),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
