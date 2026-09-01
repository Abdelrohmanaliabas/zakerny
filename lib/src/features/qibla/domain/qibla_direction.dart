class QiblaDirection {
  const QiblaDirection({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.bearing,
    required this.distanceKm,
  });

  final String city;
  final double latitude;
  final double longitude;
  final double bearing;
  final double distanceKm;

  String get bearingLabel => '${bearing.round()}\u00b0';
  String get distanceLabel => '${distanceKm.round()} كم';
}
