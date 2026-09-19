import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/storage/app_local_store.dart';
import '../../../core/utils/audio_asset_utils.dart';
import '../../prayer_times/data/prayer_repository.dart';
import '../../prayer_times/domain/prayer_preferences.dart';
import '../domain/dhikr_reminder_item.dart';

/// خدمة التذكير الصوتي التلقائي بالأذكار والتسابيح
/// تقوم بتشغيل مقاطع صوتية نقية للأذكار المختارة في فترات دورية منتظمة
class VoiceDhikrService {
  VoiceDhikrService._();

  static final VoiceDhikrService instance = VoiceDhikrService._();

  final AudioPlayer _player = AudioPlayer();
  Timer? _periodicTimer;
  PrayerPreferences? _preferences;
  int _lastIndex = 0;

  final ValueNotifier<String?> currentlyPlayingId = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  /// تهيئة الخدمة عند إقلاع التطبيق
  void init(AppLocalStore store) {
    _player.playerStateStream.listen((state) {
      final active = state.playing &&
          state.processingState != ProcessingState.completed &&
          state.processingState != ProcessingState.idle;
      isPlaying.value = active;
      if (!active && state.processingState == ProcessingState.completed) {
        currentlyPlayingId.value = null;
      }
    });

    final repo = PrayerRepository(store);
    updatePreferences(repo.getPreferences());
  }

  /// تحديث الإعدادات وإعادة جدولة المؤقت التلقائي
  void updatePreferences(PrayerPreferences prefs) {
    _preferences = prefs;
    _restartPeriodicTimer();
  }

  /// إيقاف وإعادة تشغيل المؤقت الدوري بناءً على الإعدادات الحالية
  void _restartPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;

    final prefs = _preferences;
    if (prefs == null) return;
    if (!prefs.dhikrReminderEnabled || !prefs.dhikrVoiceEnabled) return;
    if (prefs.dhikrIntervalMinutes <= 0) return;

    final duration = Duration(minutes: prefs.dhikrIntervalMinutes);
    _periodicTimer = Timer.periodic(duration, (_) {
      playNextPeriodicDhikr();
    });
  }

  /// الحصول على قائمة الأذكار الصوتية المفعلة حالياً
  List<DhikrReminderItem> getActiveAudioReminders() {
    final prefs = _preferences;
    final enabledIds = prefs?.enabledDhikrIds ?? defaultEnabledDhikrIds;
    return defaultDhikrReminders
        .where((item) =>
            item.audioAsset != null && enabledIds.contains(item.id))
        .toList();
  }

  /// تشغيل الذكر الصوتي التالي دورياً
  Future<void> playNextPeriodicDhikr() async {
    final activeItems = getActiveAudioReminders();
    if (activeItems.isEmpty) return;

    // التأكد من أن الوقت مناسب (خلال ساعات النهار واليقظة من 7:30 صباحاً حتى 11:00 مساءً)
    final now = DateTime.now();
    if (now.hour < 7 || (now.hour >= 23 && now.minute > 30)) {
      return;
    }

    _lastIndex = (_lastIndex + 1) % activeItems.length;
    final item = activeItems[_lastIndex];
    await playDhikr(item);
  }

  /// تشغيل صوت ذكر محدد (سواء للاختبار أو التنبيه الدوري)
  Future<void> playDhikr(DhikrReminderItem item) async {
    final asset = item.audioAsset;
    if (asset == null) return;

    try {
      currentlyPlayingId.value = item.id;
      await _player.stop();
      await AudioAssetUtils.playAssetAudio(
        _player,
        asset,
        id: 'dhikr_${item.id}',
        title: item.title,
        artist: 'ذكرني • التذكير الصوتي',
        album: 'الأذكار والتسابيح',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ أثناء تشغيل صوت الذكر: $e');
      }
      currentlyPlayingId.value = null;
    }
  }

  /// تجربة تشغيل ذكر محدد في شاشة الإعدادات
  Future<void> previewOrToggle(DhikrReminderItem item) async {
    if (currentlyPlayingId.value == item.id && isPlaying.value) {
      await stop();
    } else {
      await playDhikr(item);
    }
  }

  /// تجربة عشوائية فورية لأي ذكر مفعل للتحقق من عمل الصوت
  Future<void> testRandomActiveDhikr() async {
    final active = getActiveAudioReminders();
    if (active.isEmpty) {
      final allAudio = defaultDhikrReminders.where((i) => i.audioAsset != null).toList();
      if (allAudio.isNotEmpty) {
        await playDhikr(allAudio[Random().nextInt(allAudio.length)]);
      }
      return;
    }
    final pick = active[Random().nextInt(active.length)];
    await playDhikr(pick);
  }

  /// إيقاف الصوت الحالي فوراً
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    currentlyPlayingId.value = null;
    isPlaying.value = false;
  }

  /// التخلص من الموارد
  void dispose() {
    _periodicTimer?.cancel();
    _player.dispose();
  }
}
