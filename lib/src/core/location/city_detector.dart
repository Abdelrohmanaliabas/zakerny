import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';

class EgyptianCityRecord {
  const EgyptianCityRecord({
    required this.name,
    required this.governorate,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String governorate;
  final double latitude;
  final double longitude;

  String get displayName => '$name، $governorate';
}

class CityDetector {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'User-Agent': 'ZakernyApp/1.0 (Islamic Prayer & Azan App)',
        'Accept-Language': 'ar,en',
      },
    ),
  );

  /// Curated Egyptian cities & key Islamic locations with high accuracy
  static const List<EgyptianCityRecord> knownCities = [
    // محافظة المنوفية
    EgyptianCityRecord(name: 'مدينة السادات', governorate: 'المنوفية', latitude: 30.3800, longitude: 30.5100),
    EgyptianCityRecord(name: 'شبين الكوم', governorate: 'المنوفية', latitude: 30.5520, longitude: 31.0090),
    EgyptianCityRecord(name: 'منوف', governorate: 'المنوفية', latitude: 30.4650, longitude: 30.9320),
    EgyptianCityRecord(name: 'أشمون', governorate: 'المنوفية', latitude: 30.2970, longitude: 30.9840),
    EgyptianCityRecord(name: 'قويسنا', governorate: 'المنوفية', latitude: 30.5640, longitude: 31.1440),
    EgyptianCityRecord(name: 'بركة السبع', governorate: 'المنوفية', latitude: 30.6380, longitude: 31.0840),
    EgyptianCityRecord(name: 'الباجور', governorate: 'المنوفية', latitude: 30.4300, longitude: 31.0420),
    EgyptianCityRecord(name: 'تلا', governorate: 'المنوفية', latitude: 30.6800, longitude: 30.9450),
    EgyptianCityRecord(name: 'الشهداء', governorate: 'المنوفية', latitude: 30.5980, longitude: 30.8200),

    // القاهرة الكبرى والجيزة
    EgyptianCityRecord(name: 'القاهرة', governorate: 'القاهرة', latitude: 30.0444, longitude: 31.2357),
    EgyptianCityRecord(name: 'الجيزة', governorate: 'الجيزة', latitude: 30.0131, longitude: 31.2089),
    EgyptianCityRecord(name: 'مدينة السادس من أكتوبر', governorate: 'الجيزة', latitude: 29.9737, longitude: 30.9444),
    EgyptianCityRecord(name: 'الشيخ زايد', governorate: 'الجيزة', latitude: 30.0460, longitude: 30.9800),
    EgyptianCityRecord(name: 'القاهرة الجديدة', governorate: 'القاهرة', latitude: 30.0300, longitude: 31.4700),
    EgyptianCityRecord(name: 'الشروق', governorate: 'القاهرة', latitude: 30.1500, longitude: 31.6200),
    EgyptianCityRecord(name: 'بدر', governorate: 'القاهرة', latitude: 30.1400, longitude: 31.7400),
    EgyptianCityRecord(name: 'حلوان', governorate: 'القاهرة', latitude: 29.8400, longitude: 31.3300),

    // الدلتا والقليوبية والبحيرة والغربية
    EgyptianCityRecord(name: 'بنها', governorate: 'القليوبية', latitude: 30.4660, longitude: 31.1830),
    EgyptianCityRecord(name: 'طوخ', governorate: 'القليوبية', latitude: 30.3540, longitude: 31.1980),
    EgyptianCityRecord(name: 'شبرا الخيمة', governorate: 'القليوبية', latitude: 30.1286, longitude: 31.2422),
    EgyptianCityRecord(name: 'طنطا', governorate: 'الغربية', latitude: 30.7865, longitude: 31.0004),
    EgyptianCityRecord(name: 'المحلة الكبرى', governorate: 'الغربية', latitude: 30.9706, longitude: 31.1664),
    EgyptianCityRecord(name: 'المنصورة', governorate: 'الدقهلية', latitude: 31.0364, longitude: 31.3807),
    EgyptianCityRecord(name: 'الزقازيق', governorate: 'الشرقية', latitude: 30.5877, longitude: 31.5020),
    EgyptianCityRecord(name: 'العاشر من رمضان', governorate: 'الشرقية', latitude: 30.3000, longitude: 31.7400),
    EgyptianCityRecord(name: 'دمنهور', governorate: 'البحيرة', latitude: 31.0379, longitude: 30.4699),
    EgyptianCityRecord(name: 'وادي النطرون', governorate: 'البحيرة', latitude: 30.4167, longitude: 30.3400),
    EgyptianCityRecord(name: 'كفر الدوار', governorate: 'البحيرة', latitude: 31.1340, longitude: 30.1280),
    EgyptianCityRecord(name: 'كفر الشيخ', governorate: 'كفر الشيخ', latitude: 31.1107, longitude: 30.9388),
    EgyptianCityRecord(name: 'دمياط', governorate: 'دمياط', latitude: 31.4175, longitude: 31.8144),

    // الساحل والقناة
    EgyptianCityRecord(name: 'الإسكندرية', governorate: 'الإسكندرية', latitude: 31.2001, longitude: 29.9187),
    EgyptianCityRecord(name: 'برج العرب', governorate: 'الإسكندرية', latitude: 30.9167, longitude: 29.5333),
    EgyptianCityRecord(name: 'مرسى مطروح', governorate: 'مطروح', latitude: 31.3526, longitude: 27.2453),
    EgyptianCityRecord(name: 'العلمين', governorate: 'مطروح', latitude: 30.8333, longitude: 28.9500),
    EgyptianCityRecord(name: 'بورسعيد', governorate: 'بورسعيد', latitude: 31.2653, longitude: 32.3019),
    EgyptianCityRecord(name: 'الإسماعيلية', governorate: 'الإسماعيلية', latitude: 30.5965, longitude: 32.2715),
    EgyptianCityRecord(name: 'السويس', governorate: 'السويس', latitude: 29.9668, longitude: 32.5498),

    // الصعيد والوجه القبلي
    EgyptianCityRecord(name: 'الفيوم', governorate: 'الفيوم', latitude: 29.3084, longitude: 30.8428),
    EgyptianCityRecord(name: 'بني سويف', governorate: 'بني سويف', latitude: 29.0661, longitude: 31.0994),
    EgyptianCityRecord(name: 'المنيا', governorate: 'المنيا', latitude: 28.0871, longitude: 30.7618),
    EgyptianCityRecord(name: 'ملوي', governorate: 'المنيا', latitude: 27.7314, longitude: 30.8417),
    EgyptianCityRecord(name: 'أسيوط', governorate: 'أسيوط', latitude: 27.1801, longitude: 31.1837),
    EgyptianCityRecord(name: 'سوهاج', governorate: 'سوهاج', latitude: 26.5569, longitude: 31.6948),
    EgyptianCityRecord(name: 'قنا', governorate: 'قنا', latitude: 26.1551, longitude: 32.7160),
    EgyptianCityRecord(name: 'الأقصر', governorate: 'الأقصر', latitude: 25.6872, longitude: 32.6396),
    EgyptianCityRecord(name: 'أسوان', governorate: 'أسوان', latitude: 24.0889, longitude: 32.8998),

    // البحر الأحمر وسيناء
    EgyptianCityRecord(name: 'الغردقة', governorate: 'البحر الأحمر', latitude: 27.2579, longitude: 33.8116),
    EgyptianCityRecord(name: 'شرم الشيخ', governorate: 'جنوب سيناء', latitude: 27.9158, longitude: 34.3299),
    EgyptianCityRecord(name: 'الطور', governorate: 'جنوب سيناء', latitude: 28.2415, longitude: 33.6231),
    EgyptianCityRecord(name: 'العريش', governorate: 'شمال سيناء', latitude: 31.1325, longitude: 33.8034),

    // العواصم والمدن الإسلامية الرئيسية
    EgyptianCityRecord(name: 'مكة المكرمة', governorate: 'السعودية', latitude: 21.4225, longitude: 39.8262),
    EgyptianCityRecord(name: 'المدينة المنورة', governorate: 'السعودية', latitude: 24.4672, longitude: 39.6111),
    EgyptianCityRecord(name: 'الرياض', governorate: 'السعودية', latitude: 24.7136, longitude: 46.6753),
    EgyptianCityRecord(name: 'جدة', governorate: 'السعودية', latitude: 21.5433, longitude: 39.1728),
  ];

  /// Detects city name using online reverse geocoding with fast fallback to offline nearest-city
  static Future<String> detectCity(double latitude, double longitude) async {
    try {
      final onlineName = await _reverseGeocodeOnline(latitude, longitude);
      if (onlineName != null && onlineName.isNotEmpty) {
        return onlineName;
      }
    } catch (_) {}

    return findNearestCity(latitude, longitude);
  }

  static Future<String?> _reverseGeocodeOnline(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latitude,
          'lon': longitude,
          'zoom': 14,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data is Map<String, dynamic>) {
          final address = data['address'] as Map<String, dynamic>?;
          if (address != null) {
            final city = address['city'] ??
                address['town'] ??
                address['suburb'] ??
                address['county'] ??
                address['village'] ??
                address['city_district'];
            final state = address['state'] ?? address['governorate'];

            if (city != null && state != null) {
              return '$city، $state';
            } else if (city != null) {
              return city.toString();
            } else if (state != null) {
              return state.toString();
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Calculates nearest known city using Haversine distance
  static String findNearestCity(double latitude, double longitude) {
    double minDistance = double.infinity;
    EgyptianCityRecord? closest;

    for (final city in knownCities) {
      final distance = _haversineDistanceKm(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closest = city;
      }
    }

    if (closest != null) {
      return closest.displayName;
    }

    return 'القاهرة';
  }

  static double _haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
}
