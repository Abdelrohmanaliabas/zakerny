import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/app_local_store.dart';
import '../../prayer_times/application/prayer_controller.dart';
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
  }

  @override
  void dispose() {
    _city.dispose();
    _lat.dispose();
    _lng.dispose();
    _customReminder.dispose();
    super.dispose();
  }

  Future<void> _save(PrayerPreferences prefs) async {
    setState(() => _saving = true);
    try {
      final saved = await widget.prayer.save(prefs);
      if (!mounted) return;
      setState(() => _prefs = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات وإعادة جدولة التنبيهات والأذان بنجاح'),
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
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إرسال إشعار الأذان التجريبي بصوت الأذان والخيارات التفاعلية',
            ),
            backgroundColor: Color(0xFF0D9488),
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
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
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

          // Prayer Notifications Header & Explanatory Card
          Text(
            'نظام التنبيهات والأذان',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'نظام تنبيه مزدوج وموثوق:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. تنبيه مسبق قبل الأذان بالدقائق المحددة للاستعداد والوضوء.\n'
                  '2. رنين الأذان الكامل في وقت الصلاة الفعلي بالثانية.\n'
                  '3. إشعار تفاعلي فوري على الشاشة وأزرار سريعة لكتم أو فتح التطبيق.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Overlay Window Setting
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
              _saving ? 'جار الحفظ والجدولة...' : 'حفظ الإعدادات وجدولة الأذان',
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
