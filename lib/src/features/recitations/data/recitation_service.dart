import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/recitation_models.dart';

class RecitationService {
  RecitationService({Dio? dio, AudioPlayer? player})
    : _dio = dio ?? Dio(),
      _player = player ?? _sharedPlayer {
    _initListener();
  }

  static final AudioPlayer _sharedPlayer = AudioPlayer();
  static bool _listenerInitialized = false;

  final Dio _dio;
  final AudioPlayer _player;

  static final ValueNotifier<ActiveRecitation?> _activeRecitationNotifier =
      ValueNotifier<ActiveRecitation?>(null);

  ValueListenable<ActiveRecitation?> get activeRecitationNotifier =>
      _activeRecitationNotifier;

  ActiveRecitation? get activeRecitation => _activeRecitationNotifier.value;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  PlayerState get playerState => _player.playerState;
  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position;

  Stream<Duration?> get durationStream => _player.durationStream;
  Duration? get duration => _player.duration;

  void _initListener() {
    if (_listenerInitialized) return;
    _listenerInitialized = true;
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _activeRecitationNotifier.value = null;
      }
    });
  }

  Future<void> playUrls(
    List<String> urls, {
    Reciter? reciter,
    RecitationSurah? surah,
  }) async {
    final title = surah != null ? 'سورة ${surah.name}' : 'تلاوة عطرة';
    final artist = reciter?.name ?? 'القارئ';
    final tagId =
        '${reciter?.id ?? 'stream'}_${surah?.id ?? urls.first.hashCode}';

    final mediaItem = MediaItem(
      id: tagId,
      album: 'تلاوات القرآن الكريم',
      title: title,
      artist: artist,
      artUri: Uri.parse('asset:///assets/branding/app_icon.png'),
    );

    if (reciter != null && surah != null) {
      _activeRecitationNotifier.value = ActiveRecitation(
        reciter: reciter,
        surah: surah,
        isDownloaded: false,
      );
    }

    Object? lastError;
    for (final url in urls) {
      try {
        final audioSource = AudioSource.uri(
          Uri.parse(url),
          tag: mediaItem,
        );
        await _player.setAudioSource(audioSource);
        await _player.play();
        return;
      } catch (error) {
        lastError = error;
      }
    }
    _activeRecitationNotifier.value = null;
    throw lastError ?? Exception('No recitation URL is available');
  }

  Future<void> playFile(
    String path, {
    Reciter? reciter,
    RecitationSurah? surah,
  }) async {
    final title = surah != null ? 'سورة ${surah.name}' : 'تلاوة محملة';
    final artist = reciter?.name ?? 'القارئ';
    final tagId = '${reciter?.id ?? 'file'}_${surah?.id ?? path.hashCode}';

    final mediaItem = MediaItem(
      id: tagId,
      album: 'تلاوات القرآن الكريم',
      title: title,
      artist: artist,
      artUri: Uri.parse('asset:///assets/branding/app_icon.png'),
    );

    if (reciter != null && surah != null) {
      _activeRecitationNotifier.value = ActiveRecitation(
        reciter: reciter,
        surah: surah,
        isDownloaded: true,
        localPath: path,
      );
    }

    final audioSource = AudioSource.file(
      path,
      tag: mediaItem,
    );
    await _player.setAudioSource(audioSource);
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _activeRecitationNotifier.value = null;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<String> download({
    required List<String> urls,
    required String fileName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final recitationsDir = Directory('${dir.path}/recitations');
    if (!await recitationsDir.exists()) {
      await recitationsDir.create(recursive: true);
    }
    final path = '${recitationsDir.path}/$fileName.mp3';
    Object? lastError;
    for (final url in urls) {
      try {
        await _dio.download(url, path);
        return path;
      } catch (error) {
        lastError = error;
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
    throw lastError ?? Exception('No recitation URL is available');
  }

  Future<void> deleteFile(String path) async {
    final active = _activeRecitationNotifier.value;
    if (active?.localPath == path) {
      await stop();
    }
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
