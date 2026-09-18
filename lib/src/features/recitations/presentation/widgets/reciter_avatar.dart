import 'package:flutter/material.dart';

import '../../domain/recitation_models.dart';

class ReciterAvatar extends StatelessWidget {
  const ReciterAvatar({
    super.key,
    required this.reciter,
    this.size = 46.0,
    this.showBorder = true,
  });

  final Reciter reciter;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildLetterFallback() {
      final nameTrimmed = reciter.name.trim();
      final initial = nameTrimmed.isNotEmpty ? nameTrimmed[0] : 'ق';

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              fontSize: size * 0.44,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    final photoUrl = reciter.photoUrl;

    Widget imageContent = Image.asset(
      reciter.defaultAvatarAsset,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (photoUrl != null && photoUrl.isNotEmpty) {
          return Image.network(
            photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => buildLetterFallback(),
          );
        }
        return buildLetterFallback();
      },
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: imageContent),
    );
  }
}
