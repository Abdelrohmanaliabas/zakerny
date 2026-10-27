import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/core/storage/app_local_store.dart';
import 'package:zakerny/src/features/lectures/application/lecture_service.dart';
import 'package:zakerny/src/features/lectures/application/lectures_controller.dart';
import 'package:zakerny/src/features/lectures/data/lecture_repository.dart';
import 'package:zakerny/src/features/lectures/data/lectures_data.dart';
import 'package:zakerny/src/features/lectures/domain/lecture_models.dart';

class _FakeStore implements AppLocalStore {
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
      _data[key] as Map<String, dynamic>?;

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async =>
      _data[key] = value;

  @override
  List<Map<String, dynamic>> getJsonList(String key) {
    final val = _data[key];
    if (val is List) {
      return val.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  @override
  Future<void> setJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async =>
      _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lectures & Series Feature Tests', () {
    test('LecturesData has famous sheikhs including Sheikh Samir Mostafa', () {
      final sheikhs = LecturesData.allSheikhs;
      expect(sheikhs.length, greaterThanOrEqualTo(5));

      final samir = sheikhs.firstWhere((s) => s.id == 'samir_mostafa');
      expect(samir.name, contains('مصطفى'));
      expect(samir.name, contains('سمير'));

      final othman = sheikhs.firstWhere((s) => s.id == 'othman_khamis');
      expect(othman.name, contains('عثمان الخميس'));
    });

    test('LecturesData contains verified series and over 300 lectures', () {
      final series = LecturesData.allSeries;
      expect(series.length, greaterThanOrEqualTo(10));

      final lectures = LecturesData.allLectures;
      expect(lectures.length, greaterThan(300));

      for (final l in lectures.take(20)) {
        expect(l.id, isNotEmpty);
        expect(l.title, isNotEmpty);
        expect(l.audioUrl, startsWith('http'));
      }
    });

    test('LectureRepository properly manages favorites and downloads', () async {
      final store = _FakeStore();
      final repo = LectureRepository(store);

      expect(repo.getFavorites(), isEmpty);
      expect(repo.isFavorite('samir_khotab_1'), isFalse);

      await repo.toggleFavorite('samir_khotab_1');
      expect(repo.isFavorite('samir_khotab_1'), isTrue);
      expect(repo.getFavorites(), contains('samir_khotab_1'));

      await repo.toggleFavorite('samir_khotab_1');
      expect(repo.isFavorite('samir_khotab_1'), isFalse);

      expect(repo.downloads(), isEmpty);
      await repo.saveDownload(
        const DownloadedLecture(
          lectureId: 'samir_khotab_1',
          localPath: '/tmp/test.mp3',
          downloadedAt: '2026-10-22',
        ),
      );
      expect(repo.isDownloaded('samir_khotab_1'), isTrue);
      expect(repo.findDownload('samir_khotab_1')?.localPath, '/tmp/test.mp3');

      await repo.removeDownload('samir_khotab_1');
      expect(repo.isDownloaded('samir_khotab_1'), isFalse);
    });

    test('LecturesController filters by sheikh and search query', () {
      final store = _FakeStore();
      final repo = LectureRepository(store);
      final service = LectureService();
      final controller = LecturesController(repository: repo, service: service);

      expect(controller.filteredLectures.length, LecturesData.allLectures.length);

      // Filter by Samir Mostafa
      controller.selectSheikh('samir_mostafa');
      expect(
        controller.filteredLectures.every((l) => l.sheikhId == 'samir_mostafa'),
        isTrue,
      );

      // Search query
      controller.setSearchQuery('الثبات');
      expect(
        controller.filteredLectures.every(
          (l) => l.title.contains('الثبات') || l.sheikhName.contains('الثبات'),
        ),
        isTrue,
      );

      // Reset
      controller.resetFilters();
      expect(controller.filteredLectures.length, LecturesData.allLectures.length);
    });

    test('LecturesData includes Sheikh Mohamed Metwally El-Shaarawy with series and video lectures', () {
      final sheikhs = LecturesData.allSheikhs;
      final shaarawi = sheikhs.firstWhere((s) => s.id == 'shaarawi');
      expect(shaarawi.name, contains('الشعراوي'));
      expect(shaarawi.title, contains('إمام الدعاة'));

      final series = LecturesData.allSeries.where((s) => s.sheikhId == 'shaarawi').toList();
      expect(series.length, greaterThanOrEqualTo(3));
      expect(series.any((s) => s.id == 'shaarawi_khotab'), isTrue);

      final lectures = LecturesData.allLectures.where((l) => l.sheikhId == 'shaarawi').toList();
      expect(lectures.length, greaterThanOrEqualTo(10));

      final videoLectures = lectures.where((l) => l.hasVideo).toList();
      expect(videoLectures, isNotEmpty);
      expect(videoLectures.first.videoUrl, startsWith('http'));

      final json = videoLectures.first.toJson();
      expect(json['videoUrl'], isNotNull);
      final restored = LectureItem.fromJson(json);
      expect(restored.hasVideo, isTrue);
      expect(restored.videoUrl, equals(videoLectures.first.videoUrl));
    });
  });
}
