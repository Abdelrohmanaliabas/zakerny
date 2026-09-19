import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/core/utils/arabic_text_utils.dart';

void main() {
  group('ArabicTextUtils', () {
    test('removes tashkeel and harakat accurately', () {
      const text = 'سُورَةُ البَقَرَةِ الرَّحْمٰنُ';
      final clean = ArabicTextUtils.removeTashkeel(text);
      expect(clean, 'سورة البقرة الرحمن');
    });

    test('normalizes alef, taa marbuta, and alef maqsura', () {
      expect(ArabicTextUtils.normalize('إِيَّاكَ نَعْبُدُ'), 'اياك نعبد');
      expect(ArabicTextUtils.normalize('الفَاتِحَةُ'), 'الفاتحه');
      expect(ArabicTextUtils.normalize('عَلَى'), 'علي');
      expect(ArabicTextUtils.normalize('آمَنَ'), 'امن');
    });

    test('matches search queries without tashkeel or hamza', () {
      const surahName = 'سُورَةُ الفَاتِحَةِ';
      expect(ArabicTextUtils.contains(surahName, 'الفاتحة'), isTrue);
      expect(ArabicTextUtils.contains(surahName, 'الفاتحه'), isTrue);
      expect(ArabicTextUtils.contains(surahName, 'فاتحه'), isTrue);
      expect(ArabicTextUtils.contains(surahName, 'سورة الفاتحة'), isTrue);

      const hadithText = 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى';
      expect(ArabicTextUtils.contains(hadithText, 'انما الاعمال بالنيات'), isTrue);
      expect(ArabicTextUtils.contains(hadithText, 'لكل امرئ'), isTrue);
      expect(ArabicTextUtils.contains(hadithText, 'ما نوى'), isTrue);
      expect(ArabicTextUtils.contains(hadithText, 'ما نوي'), isTrue);
    });
  });
}
