import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import '../../recitations/data/recitation_service.dart';
import '../domain/lecture_models.dart';

class LectureService {
  LectureService({Dio? dio, AudioPlayer? player})
      : _dio = dio ?? Dio(),
        _player = player ?? RecitationService.sharedPlayer {
    _initListener();
  }

  final Dio _dio;
  final AudioPlayer _player;
  static bool _listenerInitialized = false;

  static final ValueNotifier<ActiveLecture?> _activeLectureNotifier =
      ValueNotifier<ActiveLecture?>(null);
  ValueListenable<ActiveLecture?> get activeLectureNotifier =>
      _activeLectureNotifier;
  ActiveLecture? get activeLecture => _activeLectureNotifier.value;

  // Track live download progress: lectureId -> 0.0 .. 1.0
  final ValueNotifier<Map<String, double>> downloadProgressNotifier =
      ValueNotifier<Map<String, double>>({});

  final ValueNotifier<double> speedNotifier = ValueNotifier<double>(1.0);
  Timer? _sleepTimer;
  final ValueNotifier<Duration?> sleepTimerRemainingNotifier =
      ValueNotifier<Duration?>(null);

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  PlayerState get playerState => _player.playerState;
  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position;

  Stream<Duration?> get durationStream => _player.durationStream;
  Duration? get duration => _player.duration;

  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  void _initListener() {
    if (_listenerInitialized) return;
    _listenerInitialized = true;
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _activeLectureNotifier.value = null;
        _player.stop();
      }
    });
  }

  Future<void> playLecture(
    LectureItem lecture, {
    bool isDownloaded = false,
    String? localPath,
    Duration? initialPosition,
  }) async {
    // 1. Reset any active Quran recitation to avoid conflicts
    RecitationService.resetActive();

    final mediaItem = MediaItem(
      id: 'lecture_${lecture.id}',
      album: lecture.seriesTitle ?? 'الخطب والدروس الإسلامية',
      title: lecture.title,
      artist: lecture.sheikhName,
      artUri: Uri.parse('asset:///assets/branding/app_icon.png'),
      duration: lecture.durationSeconds != null
          ? Duration(seconds: lecture.durationSeconds!)
          : null,
      playable: true,
    );

    _activeLectureNotifier.value = ActiveLecture(
      lecture: lecture,
      isDownloaded: isDownloaded,
      localPath: localPath,
    );

    if (isDownloaded && localPath != null && await File(localPath).exists()) {
      final source = AudioSource.file(localPath, tag: mediaItem);
      await _player.setAudioSource(source);
      if (initialPosition != null && initialPosition > Duration.zero) {
        await _player.seek(initialPosition);
      }
      await _player.setSpeed(speedNotifier.value);
      await _player.play();
      return;
    }

    Object? lastError;
    final urls = lecture.allUrls;
    for (final url in urls) {
      try {
        final source = AudioSource.uri(
          Uri.parse(url),
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
          },
          tag: mediaItem,
        );
        await _player.setAudioSource(source);
        if (initialPosition != null && initialPosition > Duration.zero) {
          await _player.seek(initialPosition);
        }
        await _player.setSpeed(speedNotifier.value);
        await _player.play();
        return;
      } catch (err) {
        lastError = err;
      }
    }

    _activeLectureNotifier.value = null;
    throw lastError ??
        Exception('تعذر تشغيل الدرس، يرجى التأكد من اتصال الإنترنت');
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _activeLectureNotifier.value = null;
    cancelSleepTimer();
  }

  Future<void> seek(Duration pos) async {
    await _player.seek(pos);
  }

  Future<void> seekRelative(Duration delta) async {
    final current = _player.position;
    final total = _player.duration ?? Duration.zero;
    final target = current + delta;
    if (target < Duration.zero) {
      await seek(Duration.zero);
    } else if (total > Duration.zero && target > total) {
      await seek(total);
    } else {
      await seek(target);
    }
  }

  Future<void> setSpeed(double speed) async {
    speedNotifier.value = speed;
    await _player.setSpeed(speed);
  }

  void setSleepTimer(Duration duration, {VoidCallback? onExpire}) {
    cancelSleepTimer();
    sleepTimerRemainingNotifier.value = duration;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = sleepTimerRemainingNotifier.value;
      if (remaining == null || remaining.inSeconds <= 1) {
        cancelSleepTimer();
        pause();
        onExpire?.call();
      } else {
        sleepTimerRemainingNotifier.value =
            remaining - const Duration(seconds: 1);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepTimerRemainingNotifier.value = null;
  }

  Future<String> downloadLecture(LectureItem lecture) async {
    final dir = await getApplicationDocumentsDirectory();
    final lecturesDir = Directory('${dir.path}/lectures');
    if (!await lecturesDir.exists()) {
      await lecturesDir.create(recursive: true);
    }

    final safeFileName = lecture.id.replaceAll(RegExp(r'[^\w\-]'), '_');
    final filePath = '${lecturesDir.path}/$safeFileName.mp3';

    final id = lecture.id;
    _updateProgress(id, 0.01);

    Object? lastError;
    final urls = lecture.allUrls;
    for (final url in urls) {
      try {
        await _dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = (received / total).clamp(0.0, 1.0);
              _updateProgress(id, progress);
            }
          },
        );
        _clearProgress(id);
        return filePath;
      } catch (err) {
        lastError = err;
        final f = File(filePath);
        if (await f.exists()) await f.delete();
      }
    }

    _clearProgress(id);
    throw lastError ?? Exception('تعذر تحميل الدرس');
  }

  void _updateProgress(String id, double val) {
    final map = Map<String, double>.from(downloadProgressNotifier.value);
    map[id] = val;
    downloadProgressNotifier.value = map;
  }

  void _clearProgress(String id) {
    final map = Map<String, double>.from(downloadProgressNotifier.value);
    map.remove(id);
    downloadProgressNotifier.value = map;
  }

  Future<void> deleteDownload(String path) async {
    final active = _activeLectureNotifier.value;
    if (active?.localPath == path) {
      await stop();
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
