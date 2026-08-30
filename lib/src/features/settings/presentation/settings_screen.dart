import 'package:flutter/material.dart';

import '../../prayer_times/application/prayer_controller.dart';
import '../../prayer_times/domain/prayer_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.prayer});
  final PrayerController prayer;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PrayerPreferences _prefs;
  late final TextEditingController _city;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _customReminder;
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
          content: Text('تم حفظ الإعدادات وإعادة جدولة التنبيهات'),
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

  @override
  Widget build(BuildContext context) {
    final reminderOptions = [0, 5, 10, 15, 30];
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: reminderOptions
                .map(
                  (m) => ChoiceChip(
                    label: Text('$m دقيقة'),
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
              labelText: 'قيمة مخصصة للتنبيه بالدقائق',
            ),
            onChanged: (value) => _prefs = _prefs.copyWith(
              reminderMinutes: int.tryParse(value) ?? _prefs.reminderMinutes,
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          FilledButton(
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
            child: Text(_saving ? 'جار الحفظ...' : 'حفظ'),
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
