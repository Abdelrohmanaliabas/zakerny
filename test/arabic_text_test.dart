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

    test('matches Quranic verses in Uthmani script when searched without tashkeel', () {
      // 1. Al-Fatiha: Dagger Alif in صِرَٰط and ٱلْعَٰلَمِينَ and مَٰلِكِ
      const fatihaSirat = 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ';
      expect(ArabicTextUtils.contains(fatihaSirat, 'الصراط المستقيم'), isTrue);
      expect(ArabicTextUtils.contains(fatihaSirat, 'الصراط'), isTrue);
      expect(ArabicTextUtils.contains(fatihaSirat, 'المستقيم'), isTrue);
      expect(ArabicTextUtils.contains(fatihaSirat, 'اهدنا'), isTrue);
      expect(ArabicTextUtils.contains(fatihaSirat, 'صراط'), isTrue);

      const fatihaMalik = 'مَٰلِكِ يَوْمِ ٱلدِّينِ';
      expect(ArabicTextUtils.contains(fatihaMalik, 'مالك'), isTrue);
      expect(ArabicTextUtils.contains(fatihaMalik, 'مالك يوم الدين'), isTrue);
      expect(ArabicTextUtils.contains(fatihaMalik, 'يوم الدين'), isTrue);

      const fatihaAlameen = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';
      expect(ArabicTextUtils.contains(fatihaAlameen, 'العالمين'), isTrue);
      expect(ArabicTextUtils.contains(fatihaAlameen, 'الحمد لله رب العالمين'), isTrue);

      // 2. Al-Baqarah: Waw with dagger alif in الصلاة and الزكاة
      const salahAyah = 'وَأَقِيمُواْ ٱلصَّلَوٰةَ وَءَاتُواْ ٱلزَّكَوٰةَ وَٱرْكَعُواْ مَعَ ٱلرَّٰكِعِينَ';
      expect(ArabicTextUtils.contains(salahAyah, 'واقيموا الصلاة'), isTrue);
      expect(ArabicTextUtils.contains(salahAyah, 'الصلاة'), isTrue);
      expect(ArabicTextUtils.contains(salahAyah, 'الصلاه'), isTrue);
      expect(ArabicTextUtils.contains(salahAyah, 'الزكاة'), isTrue);
      expect(ArabicTextUtils.contains(salahAyah, 'الزكاه'), isTrue);
      expect(ArabicTextUtils.contains(salahAyah, 'الراكعين'), isTrue);

      // 3. Al-Baqarah: ذلك الكتاب
      const baqarahKitab = 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًۭى لِّلْمُتَّقِينَ';
      expect(ArabicTextUtils.contains(baqarahKitab, 'ذلك الكتاب'), isTrue);
      expect(ArabicTextUtils.contains(baqarahKitab, 'الكتاب'), isTrue);
      expect(ArabicTextUtils.contains(baqarahKitab, 'لا ريب فيه'), isTrue);
      expect(ArabicTextUtils.contains(baqarahKitab, 'للمتقين'), isTrue);

      // 4. Ayat Al-Kursi
      const kursi = 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُ';
      expect(ArabicTextUtils.contains(kursi, 'الله لا اله الا هو'), isTrue);
      expect(ArabicTextUtils.contains(kursi, 'لا اله الا هو'), isTrue);
      expect(ArabicTextUtils.contains(kursi, 'الحي القيوم'), isTrue);

      // 5. Al-Ikhlas
      const ikhlas = 'قُلْ هُوَ اللَّهُ أَحَدٌ';
      expect(ArabicTextUtils.contains(ikhlas, 'قل هو الله احد'), isTrue);
      expect(ArabicTextUtils.contains(ikhlas, 'الله احد'), isTrue);

      // 6. Al-Isra: سبحان الذي اسرى
      const isra = 'سُبۡحَٰنَ ٱلَّذِىٓ أَسۡرَىٰ بِعَبۡدِهِۦ لَيۡلٗا';
      expect(ArabicTextUtils.contains(isra, 'سبحان الذي اسرى'), isTrue);
      expect(ArabicTextUtils.contains(isra, 'سبحان الذي اسري'), isTrue);
      expect(ArabicTextUtils.contains(isra, 'سبحان'), isTrue);

      // 7. An-Nas
      const nas1 = 'إِلَٰهِ ٱلنَّاسِ';
      expect(ArabicTextUtils.contains(nas1, 'اله الناس'), isTrue);
      expect(ArabicTextUtils.contains(nas1, 'إله الناس'), isTrue);

      const nas2 = 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ';
      expect(ArabicTextUtils.contains(nas2, 'الذي يوسوس'), isTrue);
      expect(ArabicTextUtils.contains(nas2, 'في صدور الناس'), isTrue);

      // 8. Al-Kawthar: أَعۡطَيۡنَٰكَ (dagger alif)
      const kawthar = 'إِنَّآ أَعۡطَيۡنَٰكَ ٱلۡكَوْثَرَ';
      expect(ArabicTextUtils.contains(kawthar, 'انا اعطيناك الكوثر'), isTrue);
      expect(ArabicTextUtils.contains(kawthar, 'إنا أعطيناك الكوثر'), isTrue);
      expect(ArabicTextUtils.contains(kawthar, 'اعطيناك'), isTrue);

      // 9. Al-Kafirun: يَٰٓأَيُّهَا ٱلۡكَٰفِرُونَ
      const kafirun = 'قُلۡ يَٰٓأَيُّهَا ٱلۡكَٰفِرُونَ';
      expect(ArabicTextUtils.contains(kafirun, 'قل يا ايها الكافرون'), isTrue);
      expect(ArabicTextUtils.contains(kafirun, 'يا ايها الكافرون'), isTrue);
      expect(ArabicTextUtils.contains(kafirun, 'الكافرون'), isTrue);

      // 10. Al-Masad
      const masad = 'تَبَّتۡ يَدَآ أَبِى لَهَبٖ وَتَبَّ';
      expect(ArabicTextUtils.contains(masad, 'تبت يدا ابي لهب'), isTrue);
      expect(ArabicTextUtils.contains(masad, 'ابي لهب'), isTrue);
    });
  });
}
