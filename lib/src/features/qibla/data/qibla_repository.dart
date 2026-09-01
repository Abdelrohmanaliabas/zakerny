import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../../../core/storage/app_local_store.dart';
import '../../prayer_times/data/prayer_repository.dart';
import '../domain/qibla_direction.dart';

class QiblaRepository {
  QiblaRepository(this._store);

  static const _kaabaLatitude = 21.422487;
  static const _kaabaLongitude = 39.826206;
  static const _earthRadiusKm = 6371.0;

  final AppLocalStore _store;

  QiblaDirection fromSavedLocation() {
    final prefs = PrayerRepository(_store).getPreferences();
    return _calculate(
      city: prefs.city,
      latitude: prefs.latitude,
      longitude: prefs.longitude,
    );
  }

  Future<QiblaDirection> fromCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('لم يتم منح إذن الموقع');
    }
    final position = await Geolocator.getCurrentPosition();
    return _calculate(
      city: 'موقعي الحالي',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  QiblaDirection _calculate({
    required String city,
    required double latitude,
    required double longitude,
  }) {
    final lat = _degreesToRadians(latitude);
    final lon = _degreesToRadians(longitude);
    final kaabaLat = _degreesToRadians(_kaabaLatitude);
    final kaabaLon = _degreesToRadians(_kaabaLongitude);
    final deltaLon = kaabaLon - lon;

    final y = math.sin(deltaLon);
    final x =
        math.cos(lat) * math.tan(kaabaLat) - math.sin(lat) * math.cos(deltaLon);
    final bearing = (_radiansToDegrees(math.atan2(y, x)) + 360) % 360;
    final distance = _distanceKm(lat, lon, kaabaLat, kaabaLon);

    return QiblaDirection(
      city: city,
      latitude: latitude,
      longitude: longitude,
      bearing: bearing,
      distanceKm: distance,
    );
  }

  double _distanceKm(double lat, double lon, double kaabaLat, double kaabaLon) {
    final deltaLat = kaabaLat - lat;
    final deltaLon = kaabaLon - lon;
    final a =
        math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat) *
            math.cos(kaabaLat) *
            math.pow(math.sin(deltaLon / 2), 2);
    return _earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degreesToRadians(double value) => value * math.pi / 180;
  double _radiansToDegrees(double value) => value * 180 / math.pi;
}
