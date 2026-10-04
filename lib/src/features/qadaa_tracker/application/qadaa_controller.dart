import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/qadaa_repository.dart';
import '../domain/qadaa_models.dart';

class QadaaController extends ChangeNotifier {
  QadaaController(this._repository) {
    _loadData();
  }

  final QadaaRepository _repository;

  final Map<QadaaPrayerType, QadaaPrayerProgress> _prayers = {};
  int _fastingTarget = 0;
  List<QadaaFastingRecord> _fastingHistory = [];

  void _loadData() {
    for (final type in QadaaPrayerType.values) {
      _prayers[type] = _repository.getPrayerProgress(type);
    }
    _fastingTarget = _repository.getFastingTarget();
    _fastingHistory = _repository.getFastingHistory();
    notifyListeners();
  }

  // ----------------------------------------------------
  // Prayers Getters
  // ----------------------------------------------------
  QadaaPrayerProgress getPrayer(QadaaPrayerType type) {
    return _prayers[type] ??
        QadaaPrayerProgress(prayerType: type, total: 0, completed: 0);
  }

  List<QadaaPrayerProgress> get obligatoryPrayers => [
        getPrayer(QadaaPrayerType.fajr),
        getPrayer(QadaaPrayerType.dhuhr),
        getPrayer(QadaaPrayerType.asr),
        getPrayer(QadaaPrayerType.maghrib),
        getPrayer(QadaaPrayerType.isha),
      ];

  int get totalObligatoryTotal =>
      obligatoryPrayers.fold(0, (sum, p) => sum + p.total);

  int get totalObligatoryCompleted =>
      obligatoryPrayers.fold(0, (sum, p) => sum + p.completed);

  int get totalObligatoryRemaining =>
      obligatoryPrayers.fold(0, (sum, p) => sum + p.remaining);

  double get totalObligatoryProgress {
    if (totalObligatoryTotal <= 0) return 1.0;
    return (totalObligatoryCompleted / totalObligatoryTotal).clamp(0.0, 1.0);
  }

  int get estimatedRemainingDays {
    if (obligatoryPrayers.isEmpty) return 0;
    return obligatoryPrayers
        .map((p) => p.remaining)
        .reduce((a, b) => a > b ? a : b);
  }

  // ----------------------------------------------------
  // Prayers Actions
  // ----------------------------------------------------
  Future<void> completePrayer(QadaaPrayerType type, [int delta = 1]) async {
    final current = getPrayer(type);
    final nextCompleted = (current.completed + delta).clamp(0, current.total > 0 ? current.total : 999999);
    final updated = current.copyWith(completed: nextCompleted);
    _prayers[type] = updated;
    await _repository.setPrayerCompleted(type, nextCompleted);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  Future<void> undoPrayer(QadaaPrayerType type, [int delta = 1]) async {
    final current = getPrayer(type);
    final nextCompleted = (current.completed - delta).clamp(0, current.total);
    final updated = current.copyWith(completed: nextCompleted);
    _prayers[type] = updated;
    await _repository.setPrayerCompleted(type, nextCompleted);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  Future<void> completeFullDayObligatoryPrayers() async {
    for (final type in [
      QadaaPrayerType.fajr,
      QadaaPrayerType.dhuhr,
      QadaaPrayerType.asr,
      QadaaPrayerType.maghrib,
      QadaaPrayerType.isha,
    ]) {
      final current = getPrayer(type);
      final nextCompleted = (current.completed + 1).clamp(0, current.total > 0 ? current.total : 999999);
      _prayers[type] = current.copyWith(completed: nextCompleted);
      await _repository.setPrayerCompleted(type, nextCompleted);
    }
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  Future<void> setPrayerTotal(QadaaPrayerType type, int total) async {
    final current = getPrayer(type);
    final updated = current.copyWith(total: total.clamp(0, 999999));
    _prayers[type] = updated;
    await _repository.setPrayerTotal(type, updated.total);
    notifyListeners();
  }

  Future<void> setAllObligatoryTotals(int daysCount) async {
    for (final type in [
      QadaaPrayerType.fajr,
      QadaaPrayerType.dhuhr,
      QadaaPrayerType.asr,
      QadaaPrayerType.maghrib,
      QadaaPrayerType.isha,
    ]) {
      final current = getPrayer(type);
      _prayers[type] = current.copyWith(total: daysCount);
    }
    await _repository.batchSetObligatoryTotals(daysCount);
    notifyListeners();
  }

  Future<void> calculateAndSetFromDuration({
    int years = 0,
    int months = 0,
    int days = 0,
  }) async {
    final totalDays = (years * 365) + (months * 30) + days;
    await setAllObligatoryTotals(totalDays);
  }

  // ----------------------------------------------------
  // Fasting Getters & Actions
  // ----------------------------------------------------
  int get fastingTarget => _fastingTarget;

  int get fastingCompleted => _fastingHistory
      .where((r) => r.type == QadaaFastingType.ramadan)
      .length;

  int get fastingRemaining =>
      (_fastingTarget - fastingCompleted).clamp(0, _fastingTarget);

  double get fastingProgress {
    if (_fastingTarget <= 0) return 1.0;
    return (fastingCompleted / _fastingTarget).clamp(0.0, 1.0);
  }

  List<QadaaFastingRecord> get fastingHistory => List.unmodifiable(_fastingHistory);

  Future<void> setFastingTarget(int target) async {
    _fastingTarget = target.clamp(0, 9999);
    await _repository.setFastingTarget(_fastingTarget);
    notifyListeners();
  }

  Future<void> logFastingDay({
    required QadaaFastingType type,
    DateTime? date,
    String? note,
  }) async {
    final record = QadaaFastingRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date ?? DateTime.now(),
      type: type,
      note: note,
    );
    await _repository.addFastingRecord(record);
    _fastingHistory = _repository.getFastingHistory();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> removeFastingRecord(String id) async {
    await _repository.deleteFastingRecord(id);
    _fastingHistory = _repository.getFastingHistory();
    HapticFeedback.lightImpact();
    notifyListeners();
  }
}
