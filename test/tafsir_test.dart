import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/quran/data/tafsir_service.dart';
import 'package:zakerny/src/features/quran/domain/quran_models.dart';
import 'package:zakerny/src/features/quran/domain/tafsir_models.dart';
import 'package:zakerny/src/features/quran/presentation/widgets/ayah_tafsir_sheet.dart';

class InMemoryAppLocalStore implements AppLocalStore {
  final Map<String, dynamic> _data = {};

  @override
  Future<void> init() async {}

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Future<void> setInt(String key, int value) async => _data[key] = value;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  Future<void> setDouble(String key, double value) async => _data[key] = value;

  @override
  Map<String, dynamic>? getJson(String key) =>
      _data[key] != null ? Map<String, dynamic>.from(_data[key] as Map) : null;

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async =>
      _data[key] = value;

  @override
  List<Map<String, dynamic>> getJsonList(String key) =>
      (_data[key] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ??
      [];

  @override
  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async =>
      _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

void main() {
  group('Tafsir models and service', () {
    test('supported tafsirs are available and include Muyassar and Jalalayn', () {
      expect(supportedTafsirs.length, greaterThanOrEqualTo(4));
      expect(supportedTafsirs.any((t) => t.id == 'ar.muyassar'), isTrue);
      expect(supportedTafsirs.any((t) => t.id == 'ar.jalalayn'), isTrue);
      expect(supportedTafsirs.any((t) => t.id == 'ar.saadi'), isTrue);
      expect(supportedTafsirs.any((t) => t.id == 'ar.ibnkathir'), isTrue);
    });

    test('tafsir service returns offline fallback when network is unavailable', () async {
      final store = InMemoryAppLocalStore();
      final service = TafsirService(store);

      final tafsir = await service.getAyahTafsir(
        surahId: 1,
        surahName: 'الفاتحة',
        ayahNumber: 1,
        ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      );

      expect(tafsir.surahId, 1);
      expect(tafsir.ayahNumber, 1);
      expect(tafsir.text, contains('أبتدئ قراءة القرآن'));
      expect(tafsir.editionId, 'ar.muyassar');
    });

    test('tafsir service caches and retrieves cached ayah tafsir properly', () async {
      final store = InMemoryAppLocalStore();
      final service = TafsirService(store);

      const customTafsir = AyahTafsir(
        surahId: 112,
        surahName: 'الإخلاص',
        ayahNumber: 1,
        ayahText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        editionId: 'ar.muyassar',
        editionName: 'التفسير الميسر',
        text: 'هو الله الواحد الأحد الذي لا شريك له.',
        isCached: true,
      );

      await store.setJson(
        'quran_tafsir_ar.muyassar_112_1',
        customTafsir.toJson(),
      );

      final result = await service.getAyahTafsir(
        surahId: 112,
        surahName: 'الإخلاص',
        ayahNumber: 1,
        ayahText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        editionId: 'ar.muyassar',
      );

      expect(result.text, 'هو الله الواحد الأحد الذي لا شريك له.');
    });

    test('tafsir preferred edition persists in store', () async {
      final store = InMemoryAppLocalStore();
      final service = TafsirService(store);

      expect(service.getPreferredEdition(), 'ar.muyassar');
      await service.setPreferredEdition('ar.jalalayn');
      expect(service.getPreferredEdition(), 'ar.jalalayn');
    });
  });

  group('AyahTafsirSheet Widget', () {
    testWidgets('AyahTafsirSheet renders ayah text, tafsir source selector, and controls',
        (tester) async {
      final store = InMemoryAppLocalStore();
      final service = TafsirService(store);

      const surah = Surah(
        id: 1,
        name: 'الفاتحة',
        ayahs: [
          Ayah(number: 1, text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AyahTafsirSheet(
              surah: surah,
              ayah: surah.ayahs.first,
              tafsirService: service,
              displayText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تفسير الآية الكريمة'), findsOneWidget);
      expect(find.textContaining('الفاتحة'), findsWidgets);
      expect(find.text('التفسير الميسر'), findsWidgets);
      expect(find.text('تفسير الجلالين'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });
  });
}
