import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/recitation_service.dart';
import '../../domain/recitation_models.dart';
import 'reciter_avatar.dart';

class RecitationPlayerBar extends StatelessWidget {
  const RecitationPlayerBar({
    super.key,
    RecitationService? service,
  }) : _service = service;

  final RecitationService? _service;

  RecitationService get service => _service ?? RecitationService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ActiveRecitation?>(
      valueListenable: service.activeRecitationNotifier,
      builder: (context, active, child) {
        if (active == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: StreamBuilder<PlayerState>(
            stream: service.playerStateStream,
            builder: (context, playerSnapshot) {
              final playerState = playerSnapshot.data ?? service.playerState;
              final isPlaying = playerState.playing;
              final isBuffering =
                  playerState.processingState == ProcessingState.buffering ||
                  playerState.processingState == ProcessingState.loading;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          ReciterAvatar(
                            reciter: active.reciter,
                            size: 44,
                          ),
                          if (isPlaying)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.brightness == Brightness.dark
                                        ? colorScheme.surfaceContainerHighest
                                        : colorScheme.surface,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.graphic_eq,
                                  size: 10,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              active.displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${active.reciter.name} • ${active.isDownloaded ? 'محملة' : 'بث مباشر'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isBuffering)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      else ...[
                        IconButton(
                          tooltip: 'رجوع 10 ثوانٍ',
                          icon: const Icon(Icons.replay_10),
                          iconSize: 22,
                          onPressed: () {
                            final current = service.position;
                            final target = current - const Duration(seconds: 10);
                            service.seek(
                              target < Duration.zero ? Duration.zero : target,
                            );
                          },
                        ),
                        IconButton(
                          tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: colorScheme.primary,
                          ),
                          iconSize: 36,
                          onPressed: () {
                            if (isPlaying) {
                              service.pause();
                            } else {
                              service.resume();
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'إيقاف نهائي',
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            color: colorScheme.error,
                          ),
                          iconSize: 28,
                          onPressed: () => service.stop(),
                        ),
                      ],
                    ],
                  ),
                  StreamBuilder<Duration>(
                    stream: service.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? service.position;
                      return StreamBuilder<Duration?>(
                        stream: service.durationStream,
                        builder: (context, durSnapshot) {
                          final duration =
                              durSnapshot.data ?? service.duration ?? Duration.zero;

                          final totalMs = duration.inMilliseconds;
                          final posMs = position.inMilliseconds;
                          final maxVal = totalMs > 0 ? totalMs.toDouble() : 1.0;
                          final currentVal =
                              posMs.clamp(0, totalMs > 0 ? totalMs : 1).toDouble();

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3.5,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                ),
                                child: Slider(
                                  value: currentVal,
                                  max: maxVal,
                                  onChanged: totalMs > 0
                                      ? (value) {
                                          service.seek(
                                            Duration(milliseconds: value.round()),
                                          );
                                        }
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
