import '../../../core/storage/app_local_store.dart';
import '../domain/qadaa_models.dart';

class QadaaRepository {
  QadaaRepository(this._store);

  final AppLocalStore _store;

  static const String _prayerPrefix = 'qadaa_prayer_';
  static const String _fastingTargetKey = 'qadaa_fasting_target_v1';
  static const String _fastingHistoryKey = 'qadaa_fasting_history_v1';

  // ----------------------------------------------------
  // Prayers
  // ----------------------------------------------------
  QadaaPrayerProgress getPrayerProgress(QadaaPrayerType type) {
    final total = _store.getInt('$_prayerPrefix${type.id}_total') ?? 0;
    final completed = _store.getInt('$_prayerPrefix${type.id}_completed') ?? 0;
    return QadaaPrayerProgress(
      prayerType: type,
      total: total,
      completed: completed,
    );
  }

  Future<void> savePrayerProgress(QadaaPrayerProgress progress) async {
    await _store.setInt(
      '$_prayerPrefix${progress.prayerType.id}_total',
      progress.total,
    );
    await _store.setInt(
      '$_prayerPrefix${progress.prayerType.id}_completed',
      progress.completed,
    );
  }

  Future<void> setPrayerTotal(QadaaPrayerType type, int total) async {
    await _store.setInt('$_prayerPrefix${type.id}_total', total.clamp(0, 999999));
  }

  Future<void> setPrayerCompleted(QadaaPrayerType type, int completed) async {
    await _store.setInt('$_prayerPrefix${type.id}_completed', completed.clamp(0, 999999));
  }

  Future<void> batchSetObligatoryTotals(int daysCount) async {
    for (final type in [
      QadaaPrayerType.fajr,
      QadaaPrayerType.dhuhr,
      QadaaPrayerType.asr,
      QadaaPrayerType.maghrib,
      QadaaPrayerType.isha,
    ]) {
      await setPrayerTotal(type, daysCount);
    }
  }

  // ----------------------------------------------------
  // Fasting
  // ----------------------------------------------------
  int getFastingTarget() {
    return _store.getInt(_fastingTargetKey) ?? 0;
  }

  Future<void> setFastingTarget(int target) async {
    await _store.setInt(_fastingTargetKey, target.clamp(0, 99999));
  }

  List<QadaaFastingRecord> getFastingHistory() {
    final list = _store.getJsonList(_fastingHistoryKey);
    return list.map((json) => QadaaFastingRecord.fromJson(json)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addFastingRecord(QadaaFastingRecord record) async {
    final history = getFastingHistory();
    history.insert(0, record);
    await _store.setJsonList(
      _fastingHistoryKey,
      history.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> deleteFastingRecord(String id) async {
    final history = getFastingHistory();
    history.removeWhere((item) => item.id == id);
    await _store.setJsonList(
      _fastingHistoryKey,
      history.map((e) => e.toJson()).toList(),
    );
  }
}
