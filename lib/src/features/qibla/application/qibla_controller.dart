import '../data/qibla_repository.dart';
import '../domain/qibla_direction.dart';

class QiblaController {
  const QiblaController(this.repository);

  final QiblaRepository repository;

  QiblaDirection savedLocationDirection() => repository.fromSavedLocation();
  Future<QiblaDirection> currentLocationDirection() =>
      repository.fromCurrentLocation();
}
