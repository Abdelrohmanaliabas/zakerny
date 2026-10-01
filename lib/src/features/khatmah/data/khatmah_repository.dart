import '../../../core/storage/app_local_store.dart';
import '../domain/khatmah_model.dart';

class KhatmahRepository {
  KhatmahRepository(this._store);

  final AppLocalStore _store;

  static const _activeKhatmahKey = 'active_khatmah_plan';
  static const _completedKhatmahsKey = 'completed_khatmahs_history';

  KhatmahPlan getActiveKhatmah() {
    final json = _store.getJson(_activeKhatmahKey);
    if (json != null) {
      return KhatmahPlan.fromJson(json);
    }
    // Default initial Khatmah plan: 30 days, starting today
    final now = DateTime.now();
    return KhatmahPlan(
      id: 'khatmah_${now.millisecondsSinceEpoch}',
      title: 'ختمة شهر القرآن',
      totalDays: 30,
      startDate: now,
      targetDate: now.add(const Duration(days: 30)),
      currentPage: 1,
      dailyTargetPages: 20,
    );
  }

  Future<void> saveActiveKhatmah(KhatmahPlan plan) async {
    await _store.setJson(_activeKhatmahKey, plan.toJson());
  }

  Future<void> updateCurrentPage(int newPage) async {
    final current = getActiveKhatmah();
    final clampedPage = newPage.clamp(1, KhatmahPlan.totalQuranPages);
    final isDone = clampedPage >= KhatmahPlan.totalQuranPages;

    final updated = current.copyWith(
      currentPage: clampedPage,
      isCompleted: isDone,
      completedDate: isDone ? DateTime.now() : null,
    );
    await saveActiveKhatmah(updated);

    if (isDone) {
      await _archiveCompletedKhatmah(updated);
    }
  }

  Future<void> createNewKhatmah({
    required String title,
    required int totalDays,
    int dailyTargetPages = 20,
    int startingPage = 1,
  }) async {
    final now = DateTime.now();
    final newPlan = KhatmahPlan(
      id: 'khatmah_${now.millisecondsSinceEpoch}',
      title: title,
      totalDays: totalDays,
      startDate: now,
      targetDate: now.add(Duration(days: totalDays)),
      currentPage: startingPage.clamp(1, KhatmahPlan.totalQuranPages),
      dailyTargetPages: dailyTargetPages,
    );
    await saveActiveKhatmah(newPlan);
  }

  List<KhatmahPlan> getCompletedKhatmahs() {
    final list = _store.getJsonList(_completedKhatmahsKey);
    return list.map(KhatmahPlan.fromJson).toList();
  }

  Future<void> _archiveCompletedKhatmah(KhatmahPlan plan) async {
    final existing = getCompletedKhatmahs();
    final updated = [plan, ...existing];
    await _store.setJsonList(
      _completedKhatmahsKey,
      updated.map((p) => p.toJson()).toList(),
    );
  }
}
