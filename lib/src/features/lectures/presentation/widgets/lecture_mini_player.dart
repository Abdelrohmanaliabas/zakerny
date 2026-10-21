import 'package:flutter/material.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../domain/lecture_models.dart';
import '../../application/lectures_controller.dart';
import 'lecture_player_bottom_sheet.dart';

class LectureMiniPlayer extends StatelessWidget {
  const LectureMiniPlayer({
    super.key,
    required this.controller,
  });

  final LecturesController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = controller.service;

    return ValueListenableBuilder<ActiveLecture?>(
      valueListenable: service.activeLectureNotifier,
      builder: (context, active, _) {
        if (active == null) {
          return const SizedBox.shrink();
        }

        final lecture = active.lecture;

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          decoration: BoxDecoration(
            color: isDark
                ? FatimidColors.obsidianCard.withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => LecturePlayerBottomSheet.show(context, controller),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress line at top
                  StreamBuilder<Duration>(
                    stream: service.positionStream,
                    builder: (context, snap) {
                      final pos = snap.data ?? service.position;
                      final total = service.duration ?? Duration.zero;
                      final progress = (total.inMilliseconds > 0)
                          ? (pos.inMilliseconds / total.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0.0;

                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 2.5,
                          backgroundColor: Colors.transparent,
                          color: FatimidColors.goldPrimary,
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Avatar / icon
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: FatimidColors.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: FatimidColors.goldPrimary
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.record_voice_over_rounded,
                              color: Color(0xFF261800),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title & Sheikh
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lecture.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                lecture.sheikhName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: FatimidColors.goldPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Controls: Replay 10, Play/Pause, Forward 10, Close
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10_rounded, size: 22),
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                              onPressed: () => service
                                  .seekRelative(const Duration(seconds: -10)),
                            ),
                            StreamBuilder(
                              stream: service.playerStateStream,
                              builder: (context, _) {
                                final isPlaying = service.isPlaying;
                                return IconButton(
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                    size: 36,
                                  ),
                                  color: FatimidColors.goldPrimary,
                                  onPressed: controller.togglePlayPause,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.forward_10_rounded,
                                size: 22,
                              ),
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                              onPressed: () => service
                                  .seekRelative(const Duration(seconds: 10)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF94A3B8),
                              onPressed: service.stop,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
