import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/storage/app_local_store.dart';
import '../../../core/utils/audio_asset_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';
import '../../dhikr_reminders/application/voice_dhikr_service.dart';
import '../../dhikr_reminders/domain/dhikr_reminder_item.dart';
import '../../prayer_times/application/prayer_controller.dart';
import '../../prayer_times/domain/adhan_voice.dart';
import '../../prayer_times/domain/prayer_preferences.dart';
import '../../prayer_times/overlay/adhan_overlay_widget.dart';
import '../../prayer_times/presentation/in_app_adhan_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.prayer,
    required this.store,
    required this.onThemeModeChanged,
  });

  final PrayerController prayer;
  final AppLocalStore store;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PrayerPreferences _prefs;
  late final TextEditingController _city;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _customReminder;
  late ThemeMode _themeMode;
  bool _saving = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingVoiceId;

  @override
  void initState() {
    super.initState();
    _prefs = widget.prayer.loadPreferences();
    _city = TextEditingController(text: _prefs.city);
    _lat = TextEditingController(text: _prefs.latitude.toStringAsFixed(4));
    _lng = TextEditingController(text: _prefs.longitude.toStringAsFixed(4));
    _customReminder = TextEditingController(
      text: _prefs.reminderMinutes.toString(),
    );
    _themeMode = switch (widget.store.getString('app_theme_mode')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted && !state.playing && state.processingState == ProcessingState.completed) {
        setState(() => _playingVoiceId = null);
      }
    });
  }

  @override
  void dispose() {
    _city.dispose();
    _lat.dispose();
    _lng.dispose();
    _customReminder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPreview(AdhanVoice voice) async {
    try {
      if (_playingVoiceId == voice.id) {
        await _audioPlayer.stop();
        if (mounted) setState(() => _playingVoiceId = null);
      } else {
        await _audioPlayer.stop();
        if (mounted) setState(() => _playingVoiceId = voice.id);
        await AudioAssetUtils.playAssetAudio(
          _audioPlayer,
          voice.assetPath,
          id: voice.id,
          title: voice.name,
          artist: voice.subtitle,
          album: 'أصوات الأذان',
        );
      }
    } catch (e) {
      debugPrint('Error previewing adhan voice: $e');
      if (mounted) {
        setState(() => _playingVoiceId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تشغيل صوت الأذان: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _save(PrayerPreferences prefs) async {
    setState(() => _saving = true);
    try {
      final saved = await widget.prayer.save(prefs);
      if (!mounted) return;
      setState(() => _prefs = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات وإعادة جدولة التنبيهات والأذكار بنجاح'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleOverlay(bool value) async {
    if (value && !kIsWeb && Platform.isAndroid) {
      final granted = await AdhanOverlayManager.isPermissionGranted();
      if (!granted) {
        final result = await AdhanOverlayManager.requestPermission();
        if (result != true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'يرجى منح إذن "الظهور فوق التطبيقات" لتفعيل ميزة الشاشة العائمة',
              ),
            ),
          );
        }
      }
    }
    setState(() {
      _prefs = _prefs.copyWith(overlayOnAdhan: value);
    });
    await _save(_prefs);
  }

  Future<void> _previewOverlay() async {
    if (kIsWeb || !Platform.isAndroid) {
      await InAppAdhanDialog.show(
        context,
        prayerName: 'العصر',
        city: _prefs.city,
        audioAsset: _prefs.selectedVoice.assetPath,
      );
      return;
    }

    final granted = await AdhanOverlayManager.isPermissionGranted();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تحتاج إلى تفعيل إذن "الظهور فوق التطبيقات" أولاً من إعدادات النظام',
          ),
          action: SnackBarAction(
            label: 'منح الإذن',
            onPressed: () => AdhanOverlayManager.requestPermission(),
          ),
        ),
      );
      return;
    }

    await AdhanOverlayManager.showAdhanOverlay(
      prayerName: 'العصر',
      time: '03:45 م',
      city: _prefs.city,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إظهار شاشة الأذان فوق التطبيقات للمعاينة'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
    }
  }

  Future<void> _testAdhanNotification() async {
    try {
      await widget.prayer.notifications.showTestAdhanNotification(
        prayerName: 'الظهر',
        city: _prefs.city,
        voice: _prefs.selectedVoice,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال إشعار الأذان التجريبي بصوت ${_prefs.selectedVoice.name}',
            ),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _testDhikrNotification({bool overlay = false}) async {
    try {
      final sampleItem = defaultDhikrReminders.first;
      if (overlay) {
        if (!kIsWeb && Platform.isAndroid) {
          final granted = await AdhanOverlayManager.isPermissionGranted();
          if (!granted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'تحتاج إلى تفعيل إذن "الظهور فوق التطبيقات" أولاً من إعدادات النظام',
                ),
                action: SnackBarAction(
                  label: 'منح الإذن',
                  onPressed: () => AdhanOverlayManager.requestPermission(),
                ),
              ),
            );
            return;
          }
        }
      }

      await widget.prayer.notifications.showTestDhikrNotification(
        item: sampleItem,
        showOverlay: overlay,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              overlay
                  ? 'تم إظهار نافذة الذكر العائمة بنجاح ✨'
                  : 'تم إرسال إشعار الذكر التجريبي بنجاح 🔔',
            ),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderOptions = [0, 5, 10, 15, 30];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'الإعدادات والأذان',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'المظهر والسمة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('تلقائي'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('فاتح'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('داكن'),
              ),
            ],
            selected: {_themeMode},
            onSelectionChanged: (selection) {
              final mode = selection.first;
              setState(() => _themeMode = mode);
              widget.onThemeModeChanged(mode);
            },
          ),
          const SizedBox(height: 24),

          // Prayer Notifications Header
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'نظام التنبيهات والأذان',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Adhan Voice Selection Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          color: Color(0xFF0D9488),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'صوت الأذان والمؤذن',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'اختر صوت الأذان المفضل مع إمكانية الاستماع والمعاينة',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...supportedAdhanVoices.map((voice) {
                    final isSelected = _prefs.adhanVoice == voice.id;
                    final isPlaying = _playingVoiceId == voice.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D9488).withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : colorScheme.outlineVariant.withValues(alpha: 0.6),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : colorScheme.outline,
                        ),
                        title: Text(
                          voice.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF0D9488) : null,
                          ),
                        ),
                        subtitle: Text(
                          voice.subtitle,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: isPlaying
                                ? const Color(0xFF0D9488)
                                : const Color(0xFF0D9488).withValues(alpha: 0.15),
                            foregroundColor: isPlaying
                                ? Colors.white
                                : const Color(0xFF0D9488),
                          ),
                          icon: Icon(
                            isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                            size: 20,
                          ),
                          tooltip: isPlaying ? 'إيقاف' : 'استماع',
                          onPressed: () => _toggleAudioPreview(voice),
                        ),
                        onTap: () {
                          setState(() {
                            _prefs = _prefs.copyWith(adhanVoice: voice.id);
                          });
                          _save(_prefs);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Overlay Window Setting Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: _prefs.overlayOnAdhan
                    ? const Color(0xFF0D9488)
                    : colorScheme.outlineVariant,
                width: _prefs.overlayOnAdhan ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    title: const Text(
                      'الظهور فوق التطبيقات عند الأذان',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'إذا كان الهاتف قيد الاستخدام، تظهر شاشة أذان تفاعلية فوق أي تطبيق مفتوح.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _prefs.overlayOnAdhan,
                    onChanged: _saving ? null : _toggleOverlay,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _previewOverlay,
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text(
                            'معاينة الشاشة العائمة',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _testAdhanNotification,
                          icon: const Icon(Icons.notifications_active, size: 18),
                          label: const Text(
                            'تجربة إشعار الأذان',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. New Section: Periodic Daytime Dhikr Reminders
          Text(
            'الأذكار والتسابيح والتنبيه الصوتي',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: _prefs.dhikrReminderEnabled
                    ? const Color(0xFF0D9488)
                    : colorScheme.outlineVariant,
                width: _prefs.dhikrReminderEnabled ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    title: const Text(
                      'تفعيل التذكير بالأذكار والصلاة على النبي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'إشعارات وتنبيهات دورية تذكرك بالصلاة على النبي ﷺ والتهليل والاستغفار والتسبيح خلال اليوم.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _prefs.dhikrReminderEnabled,
                    onChanged: (val) {
                      setState(() {
                        _prefs = _prefs.copyWith(dhikrReminderEnabled: val);
                      });
                      _save(_prefs);
                    },
                  ),
                  if (_prefs.dhikrReminderEnabled) ...[
                    const Divider(height: 24),
                    // التنبيه الصوتي الناطق
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      title: const Text(
                        'التنبيه الصوتي بالأذكار (صوت ناطق)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'صوت عذب يذكرك بالصلاة على النبي ﷺ والتهليل والتسبيح دورياً حتى عند ترك الهاتف.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _prefs.dhikrVoiceEnabled,
                      onChanged: (val) {
                        setState(() {
                          _prefs = _prefs.copyWith(dhikrVoiceEnabled: val);
                        });
                        _save(_prefs);
                      },
                    ),
                    const Divider(height: 20),
                    Text(
                      'وتيرة التكرار خلال أوقات اليوم النشطة:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'label': 'كل 5 دقائق', 'val': 5},
                        {'label': 'كل 10 دقائق', 'val': 10},
                        {'label': 'كل 15 دقيقة', 'val': 15},
                        {'label': 'كل 30 دقيقة', 'val': 30},
                        {'label': 'كل ساعة', 'val': 60},
                        {'label': 'كل ساعتين', 'val': 120},
                      ].map((opt) {
                        final val = opt['val'] as int;
                        final isSelected = _prefs.dhikrIntervalMinutes == val;
                        return ChoiceChip(
                          label: Text(opt['label'] as String),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _prefs = _prefs.copyWith(dhikrIntervalMinutes: val);
                            });
                            _save(_prefs);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    // قسم تحديد الأذكار المقروءة وسماع أصواتها
                    Row(
                      children: [
                        const Icon(Icons.checklist_rounded, size: 20, color: Color(0xFF0D9488)),
                        const SizedBox(width: 8),
                        Text(
                          'تحديد الأذكار المفعلة وسماع أصواتها:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حدّد الأذكار التي تود سماعها، واضغط على زر التشغيل للاستماع لصوت الذكر مباشرة:',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...defaultDhikrReminders.where((item) => item.audioAsset != null).map((item) {
                      final isEnabled = _prefs.enabledDhikrIds.contains(item.id);
                      return ValueListenableBuilder<String?>(
                        valueListenable: VoiceDhikrService.instance.currentlyPlayingId,
                        builder: (context, playingId, _) {
                          final isItemPlaying = playingId == item.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isItemPlaying
                                  ? const Color(0xFFD4AF37).withValues(alpha: 0.12)
                                  : (isEnabled
                                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isItemPlaying
                                    ? const Color(0xFFD4AF37)
                                    : (isEnabled
                                        ? const Color(0xFF0D9488).withValues(alpha: 0.3)
                                        : Colors.transparent),
                                width: isItemPlaying ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isEnabled,
                                  activeColor: const Color(0xFF0D9488),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (checked) {
                                    final current = List<String>.from(_prefs.enabledDhikrIds);
                                    if (checked == true) {
                                      if (!current.contains(item.id)) current.add(item.id);
                                    } else {
                                      current.remove(item.id);
                                    }
                                    setState(() {
                                      _prefs = _prefs.copyWith(enabledDhikrIds: current);
                                    });
                                    _save(_prefs);
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isEnabled
                                              ? colorScheme.onSurface
                                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      if (item.spokenPhrase != null)
                                        Text(
                                          'الصوت: "${item.spokenPhrase}"',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF0D9488),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton.filledTonal(
                                  tooltip: isItemPlaying ? 'إيقاف' : 'استماع لصوت الذكر',
                                  style: IconButton.styleFrom(
                                    backgroundColor: isItemPlaying
                                        ? const Color(0xFFD4AF37)
                                        : const Color(0xFF0D9488).withValues(alpha: 0.15),
                                    foregroundColor: isItemPlaying
                                        ? const Color(0xFF332000)
                                        : const Color(0xFF0D9488),
                                  ),
                                  icon: Icon(
                                    isItemPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () => VoiceDhikrService.instance.previewOrToggle(item),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.featured_play_list_rounded,
                          color: Color(0xFFD4AF37),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'نافذة إسلامية عائمة عند التذكير',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'ظهور بطاقة ذكر أنيقة فوق التطبيقات أثناء تصفح الهاتف تُغلق تلقائياً بعد ثوانٍ معدودة.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _prefs.dhikrOverlayEnabled,
                      onChanged: (val) {
                        setState(() {
                          _prefs = _prefs.copyWith(dhikrOverlayEnabled: val);
                        });
                        _save(_prefs);
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => VoiceDhikrService.instance.testRandomActiveDhikr(),
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          label: const Text('تجربة التذكير الصوتي الآن', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _testDhikrNotification(overlay: false),
                          icon: const Icon(Icons.notifications_active_outlined, size: 18),
                          label: const Text(
                            'تجربة إشعار الذكر',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _testDhikrNotification(overlay: true),
                          icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                          label: const Text(
                            'تجربة النافذة العائمة',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('مواقيت الصلاة والموقع', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          TextField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'المدينة'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lat,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lng,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      final prefs = await widget.prayer.useCurrentLocation(
                        _prefs,
                      );
                      if (!mounted) return;
                      setState(() {
                        _prefs = prefs;
                        _city.text = prefs.city;
                        _lat.text = prefs.latitude.toStringAsFixed(4);
                        _lng.text = prefs.longitude.toStringAsFixed(4);
                      });
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            icon: const Icon(Icons.my_location),
            label: const Text('استخدم موقعي الحالي'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _prefs.calculationMethod,
            decoration: const InputDecoration(labelText: 'طريقة الحساب'),
            items: const [
              DropdownMenuItem(value: 'egyptian', child: Text('Egyptian')),
              DropdownMenuItem(
                value: 'muslimWorldLeague',
                child: Text('Muslim World League'),
              ),
              DropdownMenuItem(value: 'ummAlQura', child: Text('Umm Al-Qura')),
            ],
            onChanged: (value) => setState(
              () => _prefs = _prefs.copyWith(calculationMethod: value),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _prefs.madhab,
            decoration: const InputDecoration(labelText: 'مذهب العصر'),
            items: const [
              DropdownMenuItem(value: 'shafi', child: Text('Shafi')),
              DropdownMenuItem(value: 'hanafi', child: Text('Hanafi')),
            ],
            onChanged: (value) =>
                setState(() => _prefs = _prefs.copyWith(madhab: value)),
          ),
          const SizedBox(height: 20),
          Text(
            'وقت التنبيه المسبق قبل الأذان',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: reminderOptions
                .map(
                  (m) => ChoiceChip(
                    label: Text(m == 0 ? 'بدون تذكير مسبق' : '$m دقيقة قبلها'),
                    selected: _prefs.reminderMinutes == m,
                    onSelected: (_) => setState(() {
                      _prefs = _prefs.copyWith(reminderMinutes: m);
                      _customReminder.text = '$m';
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customReminder,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'قيمة مخصصة للتنبيه المسبق بالدقائق',
            ),
            onChanged: (value) => _prefs = _prefs.copyWith(
              reminderMinutes: int.tryParse(value) ?? _prefs.reminderMinutes,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'الصلوات المفعلة للتنبيه والأذان',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._prefs.enabledPrayers.entries.map(
            (entry) => SwitchListTile(
              title: Text(_prayerName(entry.key)),
              value: entry.value,
              onChanged: (value) => setState(() {
                _prefs = _prefs.copyWith(
                  enabledPrayers: {..._prefs.enabledPrayers, entry.key: value},
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _saving
                ? null
                : () {
                    final lat = double.tryParse(_lat.text) ?? _prefs.latitude;
                    final lng = double.tryParse(_lng.text) ?? _prefs.longitude;
                    _save(
                      _prefs.copyWith(
                        city: _city.text.trim().isEmpty
                            ? 'موقع يدوي'
                            : _city.text.trim(),
                        latitude: lat,
                        longitude: lng,
                      ),
                    );
                  },
            child: Text(
              _saving ? 'جار الحفظ والجدولة...' : 'حفظ الإعدادات وجدولة الأذان والتنبيهات',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _prayerName(String key) => switch (key) {
    'fajr' => 'الفجر',
    'dhuhr' => 'الظهر',
    'asr' => 'العصر',
    'maghrib' => 'المغرب',
    'isha' => 'العشاء',
    _ => key,
  };
}
