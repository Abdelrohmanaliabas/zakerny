import '../../../core/storage/app_local_store.dart';
import '../domain/ibadah_model.dart';

class IbadahRepository {
  IbadahRepository(this._store);

  final AppLocalStore _store;

  static String _keyForDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'ibadah_record_${y}_${m}_$d';
  }

  DailyIbadahRecord getRecordForDate(DateTime date) {
    final key = _keyForDate(date);
    final json = _store.getJson(key);
    if (json != null) {
      return DailyIbadahRecord.fromJson(json);
    }
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return DailyIbadahRecord(dateStr: '$y-$m-$d');
  }

  Future<void> saveRecord(DateTime date, DailyIbadahRecord record) async {
    final key = _keyForDate(date);
    await _store.setJson(key, record.toJson());
  }

  List<DailyIbadahRecord> getPast7DaysRecords(DateTime today) {
    final list = <DailyIbadahRecord>[];
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      list.add(getRecordForDate(d));
    }
    return list;
  }
}
