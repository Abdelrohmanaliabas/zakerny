import 'package:flutter/material.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../domain/lecture_models.dart';
import '../../application/lectures_controller.dart';
import 'lecture_video_player_dialog.dart';

class LectureCard extends StatelessWidget {
  const LectureCard({
    super.key,
    required this.lecture,
    required this.controller,
    this.onTap,
  });

  final LectureItem lecture;
  final LecturesController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrent = controller.isCurrentLecture(lecture.id);
    final isPlaying = controller.isPlayingLecture(lecture.id);
    final isDownloaded = controller.isDownloaded(lecture.id);
    final isFav = controller.isFavorite(lecture.id);
    final progress = controller.getDownloadProgress(lecture.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark
                ? FatimidColors.obsidianCard
                : const Color(0xFFF0FDF4))
            : (isDark
                ? FatimidColors.obsidianCard.withValues(alpha: 0.9)
                : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? FatimidColors.goldPrimary
              : (isDark
                  ? FatimidColors.goldPrimary.withValues(alpha: 0.15)
                  : const Color(0xFFE2E8F0)),
          width: isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => controller.play(lecture),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Play / State Avatar Button
                GestureDetector(
                  onTap: () => controller.play(lecture),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isCurrent
                          ? FatimidColors.goldGradient
                          : LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E293B),
                                      const Color(0xFF0F172A)
                                    ]
                                  : [
                                      const Color(0xFFF1F5F9),
                                      const Color(0xFFE2E8F0)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? FatimidColors.goldPrimary
                            : FatimidColors.goldPrimary.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isCurrent
                            ? const Color(0xFF261800)
                            : (isDark
                                ? FatimidColors.goldLight
                                : FatimidColors.emeraldPrimary),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Lecture details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight:
                              isCurrent ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 13.5,
                          color: isCurrent
                              ? (isDark
                                  ? FatimidColors.goldLight
                                  : FatimidColors.emeraldDark)
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A)),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              lecture.sheikhName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          if (lecture.durationText.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 11,
                                    color: FatimidColors.goldPrimary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    lecture.durationText,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (lecture.seriesTitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          lecture.seriesTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                      if (lecture.hasVideo) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => LectureVideoPlayerDialog.show(
                            context,
                            lecture: lecture,
                            controller: controller,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706)
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.45),
                                width: 0.9,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam_rounded,
                                    size: 11, color: Color(0xFFF59E0B)),
                                SizedBox(width: 3),
                                Text(
                                  'مشاهدة الفيديو 🎥',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action buttons: Video, Download, Favorite
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video Play Action
                    if (lecture.hasVideo)
                      IconButton(
                        tooltip: 'مشاهدة الفيديو',
                        icon: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Color(0xFFF59E0B),
                          size: 24,
                        ),
                        onPressed: () => LectureVideoPlayerDialog.show(
                          context,
                          lecture: lecture,
                          controller: controller,
                        ),
                      ),
                    // Download action
                    if (progress != null)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.5,
                              color: FatimidColors.goldPrimary,
                              backgroundColor:
                                  FatimidColors.goldPrimary.withValues(alpha: 0.2),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isDownloaded)
                      IconButton(
                        tooltip: 'محمل أوفلاين (اضغط للحذف)',
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 22,
                        ),
                        onPressed: () => _confirmDelete(context),
                      )
                    else
                      IconButton(
                        tooltip: 'تنزيل للاستماع بدون إنترنت',
                        icon: Icon(
                          Icons.download_rounded,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          size: 22,
                        ),
                        onPressed: () => _handleDownload(context),
                      ),

                    // Favorite button
                    IconButton(
                      tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav
                            ? const Color(0xFFEF4444)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                        size: 20,
                      ),
                      onPressed: () => controller.toggleFavorite(lecture),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDownload(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'جاري بدء تنزيل: ${lecture.title}',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      await controller.download(lecture);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF047857),
            content: Text(
              'تم تنزيل الدرس بنجاح للاستماع أوفلاين: ${lecture.title}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB91C1C),
            content: Text(
              'تعذر التنزيل، يرجى المحاولة لاحقاً: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'حذف الدرس المحمل',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف ملف "${lecture.title}" من الذاكرة المحلية لتوفير المساحة؟',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteDownload(lecture);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم حذف الملف من الذاكرة المحلية',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
