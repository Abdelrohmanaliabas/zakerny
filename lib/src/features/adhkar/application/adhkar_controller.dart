import '../data/adhkar_repository.dart';
import '../domain/dhikr_models.dart';

class AdhkarController {
  const AdhkarController(this.repository);

  final AdhkarRepository repository;

  Future<List<DhikrCategory>> loadCategories() => repository.loadCategories();
  int countFor(String dhikrId) => repository.countFor(dhikrId);
  Future<int> increment(DhikrItem item) => repository.increment(item);
  Future<void> reset(String dhikrId) => repository.reset(dhikrId);
}
