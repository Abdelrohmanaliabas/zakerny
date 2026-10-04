import 'package:flutter/material.dart';

enum QadaaPrayerType {
  fajr('fajr', 'صلاة الفجر', 2, Icons.wb_twilight_rounded, Color(0xFF2563EB)),
  dhuhr('dhuhr', 'صلاة الظهر', 4, Icons.wb_sunny_rounded, Color(0xFFD97706)),
  asr('asr', 'صلاة العصر', 4, Icons.wb_cloudy_rounded, Color(0xFFEA580C)),
  maghrib('maghrib', 'صلاة المغرب', 3, Icons.nightlight_round, Color(0xFFB45309)),
  isha('isha', 'صلاة العشاء', 4, Icons.nights_stay_rounded, Color(0xFF4F46E5)),
  witr('witr', 'صلاة الوتر', 3, Icons.auto_awesome_rounded, Color(0xFF0D9488));

  const QadaaPrayerType(
    this.id,
    this.title,
    this.rakats,
    this.icon,
    this.color,
  );

  final String id;
  final String title;
  final int rakats;
  final IconData icon;
  final Color color;

  static QadaaPrayerType fromId(String id) {
    return QadaaPrayerType.values.firstWhere(
      (p) => p.id == id,
      orElse: () => QadaaPrayerType.fajr,
    );
  }
}

class QadaaPrayerProgress {
  const QadaaPrayerProgress({
    required this.prayerType,
    required this.total,
    required this.completed,
  });

  final QadaaPrayerType prayerType;
  final int total;
  final int completed;

  int get remaining => (total - completed).clamp(0, total);
  double get progress => total <= 0 ? 1.0 : (completed / total).clamp(0.0, 1.0);
  bool get isCompleted => total > 0 && completed >= total;

  QadaaPrayerProgress copyWith({
    int? total,
    int? completed,
  }) {
    return QadaaPrayerProgress(
      prayerType: prayerType,
      total: total ?? this.total,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'prayerType': prayerType.id,
        'total': total,
        'completed': completed,
      };

  factory QadaaPrayerProgress.fromJson(Map<String, dynamic> json) =>
      QadaaPrayerProgress(
        prayerType: QadaaPrayerType.fromId(json['prayerType'] as String),
        total: json['total'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
      );
}

enum QadaaFastingType {
  ramadan('ramadan', 'قضاء رمضان', Icons.brightness_3_rounded, Color(0xFF10B981)),
  kaffarah('kaffarah', 'كفارة يمين / إفطار', Icons.healing_rounded, Color(0xFFF59E0B)),
  nadhr('nadhr', 'قضاء نذر', Icons.verified_rounded, Color(0xFF3B82F6)),
  tatawwu('tatawwu', 'تطوع قضاء', Icons.favorite_border_rounded, Color(0xFFEC4899));

  const QadaaFastingType(this.id, this.title, this.icon, this.color);

  final String id;
  final String title;
  final IconData icon;
  final Color color;

  static QadaaFastingType fromId(String id) {
    return QadaaFastingType.values.firstWhere(
      (f) => f.id == id,
      orElse: () => QadaaFastingType.ramadan,
    );
  }
}

class QadaaFastingRecord {
  const QadaaFastingRecord({
    required this.id,
    required this.date,
    required this.type,
    this.note,
  });

  final String id;
  final DateTime date;
  final QadaaFastingType type;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.id,
        if (note != null) 'note': note,
      };

  factory QadaaFastingRecord.fromJson(Map<String, dynamic> json) =>
      QadaaFastingRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        type: QadaaFastingType.fromId(json['type'] as String),
        note: json['note'] as String?,
      );
}
