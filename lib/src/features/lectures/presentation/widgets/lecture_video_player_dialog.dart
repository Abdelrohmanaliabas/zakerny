import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../domain/lecture_models.dart';
import '../../application/lectures_controller.dart';

class LectureVideoPlayerDialog extends StatelessWidget {
  const LectureVideoPlayerDialog({
    super.key,
    required this.lecture,
    required this.controller,
  });

  final LectureItem lecture;
  final LecturesController controller;

  static Future<void> show(
    BuildContext context, {
    required LectureItem lecture,
    required LecturesController controller,
  }) {
    // Pause any ongoing background audio so sound doesn't clash
    try {
      controller.service.pause();
    } catch (_) {}

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: isDesktop ? 40 : 20,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: isDesktop ? 620 : 580,
            ),
            child: LectureVideoPlayerDialog(
              lecture: lecture,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchVideo(BuildContext context) async {
    final videoUrl = lecture.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'عذراً، رابط الفيديو غير متاح حالياً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    try {
      controller.service.pause();
    } catch (_) {}

    final uri = Uri.parse(videoUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  void _copyLink(BuildContext context) {
    final videoUrl = lecture.videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: videoUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم نسخ رابط الفيديو إلى الحافظة بنجاح',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: FatimidColors.emeraldDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1613),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              border: Border(
                bottom: BorderSide(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: FatimidColors.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.video_collection_rounded,
                    color: Color(0xFF261800),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture.sheikhName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: FatimidColors.goldLight,
                        ),
                      ),
                      Text(
                        lecture.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'إغلاق',
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Body Preview Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Video Banner Card with glowing play button
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E2923),
                          const Color(0xFF0F1B17),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FatimidColors.goldPrimary.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Sheikh portrait if available
                        if (lecture.sheikhId == 'shaarawi')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Opacity(
                              opacity: 0.22,
                              child: Image.asset(
                                'assets/images/shaarawi.jpg',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Center Play Button & Title
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _launchVideo(context),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: FatimidColors.goldGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: FatimidColors.goldPrimary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 24,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 44,
                                  color: Color(0xFF261800),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FatimidColors.goldPrimary
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                lecture.seriesTitle ?? 'درس مرئي بجودة عالية',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: FatimidColors.goldLight,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // HD Badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: FatimidColors.emeraldDark
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF6EE7B7)
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.hd_rounded,
                                    size: 14, color: Color(0xFF6EE7B7)),
                                SizedBox(width: 4),
                                Text(
                                  'فيديو مرئي',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6EE7B7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: FatimidColors.goldLight),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'يتم تشغيل الفيديو عبر مشغل النظام أو المتصفح لدعم تسريع العتاد ودقة 4K مع الحفاظ الكامل على استقرار تلاوات القرآن الكريم والأصوات داخل التطبيق.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.5,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Action Buttons
                  Row(
                    children: [
                      // Launch Video Button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_fill_rounded,
                              size: 20),
                          label: const Text(
                            'تشغيل الفيديو الآن 🎬',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FatimidColors.goldPrimary,
                            foregroundColor: const Color(0xFF261800),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _launchVideo(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Secondary actions
                  Row(
                    children: [
                      // Copy link button
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text(
                            'نسخ رابط الفيديو 📋',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _copyLink(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Play Audio in-app button
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.headphones_rounded, size: 16),
                          label: const Text(
                            'استماع صوتياً فقط 🎧',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FatimidColors.goldLight,
                            side: BorderSide(
                              color: FatimidColors.goldPrimary
                                  .withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            controller.play(lecture);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
