import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/prayer_times/data/prayer_repository.dart';

void main() {
  test('default prayer preferences are available offline', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final prefs = PrayerRepository(store).getPreferences();

    expect(prefs.city, 'القاهرة');
    expect(prefs.enabledPrayers['fajr'], isTrue);
  });
}
