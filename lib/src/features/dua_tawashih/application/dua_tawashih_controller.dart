import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../recitations/data/recitation_service.dart';
import '../../recitations/domain/recitation_models.dart';
import '../data/dua_tawashih_repository.dart';
import '../data/ruqyah_data.dart';
import '../domain/dua_models.dart';
import '../domain/ruqyah_models.dart';
import '../domain/tawashih_models.dart';

class DuaTawashihController extends ChangeNotifier {
  DuaTawashihController({
    required DuaTawashihRepository repository,
    required RecitationService recitationService,
  })  : _repository = repository,
        _recitationService = recitationService;

  final DuaTawashihRepository _repository;
  final RecitationService _recitationService;

  RecitationService get recitationService => _recitationService;

  // Duas state
  String _duaQuery = '';
  DuaCategoryType? _selectedCategory;
  bool _onlyFavoriteDuas = false;

  String get duaQuery => _duaQuery;
  DuaCategoryType? get selectedCategory => _selectedCategory;
  bool get onlyFavoriteDuas => _onlyFavoriteDuas;

  // Tawashih state
  String _tawashihQuery = '';
  String? _selectedMunshidId;
  bool _onlyFavoriteTawashih = false;

  String get tawashihQuery => _tawashihQuery;
  String? get selectedMunshidId => _selectedMunshidId;
  bool get onlyFavoriteTawashih => _onlyFavoriteTawashih;

  // Ruqyah state
  RuqyahSection _selectedRuqyahSection = RuqyahSection.all;
  RuqyahPurpose _selectedRuqyahPurpose = RuqyahPurpose.all;
  String _ruqyahQuery = '';
  String? _currentRuqyahAudioId;

  RuqyahSection get selectedRuqyahSection => _selectedRuqyahSection;
  RuqyahPurpose get selectedRuqyahPurpose => _selectedRuqyahPurpose;
  String get ruqyahQuery => _ruqyahQuery;
  String? get currentRuqyahAudioId => _currentRuqyahAudioId;

  // Currently playing Tawashih track ID
  String? _currentTawashihId;
  String? get currentTawashihId => _currentTawashihId;

  // Data getters
  List<Munshid> get munshidin => _repository.getMunshidin();

