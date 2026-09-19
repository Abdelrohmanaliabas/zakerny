import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

/// أداة لتشغيل الملفات الصوتية المحلية المضمنة (Assets) عبر جميع المنصات بما فيها Android و iOS و Windows
/// مع التوافق التام مع مكتبة just_audio_background بإرفاق MediaItem tag دائماً
class AudioAssetUtils {
  static final Map<String, String> _cachedPaths = {};

  /// الحصول على مسار محلي قابل للتشغيل من مكتبة الوسائط بنظام التشغيل
  static Future<String> getPlayableFilePath(String assetPath) async {
    if (_cachedPaths.containsKey(assetPath)) {
      final cached = _cachedPaths[assetPath]!;
      if (File(cached).existsSync()) {
        return cached;
      }
    }

    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final sanitizedFileName = assetPath.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final targetFile = File('${tempDir.path}/$sanitizedFileName');

    // كتابة الملف في حال عدم وجوده أو اختلاف الحجم
    if (!await targetFile.exists() || await targetFile.length() != byteData.lengthInBytes) {
      await targetFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        flush: true,
      );
    }

    _cachedPaths[assetPath] = targetFile.path;
    return targetFile.path;
  }

  /// إعداد وتشغيل ملف صوتي من الأصول بصورة آمنة ومتوافقة مع just_audio_background عبر إضافة MediaItem tag
  static Future<void> playAssetAudio(
    AudioPlayer player,
    String assetPath, {
    String? id,
    String? title,
    String? artist,
    String? album,
  }) async {
    final mediaItem = MediaItem(
      id: id ?? assetPath,
      title: title ?? 'أذان الصلاة',
      artist: artist ?? 'ذكرني',
      album: album ?? 'أصوات الأذان',
      artUri: Uri.parse('asset:///assets/branding/app_icon.png'),
    );

    try {
      AudioSource source;
      if (kIsWeb) {
        source = AudioSource.uri(
          Uri.parse('asset:///$assetPath'),
          tag: mediaItem,
        );
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // أنظمة سطح المكتب تفضل مسار ملف محلي مباشر عبر file://
        final filePath = await getPlayableFilePath(assetPath);
        source = AudioSource.file(
          filePath,
          tag: mediaItem,
        );
      } else {
        // Android و iOS
        source = AudioSource.asset(
          assetPath,
          tag: mediaItem,
        );
      }

      await player.setAudioSource(source);
      await player.play();
    } catch (error) {
      // محاولة احتياطية في حال فشل تحميل asset على بعض أجهزة أندرويد
      if (!kIsWeb) {
        try {
          final filePath = await getPlayableFilePath(assetPath);
          final fallbackSource = AudioSource.file(
            filePath,
            tag: mediaItem,
          );
          await player.setAudioSource(fallbackSource);
          await player.play();
          return;
        } catch (_) {}
      }

      debugPrint('Error playing audio asset ($assetPath): $error');
      rethrow;
    }
  }
}
