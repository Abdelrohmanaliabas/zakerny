import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class InAppAdhanDialog extends StatefulWidget {
  const InAppAdhanDialog({
    super.key,
    required this.prayerName,
    required this.city,
    this.autoPlayAudio = true,
    this.audioAsset,
  });

  final String prayerName;
  final String city;
  final bool autoPlayAudio;
  final String? audioAsset;

  static Future<void> show(
    BuildContext context, {
    required String prayerName,
    required String city,
    bool autoPlayAudio = true,
    String? audioAsset,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InAppAdhanDialog(
        prayerName: prayerName,
        city: city,
        autoPlayAudio: autoPlayAudio,
        audioAsset: audioAsset,
      ),
    );
  }

  @override
  State<InAppAdhanDialog> createState() => _InAppAdhanDialogState();
}

class _InAppAdhanDialogState extends State<InAppAdhanDialog>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.autoPlayAudio) {
      _initAndPlayAudio();
    }
  }

  Future<void> _initAndPlayAudio() async {
    try {
      final asset = widget.audioAsset ?? 'assets/audio/adhan_makkah.mp3';
      await _player.setAsset(asset);
      await _player.play();
      if (mounted) setState(() => _isPlaying = true);

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xF0062822),
                Color(0xF00F433A),
                Color(0xF0031814),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                blurRadius: 35,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row with App Name & Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Color(0xFF34D399),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ذكرني • نداء الصلاة',
                        style: TextStyle(
                          color: Color(0xFF9AE6B4),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Animated Pulsing Icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        const Color(0xFF0F766E).withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFFFBBF24),
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'الله أكبر • الله أكبر',
                style: TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'حان الآن موعد أذان ${widget.prayerName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'حسب التوقيت المحلي لـ ${widget.city}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 16),

              // Dua Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      '«حي على الصلاة • حي على الفلاح»',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ»',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontFamily: 'Amiri',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _toggleAudio,
                      icon: Icon(
                        _isPlaying ? Icons.volume_off : Icons.volume_up,
                        size: 20,
                      ),
                      label: Text(
                        _isPlaying ? 'كتم الأذان' : 'تشغيل الصوت',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text(
                        'تم الاستماع',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
