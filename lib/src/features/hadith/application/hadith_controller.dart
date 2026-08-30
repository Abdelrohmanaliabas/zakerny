import '../data/hadith_repository.dart';
import '../domain/hadith_models.dart';

class HadithController {
  HadithController(this.repository);
  final HadithRepository repository;

  Future<List<Hadith>> load() => repository.loadHadiths();
  Future<List<Hadith>> search(String query) => repository.search(query);
  int? lastHadithId() => repository.lastHadithId();
  Future<void> saveLastHadith(int id) => repository.saveLastHadith(id);
}
