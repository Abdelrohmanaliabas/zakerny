import 'package:flutter/material.dart';

class ZekrniHeader extends StatelessWidget {
  const ZekrniHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSearch = false,
    this.onSearchChanged,
  });

  final String title;
  final String? subtitle;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF101F1A).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.primary.withValues(alpha: 0.16),
                child: Icon(Icons.auto_stories, color: color.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(color: color.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.tune),
                tooltip: 'خيارات',
              ),
            ],
          ),
          if (showSearch) ...[
            const SizedBox(height: 16),
            TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'بحث...',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
