import 'package:flutter/foundation.dart';
import '../data/khatmah_repository.dart';
import '../domain/khatmah_model.dart';

class KhatmahController extends ChangeNotifier {
  KhatmahController(this._repository) {
    _activePlan = _repository.getActiveKhatmah();
  }

  final KhatmahRepository _repository;
  late KhatmahPlan _activePlan;

  KhatmahPlan get activePlan => _activePlan;
  List<KhatmahPlan> get completedPlans => _repository.getCompletedKhatmahs();

  Future<void> updateCurrentPage(int page) async {
    await _repository.updateCurrentPage(page);
    _activePlan = _repository.getActiveKhatmah();
    notifyListeners();
  }

  Future<void> incrementPages(int delta) async {
    final target = _activePlan.currentPage + delta;
    await updateCurrentPage(target);
  }

  Future<void> createNewKhatmah({
    required String title,
    required int totalDays,
    int dailyTargetPages = 20,
    int startingPage = 1,
  }) async {
    await _repository.createNewKhatmah(
      title: title,
      totalDays: totalDays,
      dailyTargetPages: dailyTargetPages,
      startingPage: startingPage,
    );
    _activePlan = _repository.getActiveKhatmah();
    notifyListeners();
  }

  Future<void> toggleReminder(bool enabled) async {
    final updated = _activePlan.copyWith(reminderEnabled: enabled);
    await _repository.saveActiveKhatmah(updated);
    _activePlan = updated;
    notifyListeners();
  }

  Future<void> updateReminderTime(String time) async {
    final updated = _activePlan.copyWith(reminderTime: time);
    await _repository.saveActiveKhatmah(updated);
    _activePlan = updated;
    notifyListeners();
  }
}
