import 'dart:math';

class KhatmahPlan {
  const KhatmahPlan({
    required this.id,
    required this.title,
    required this.totalDays,
    required this.startDate,
    required this.currentPage,
    this.targetDate,
    this.dailyTargetPages = 20,
    this.reminderEnabled = true,
    this.reminderTime = '20:00',
    this.isCompleted = false,
    this.completedDate,
  });

  final String id;
  final String title;
  final int totalDays;
  final DateTime startDate;
  final DateTime? targetDate;
  final int currentPage; // 1 to 604
  final int dailyTargetPages;
  final bool reminderEnabled;
  final String reminderTime;
  final bool isCompleted;
  final DateTime? completedDate;

  static const int totalQuranPages = 604;

  double get progressPercentage =>
      ((currentPage / totalQuranPages) * 100).clamp(0.0, 100.0);

  int get remainingPages => max(0, totalQuranPages - currentPage);

  int get currentJuz {
    if (currentPage <= 0) return 1;
    final juz = ((currentPage - 1) / 20).floor() + 1;
    return juz.clamp(1, 30);
  }

  int get daysRemaining {
    final target = targetDate ?? startDate.add(Duration(days: totalDays));
    final diff = target.difference(DateTime.now()).inDays;
    return max(0, diff);
  }

  int get pagesPerPrayer => (dailyTargetPages / 5.0).ceil();

  int get todayExpectedPage {
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    final expected = (daysElapsed + 1) * dailyTargetPages;
    return expected.clamp(0, totalQuranPages);
  }

  int get pagesAheadOrBehind => currentPage - todayExpectedPage;

  KhatmahPlan copyWith({
    String? id,
    String? title,
    int? totalDays,
    DateTime? startDate,
    DateTime? targetDate,
    int? currentPage,
    int? dailyTargetPages,
    bool? reminderEnabled,
    String? reminderTime,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return KhatmahPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      totalDays: totalDays ?? this.totalDays,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      currentPage: currentPage ?? this.currentPage,
      dailyTargetPages: dailyTargetPages ?? this.dailyTargetPages,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String(),
        'targetDate': targetDate?.toIso8601String(),
        'currentPage': currentPage,
        'dailyTargetPages': dailyTargetPages,
        'reminderEnabled': reminderEnabled,
        'reminderTime': reminderTime,
        'isCompleted': isCompleted,
        'completedDate': completedDate?.toIso8601String(),
      };

  factory KhatmahPlan.fromJson(Map<String, dynamic> json) {
    return KhatmahPlan(
      id: json['id'] as String? ?? 'default_khatmah',
      title: json['title'] as String? ?? 'ختمة القرآن الكريم',
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 30,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      dailyTargetPages: (json['dailyTargetPages'] as num?)?.toInt() ?? 20,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? '20:00',
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
    );
  }
}
