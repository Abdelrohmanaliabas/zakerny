import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../../recitations/data/recitation_service.dart';
import '../../../recitations/domain/recitation_models.dart';
import '../../domain/quran_models.dart';

class QuranTvChannelScreen extends StatefulWidget {
  const QuranTvChannelScreen({
    super.key,
    this.initialSurahId,
    this.initialAyahNumber,
    this.initialSurah,
    this.reciter,
    this.recitationService,
  });

  final int? initialSurahId;
  final int? initialAyahNumber;
  final Surah? initialSurah;
  final Reciter? reciter;
  final RecitationService? recitationService;

  static void show(
    BuildContext context, {
    int? surahId,
    int? ayahNumber,
    Surah? surah,
    Reciter? reciter,
    RecitationService? recitationService,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return QuranTvChannelScreen(
            initialSurahId: surahId,
            initialAyahNumber: ayahNumber,
            initialSurah: surah,
            reciter: reciter,
            recitationService: recitationService,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<QuranTvChannelScreen> createState() => _QuranTvChannelScreenState();
}

class _NatureScene {
  const _NatureScene({
    required this.id,
    required this.name,
    required this.category,
    required this.assetPath,
  });

  final String id;
  final String name;
  final String category;
  final String assetPath;
}

class _QuranTvChannelScreenState extends State<QuranTvChannelScreen>
    with TickerProviderStateMixin {
  late final RecitationService _service;
  late final AnimationController _kenBurnsController;
  late final ScrollController _scrollController;
  StreamSubscription<Duration>? _positionSub;

  // 21 Curated Diverse Scenic Nature Backgrounds
  static const List<_NatureScene> _scenes = [
    // Marine & Underwater Life 🐠🌊
    _NatureScene(
      id: 'coral_reef_fish',
      name: 'شعاب مرجانية وأسماك استوائية 🐠',
      category: 'أعماق البحار',
      assetPath: 'assets/images/nature/coral_reef_fish.jpg',
    ),
    _NatureScene(
      id: 'sea_turtle_reef',
      name: 'سلحفاة بحرية في مياه فيروزية 🐢',
      category: 'أعماق البحار',
      assetPath: 'assets/images/nature/sea_turtle_reef.jpg',
    ),
    _NatureScene(
      id: 'dolphins_ocean',
      name: 'دلافين في زرقة المحيط 🐬',
      category: 'أعماق البحار',
      assetPath: 'assets/images/nature/dolphins_ocean.jpg',
    ),
    _NatureScene(
      id: 'ocean_sunset_waves',
      name: 'أمواج البحر عند الغروب الذهبي 🌅',
      category: 'بحار وشواطئ',
      assetPath: 'assets/images/nature/ocean_sunset_waves.jpg',
    ),
    _NatureScene(
      id: 'tropical_island',
      name: 'جزيرة استوائية وشاطئ رملي 🏝️',
      category: 'بحار وشواطئ',
      assetPath: 'assets/images/nature/tropical_island.jpg',
    ),
    _NatureScene(
      id: 'ocean_coral_reef',
      name: 'أعماق المحيط وشعاب المرجان 🪸',
      category: 'أعماق البحار',
      assetPath: 'assets/images/nature/ocean_coral_reef.jpg',
    ),

    // Serene Wildlife & Animals 🐎🦌🦅🦩
    _NatureScene(
      id: 'arabian_horses_meadow',
      name: 'خيول عربية في مروج خضراء 🐎',
      category: 'حيوانات وطبيعة',
      assetPath: 'assets/images/nature/arabian_horses_meadow.jpg',
    ),
    _NatureScene(
      id: 'forest_deer',
      name: 'غزال وقور في غابة هادئة 🦌',
      category: 'حيوانات وطبيعة',
      assetPath: 'assets/images/nature/forest_deer.jpg',
    ),
    _NatureScene(
      id: 'majestic_eagle',
      name: 'نسر محلق فوق قمم الجبال 🦅',
      category: 'حيوانات وطبيعة',
      assetPath: 'assets/images/nature/majestic_eagle.jpg',
    ),
    _NatureScene(
      id: 'pink_flamingos',
      name: 'طيور فلامنجو على بحيرة هادئة 🦩',
      category: 'حيوانات وطبيعة',
      assetPath: 'assets/images/nature/pink_flamingos.jpg',
    ),

    // Waterfalls, Mountains & Valleys 🏞️🌲🏔️
    _NatureScene(
      id: 'waterfall',
      name: 'شلال الفردوس والواحة الخضراء 🌊',
      category: 'شلالات وأنهار',
      assetPath: 'assets/images/nature/waterfall.jpg',
    ),
    _NatureScene(
      id: 'mountain_stream',
      name: 'نهر جبلي عذب وغابات الصنوبر 🌲',
      category: 'شلالات وأنهار',
      assetPath: 'assets/images/nature/mountain_stream.jpg',
    ),
    _NatureScene(
      id: 'misty_valley',
      name: 'وادي الضباب الصباحي والبحيرة 🏔️',
      category: 'جبال ومروج',
      assetPath: 'assets/images/nature/misty_valley.jpg',
    ),
    _NatureScene(
      id: 'sunset_hills',
      name: 'غروب الشمس فوق التلال الزمردية 🌄',
      category: 'جبال ومروج',
      assetPath: 'assets/images/nature/sunset_hills.jpg',
    ),
    _NatureScene(
      id: 'alpine_flowers',
      name: 'مروج جبال الألب والزهور البرية 🌸',
      category: 'جبال ومروج',
      assetPath: 'assets/images/nature/alpine_flowers.jpg',
    ),
    _NatureScene(
      id: 'bamboo_forest',
      name: 'غابة الخيزران الزمردية الهادئة 🎋',
      category: 'غابات وطبيعة',
      assetPath: 'assets/images/nature/bamboo_forest.jpg',
    ),
    _NatureScene(
      id: 'autumn_lake',
      name: 'بحيرة خريفية ذهبية هادئة 🍂',
      category: 'غابات وطبيعة',
      assetPath: 'assets/images/nature/autumn_lake.jpg',
    ),
    _NatureScene(
      id: 'desert_dunes',
      name: 'كثبان الصحراء الذهبية المتموجة 🏜️',
      category: 'صحراء وآفاق',
      assetPath: 'assets/images/nature/desert_dunes.jpg',
    ),

    // Spiritual Holy Sanctuaries & Cosmos 🕋🕌🌌
    _NatureScene(
      id: 'makkah_twilight',
      name: 'الكعبة المشرفة والحرم المكي الشريف 🕋',
      category: 'مشاهد إيمانية',
      assetPath: 'assets/images/nature/makkah_twilight.jpg',
    ),
    _NatureScene(
      id: 'madinah_prophet',
      name: 'المسجد النبوي الشريف بالمدينة المنورة 🕌',
      category: 'مشاهد إيمانية',
      assetPath: 'assets/images/nature/madinah_prophet.jpg',
    ),
    _NatureScene(
      id: 'starry_galaxy',
      name: 'سماء مرصعة بالنجوم ومجرة درب التبانة 🌌',
      category: 'آفاق وسماوات',
      assetPath: 'assets/images/nature/starry_galaxy.jpg',
    ),
  ];

  int _currentSceneIndex = 0;
  Surah? _surah;
  bool _isLoading = true;
  bool _showHud = true;
  Timer? _hudTimer;
  Timer? _sceneCycleTimer;
  bool _autoCycleScenes = true;
  static const int _sceneCycleSeconds = 25; // Cycles every 25 seconds (Saudi Quran TV style)
  bool _showSceneToast = false;
  Timer? _sceneToastTimer;

  bool _isTvFocusMode = false;
  int _activeAyahIndex = 0;
  bool _isFullscreen = false;
  double? _dragSliderValue;

  // Manual calibration offset for perfect sync with any reciter's pacing
  int _userAyahOffset = 0;
  int _rawCalculatedIndex = 0;
  bool _autoSyncEnabled = true;

  // Timeline weights for accurate Ayah-speech synchronization
  List<double> _cumulativeAyahFractions = [];

  @override
  void initState() {
    super.initState();
    _service = widget.recitationService ?? RecitationService();

    // Cinematic Ken Burns camera zoom animation
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    if (widget.initialSurah != null) {
      _surah = widget.initialSurah;
      _computeAyahTimeline();
      _isLoading = false;
    } else {
      _loadSurahData();
    }

    _startHudTimer();
    _startSceneCycleTimer();
    _subscribeToAudioPosition();
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    _sceneCycleTimer?.cancel();
    _sceneToastTimer?.cancel();
    _positionSub?.cancel();
    _scrollController.dispose();
    _kenBurnsController.dispose();
    super.dispose();
  }

  void _computeAyahTimeline() {
    if (_surah == null || _surah!.ayahs.isEmpty) return;
    final ayahs = _surah!.ayahs;
    final weights = <double>[];
    double totalWeight = 0;

    for (int i = 0; i < ayahs.length; i++) {
      final a = ayahs[i];
      // Strip diacritics and signs to count actual phonetic letters
      final clean = a.text.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\s]'), '');
      final wordCount = a.text.trim().split(RegExp(r'\s+')).length;

      // Realistic recitation weight: character phonemes + word rhythm + verse waqf pause (~12 char units)
      double w = clean.length.toDouble() + (wordCount * 2.2) + 12.0;

      // Introductory Isti'adhah & Basmalah padding for the first verse (except Surah At-Tawbah)
      if (i == 0 && _surah!.id != 9) {
        w += 28.0;
      }
      weights.add(w);
      totalWeight += w;
    }

    _cumulativeAyahFractions = [];
    double accum = 0;
    for (final w in weights) {
      accum += w;
      _cumulativeAyahFractions.add(accum / totalWeight);
    }

    if (widget.initialAyahNumber != null) {
      final initialIdx = (widget.initialAyahNumber! - 1).clamp(0, ayahs.length - 1);
      _activeAyahIndex = initialIdx;
    }
  }

  Future<void> _loadSurahData() async {
    try {
      final raw = await rootBundle.loadString('assets/quran/quran.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final surahs = (json['surahs'] as List)
          .map((e) => Surah.fromJson(e as Map<String, dynamic>))
          .toList();

      final active = _service.activeRecitation;
      final targetId = widget.initialSurahId ?? active?.surah.id ?? 1;

      final match = surahs.where((s) => s.id == targetId).firstOrNull ?? surahs.first;

      if (mounted) {
        setState(() {
          _surah = match;
          _computeAyahTimeline();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _subscribeToAudioPosition() {
    _positionSub = _service.positionStream.listen((pos) {
      if (!mounted || _surah == null || _cumulativeAyahFractions.isEmpty) return;

      final dur = _service.duration;
      if (dur == null || dur <= Duration.zero) return;

      final progress = (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

      int rawIdx = 0;
      for (int i = 0; i < _cumulativeAyahFractions.length; i++) {
        if (progress <= _cumulativeAyahFractions[i]) {
          rawIdx = i;
          break;
        }
      }
      _rawCalculatedIndex = rawIdx;

      if (_autoSyncEnabled) {
        final targetIdx = (rawIdx + _userAyahOffset).clamp(0, _surah!.ayahs.length - 1);
        if (targetIdx != _activeAyahIndex) {
          setState(() {
            _activeAyahIndex = targetIdx;
          });

          // In continuous mode, smoothly keep the active ayah in view
          if (!_isTvFocusMode && _scrollController.hasClients) {
            _smoothScrollToActiveAyah(targetIdx);
          }
        }
      }
    });
  }

  void _smoothScrollToActiveAyah(int index) {
    if (!_scrollController.hasClients) return;
    // Estimated height per ayah card ~160px
    final targetOffset = (index * 155.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  void _stepAyah(int delta) {
    if (_surah == null || _surah!.ayahs.isEmpty) return;
    final total = _surah!.ayahs.length;
    final newIndex = (_activeAyahIndex + delta).clamp(0, total - 1);
    setState(() {
      _activeAyahIndex = newIndex;
      // Recalibrate offset so the user's manual step persists through audio progress
      _userAyahOffset = newIndex - _rawCalculatedIndex;
    });
    if (!_isTvFocusMode && _scrollController.hasClients) {
      _smoothScrollToActiveAyah(newIndex);
    }
    _onUserActivity();
  }

  void _resetSyncOffset() {
    setState(() {
      _userAyahOffset = 0;
      _activeAyahIndex = _rawCalculatedIndex.clamp(0, (_surah?.ayahs.length ?? 1) - 1);
    });
    if (!_isTvFocusMode && _scrollController.hasClients) {
      _smoothScrollToActiveAyah(_activeAyahIndex);
    }
    _onUserActivity();
  }

  void _toggleAutoSync() {
    setState(() {
      _autoSyncEnabled = !_autoSyncEnabled;
      if (_autoSyncEnabled) {
        _activeAyahIndex = (_rawCalculatedIndex + _userAyahOffset)
            .clamp(0, (_surah?.ayahs.length ?? 1) - 1);
      }
    });
    _onUserActivity();
  }

  void _seekAudioToAyah(int index) {
    if (_surah == null || index < 0 || index >= _surah!.ayahs.length) return;
    setState(() {
      _activeAyahIndex = index;
      _userAyahOffset = 0;
    });

    final dur = _service.duration;
    if (dur != null && dur > Duration.zero && index < _cumulativeAyahFractions.length) {
      final startFrac = index == 0 ? 0.0 : _cumulativeAyahFractions[index - 1];
      final targetMs = (startFrac * dur.inMilliseconds).toInt();
      try {
        _service.seek(Duration(milliseconds: targetMs));
      } catch (_) {}
    }

    if (!_isTvFocusMode && _scrollController.hasClients) {
      _smoothScrollToActiveAyah(index);
    }
    _onUserActivity();
  }

  void _jumpToAyah(int index) {
    _seekAudioToAyah(index);
  }

  void _nextAyah() {
    _stepAyah(1);
  }

  void _prevAyah() {
    _stepAyah(-1);
  }

  void _startSceneCycleTimer() {
    _sceneCycleTimer?.cancel();
    if (!_autoCycleScenes) return;

    _sceneCycleTimer = Timer.periodic(
      Duration(seconds: _sceneCycleSeconds),
      (_) {
        if (mounted && _autoCycleScenes) {
          setState(() {
            _currentSceneIndex = (_currentSceneIndex + 1) % _scenes.length;
            _showSceneToast = true;
          });
          _startSceneToastTimer();
        }
      },
    );
  }

  void _startSceneToastTimer() {
    _sceneToastTimer?.cancel();
    _sceneToastTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showSceneToast = false);
      }
    });
  }

  void _toggleAutoCycle() {
    setState(() {
      _autoCycleScenes = !_autoCycleScenes;
    });
    if (_autoCycleScenes) {
      _startSceneCycleTimer();
    } else {
      _sceneCycleTimer?.cancel();
    }
    _onUserActivity();
  }

  void _selectScene(int index) {
    setState(() {
      _currentSceneIndex = index;
      _showSceneToast = true;
    });
    _startSceneToastTimer();
    _onUserActivity();
  }

  void _startHudTimer() {
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _service.isPlaying) {
        setState(() => _showHud = false);
      }
    });
  }

  void _onUserActivity() {
    if (!_showHud) {
      setState(() => _showHud = true);
    }
    _startHudTimer();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleTvFocusMode() {
    setState(() {
      _isTvFocusMode = !_isTvFocusMode;
    });
    _onUserActivity();
    if (!_isTvFocusMode && _scrollController.hasClients) {
      _smoothScrollToActiveAyah(_activeAyahIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScene = _scenes[_currentSceneIndex];
    final reciter = widget.reciter ?? _service.activeRecitation?.reciter;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onUserActivity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Scenic Nature Background with Ken Burns & Smooth Cross-fade
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: AnimatedBuilder(
                  key: ValueKey<String>(currentScene.assetPath),
                  animation: _kenBurnsController,
                  builder: (context, child) {
                    final scale = 1.05 + (_kenBurnsController.value * 0.08);
                    final alignX = (_kenBurnsController.value - 0.5) * 0.15;
                    return Transform.scale(
                      scale: scale,
                      alignment: Alignment(alignX, 0.0),
                      child: Image.asset(
                        currentScene.assetPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.0,
                              colors: [Color(0xFF0F2B22), Color(0xFF06120E)],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Cinematic Atmosphere Dark Vignette & Gradient Overlays
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.15,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Central Quran Verses Content
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(FatimidColors.goldPrimary),
                  ),
                )
              else if (_surah != null)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isTvFocusMode
                        ? _buildTvFocusModeAyah()
                        : _buildContinuousVersesStream(),
                  ),
                ),

              // 4. Scene Transition Toast Badge
              if (_showSceneToast)
                Positioned(
                  top: 80,
                  left: 24,
                  child: AnimatedOpacity(
                    opacity: _showSceneToast ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.panorama_rounded,
                              size: 16, color: FatimidColors.goldLight),
                          const SizedBox(width: 8),
                          Text(
                            currentScene.name,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 5. Top TV Brand Header (RTL)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showHud ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_showHud,
                    child: _buildTopTvHeader(reciter),
                  ),
                ),
              ),

              // 6. Bottom TV HUD Audio Controls & Settings
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showHud ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_showHud,
                    child: _buildBottomHud(currentScene),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTvHeader(Reciter? reciter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 650;
            final isVeryCompact = constraints.maxWidth < 450;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TV Channel Logo
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryCompact ? 8 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: FatimidColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tv_rounded, size: 16, color: Color(0xFF261800)),
                      if (!isVeryCompact) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'قناة القرآن الكريم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF261800),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Surah Title in Center
                if (_surah != null)
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'سورة ${_surah!.name}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: FatimidColors.goldLight,
                                ),
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: FatimidColors.emeraldDark
                                      .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_surah!.revelationLabel} • ${_surah!.ayahs.length} آية',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6EE7B7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                // Reciter Badge
                if (reciter != null && !isCompact) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            reciter.defaultAvatarAsset,
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              size: 16,
                              color: FatimidColors.goldLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reciter.name,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(width: 8),

                // Close button
                IconButton(
                  tooltip: 'إغلاق شاشة القناة',
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinuousVersesStream() {
    final ayahs = _surah!.ayahs;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          itemCount: ayahs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildBasmalahHeader();
            }

            final ayahIdx = index - 1;
            final ayah = ayahs[ayahIdx];
            final isCurrent = ayahIdx == _activeAyahIndex;

            return GestureDetector(
              onTap: () => _jumpToAyah(ayahIdx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.black.withValues(alpha: 0.65)
                      : Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? FatimidColors.goldPrimary
                        : FatimidColors.goldPrimary.withValues(alpha: 0.2),
                    width: isCurrent ? 2.0 : 1.0,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Active indicator icon
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: FatimidColors.goldGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 14,
                          color: Color(0xFF261800),
                        ),
                      ),

                    // Ayah Calligraphy Text
                    Expanded(
                      child: Text(
                        ayah.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: isCurrent ? 24 : 21,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? FatimidColors.goldLight
                              : Colors.white.withValues(alpha: 0.88),
                          height: 2.1,
                          shadows: [
                            Shadow(
                              color: isCurrent
                                  ? FatimidColors.goldPrimary.withValues(alpha: 0.8)
                                  : Colors.black,
                              blurRadius: isCurrent ? 14 : 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Ayah Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? FatimidColors.goldPrimary
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _toArabicDigits(ayah.number),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFF261800) : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTvFocusModeAyah() {
    final ayahs = _surah!.ayahs;
    final currentAyah = ayahs[_activeAyahIndex.clamp(0, ayahs.length - 1)];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illuminated Central TV Card with smooth flip animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(currentAyah.number),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.75),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 36,
                      spreadRadius: 3,
                    ),
                    const BoxShadow(
                      color: Colors.black87,
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ayah Text
                    Text(
                      currentAyah.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: FatimidColors.goldLight,
                        height: 2.2,
                        shadows: [
                          Shadow(
                            color: Color(0xFFFBBF24),
                            blurRadius: 16,
                          ),
                          Shadow(
                            color: Colors.black,
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Ayah Progress Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: FatimidColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'الآية ${_toArabicDigits(currentAyah.number)} من ${_toArabicDigits(ayahs.length)}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF261800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Navigation & Sync Calibration Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Ayah Button
                IconButton(
                  tooltip: 'الآية السابقة (تأخير آية)',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FatimidColors.goldLight,
                      size: 18,
                    ),
                  ),
                  onPressed: _activeAyahIndex > 0 ? _prevAyah : null,
                ),

                const SizedBox(width: 16),

                // Ayah Index Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_toArabicDigits(_activeAyahIndex + 1)} / ${_toArabicDigits(ayahs.length)}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Next Ayah Button
                IconButton(
                  tooltip: 'الآية التالية (تقديم آية)',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: FatimidColors.goldLight,
                      size: 18,
                    ),
                  ),
                  onPressed: _activeAyahIndex < ayahs.length - 1 ? _nextAyah : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Live Sync Offset Calibration Toolbar
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                // Quick +1 Ayah Nudge
                InkWell(
                  onTap: () => _stepAyah(1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fast_forward_rounded,
                            size: 14, color: FatimidColors.goldLight),
                        SizedBox(width: 4),
                        Text(
                          '+1 آية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick -1 Ayah Nudge
                InkWell(
                  onTap: () => _stepAyah(-1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fast_rewind_rounded,
                            size: 14, color: FatimidColors.goldLight),
                        SizedBox(width: 4),
                        Text(
                          '-1 آية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Offset Indicator & Reset
                if (_userAyahOffset != 0)
                  InkWell(
                    onTap: _resetSyncOffset,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: FatimidColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded,
                              size: 13, color: Color(0xFF261800)),
                          const SizedBox(width: 4),
                          Text(
                            'ضبط (${_userAyahOffset > 0 ? "+$_userAyahOffset" : "$_userAyahOffset"})',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF261800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Seek audio to this verse
                InkWell(
                  onTap: () => _seekAudioToAyah(_activeAyahIndex),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white24,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded,
                            size: 13, color: FatimidColors.goldLight),
                        SizedBox(width: 4),
                        Text(
                          'تشغيل الصوت هنا',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Auto Sync Toggle
                InkWell(
                  onTap: _toggleAutoSync,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _autoSyncEnabled
                          ? Colors.teal.withValues(alpha: 0.25)
                          : Colors.orange.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _autoSyncEnabled
                            ? Colors.tealAccent.withValues(alpha: 0.5)
                            : Colors.orangeAccent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _autoSyncEnabled
                              ? Icons.sync_rounded
                              : Icons.sync_disabled_rounded,
                          size: 13,
                          color: _autoSyncEnabled
                              ? Colors.tealAccent
                              : Colors.orangeAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _autoSyncEnabled ? 'مزامنة تلقائية' : 'مزامنة يدوية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _autoSyncEnabled
                                ? Colors.tealAccent
                                : Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasmalahHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
            ),
          ),
          child: const Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: FatimidColors.goldPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHud(_NatureScene currentScene) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Audio Progress Slider with Safe Dragging
            StreamBuilder<Duration>(
              stream: _service.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? _service.position;
                return StreamBuilder<Duration?>(
                  stream: _service.durationStream,
                  builder: (context, durSnap) {
                    final dur = durSnap.data ?? _service.duration ?? Duration.zero;
                    final posMs = pos.inMilliseconds.toDouble();
                    final durMs = dur.inMilliseconds > 0
                        ? dur.inMilliseconds.toDouble()
                        : (posMs > 0 ? posMs : 1.0);

                    return Row(
                      children: [
                        Text(
                          _formatTime(Duration(
                            milliseconds: (_dragSliderValue ?? posMs).toInt(),
                          )),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.0,
                              activeTrackColor: FatimidColors.goldPrimary,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: FatimidColors.goldLight,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5),
                            ),
                            child: Slider(
                              value: (_dragSliderValue ?? posMs).clamp(0.0, durMs),
                              max: durMs,
                              onChanged: dur.inMilliseconds > 0
                                  ? (val) {
                                      setState(() => _dragSliderValue = val);
                                      _onUserActivity();
                                    }
                                  : null,
                              onChangeEnd: dur.inMilliseconds > 0
                                  ? (val) {
                                      try {
                                        _service.seek(Duration(milliseconds: val.toInt()));
                                      } catch (_) {}
                                      setState(() => _dragSliderValue = null);
                                      _onUserActivity();
                                    }
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(dur),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Controls Row
            Row(
              children: [
                // Play / Pause
                StreamBuilder<PlayerState>(
                  stream: _service.playerStateStream,
                  builder: (context, snap) {
                    final isPlaying = snap.data?.playing ?? _service.isPlaying;
                    return IconButton(
                      tooltip: isPlaying ? 'إيقاف مؤقت' : 'استئناف التلاوة',
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: FatimidColors.goldPrimary,
                        size: 34,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          _service.pause();
                        } else {
                          _service.resume();
                        }
                        _onUserActivity();
                      },
                    );
                  },
                ),

                // Replay 10s
                IconButton(
                  tooltip: 'رجوع 10 ثوانٍ',
                  icon: const Icon(Icons.replay_10_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    final target = _service.position - const Duration(seconds: 10);
                    try {
                      _service.seek(target < Duration.zero ? Duration.zero : target);
                    } catch (_) {}
                    _onUserActivity();
                  },
                ),

                // Forward 10s
                IconButton(
                  tooltip: 'تقديم 10 ثوانٍ',
                  icon: const Icon(Icons.forward_10_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    final target = _service.position + const Duration(seconds: 10);
                    try {
                      _service.seek(target);
                    } catch (_) {}
                    _onUserActivity();
                  },
                ),

                const SizedBox(width: 8),

                // Auto-Cycle Scenes Toggle
                GestureDetector(
                  onTap: _toggleAutoCycle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _autoCycleScenes
                          ? FatimidColors.emeraldDark.withValues(alpha: 0.85)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _autoCycleScenes
                            ? FatimidColors.goldPrimary
                            : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _autoCycleScenes
                              ? Icons.autorenew_rounded
                              : Icons.pause_circle_outline_rounded,
                          size: 14,
                          color: _autoCycleScenes
                              ? FatimidColors.goldLight
                              : Colors.white70,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _autoCycleScenes
                              ? 'تبديل المشاهد تلقائياً (25ث)'
                              : 'التبديل التلقائي متوقف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _autoCycleScenes
                                ? FatimidColors.goldLight
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Toggle Focus Mode vs Stream Mode
                IconButton(
                  tooltip: _isTvFocusMode
                      ? 'التبديل للشريط المستمر'
                      : 'التبديل لعرض الآية التلفزيونية',
                  icon: Icon(
                    _isTvFocusMode
                        ? Icons.view_stream_rounded
                        : Icons.filter_center_focus_rounded,
                    color: FatimidColors.goldLight,
                    size: 24,
                  ),
                  onPressed: _toggleTvFocusMode,
                ),

                // Scene Switcher (Choose from 21 landscapes)
                PopupMenuButton<int>(
                  tooltip: 'اختيار من 21 منظر طبيعي خلاب',
                  initialValue: _currentSceneIndex,
                  onSelected: _selectScene,
                  color: const Color(0xFF0D1B17),
                  constraints: const BoxConstraints(maxHeight: 460, maxWidth: 320),
                  itemBuilder: (context) => [
                    for (int i = 0; i < _scenes.length; i++)
                      PopupMenuItem(
                        value: i,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                _scenes[i].assetPath,
                                width: 38,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _scenes[i].name,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: _currentSceneIndex == i
                                          ? FatimidColors.goldPrimary
                                          : Colors.white,
                                      fontWeight: _currentSceneIndex == i
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    _scenes[i].category,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 9.5,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: FatimidColors.goldGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.landscape_rounded,
                            size: 15, color: Color(0xFF261800)),
                        const SizedBox(width: 5),
                        Text(
                          'المشاهد (${_scenes.length})',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF261800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Fullscreen toggle
                IconButton(
                  tooltip: _isFullscreen ? 'خروج من الشاشة الكاملة' : 'ملء الشاشة',
                  icon: Icon(
                    _isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _toggleFullscreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String _toArabicDigits(int value) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return value
        .toString()
        .split('')
        .map((ch) => int.tryParse(ch) != null ? arabicDigits[int.parse(ch)] : ch)
        .join('');
  }
}
