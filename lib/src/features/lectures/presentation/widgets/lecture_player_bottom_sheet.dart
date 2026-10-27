import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../application/lectures_controller.dart';
import 'lecture_video_player_dialog.dart';

class LecturePlayerBottomSheet extends StatelessWidget {
  const LecturePlayerBottomSheet({
    super.key,
    required this.controller,
  });

  final LecturesController controller;

  static void show(BuildContext context, LecturesController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LecturePlayerBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = controller.service;
    final active = service.activeLecture;

    if (active == null) {
      return const SizedBox.shrink();
    }

    final lecture = active.lecture;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: isDark
            ? FatimidColors.obsidianDark
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),

            // Top bar: Series badge & close button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      lecture.seriesTitle ?? 'الخطب والدروس الإسلامية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? FatimidColors.goldLight
                            : FatimidColors.goldPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Medallion Artwork
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: FatimidColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF0F2C22),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      color: FatimidColors.goldLight,
                      size: 52,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title & Sheikh
            Text(
              lecture.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F2C22),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lecture.sheikhName,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: FatimidColors.goldPrimary,
              ),
            ),
            if (lecture.hasVideo) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  LectureVideoPlayerDialog.show(
                    context,
                    lecture: lecture,
                    controller: controller,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFB45309)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded,
                          size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'مشاهدة الفيديو المرئي 🎬',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Playback Progress Slider
            StreamBuilder<Duration>(
              stream: service.positionStream,
              builder: (context, snapshot) {
                final pos = snapshot.data ?? service.position;
                final total = service.duration ?? Duration.zero;
                final posSec = pos.inSeconds.toDouble();
                final totalSec = total.inSeconds > 0
                    ? total.inSeconds.toDouble()
                    : (posSec > 0 ? posSec : 1.0);

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: FatimidColors.goldPrimary,
                        inactiveTrackColor: isDark
                            ? Colors.white12
                            : const Color(0xFFE2E8F0),
                        thumbColor: FatimidColors.goldLight,
                        overlayColor:
                            FatimidColors.goldPrimary.withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        trackHeight: 3.5,
                      ),
                      child: Slider(
                        value: posSec.clamp(0.0, totalSec),
                        max: totalSec,
                        onChanged: (val) {
                          service.seek(Duration(seconds: val.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(pos),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            total > Duration.zero
                                ? _formatTime(total)
                                : lecture.durationText,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            // Main Controls: Speed, Rewind 10s, Play/Pause, Forward 10s, Sleep Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Speed Selector Button
                ValueListenableBuilder<double>(
                  valueListenable: service.speedNotifier,
                  builder: (context, speed, _) => IconButton(
                    tooltip: 'سرعة القراءة ($speed x)',
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            FatimidColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              FatimidColors.goldPrimary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '${speed == speed.toInt() ? speed.toInt() : speed}x',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                    ),
                    onPressed: () => _showSpeedDialog(context),
                  ),
                ),

                // Rewind 10s
                IconButton(
                  tooltip: 'رجوع 10 ثوانٍ',
                  icon: const Icon(Icons.replay_10_rounded, size: 32),
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  onPressed: () =>
                      service.seekRelative(const Duration(seconds: -10)),
                ),

                // Big Play / Pause
                StreamBuilder(
                  stream: service.playerStateStream,
                  builder: (context, _) {
                    final isPlaying = service.isPlaying;
                    return GestureDetector(
                      onTap: controller.togglePlayPause,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: FatimidColors.goldGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: FatimidColors.goldPrimary
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 38,
                            color: const Color(0xFF261800),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Forward 10s
                IconButton(
                  tooltip: 'تقديم 10 ثوانٍ',
                  icon: const Icon(Icons.forward_10_rounded, size: 32),
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  onPressed: () =>
                      service.seekRelative(const Duration(seconds: 10)),
                ),

                // Sleep Timer Button
                ValueListenableBuilder<Duration?>(
                  valueListenable: service.sleepTimerRemainingNotifier,
                  builder: (context, remaining, _) {
                    final hasTimer = remaining != null;
                    return IconButton(
                      tooltip: hasTimer
                          ? 'مؤقت النوم نشط (${_formatTime(remaining)})'
                          : 'مؤقت النوم',
                      icon: Icon(
                        hasTimer ? Icons.bedtime : Icons.bedtime_outlined,
                        color: hasTimer
                            ? FatimidColors.goldPrimary
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                        size: 24,
                      ),
                      onPressed: () => _showSleepTimerDialog(context),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Actions row: Favorite, Download, Share
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Favorite
                TextButton.icon(
                  icon: Icon(
                    controller.isFavorite(lecture.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: controller.isFavorite(lecture.id)
                        ? const Color(0xFFEF4444)
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
                    size: 19,
                  ),
                  label: Text(
                    controller.isFavorite(lecture.id) ? 'مفضل' : 'تفضيل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                    ),
                  ),
                  onPressed: () => controller.toggleFavorite(lecture),
                ),
                const SizedBox(width: 16),

                // Download
                TextButton.icon(
                  icon: Icon(
                    controller.isDownloaded(lecture.id)
                        ? Icons.check_circle_rounded
                        : Icons.download_rounded,
                    color: controller.isDownloaded(lecture.id)
                        ? const Color(0xFF10B981)
                        : FatimidColors.goldPrimary,
                    size: 19,
                  ),
                  label: Text(
                    controller.isDownloaded(lecture.id)
                        ? 'محمل أوفلاين'
                        : 'تنزيل أوفلاين',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                    ),
                  ),
                  onPressed: () {
                    if (!controller.isDownloaded(lecture.id)) {
                      controller.download(lecture);
                    }
                  },
                ),
                const SizedBox(width: 16),

                // Share
                TextButton.icon(
                  icon: Icon(
                    Icons.share_rounded,
                    size: 19,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  label: Text(
                    'مشاركة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                    ),
                  ),
                  onPressed: () {
                    // ignore: deprecated_member_use
                    Share.share(
                      'استمع إلى "${lecture.title}" لـ ${lecture.sheikhName}\n${lecture.audioUrl}\nعبر تطبيق ذكرني',
                      subject: lecture.title,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    final speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'سرعة التشغيل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ...speeds.map(
                (s) => ListTile(
                  dense: true,
                  title: Text(
                    s == 1.0 ? 'عادي (1.0x)' : '$s x',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: controller.service.speedNotifier.value == s
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: controller.service.speedNotifier.value == s
                          ? FatimidColors.goldPrimary
                          : null,
                    ),
                  ),
                  onTap: () {
                    controller.service.setSpeed(s);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    final timers = [
      {'label': '15 دقيقة', 'duration': const Duration(minutes: 15)},
      {'label': '30 دقيقة', 'duration': const Duration(minutes: 30)},
      {'label': '45 دقيقة', 'duration': const Duration(minutes: 45)},
      {'label': 'ساعة كاملة', 'duration': const Duration(hours: 1)},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'مؤقت إيقاف التشغيل التلقائي (مؤقت النوم)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.service.sleepTimerRemainingNotifier.value != null)
                ListTile(
                  leading: const Icon(Icons.cancel_rounded, color: Colors.red),
                  title: const Text(
                    'إلغاء المؤقت الحالي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    controller.service.cancelSleepTimer();
                    Navigator.pop(ctx);
                  },
                ),
              ...timers.map(
                (item) => ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(
                    item['label'] as String,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  onTap: () {
                    controller.service.setSleepTimer(
                      item['duration'] as Duration,
                      onExpire: () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'انتهى مؤقت النوم وتم إيقاف التشغيل',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          );
                        }
                      },
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    final h = m ~/ 60;
    final min = m % 60;
    if (h > 0) {
      return '$h:${min.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$min:${s.toString().padLeft(2, '0')}';
  }
}
