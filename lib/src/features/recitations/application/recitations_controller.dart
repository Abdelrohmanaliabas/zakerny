import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/recitation_repository.dart';
import '../data/recitation_service.dart';
import '../domain/recitation_models.dart';

class RecitationsController {
  RecitationsController(this.repository, this.service);
  final RecitationRepository repository;
  final RecitationService service;

  Future<List<Reciter>> loadReciters() => repository.loadReciters();
  List<DownloadedRecitation> downloads() => repository.downloads();
  DownloadedRecitation? findDownload(String reciterId, int surahId) =>
      repository.findDownload(reciterId, surahId);

  ValueListenable<ActiveRecitation?> get activeRecitationNotifier =>
      service.activeRecitationNotifier;
  ActiveRecitation? get activeRecitation => service.activeRecitation;
  Stream<PlayerState> get playerStateStream => service.playerStateStream;
  Stream<Duration> get positionStream => service.positionStream;
  Stream<Duration?> get durationStream => service.durationStream;
  bool get isPlaying => service.isPlaying;

  bool isCurrentTrack(String reciterId, int surahId, [int? ayahNumber]) {
    final active = service.activeRecitation;
    return active != null && active.matches(reciterId, surahId, ayahNumber);
  }

  bool isCurrentTrackPlaying(String reciterId, int surahId, [int? ayahNumber]) {
    return isCurrentTrack(reciterId, surahId, ayahNumber) && service.isPlaying;
  }

  bool isSurahActive(int surahId) {
    final active = service.activeRecitation;
    return active != null && active.surah.id == surahId;
  }

  bool isSurahPlaying(int surahId) {
    final active = service.activeRecitation;
    return active != null &&
        active.surah.id == surahId &&
        active.ayahNumber == null &&
        service.isPlaying;
  }

  bool isAyahPlaying(int surahId, int ayahNumber) {
    final active = service.activeRecitation;
    return active != null &&
        active.surah.id == surahId &&
        active.ayahNumber == ayahNumber &&
        service.isPlaying;
  }

  Future<void> play(Reciter reciter, RecitationSurah surah) async {
    final download = findDownload(reciter.id, surah.id);
    if (download != null) {
      return service.playFile(
        download.path,
        reciter: reciter,
        surah: surah,
      );
    }
    if (surah.streamUrls.isEmpty) {
      throw Exception('لا يوجد رابط متاح لهذه التلاوة');
    }
    return service.playUrls(
      surah.streamUrls,
      reciter: reciter,
      surah: surah,
    );
  }

  Future<void> playSurahById(int surahId, {String? reciterId}) async {
    final reciters = await loadReciters();
    final reciter = reciters.where((r) => r.id == (reciterId ?? 'alafasy')).firstOrNull ??
        reciters.first;
    final surah = reciter.surahs.where((s) => s.id == surahId).firstOrNull;
    if (surah == null) {
      throw Exception('السورة غير متوفرة لهذا القارئ');
    }
    return play(reciter, surah);
  }

  Future<void> togglePlayPauseSurahById(int surahId, {String? reciterId}) async {
    final active = service.activeRecitation;
    if (active != null && active.surah.id == surahId && active.ayahNumber == null) {
      if (service.isPlaying) {
        await service.pause();
      } else {
        await service.resume();
      }
      return;
    }
    await playSurahById(surahId, reciterId: reciterId);
  }

  Future<void> playAyah({
    required Reciter reciter,
    required int surahId,
    required String surahName,
    required int ayahNumber,
    int? globalNumber,
  }) async {
    return service.playAyah(
      reciter: reciter,
      surahId: surahId,
      surahName: surahName,
      ayahNumber: ayahNumber,
      globalNumber: globalNumber,
    );
  }

  Future<void> togglePlayPauseAyah({
    required Reciter reciter,
    required int surahId,
    required String surahName,
    required int ayahNumber,
    int? globalNumber,
  }) async {
    final active = service.activeRecitation;
    if (active != null &&
        active.surah.id == surahId &&
        active.ayahNumber == ayahNumber) {
      if (service.isPlaying) {
        await service.pause();
      } else {
        await service.resume();
      }
      return;
    }
    await playAyah(
      reciter: reciter,
      surahId: surahId,
      surahName: surahName,
      ayahNumber: ayahNumber,
      globalNumber: globalNumber,
    );
  }

  Future<void> togglePlayPause(Reciter reciter, RecitationSurah surah) async {
    if (isCurrentTrack(reciter.id, surah.id)) {
      if (service.isPlaying) {
        await service.pause();
      } else {
        await service.resume();
      }
    } else {
      await play(reciter, surah);
    }
  }

  Future<void> pause() => service.pause();
  Future<void> resume() => service.resume();
  Future<void> stop() => service.stop();
  Future<void> seek(Duration position) => service.seek(position);

  Future<void> download(Reciter reciter, RecitationSurah surah) async {
    if (surah.streamUrls.isEmpty) {
      throw Exception('لا يوجد رابط متاح للتحميل');
    }
    final path = await service.download(
      urls: surah.streamUrls,
      fileName: '${reciter.id}_${surah.id}',
    );
    await repository.saveDownload(
      DownloadedRecitation(
        reciterId: reciter.id,
        surahId: surah.id,
        path: path,
      ),
    );
  }

  Future<void> deleteDownload(DownloadedRecitation download) async {
    await service.deleteFile(download.path);
    await repository.removeDownload(download.reciterId, download.surahId);
  }
}

