import '../data/quran_repository.dart';
import '../domain/quran_models.dart';

class QuranController {
  QuranController(this.repository);
  final QuranRepository repository;

  Future<List<Surah>> loadSurahs() => repository.loadSurahs();
  Future<Surah?> findSurah(int id) => repository.findSurah(id);
  List<QuranBookmark> bookmarks() => repository.bookmarks();
  QuranBookmark? lastRead() => repository.lastRead();

  Future<void> bookmark(Surah surah, Ayah ayah) {
    return repository.addBookmark(
      QuranBookmark(
        surahId: surah.id,
        surahName: surah.name,
        ayahNumber: ayah.number,
      ),
    );
  }

  Future<void> saveLastRead(Surah surah, Ayah ayah) {
    return repository.saveLastRead(
      QuranBookmark(
        surahId: surah.id,
        surahName: surah.name,
        ayahNumber: ayah.number,
      ),
    );
  }

  double getFontSize() => repository.getFontSize();
  Future<void> setFontSize(double size) => repository.setFontSize(size);

  bool getMushafMode() => repository.getMushafMode();
  Future<void> setMushafMode(bool value) => repository.setMushafMode(value);
}

