import 'package:flutter/material.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../domain/lecture_models.dart';
import '../../application/lectures_controller.dart';
import 'lecture_card.dart';

class SeriesDetailView extends StatelessWidget {
  const SeriesDetailView({
    super.key,
    required this.series,
    required this.controller,
  });

  final LectureSeries series;
  final LecturesController controller;

  static void show(
    BuildContext context,
    LectureSeries series,
    LecturesController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SeriesDetailView(
        series: series,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final episodes = controller.getLecturesForSeries(series.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? FatimidColors.obsidianDark
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: FatimidColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFF261800),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            series.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F2C22),
                            ),
                          ),
                          Text(
                            '${series.sheikhName} • ${episodes.length} حلقة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FatimidColors.goldPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Description
              if (series.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      series.description,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              const Divider(height: 1),

              // Episodes list
              Expanded(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 40),
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final ep = episodes[index];
                        return LectureCard(
                          lecture: ep,
                          controller: controller,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
