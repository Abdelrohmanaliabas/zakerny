import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/utils/audio_asset_utils.dart';
import '../../../core/widgets/fatimid_decorations.dart';

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

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.autoPlayAudio) {
      _initAndPlayAudio();
    }
  }

  Future<void> _initAndPlayAudio() async {
    try {
      final asset = widget.audioAsset ?? 'assets/audio/adhan_makkah.mp3';
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
      await AudioAssetUtils.playAssetAudio(
        _player,
        asset,
        id: 'in_app_adhan',
        title: 'أذان ${widget.prayerName}',
        artist: 'حي على الصلاة',
        album: widget.city,
      );
      if (mounted) setState(() => _isPlaying = true);
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C2920),
                Color(0xFF071F18),
                Color(0xFF04130F),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: FatimidColors.goldPrimary,
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 36,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.25),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Top radiating rosette
              Positioned(
                top: -40,
                right: -40,
                child: FatimidRosette(
                  size: 180,
                  color: FatimidColors.goldLight,
                  opacity: 0.15,
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: FatimidRosette(
                  size: 160,
                  color: FatimidColors.goldLight,
                  opacity: 0.12,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
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
                                gradient: FatimidColors.goldGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mosque,
                                color: Color(0xFF332000),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'ذكرني • نداء الصلاة',
                              style: TextStyle(
                                color: FatimidColors.goldLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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

                    // Animated Pulsing Keel Medallion
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              FatimidColors.goldPrimary.withValues(alpha: 0.45),
                              FatimidColors.emeraldPrimary.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: FatimidColors.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFF332000),
                            size: 42,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'الله أكبر • الله أكبر',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                        letterSpacing: 0.5,
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

                    // Dua Card with Fatimid gold border
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                          width: 1,
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
                              foregroundColor: FatimidColors.goldLight,
                              side: BorderSide(
                                color: FatimidColors.goldPrimary.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                              backgroundColor: FatimidColors.emeraldMedium,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
            ],
          ),
        ),
      ),
    );
  }
}
