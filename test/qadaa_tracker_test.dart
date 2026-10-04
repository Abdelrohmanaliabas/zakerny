import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/qadaa_tracker/application/qadaa_controller.dart';
import 'package:zakerny/src/features/qadaa_tracker/data/qadaa_repository.dart';
import 'package:zakerny/src/features/qadaa_tracker/domain/qadaa_models.dart';
import 'package:zakerny/src/features/qadaa_tracker/presentation/qadaa_tracker_screen.dart';

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
  group('Qadaa Tracker Unit Tests', () {
    late InMemoryAppLocalStore store;
    late QadaaRepository repository;
    late QadaaController controller;

    setUp(() {
      store = InMemoryAppLocalStore();
      repository = QadaaRepository(store);
      controller = QadaaController(repository);
    });

    test('QadaaPrayerProgress calculates remaining and percentage accurately', () {
      final p1 = QadaaPrayerProgress(
        prayerType: QadaaPrayerType.fajr,
        total: 10,
        completed: 4,
      );

      expect(p1.remaining, 6);
      expect(p1.progress, closeTo(0.4, 0.001));
      expect(p1.isCompleted, isFalse);

      final p2 = QadaaPrayerProgress(
        prayerType: QadaaPrayerType.fajr,
        total: 10,
        completed: 10,
      );

      expect(p2.remaining, 0);
      expect(p2.progress, 1.0);
      expect(p2.isCompleted, isTrue);
    });

    test('QadaaController sets estimation period and batch creates totals', () async {
      await controller.calculateAndSetFromDuration(years: 0, months: 1, days: 0);

      expect(controller.totalObligatoryTotal, 30 * 5); // 5 obligatory prayers * 30 days
      expect(controller.getPrayer(QadaaPrayerType.fajr).total, 30);
      expect(controller.getPrayer(QadaaPrayerType.dhuhr).total, 30);
      expect(controller.getPrayer(QadaaPrayerType.asr).total, 30);
      expect(controller.getPrayer(QadaaPrayerType.maghrib).total, 30);
      expect(controller.getPrayer(QadaaPrayerType.isha).total, 30);
    });

    test('QadaaController handles single prayer completion and undo', () async {
      await controller.setPrayerTotal(QadaaPrayerType.fajr, 5);
      expect(controller.getPrayer(QadaaPrayerType.fajr).completed, 0);

      await controller.completePrayer(QadaaPrayerType.fajr);
      expect(controller.getPrayer(QadaaPrayerType.fajr).completed, 1);
      expect(controller.getPrayer(QadaaPrayerType.fajr).remaining, 4);

      await controller.undoPrayer(QadaaPrayerType.fajr);
      expect(controller.getPrayer(QadaaPrayerType.fajr).completed, 0);
      expect(controller.getPrayer(QadaaPrayerType.fajr).remaining, 5);
    });

    test('QadaaController batch completes a full day of obligatory prayers', () async {
      await controller.setPrayerTotal(QadaaPrayerType.fajr, 10);
      await controller.setPrayerTotal(QadaaPrayerType.dhuhr, 10);
      await controller.setPrayerTotal(QadaaPrayerType.asr, 10);
      await controller.setPrayerTotal(QadaaPrayerType.maghrib, 10);
      await controller.setPrayerTotal(QadaaPrayerType.isha, 10);

      await controller.completeFullDayObligatoryPrayers();

      expect(controller.getPrayer(QadaaPrayerType.fajr).completed, 1);
      expect(controller.getPrayer(QadaaPrayerType.dhuhr).completed, 1);
      expect(controller.getPrayer(QadaaPrayerType.asr).completed, 1);
      expect(controller.getPrayer(QadaaPrayerType.maghrib).completed, 1);
      expect(controller.getPrayer(QadaaPrayerType.isha).completed, 1);
      expect(controller.totalObligatoryCompleted, 5);
    });

    test('QadaaController manages fasting days and records', () async {
      await controller.setFastingTarget(15);
      expect(controller.fastingTarget, 15);
      expect(controller.fastingCompleted, 0);
      expect(controller.fastingRemaining, 15);

      await controller.logFastingDay(
        type: QadaaFastingType.ramadan,
        note: 'صيام الإثنين',
      );

      expect(controller.fastingCompleted, 1);
      expect(controller.fastingRemaining, 14);
      expect(controller.fastingHistory.length, 1);
      expect(controller.fastingHistory.first.type, QadaaFastingType.ramadan);
      expect(controller.fastingHistory.first.note, 'صيام الإثنين');

      final recordId = controller.fastingHistory.first.id;
      await controller.removeFastingRecord(recordId);

      expect(controller.fastingCompleted, 0);
      expect(controller.fastingHistory.isEmpty, isTrue);
    });

    testWidgets('QadaaTrackerScreen renders properly with prayers and fasting tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: QadaaTrackerScreen(controller: controller),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('سجل قضاء الصلوات والصيام'), findsWidgets);
      expect(find.text('قضاء الصلوات المفروضة'), findsOneWidget);
      expect(find.text('قضاء أيام الصيام'), findsOneWidget);
      expect(find.text('صلاة الفجر'), findsOneWidget);
      expect(find.text('صلاة الظهر'), findsOneWidget);
    });
  });
}
