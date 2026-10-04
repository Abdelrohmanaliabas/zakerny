import 'package:flutter/material.dart';

enum DuaCategoryType {
  quranic('quranic', 'أدعية قرآنية', Icons.menu_book_rounded, 'أدعية مباركة من آيات الذكر الحكيم'),
  prophetic('prophetic', 'جوامع الدعاء النبوي', Icons.auto_awesome_rounded, 'أدعية شاملة من هدي النبي ﷺ'),
  repentance('repentance', 'التوبة والاستغفار', Icons.autorenew_rounded, 'أدعية غفران الذنوب ومحو الخطايا وسيد الاستغفار'),
  relief('relief', 'تفريج الهم والكرب', Icons.healing_rounded, 'أدعية إزالة الغم وقضاء الحوائج والمحن'),
  rizq('rizq', 'الرزق والبركة', Icons.monetization_on_outlined, 'أدعية سعة الرزق والبركة وقضاء الدين'),
  healing('healing', 'الشفاء والعافية', Icons.favorite_border_rounded, 'أدعية الشفاء والعافية للمريض ورفع البلاء'),
  daily('daily', 'السفر واليوم والليلة', Icons.explore_outlined, 'أدعية السفر والمطر ودخول وخروج الأماكن'),
  family('family', 'الوالدين والذرية', Icons.family_restroom_rounded, 'أدعية بر الوالدين وصلاح الأبناء والأسرة'),
  nightSujood('night_sujood', 'السجود ومناجاة الأسحار', Icons.nights_stay_outlined, 'أدعية السجود والوتر والقنوت وقيام الليل'),
  seasons('seasons', 'الجمعة ورمضان والمواسم', Icons.brightness_auto_rounded, 'أدعية ساعة الإجابة وليلة القدر ومواسم الخير'),
  istikhara('istikhara', 'صلاة الاستخارة', Icons.help_outline_rounded, 'دعاء الاستخارة النبوي للتردد في الأمور'),
  khatm('khatm', 'دعاء ختم القرآن', Icons.workspace_premium_rounded, 'الدعاء المأثور الجامع لختم كتاب الله');

  const DuaCategoryType(this.id, this.title, this.icon, this.description);

  final String id;
  final String title;
  final IconData icon;
  final String description;

  static DuaCategoryType fromId(String id) {
    return DuaCategoryType.values.firstWhere(
      (c) => c.id == id,
      orElse: () => DuaCategoryType.quranic,
    );
  }
}

class DuaItem {
  const DuaItem({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.source,
    this.virtue,
    this.targetRepeat = 1,
  });

  final String id;
  final DuaCategoryType category;
  final String title;
  final String text;
  final String source;
  final String? virtue;
  final int targetRepeat;

  factory DuaItem.fromJson(Map<String, dynamic> json) => DuaItem(
        id: json['id'] as String,
        category: DuaCategoryType.fromId(json['category'] as String),
        title: json['title'] as String,
        text: json['text'] as String,
        source: json['source'] as String,
        virtue: json['virtue'] as String?,
        targetRepeat: json['targetRepeat'] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.id,
        'title': title,
        'text': text,
        'source': source,
        if (virtue != null) 'virtue': virtue,
        'targetRepeat': targetRepeat,
      };
}
