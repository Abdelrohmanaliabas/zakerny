import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../../quran/presentation/screens/quran_tv_channel_screen.dart';
import '../../data/recitation_service.dart';
import '../../domain/recitation_models.dart';
import 'reciter_avatar.dart';

class RecitationPlayerBar extends StatefulWidget {
  const RecitationPlayerBar({
    super.key,
    RecitationService? service,
  }) : _service = service;

  final RecitationService? _service;

  RecitationService get service => _service ?? RecitationService();

  @override
  State<RecitationPlayerBar> createState() => _RecitationPlayerBarState();
}

class _RecitationPlayerBarState extends State<RecitationPlayerBar> {
  double? _dragValue;

  RecitationService get service => widget.service;

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
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? FatimidColors.obsidianCard.withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 0.5,
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
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => QuranTvChannelScreen.show(
                            context,
                            surahId: active.surah.id,
                            ayahNumber: active.ayahNumber,
                            reciter: active.reciter,
                            recitationService: service,
                          ),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${active.reciter.name} • ${active.isDownloaded ? 'محملة' : 'بث مباشر'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: FatimidColors.goldPrimary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: FatimidColors.goldPrimary
                                            .withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Text(
                                      'وضع القناة 📺',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: FatimidColors.goldPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                          tooltip: 'شاشة قناة القرآن والمناظر الطبيعية 📺',
                          icon: const Icon(Icons.tv_rounded),
                          color: FatimidColors.goldPrimary,
                          iconSize: 24,
                          onPressed: () => QuranTvChannelScreen.show(
                            context,
                            surahId: active.surah.id,
                            ayahNumber: active.ayahNumber,
                            reciter: active.reciter,
                            recitationService: service,
                          ),
                        ),
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
                            color: FatimidColors.goldPrimary,
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
                                  value: _dragValue ?? currentVal,
                                  max: maxVal,
                                  onChanged: totalMs > 0
                                      ? (value) {
                                          setState(() => _dragValue = value);
                                        }
                                      : null,
                                  onChangeEnd: totalMs > 0
                                      ? (value) {
                                          try {
                                            service.seek(
                                              Duration(milliseconds: value.round()),
                                            );
                                          } catch (_) {}
                                          setState(() => _dragValue = null);
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
