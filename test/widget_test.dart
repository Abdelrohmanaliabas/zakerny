import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/adhkar/data/adhkar_repository.dart';
import 'package:zakerny/src/features/prayer_times/data/prayer_repository.dart';
import 'package:zakerny/src/features/qibla/data/qibla_repository.dart';
import 'package:zakerny/src/features/quran/data/quran_repository.dart';
import 'package:zakerny/src/features/recitations/data/recitation_repository.dart';

void main() {
  test('default prayer preferences are available offline', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final prefs = PrayerRepository(store).getPreferences();

    expect(prefs.city, 'القاهرة');
    expect(prefs.enabledPrayers['fajr'], isTrue);
  });

  test('quran local data contains juz, hizb, and page indexes', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final surahs = await QuranRepository(store).loadSurahs();
    final ayahs = surahs.expand((surah) => surah.ayahs).toList();

    expect(surahs.length, 114);
    expect(ayahs.any((ayah) => ayah.juz == 1), isTrue);
    expect(ayahs.any((ayah) => ayah.hizbQuarter == 1), isTrue);
    expect(ayahs.any((ayah) => ayah.page == 1), isTrue);
  });

  test('recitations include five reciters with full surah lists', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final reciters = await RecitationRepository(store).loadReciters();

    expect(reciters.length, 5);
    expect(reciters.every((reciter) => reciter.surahs.length == 114), isTrue);
    expect(reciters.any((reciter) => reciter.id == 'yasser_aldosari'), isTrue);
    expect(
      reciters.every(
        (reciter) =>
            reciter.surahs.every((surah) => surah.streamUrls.length > 1),
      ),
      isTrue,
    );
  });

  test('adhkar load offline and persist counters', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final repository = AdhkarRepository(store);
    final categories = await repository.loadCategories();
    final item = categories.first.items.first;

    expect(categories.isNotEmpty, isTrue);
    expect(repository.countFor(item.id), 0);
    await repository.increment(item);
    expect(repository.countFor(item.id), 1);
  });

  test('qibla direction can be calculated from saved location', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final direction = QiblaRepository(store).fromSavedLocation();

    expect(direction.bearing, greaterThan(0));
    expect(direction.distanceKm, greaterThan(0));
  });
}
