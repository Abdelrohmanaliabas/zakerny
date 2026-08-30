import 'dart:io';

import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class RecitationService {
  RecitationService({Dio? dio, AudioPlayer? player})
    : _dio = dio ?? Dio(),
      _player = player ?? AudioPlayer();

  final Dio _dio;
  final AudioPlayer _player;

  Future<void> playUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> playFile(String path) async {
    await _player.setFilePath(path);
    await _player.play();
  }

  Future<String> download({
    required String url,
    required String fileName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final recitationsDir = Directory('${dir.path}/recitations');
    if (!await recitationsDir.exists()) {
      await recitationsDir.create(recursive: true);
    }
    final path = '${recitationsDir.path}/$fileName.mp3';
    await _dio.download(url, path);
    return path;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
