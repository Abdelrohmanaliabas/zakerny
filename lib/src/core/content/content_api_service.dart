import 'package:dio/dio.dart';

class ContentApiService {
  ContentApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Map<String, dynamic>> fetchFullQuran() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.alquran.cloud/v1/quran/quran-uthmani',
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> fetchMp3QuranLanguages() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://mp3quran.net/api/v3/languages',
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> fetchHadithJsonIndex() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions.json',
    );
    return response.data ?? const {};
  }
}
