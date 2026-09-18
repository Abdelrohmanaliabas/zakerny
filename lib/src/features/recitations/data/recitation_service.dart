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
    int? ayahNumber,
    String? customTitle,
  }) async {
    final defaultSurahName = surah?.name ?? '';
    final formattedSurahName =
        (defaultSurahName.startsWith('سُورَة') || defaultSurahName.startsWith('سورة'))
            ? defaultSurahName
            : 'سورة $defaultSurahName';
    final title = customTitle ??
        (surah != null
            ? (ayahNumber != null
                ? '$formattedSurahName • آية $ayahNumber'
                : formattedSurahName)
            : 'تلاوة عطرة');
    final artist = reciter?.name ?? 'القارئ';
    final tagId =
        '${reciter?.id ?? 'stream'}_${surah?.id ?? urls.first.hashCode}_${ayahNumber ?? 'full'}';

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
        ayahNumber: ayahNumber,
        customTitle: customTitle,
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
    throw lastError ?? Exception('لا يمكن تشغيل التلاوة حالياً، يرجى التأكد من اتصال الإنترنت');
  }

  Future<void> playAyah({
    required Reciter reciter,
    required int surahId,
    required String surahName,
    required int ayahNumber,
    int? globalNumber,
  }) async {
    final surahPadded = surahId.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');

    final urls = <String>[];
    switch (reciter.id) {
      case 'alafasy':
        urls.add('https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3');
        if (globalNumber != null) {
          urls.add('https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalNumber.mp3');
        }
        break;
      case 'husary':
        urls.add('https://everyayah.com/data/Husary_128kbps/$surahPadded$ayahPadded.mp3');
        if (globalNumber != null) {
          urls.add('https://cdn.islamic.network/quran/audio/128/ar.husary/$globalNumber.mp3');
        }
        break;
      case 'minshawi':
        urls.add('https://everyayah.com/data/Minshawy_Murattal_128kbps/$surahPadded$ayahPadded.mp3');
        if (globalNumber != null) {
          urls.add('https://cdn.islamic.network/quran/audio/128/ar.minshawi/$globalNumber.mp3');
        }
        break;
      case 'abdulbasit':
        urls.add('https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$surahPadded$ayahPadded.mp3');
        urls.add('https://everyayah.com/data/Abdul_Basit_Murattal_64kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'maher_almuaiqly':
        urls.add('https://everyayah.com/data/MaherAlMuaiqly128kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'yasser_aldosari':
        urls.add('https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'saad_alghamdi':
        urls.add('https://everyayah.com/data/Ghamadi_40kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'ahmed_alajmy':
        urls.add('https://everyayah.com/data/Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net/$surahPadded$ayahPadded.mp3');
        break;
      case 'abdulrahman_alsudais':
        urls.add('https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'saud_alshuraim':
        urls.add('https://everyayah.com/data/Saood_ash-Shuraym_128kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'abu_bakr_alshatri':
        urls.add('https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'ali_jaber':
        urls.add('https://everyayah.com/data/Ali_Jaber_64kbps/$surahPadded$ayahPadded.mp3');
        break;
      case 'abdullah_basfar':
        urls.add('https://everyayah.com/data/Abdullah_Basfar_192kbps/$surahPadded$ayahPadded.mp3');
        break;
      default:
        urls.add('https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3');
        if (globalNumber != null) {
          urls.add('https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalNumber.mp3');
        }
        break;
    }

    if (reciter.id != 'alafasy') {
      urls.add('https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3');
    }

    final dummySurah = RecitationSurah(
      id: surahId,
      name: surahName,
      urls: urls,
    );

    return playUrls(
      urls,
      reciter: reciter,
      surah: dummySurah,
      ayahNumber: ayahNumber,
    );
  }

  Future<void> playFile(
    String path, {
    Reciter? reciter,
    RecitationSurah? surah,
    int? ayahNumber,
  }) async {
    final defaultSurahName = surah?.name ?? '';
    final formattedSurahName =
        (defaultSurahName.startsWith('سُورَة') || defaultSurahName.startsWith('سورة'))
            ? defaultSurahName
            : 'سورة $defaultSurahName';
    final title = surah != null
        ? (ayahNumber != null
            ? '$formattedSurahName • آية $ayahNumber'
            : formattedSurahName)
        : 'تلاوة محملة';
    final artist = reciter?.name ?? 'القارئ';
    final tagId = '${reciter?.id ?? 'file'}_${surah?.id ?? path.hashCode}_${ayahNumber ?? 'full'}';

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
        ayahNumber: ayahNumber,
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
