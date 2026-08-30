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

  Future<void> play(Reciter reciter, RecitationSurah surah) async {
    final download = findDownload(reciter.id, surah.id);
    if (download != null) return service.playFile(download.path);
    if (surah.url == null || surah.url!.isEmpty) {
      throw Exception('لا يوجد رابط متاح لهذه التلاوة');
    }
    return service.playUrl(surah.url!);
  }

  Future<void> download(Reciter reciter, RecitationSurah surah) async {
    if (surah.url == null || surah.url!.isEmpty) {
      throw Exception('لا يوجد رابط متاح للتحميل');
    }
    final path = await service.download(
      url: surah.url!,
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
