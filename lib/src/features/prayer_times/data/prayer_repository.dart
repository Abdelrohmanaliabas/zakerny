import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/storage/app_local_store.dart';
import '../domain/prayer_day.dart';
import '../domain/prayer_preferences.dart';

class PrayerRepository {
  PrayerRepository(this._store);

  static const _prefsKey = 'prayer_preferences';
  final AppLocalStore _store;

  PrayerPreferences getPreferences() {
    final json = _store.getJson(_prefsKey);
    return json == null
        ? PrayerPreferences.defaults()
        : PrayerPreferences.fromJson(json);
  }

  Future<void> savePreferences(PrayerPreferences prefs) =>
      _store.setJson(_prefsKey, prefs.toJson());

  Future<PrayerPreferences> useCurrentLocation(
    PrayerPreferences current,
  ) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('لم يتم منح إذن الموقع');
    }
    final position = await Geolocator.getCurrentPosition();
    return current.copyWith(
      city: 'موقعي الحالي',
      latitude: position.latitude,
      longitude: position.longitude,
      useCurrentLocation: true,
    );
  }

  PrayerDay timesFor(DateTime date, PrayerPreferences prefs) {
    final params = switch (prefs.calculationMethod) {
      'egyptian' => CalculationMethodParameters.egyptian(),
      'ummAlQura' => CalculationMethodParameters.ummAlQura(),
      _ => CalculationMethodParameters.muslimWorldLeague(),
    };
    params.madhab = prefs.madhab == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    final times = PrayerTimes(
      date: date,
      coordinates: Coordinates(prefs.latitude, prefs.longitude),
      calculationParameters: params,
    );
    return PrayerDay(
      prayers: [
        PrayerMoment(key: 'fajr', name: 'الفجر', time: times.fajr.toLocal()),
        PrayerMoment(
          key: 'sunrise',
          name: 'الشروق',
          time: times.sunrise.toLocal(),
        ),
        PrayerMoment(key: 'dhuhr', name: 'الظهر', time: times.dhuhr.toLocal()),
        PrayerMoment(key: 'asr', name: 'العصر', time: times.asr.toLocal()),
        PrayerMoment(
          key: 'maghrib',
          name: 'المغرب',
          time: times.maghrib.toLocal(),
        ),
        PrayerMoment(key: 'isha', name: 'العشاء', time: times.isha.toLocal()),
      ],
    );
  }
}
