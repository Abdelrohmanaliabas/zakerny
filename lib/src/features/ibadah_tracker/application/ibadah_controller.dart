import 'package:flutter/foundation.dart';
import '../data/ibadah_repository.dart';
import '../domain/ibadah_model.dart';

class IbadahController extends ChangeNotifier {
  IbadahController(this._repository) {
    _selectedDate = DateTime.now();
    _currentRecord = _repository.getRecordForDate(_selectedDate);
  }

  final IbadahRepository _repository;
  late DateTime _selectedDate;
  late DailyIbadahRecord _currentRecord;

  DateTime get selectedDate => _selectedDate;
  DailyIbadahRecord get currentRecord => _currentRecord;

  List<DailyIbadahRecord> get past7Days =>
      _repository.getPast7DaysRecords(DateTime.now());

  void selectDate(DateTime date) {
    _selectedDate = date;
    _currentRecord = _repository.getRecordForDate(date);
    notifyListeners();
  }

  Future<void> updateRecord(DailyIbadahRecord updated) async {
    _currentRecord = updated;
    await _repository.saveRecord(_selectedDate, updated);
    notifyListeners();
  }

  Future<void> setPrayerStatus(String prayerKey, PrayerStatus status) async {
    DailyIbadahRecord updated;
    switch (prayerKey) {
      case 'fajr':
        updated = _currentRecord.copyWith(fajr: status);
        break;
      case 'dhuhr':
        updated = _currentRecord.copyWith(dhuhr: status);
        break;
      case 'asr':
        updated = _currentRecord.copyWith(asr: status);
        break;
      case 'maghrib':
        updated = _currentRecord.copyWith(maghrib: status);
        break;
      case 'isha':
        updated = _currentRecord.copyWith(isha: status);
        break;
      default:
        return;
    }
    await updateRecord(updated);
  }

  Future<void> toggleSunnah(String key) async {
    DailyIbadahRecord updated;
    switch (key) {
      case 'duha':
        updated = _currentRecord.copyWith(duha: !_currentRecord.duha);
        break;
      case 'witr':
        updated = _currentRecord.copyWith(witr: !_currentRecord.witr);
        break;
      case 'rawatib':
        updated = _currentRecord.copyWith(rawatib: !_currentRecord.rawatib);
        break;
      case 'quranWard':
        updated = _currentRecord.copyWith(quranWard: !_currentRecord.quranWard);
        break;
      case 'morningDhikr':
        updated = _currentRecord.copyWith(morningDhikr: !_currentRecord.morningDhikr);
        break;
      case 'eveningDhikr':
        updated = _currentRecord.copyWith(eveningDhikr: !_currentRecord.eveningDhikr);
        break;
      case 'fasting':
        updated = _currentRecord.copyWith(fasting: !_currentRecord.fasting);
        break;
      case 'sadaqah':
        updated = _currentRecord.copyWith(sadaqah: !_currentRecord.sadaqah);
        break;
      default:
        return;
    }
    await updateRecord(updated);
  }
}
