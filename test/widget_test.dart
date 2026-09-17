import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakerny/src/core/notifications/notification_service.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/adhkar/data/adhkar_repository.dart';
import 'package:zakerny/src/features/prayer_times/data/prayer_repository.dart';
import 'package:zakerny/src/features/qibla/data/qibla_repository.dart';
import 'package:zakerny/src/features/quran/data/quran_repository.dart';
import 'package:zakerny/src/features/recitations/data/recitation_repository.dart';
import 'package:zakerny/src/features/recitations/domain/recitation_models.dart';

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

  test('active recitation correctly matches reciter and surah', () {
    const reciter = Reciter(
      id: 'mishary',
      name: 'مشاري العفاسي',
      surahs: [],
    );
    const surah = RecitationSurah(
      id: 1,
      name: 'الفاتحة',
    );
    const active = ActiveRecitation(
      reciter: reciter,
      surah: surah,
      isDownloaded: true,
      localPath: '/path/to/mishary_1.mp3',
    );

    expect(active.matches('mishary', 1), isTrue);
    expect(active.matches('mishary', 2), isFalse);
    expect(active.matches('other', 1), isFalse);
    expect(active.key, 'mishary-1');
  });

  test('quran reader font size and mode can be persisted and retrieved', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final repository = QuranRepository(store);
    expect(repository.getFontSize(), 23.0);
    expect(repository.getMushafMode(), isTrue);

    await repository.setFontSize(28.0);
    await repository.setMushafMode(false);

    expect(repository.getFontSize(), 28.0);
    expect(repository.getMushafMode(), isFalse);
  });

  test('notification service initializes safely on desktop platforms', () async {
    final service = NotificationService();
    // On Windows test environment, isSupported is false
    expect(service.isSupported, isFalse);
    // These should complete without throwing any exception
    await service.initialize();
    await service.requestPermissions();
    await service.cancelAllPrayerNotifications();
  });
}

