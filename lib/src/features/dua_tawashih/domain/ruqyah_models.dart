import 'package:flutter/material.dart';

enum RuqyahSection {
  all('all', 'الكل', Icons.auto_awesome_rounded),
  quran('quran', 'آيات الرقية من القرآن', Icons.menu_book_rounded),
  sunnah('sunnah', 'أدعية الرقية من السنة', Icons.favorite_border_rounded),
  guidance('guidance', 'كيفية وضوابط الرقية', Icons.info_outline_rounded);

  const RuqyahSection(this.id, this.title, this.icon);
  final String id;
  final String title;
  final IconData icon;
}

enum RuqyahPurpose {
  all('all', 'جميع العلل والتحصينات'),
  hasad('hasad', 'العين والحسد'),
  sihr('sihr', 'السحر والمس والوسواس'),
  shifa('shifa', 'الأمراض والآلام والشفاء'),
  children('children', 'تحصين الأطفال والبيت');

  const RuqyahPurpose(this.id, this.title);
  final String id;
  final String title;
}

class RuqyahItem {
  const RuqyahItem({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.source,
    required this.section,
    this.targetRepeat = 1,
    this.instructions,
    this.benefit,
    this.purpose = RuqyahPurpose.all,
  });

  final String id;
  final String title;
  final String arabicText;
  final String source;
  final RuqyahSection section;
  final int targetRepeat;
  final String? instructions;
  final String? benefit;
  final RuqyahPurpose purpose;
}

class RuqyahAudioItem {
  const RuqyahAudioItem({
    required this.id,
    required this.reciterName,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.description,
  });

  final String id;
  final String reciterName;
  final String title;
  final String audioUrl;
  final String duration;
  final String description;
}