  List<DuaItem> get filteredDuas {
    final all = _repository.getDuas();
    return all.where((item) {
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_onlyFavoriteDuas && !_repository.isDuaFavorite(item.id)) {
        return false;
      }
      if (_duaQuery.trim().isNotEmpty) {
        final q = _duaQuery.trim().toLowerCase();
        final inTitle = item.title.toLowerCase().contains(q);
        final inText = item.text.toLowerCase().contains(q);
        final inSource = item.source.toLowerCase().contains(q);
        final inVirtue = item.virtue?.toLowerCase().contains(q) ?? false;
        if (!inTitle && !inText && !inSource && !inVirtue) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<TawashihItem> get filteredTawashih {
    final all = _repository.getTawashih();
    return all.where((item) {
      if (_selectedMunshidId != null && item.munshidId != _selectedMunshidId) {
        return false;
      }
      if (_onlyFavoriteTawashih && !_repository.isTawashihFavorite(item.id)) {
        return false;
      }
      if (_tawashihQuery.trim().isNotEmpty) {
        final q = _tawashihQuery.trim().toLowerCase();
        final inTitle = item.title.toLowerCase().contains(q);
        final inMunshid = item.munshidName.toLowerCase().contains(q);
        final inTheme = item.theme.toLowerCase().contains(q);
        final inLyrics = item.lyrics.toLowerCase().contains(q);
        if (!inTitle && !inMunshid && !inTheme && !inLyrics) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void setDuaQuery(String query) {
    _duaQuery = query;
    notifyListeners();
  }

  void selectCategory(DuaCategoryType? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void toggleOnlyFavoriteDuas() {
    _onlyFavoriteDuas = !_onlyFavoriteDuas;
    notifyListeners();
  }

  void setTawashihQuery(String query) {
    _tawashihQuery = query;
    notifyListeners();
  }

  void selectMunshid(String? munshidId) {
    _selectedMunshidId = munshidId;
    notifyListeners();
  }

  void toggleOnlyFavoriteTawashih() {
    _onlyFavoriteTawashih = !_onlyFavoriteTawashih;
    notifyListeners();
  }

  // Favorite toggles
  bool isDuaFavorite(String id) => _repository.isDuaFavorite(id);

  Future<void> toggleDuaFavorite(String id) async {
    await _repository.toggleFavoriteDua(id);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  bool isTawashihFavorite(String id) => _repository.isTawashihFavorite(id);

  Future<void> toggleTawashihFavorite(String id) async {
    await _repository.toggleFavoriteTawashih(id);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  // Counter
  int getDuaCount(String id) => _repository.getDuaCount(id);

  Future<void> incrementDuaCount(String id) async {
    final current = getDuaCount(id);
    await _repository.setDuaCount(id, current + 1);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  Future<void> resetDuaCount(String id) async {
    await _repository.resetDuaCount(id);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  // Playback integration with RecitationService
  bool isTawashihPlaying(String id) {
    final active = _recitationService.activeRecitation;
    return active != null &&
        _currentTawashihId == id &&
        _recitationService.isPlaying;
  }

  bool isTawashihActive(String id) {
    return _currentTawashihId == id && _recitationService.activeRecitation != null;
  }

  Future<void> playTawashih(TawashihItem item) async {
    _currentTawashihId = item.id;
    notifyListeners();

    try {
      final reciter = Reciter(
        id: item.munshidId,
        name: item.munshidName,
        avatarAsset: 'assets/branding/app_icon.png',
        surahs: const [],
      );

      final surah = RecitationSurah(
        id: item.id.hashCode.abs(),
        name: item.title,
      );

      await _recitationService.playUrls(
        item.allAudioUrls,
        reciter: reciter,
        surah: surah,
        customTitle: item.title,
      );
      notifyListeners();
    } catch (_) {
      _currentTawashihId = null;
      notifyListeners();
    }
  }

  Future<void> pauseOrResume(TawashihItem item) async {
    try {
      if (_currentTawashihId == item.id) {
        if (_recitationService.isPlaying) {
          await _recitationService.pause();
        } else {
          await _recitationService.resume();
        }
        notifyListeners();
      } else {
        await playTawashih(item);
      }
    } catch (_) {
      _currentTawashihId = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _recitationService.stop();
    _currentTawashihId = null;
    _currentRuqyahAudioId = null;
    notifyListeners();
  }

  // ----------------------------------------------------
  // Ruqyah logic & methods
  // ----------------------------------------------------
  List<RuqyahAudioItem> get ruqyahAudios => RuqyahData.audios;

  List<RuqyahItem> get allRuqyahItems => [
        ...RuqyahData.quranicVerses,
        ...RuqyahData.sunnahDuas,
        ...RuqyahData.guidanceList,
      ];

  List<RuqyahItem> get filteredRuqyahItems {
    return allRuqyahItems.where((item) {
      if (_selectedRuqyahSection != RuqyahSection.all &&
          item.section != _selectedRuqyahSection) {
        return false;
      }
      if (_selectedRuqyahPurpose != RuqyahPurpose.all &&
          item.purpose != RuqyahPurpose.all &&
          item.purpose != _selectedRuqyahPurpose) {
        return false;
      }
      if (_ruqyahQuery.trim().isNotEmpty) {
        final q = _ruqyahQuery.trim().toLowerCase();
        final inTitle = item.title.toLowerCase().contains(q);
        final inText = item.arabicText.toLowerCase().contains(q);
        final inSource = item.source.toLowerCase().contains(q);
        final inBenefit = item.benefit?.toLowerCase().contains(q) ?? false;
        final inInstructions = item.instructions?.toLowerCase().contains(q) ?? false;
        if (!inTitle && !inText && !inSource && !inBenefit && !inInstructions) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void selectRuqyahSection(RuqyahSection s) {
    _selectedRuqyahSection = s;
    notifyListeners();
  }

  void selectRuqyahPurpose(RuqyahPurpose p) {
    _selectedRuqyahPurpose = p;
    notifyListeners();
  }

  void setRuqyahQuery(String q) {
    _ruqyahQuery = q;
    notifyListeners();
  }

  int getRuqyahCount(String id) => _repository.getRuqyahCount(id);

  Future<void> incrementRuqyahCount(String id) async {
    final current = getRuqyahCount(id);
    await _repository.setRuqyahCount(id, current + 1);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  Future<void> resetRuqyahCount(String id) async {
    await _repository.resetRuqyahCount(id);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  bool isRuqyahAudioPlaying(String id) {
    final active = _recitationService.activeRecitation;
    return active != null &&
        _currentRuqyahAudioId == id &&
        _recitationService.isPlaying;
  }

  bool isRuqyahAudioActive(String id) {
    return _currentRuqyahAudioId == id && _recitationService.activeRecitation != null;
  }

  Future<void> playRuqyahAudio(RuqyahAudioItem item) async {
    _currentRuqyahAudioId = item.id;
    _currentTawashihId = null;
    notifyListeners();

    try {
      final reciter = Reciter(
        id: item.id,
        name: item.reciterName,
        avatarAsset: 'assets/branding/app_icon.png',
        surahs: const [],
      );

      final surah = RecitationSurah(
        id: item.id.hashCode.abs(),
        name: item.title,
      );

      await _recitationService.playUrls(
        [item.audioUrl],
        reciter: reciter,
        surah: surah,
        customTitle: '${item.title} - ${item.reciterName}',
      );
      notifyListeners();
    } catch (_) {
      _currentRuqyahAudioId = null;
      notifyListeners();
    }
  }

  Future<void> pauseOrResumeRuqyah(RuqyahAudioItem item) async {
    try {
      if (_currentRuqyahAudioId == item.id) {
        if (_recitationService.isPlaying) {
          await _recitationService.pause();
        } else {
          await _recitationService.resume();
        }
        notifyListeners();
      } else {
        await playRuqyahAudio(item);
      }
    } catch (_) {
      _currentRuqyahAudioId = null;
      notifyListeners();
    }
  }
}
