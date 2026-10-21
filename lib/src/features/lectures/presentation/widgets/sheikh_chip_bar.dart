import 'package:flutter/material.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../application/lectures_controller.dart';

class SheikhChipBar extends StatelessWidget {
  const SheikhChipBar({
    super.key,
    required this.controller,
  });

  final LecturesController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheikhs = controller.allSheikhs;
    final selectedId = controller.selectedSheikhId;

    return SizedBox(
      height: 98,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: sheikhs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final sheikh = sheikhs[index];
          final isSelected = selectedId == sheikh.id;
          final lecturesCount =
              controller.getLecturesForSheikh(sheikh.id).length;

          return GestureDetector(
            onTap: () => controller.selectSheikh(sheikh.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 130,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? FatimidColors.obsidianCard
                        : const Color(0xFFF0FDF4))
                    : (isDark
                        ? FatimidColors.obsidianCard.withValues(alpha: 0.8)
                        : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? FatimidColors.goldPrimary
                      : (isDark
                          ? FatimidColors.goldPrimary.withValues(alpha: 0.18)
                          : const Color(0xFFE2E8F0)),
                  width: isSelected ? 1.6 : 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 5,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with initials / icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? FatimidColors.goldGradient
                          : LinearGradient(
                              colors: [
                                Color(sheikh.colorHex).withValues(alpha: 0.85),
                                Color(sheikh.colorHex),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(sheikh.name),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? const Color(0xFF261800)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Sheikh Name
                  Text(
                    sheikh.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected
                          ? (isDark
                              ? FatimidColors.goldLight
                              : FatimidColors.emeraldDark)
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),

                  // Count badge
                  Text(
                    '$lecturesCount درس وموعظة',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? FatimidColors.goldPrimary
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final clean = name.replaceFirst('الشيخ', '').replaceFirst('الدكتور', '').trim();
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'ش';
    if (parts.length == 1) return parts[0][0];
    return '${parts[0][0]}${parts[1][0]}';
  }
}
