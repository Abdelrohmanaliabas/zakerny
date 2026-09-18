import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/recitations_controller.dart';
import '../domain/recitation_models.dart';
import 'widgets/reciter_avatar.dart';

class RecitationsScreen extends StatefulWidget {
  const RecitationsScreen({super.key, required this.controller});
  final RecitationsController controller;

  @override
  State<RecitationsScreen> createState() => _RecitationsScreenState();
}

class _RecitationsScreenState extends State<RecitationsScreen> {
  late Future<List<Reciter>> _future;
  StreamSubscription<PlayerState>? _playerSubscription;
  String? _busyKey;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.controller.loadReciters();
    _playerSubscription = widget.controller.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });
    widget.controller.activeRecitationNotifier.addListener(_onActiveChanged);
  }

  void _onActiveChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    widget.controller.activeRecitationNotifier.removeListener(_onActiveChanged);
    super.dispose();
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
      body: SafeArea(
        child: Column(
          children: [
            ZekrniHeader(
              title: 'التلاوات',
              subtitle: 'تشغيل مباشر أو تحميل للاستماع بدون إنترنت',
              showSearch: true,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: FutureBuilder<List<Reciter>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorStateView(message: snapshot.error.toString());
                  }
                  final reciters = _filterReciters(snapshot.data ?? const []);
                  if (reciters.isEmpty) {
                    return const EmptyView(message: 'لا توجد قائمة شيوخ');
                  }
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reciters.length,
                        itemBuilder: (context, index) {
                          final reciter = reciters[index];
                          return Card(
                            child: ExpansionTile(
                              leading: ReciterAvatar(
                                reciter: reciter,
                                size: 46,
                              ),
                              title: Text(
                                reciter.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'المصحف كامل • ${reciter.surahs.length} سورة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              children: reciter.surahs.map((surah) {
                                final download = widget.controller.findDownload(
                                  reciter.id,
                                  surah.id,
                                );
                                final key = '${reciter.id}-${surah.id}';
                                final busy = _busyKey == key;
                                final isCurrent = widget.controller.isCurrentTrack(
                                  reciter.id,
                                  surah.id,
                                );
                                final isPlaying = widget.controller
                                    .isCurrentTrackPlaying(reciter.id, surah.id);

                                return ListTile(
                                  selected: isCurrent,
                                  selectedTileColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.15),
                                  title: Text(
                                    surah.name,
                                    style: isCurrent
                                        ? const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )
                                        : null,
                                  ),
                                  subtitle: Text(
                                    download == null
                                        ? 'Streaming عند توفر الرابط'
                                        : 'محملة وتعمل بدون إنترنت',
                                  ),
                                  leading: busy
                                      ? const SizedBox.square(
                                          dimension: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : isCurrent
                                          ? Icon(
                                              isPlaying
                                                  ? Icons.graphic_eq
                                                  : Icons.pause_circle_outline,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )
                                          : const Icon(Icons.music_note),
                                  trailing: Wrap(
                                    spacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      if (isCurrent) ...[
                                        IconButton(
                                          tooltip: isPlaying ? 'إيقاف مؤقت' : 'استئناف',
                                          onPressed: busy
                                              ? null
                                              : () => _run(
                                                    key,
                                                    () => widget.controller
                                                        .togglePlayPause(
                                                          reciter,
                                                          surah,
                                                        ),
                                                  ),
                                          icon: Icon(
                                            isPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'إيقاف التلاوة',
                                          onPressed: busy
                                              ? null
                                              : () => _run(
                                                    key,
                                                    () => widget.controller.stop(),
                                                  ),
                                          icon: Icon(
                                            Icons.stop_circle_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        ),
                                      ] else ...[
                                        IconButton(
                                          tooltip: 'تشغيل',
                                          onPressed: busy
                                              ? null
                                              : () => _run(
                                                    key,
                                                    () => widget.controller.play(
                                                      reciter,
                                                      surah,
                                                    ),
                                                  ),
                                          icon: const Icon(Icons.play_arrow),
                                        ),
                                      ],
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
                                                    () => widget.controller
                                                        .deleteDownload(download),
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Reciter> _filterReciters(List<Reciter> reciters) {
    final query = _query.trim();
    if (query.isEmpty) {
      return reciters;
    }
    return reciters
        .map((reciter) {
          final surahs = reciter.surahs
              .where((surah) => surah.name.contains(query))
              .toList();
          if (reciter.name.contains(query)) {
            return reciter;
          }
          return Reciter(id: reciter.id, name: reciter.name, surahs: surahs);
        })
        .where((reciter) => reciter.surahs.isNotEmpty)
        .toList();
  }
}
