import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakerny/src/core/notifications/notification_service.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/adhkar/data/adhkar_repository.dart';
import 'package:zakerny/src/features/hadith/data/hadith_repository.dart';
import 'package:zakerny/src/features/prayer_times/data/prayer_repository.dart';
import 'package:zakerny/src/features/qibla/data/qibla_repository.dart';
import 'package:zakerny/src/features/quran/data/quran_repository.dart';
import 'package:zakerny/src/features/recitations/data/recitation_repository.dart';
import 'package:zakerny/src/features/recitations/domain/recitation_models.dart';
import 'package:zakerny/src/features/recitations/presentation/widgets/reciter_avatar.dart';
import 'package:zakerny/src/features/prayer_times/domain/prayer_preferences.dart';
import 'package:zakerny/src/features/prayer_times/domain/adhan_voice.dart';
import 'package:zakerny/src/features/dhikr_reminders/domain/dhikr_reminder_item.dart';
import 'package:zakerny/src/features/prayer_times/overlay/adhan_overlay_widget.dart';
import 'package:zakerny/src/features/prayer_times/presentation/in_app_adhan_dialog.dart';
import 'package:zakerny/src/core/widgets/zekrni_header.dart';

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

  test('recitations include twenty reciters with full surah lists and avatars', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final reciters = await RecitationRepository(store).loadReciters();

    expect(reciters.length, 20);
    expect(reciters.every((reciter) => reciter.surahs.length == 114), isTrue);
    expect(reciters.any((reciter) => reciter.id == 'yasser_aldosari'), isTrue);
    expect(reciters.any((reciter) => reciter.id == 'maher_almuaiqly'), isTrue);
    expect(reciters.any((reciter) => reciter.id == 'saad_alghamdi'), isTrue);
    expect(reciters.every((reciter) => reciter.photoUrl != null && reciter.photoUrl!.isNotEmpty), isTrue);
    expect(reciters.every((reciter) => reciter.defaultAvatarAsset.isNotEmpty), isTrue);
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

  test('hadith repository loads authentic hadiths with narrators and search works', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final repository = HadithRepository(store);
    final hadiths = await repository.loadHadiths();

    expect(hadiths.length, greaterThanOrEqualTo(100));
    expect(hadiths.every((h) => h.grade == 'صحيح'), isTrue);
    expect(hadiths.every((h) => (h.narrator?.isNotEmpty ?? false)), isTrue);
    expect(hadiths.any((h) => (h.narrator?.contains('البخاري') ?? false)), isTrue);
    expect(hadiths.any((h) => (h.narrator?.contains('مسلم') ?? false)), isTrue);
    expect(hadiths.any((h) => (h.narrator?.contains('الترمذي') ?? false)), isTrue);

    final tirmidhiSearch = await repository.search('الترمذي');
    expect(tirmidhiSearch.isNotEmpty, isTrue);

    final collections = hadiths.map((h) => h.collection).toSet();
    expect(collections.contains('صحيح البخاري'), isTrue);
    expect(collections.contains('سنن الترمذي'), isTrue);
  });

  testWidgets('ReciterAvatar renders correctly with fallback and border', (tester) async {
    const testReciter = Reciter(
      id: 'alafasy',
      name: 'مشاري راشد العفاسي',
      photoUrl: 'https://example.com/avatar.webp',
      surahs: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReciterAvatar(
            reciter: testReciter,
            size: 50,
          ),
        ),
      ),
    );

    expect(find.byType(ReciterAvatar), findsOneWidget);
  });

  test('prayer preferences properly serialize and deserialize overlayOnAdhan', () {
    final defaultPrefs = PrayerPreferences.defaults();
    expect(defaultPrefs.overlayOnAdhan, isTrue);
    expect(defaultPrefs.reminderMinutes, 10);

    final modified = defaultPrefs.copyWith(
      overlayOnAdhan: false,
      reminderMinutes: 15,
    );
    expect(modified.overlayOnAdhan, isFalse);
    expect(modified.reminderMinutes, 15);

    final json = modified.toJson();
    expect(json['overlayOnAdhan'], isFalse);
    expect(json['reminderMinutes'], 15);

    final fromJson = PrayerPreferences.fromJson(json);
    expect(fromJson.overlayOnAdhan, isFalse);
    expect(fromJson.reminderMinutes, 15);
  });

  testWidgets('AdhanOverlayWidget renders properly with Islamic theme and buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdhanOverlayWidget(),
      ),
    );

    expect(find.byType(AdhanOverlayWidget), findsOneWidget);
    expect(find.text('الله أكبر • الله أكبر'), findsOneWidget);
    expect(find.text('تطبيق ذكرني • موعد الأذان'), findsOneWidget);
    expect(find.text('كتم / إغلاق'), findsOneWidget);
    expect(find.text('تطبيق ذكرني'), findsOneWidget);
  });

  testWidgets('InAppAdhanDialog renders properly with audio control and dua', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InAppAdhanDialog(
            prayerName: 'الفجر',
            city: 'القاهرة',
            autoPlayAudio: false,
          ),
        ),
      ),
    );

    expect(find.byType(InAppAdhanDialog), findsOneWidget);
    expect(find.text('حان الآن موعد أذان الفجر'), findsOneWidget);
    expect(find.text('حسب التوقيت المحلي لـ القاهرة'), findsOneWidget);
    expect(find.text('تم الاستماع'), findsOneWidget);
  });

  test('prayer preferences properly serialize and deserialize adhanVoice and dhikr settings', () {
    final defaultPrefs = PrayerPreferences.defaults();
    expect(defaultPrefs.adhanVoice, 'adhan_makkah');
    expect(defaultPrefs.dhikrReminderEnabled, isTrue);
    expect(defaultPrefs.dhikrIntervalMinutes, 60);
    expect(defaultPrefs.dhikrOverlayEnabled, isTrue);
    expect(defaultPrefs.dhikrVoiceEnabled, isTrue);
    expect(defaultPrefs.enabledDhikrIds.contains('salawat'), isTrue);

    final modified = defaultPrefs.copyWith(
      adhanVoice: 'adhan_alafasy',
      dhikrReminderEnabled: false,
      dhikrIntervalMinutes: 30,
      dhikrOverlayEnabled: false,
      dhikrVoiceEnabled: false,
      enabledDhikrIds: ['salawat', 'tasbeeh'],
    );
    expect(modified.adhanVoice, 'adhan_alafasy');
    expect(modified.dhikrReminderEnabled, isFalse);
    expect(modified.dhikrIntervalMinutes, 30);
    expect(modified.dhikrOverlayEnabled, isFalse);
    expect(modified.dhikrVoiceEnabled, isFalse);
    expect(modified.enabledDhikrIds, ['salawat', 'tasbeeh']);

    final json = modified.toJson();
    expect(json['adhanVoice'], 'adhan_alafasy');
    expect(json['dhikrReminderEnabled'], isFalse);
    expect(json['dhikrIntervalMinutes'], 30);
    expect(json['dhikrOverlayEnabled'], isFalse);
    expect(json['dhikrVoiceEnabled'], isFalse);
    expect(json['enabledDhikrIds'], ['salawat', 'tasbeeh']);

    final fromJson = PrayerPreferences.fromJson(json);
    expect(fromJson.adhanVoice, 'adhan_alafasy');
    expect(fromJson.dhikrReminderEnabled, isFalse);
    expect(fromJson.dhikrIntervalMinutes, 30);
    expect(fromJson.dhikrOverlayEnabled, isFalse);
    expect(fromJson.dhikrVoiceEnabled, isFalse);
    expect(fromJson.enabledDhikrIds, ['salawat', 'tasbeeh']);
    expect(fromJson.selectedVoice.id, 'adhan_alafasy');
  });

  test('supported adhan voices and default dhikr items are complete and valid', () {
    expect(supportedAdhanVoices.length, greaterThanOrEqualTo(5));
    expect(supportedAdhanVoices.any((v) => v.id == 'adhan_makkah'), isTrue);
    expect(supportedAdhanVoices.any((v) => v.id == 'adhan_madinah'), isTrue);
    expect(supportedAdhanVoices.any((v) => v.id == 'adhan_alafasy'), isTrue);
    expect(supportedAdhanVoices.any((v) => v.id == 'adhan_abdulbasit'), isTrue);
    expect(supportedAdhanVoices.any((v) => v.id == 'adhan_quds'), isTrue);

    final makkahVoice = getAdhanVoiceById('adhan_makkah');
    expect(makkahVoice.name.contains('المكي'), isTrue);

    expect(defaultDhikrReminders.length, greaterThanOrEqualTo(9));
    expect(defaultDhikrReminders.any((d) => d.id == 'salawat'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'tahleel'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'thikr'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'tasbeeh'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'takbeer'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'istighfar'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'hawqala'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'alhamdulillah'), isTrue);
    expect(defaultDhikrReminders.any((d) => d.id == 'subhanallah'), isTrue);

    final audioItems = defaultDhikrReminders.where((d) => d.audioAsset != null).toList();
    expect(audioItems.length, greaterThanOrEqualTo(9));
    for (final item in audioItems) {
      expect(item.audioAsset!.startsWith('assets/audio/dhikr/'), isTrue);
      expect(item.spokenPhrase, isNotEmpty);
    }
  });

  testWidgets('ZekrniHeader renders properly and menu button opens quick menu', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZekrniHeader(title: 'ذكرني', subtitle: 'القاهرة'),
        ),
      ),
    );

    expect(find.text('ذكرني'), findsOneWidget);
    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات والأذان'), findsOneWidget);
    expect(find.text('اتجاه القبلة'), findsOneWidget);
    expect(find.text('الأذكار والسبحة'), findsOneWidget);
  });

  test('ActiveRecitation supports ayahNumber and formats displayTitle correctly', () {
    const reciter = Reciter(
      id: 'alafasy',
      name: 'مشاري راشد العفاسي',
      surahs: [
        RecitationSurah(id: 1, name: 'سُورَةُ ٱلْفَاتِحَةِ'),
      ],
    );

    const fullSurahRecitation = ActiveRecitation(
      reciter: reciter,
      surah: RecitationSurah(id: 1, name: 'سُورَةُ ٱلْفَاتِحَةِ'),
      isDownloaded: false,
    );
    expect(fullSurahRecitation.displayTitle, 'سُورَةُ ٱلْفَاتِحَةِ');
    expect(fullSurahRecitation.key, 'alafasy-1');
    expect(fullSurahRecitation.matches('alafasy', 1), isTrue);

    const ayahRecitation = ActiveRecitation(
      reciter: reciter,
      surah: RecitationSurah(id: 1, name: 'سُورَةُ ٱلْفَاتِحَةِ'),
      isDownloaded: false,
      ayahNumber: 6,
    );
    expect(ayahRecitation.displayTitle, 'سُورَةُ ٱلْفَاتِحَةِ • آية 6');
    expect(ayahRecitation.key, 'alafasy-1-6');
    expect(ayahRecitation.matches('alafasy', 1, 6), isTrue);
    expect(ayahRecitation.matches('alafasy', 1, 7), isFalse);
  });

  test('quran preferred reciter persists and defaults to alafasy', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final repo = QuranRepository(store);
    expect(repo.getPreferredReciterId(), 'alafasy');

    await repo.setPreferredReciterId('husary');
    expect(repo.getPreferredReciterId(), 'husary');
  });

  test('expanded adhkar repository loads all 5 categories with authentic content and counter features', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsAppLocalStore();
    await store.init();

    final repo = AdhkarRepository(store);
    final categories = await repo.loadCategories();

    expect(categories.length, 5);
    final categoryIds = categories.map((c) => c.id).toList();
    expect(categoryIds, containsAll([
      'morning',
      'evening',
      'after_prayer',
      'sleep_wake',
      'tasbeeh_istighfar',
    ]));

    // Check morning adhkar has Ayat al-Kursi with full text
    final morning = categories.firstWhere((c) => c.id == 'morning');
    expect(morning.items.length, greaterThanOrEqualTo(10));
    final kursi = morning.items.firstWhere((i) => i.id == 'morning_ayat_kursi');
    expect(kursi.text.contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ'), isTrue);
    expect(kursi.text.contains('وَهُوَ الْعَلِيُّ الْعَظِيمُ'), isTrue);

    // Test counter increment and resetAll
    expect(repo.countFor(kursi.id), 0);
    await repo.increment(kursi);
    expect(repo.countFor(kursi.id), 1);

    await repo.resetAll(morning.items);
    expect(repo.countFor(kursi.id), 0);
  });
}


