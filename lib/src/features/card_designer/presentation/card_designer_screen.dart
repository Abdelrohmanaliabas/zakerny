import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../domain/card_template.dart';

class CardDesignerScreen extends StatefulWidget {
  const CardDesignerScreen({
    super.key,
    this.initialText,
    this.initialReference,
    this.isQuran = true,
  });

  final String? initialText;
  final String? initialReference;
  final bool isQuran;

  @override
  State<CardDesignerScreen> createState() => _CardDesignerScreenState();
}

class _CardDesignerScreenState extends State<CardDesignerScreen> {
  final GlobalKey _cardKey = GlobalKey();
  late TextEditingController _textController;
  late TextEditingController _referenceController;
  CardThemePreset _currentTheme = CardThemePreset.presets.first;
  double _fontSize = 20.0;
  bool _isSharing = false;

  static const List<(String, String, bool)> _presetCards = [
    (
      'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
      'سورة البقرة: ٢٥٥ (آية الكرسي)',
      true,
    ),
    (
      'إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
      'سورة الأحزاب: ٥٦',
      true,
    ),
    (
      '«مَنْ صَلَّى عَلَيَّ صَلَاةً وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرَ صَلَوَاتٍ وَحَطَّ عَنْهُ عَشْرَ خَطِيئَاتٍ»',
      'صحيح النسائي • حديث شريف',
      false,
    ),
    (
      '«أَحَبُّ الْكَلَامِ إِلَى اللَّهِ أَرْبَعٌ: سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ»',
      'صحيح مسلم • حديث شريف',
      false,
    ),
    (
      'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      'دعاء ذي النون • سورة الأنبياء: ٨٧',
      true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialText ?? _presetCards.first.$1,
    );
    _referenceController = TextEditingController(
      text: widget.initialReference ?? _presetCards.first.$2,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _shareCardImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    HapticFeedback.lightImpact();

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find render object');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode image to PNG');
      }
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/zekrni_card_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: '${_textController.text}\n\n— ${_referenceController.text}\n(تمت المشاركة عبر تطبيق ذكرني)',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تصدير البطاقة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _copyCardText() {
    HapticFeedback.selectionClick();
    final textToCopy =
        '${_textController.text}\n\n— ${_referenceController.text}\n(تطبيق ذكرني)';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ النص القرآني بنجاح إلى الحافظة 📋'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ZekrniHeader(
              title: 'صانع البطاقات الإسلامية',
              subtitle: 'تصميم ومشاركة الآيات والأحاديث بأبهى حلة',
              showSearch: false,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. المعاينة المباشرة للبطاقة (RepaintBoundary for Image export)
                      Center(
                        child: RepaintBoundary(
                          key: _cardKey,
                          child: _IslamicCardWidget(
                            text: _textController.text,
                            reference: _referenceController.text,
                            theme: _currentTheme,
                            fontSize: _fontSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. أزرار المشاركة والنسخ الرئيسية
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FatimidColors.goldPrimary,
                                foregroundColor: const Color(0xFF10281E),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 4,
                              ),
                              onPressed: _isSharing ? null : _shareCardImage,
                              icon: _isSharing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Color(0xFF10281E)),
                                      ),
                                    )
                                  : const Icon(Icons.share_rounded, size: 20),
                              label: Text(
                                _isSharing ? 'جاري التصدير...' : 'مشاركة كصورة فاخرة 🖼️',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _copyCardText,
                              icon: const Icon(Icons.copy_rounded, size: 18, color: FatimidColors.goldPrimary),
                              label: const Text(
                                'نسخ النص',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: FatimidColors.goldPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // 3. اختيار الثيم والنمط الجمالي
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
                            'طراز ونمط البطاقة',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F2C22),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: CardThemePreset.presets.map((preset) {
                          final isSel = _currentTheme.type == preset.type;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _currentTheme = preset);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: preset.backgroundGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? FatimidColors.goldPrimary
                                          : Colors.grey.withValues(alpha: 0.3),
                                      width: isSel ? 2 : 1,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      preset.name,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11,
                                        fontWeight: isSel ? FontWeight.w900 : FontWeight.bold,
                                        color: preset.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // 4. حجم الخط
                      Row(
                        children: [
                          const Icon(Icons.format_size_rounded, size: 18, color: FatimidColors.goldPrimary),
                          const SizedBox(width: 8),
                          const Text(
                            'حجم الخط:',
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Expanded(
                            child: Slider(
                              value: _fontSize,
                              min: 16.0,
                              max: 28.0,
                              divisions: 6,
                              activeColor: FatimidColors.goldPrimary,
                              onChanged: (val) => setState(() => _fontSize = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 5. تعديل النص والمصدر
                      FatimidCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تعديل محتوى البطاقة',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _textController,
                              maxLines: 4,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'نص الآية أو الحديث أو الدعاء',
                                labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _referenceController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'المصدر (اسم السورة ورقم الآية أو راوي الحديث)',
                                labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 6. نماذج جاهزة وسريعة
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
                            'نماذج وبطاقات مختارة',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F2C22),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _presetCards.map((p) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ActionChip(
                                label: Text(p.$2, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _textController.text = p.$1;
                                    _referenceController.text = p.$2;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslamicCardWidget extends StatelessWidget {
  const _IslamicCardWidget({
    required this.text,
    required this.reference,
    required this.theme,
    required this.fontSize,
  });

  final String text;
  final String reference;
  final CardThemePreset theme;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      constraints: const BoxConstraints(minHeight: 380),
      decoration: BoxDecoration(
        gradient: theme.backgroundGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner decorative thin border
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: theme.borderColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Crescent & Basmala / Rosette
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 1,
                      color: theme.borderColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.brightness_3_rounded, size: 16, color: theme.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.brightness_3_rounded, size: 16, color: theme.accentColor),
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 1,
                      color: theme.borderColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Quran / Hadith Text
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 24),

                // Reference / Source Badge
                if (reference.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.borderColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.borderColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      reference,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.referenceColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Bottom Branding / Watermark
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 0.8,
                      color: theme.borderColor.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تطبيق ذكرني • Zekerini',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: theme.textColor.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 0.8,
                      color: theme.borderColor.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
