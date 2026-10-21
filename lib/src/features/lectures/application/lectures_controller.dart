import 'package:flutter/foundation.dart';

import '../data/lecture_repository.dart';
import '../data/lectures_data.dart';
import '../domain/lecture_models.dart';
import 'lecture_service.dart';

class LecturesController extends ChangeNotifier {
  LecturesController({
    required this.repository,
    required this.service,
  }) {
    service.activeLectureNotifier.addListener(_onServiceChange);
    service.playerStateStream.listen((_) => notifyListeners());
  }

  final LectureRepository repository;
  final LectureService service;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  LectureCategory _selectedCategory = LectureCategory.all;
  LectureCategory get selectedCategory => _selectedCategory;

  String? _selectedSheikhId;
  String? get selectedSheikhId => _selectedSheikhId;

  String? _selectedSeriesId;
  String? get selectedSeriesId => _selectedSeriesId;

  bool _onlyDownloaded = false;
  bool get onlyDownloaded => _onlyDownloaded;

  void _onServiceChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    service.activeLectureNotifier.removeListener(_onServiceChange);
    super.dispose();
  }

  // Sheikhs & Series
  List<Sheikh> get allSheikhs => LecturesData.allSheikhs;
  List<LectureSeries> get allSeries => LecturesData.allSeries;
  List<LectureItem> get allLectures => LecturesData.allLectures;

  Sheikh? getSheikhById(String id) {
    try {
      return allSheikhs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  LectureSeries? getSeriesById(String id) {
    try {
      return allSeries.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<LectureSeries> getSeriesForSheikh(String sheikhId) {
    return allSeries.where((s) => s.sheikhId == sheikhId).toList();
  }

  List<LectureItem> getLecturesForSeries(String seriesId) {
    return allLectures.where((l) => l.seriesId == seriesId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  List<LectureItem> getLecturesForSheikh(String sheikhId) {
    return allLectures.where((l) => l.sheikhId == sheikhId).toList();
  }

  // Filtered lectures for current state
  List<LectureItem> get filteredLectures {
    return allLectures.where((item) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesSheikh = item.sheikhName.toLowerCase().contains(query);
        final matchesSeries = (item.seriesTitle ?? '').toLowerCase().contains(query);
        if (!matchesTitle && !matchesSheikh && !matchesSeries) return false;
      }

      // 2. Sheikh Filter
      if (_selectedSheikhId != null && item.sheikhId != _selectedSheikhId) {
        return false;
      }

      // 3. Series Filter
      if (_selectedSeriesId != null && item.seriesId != _selectedSeriesId) {
        return false;
      }

      // 4. Downloaded filter
      if (_onlyDownloaded || _selectedCategory == LectureCategory.downloaded) {
        if (!isDownloaded(item.id)) return false;
      }

      // 5. Category Filter
      if (_selectedCategory != LectureCategory.all &&
          _selectedCategory != LectureCategory.downloaded) {
        if (_selectedCategory == LectureCategory.series) {
          if (item.seriesId == null) return false;
        } else if (item.category != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(LectureCategory category) {
    _selectedCategory = category;
    if (category == LectureCategory.downloaded) {
      _onlyDownloaded = true;
    } else {
      _onlyDownloaded = false;
    }
    notifyListeners();
  }

  void selectSheikh(String? sheikhId) {
    if (_selectedSheikhId == sheikhId) {
      _selectedSheikhId = null;
    } else {
      _selectedSheikhId = sheikhId;
    }
    notifyListeners();
  }

  void selectSeries(String? seriesId) {
    _selectedSeriesId = seriesId;
    notifyListeners();
  }

  void toggleOnlyDownloaded() {
    _onlyDownloaded = !_onlyDownloaded;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = LectureCategory.all;
    _selectedSheikhId = null;
    _selectedSeriesId = null;
    _onlyDownloaded = false;
    notifyListeners();
  }

  // Playback
  bool isPlayingLecture(String lectureId) {
    final active = service.activeLecture;
    return active != null &&
        active.lecture.id == lectureId &&
        service.isPlaying;
  }

  bool isCurrentLecture(String lectureId) {
    final active = service.activeLecture;
    return active != null && active.lecture.id == lectureId;
  }

  Future<void> play(LectureItem lecture) async {
    final active = service.activeLecture;
    if (active != null && active.lecture.id == lecture.id) {
      if (service.isPlaying) {
        await service.pause();
      } else {
        await service.resume();
      }
      return;
    }

    final download = repository.findDownload(lecture.id);
    final savedSeconds = repository.getProgress(lecture.id);
    final initialPos = savedSeconds > 0 ? Duration(seconds: savedSeconds) : null;

    await service.playLecture(
      lecture,
      isDownloaded: download != null,
      localPath: download?.localPath,
      initialPosition: initialPos,
    );
    await repository.saveLastPlayed(lecture.id);
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (service.isPlaying) {
      await service.pause();
    } else {
      await service.resume();
    }
    notifyListeners();
  }

  // Downloads
  bool isDownloaded(String lectureId) => repository.isDownloaded(lectureId);

  double? getDownloadProgress(String lectureId) =>
      service.downloadProgressNotifier.value[lectureId];

  Future<void> download(LectureItem lecture) async {
    try {
      final path = await service.downloadLecture(lecture);
      await repository.saveDownload(
        DownloadedLecture(
          lectureId: lecture.id,
          localPath: path,
          downloadedAt: DateTime.now().toIso8601String(),
        ),
      );
      notifyListeners();
    } catch (err) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDownload(LectureItem lecture) async {
    final download = repository.findDownload(lecture.id);
    if (download != null) {
      await service.deleteDownload(download.localPath);
      await repository.removeDownload(lecture.id);
      notifyListeners();
    }
  }

  // Favorites
  bool isFavorite(String lectureId) => repository.isFavorite(lectureId);

  Future<void> toggleFavorite(LectureItem lecture) async {
    await repository.toggleFavorite(lecture.id);
    notifyListeners();
  }
}
