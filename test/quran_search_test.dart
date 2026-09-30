import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/features/quran/domain/quran_models.dart';

void main() {
  group('Quran Ayah Search & Normalization', () {
    final sampleAyahs = [
      Ayah(
        number: 1,
        text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        juz: 1,
        page: 1,
      ),
      Ayah(
        number: 4,
        text: 'مَٰلِكِ يَوْمِ ٱلدِّينِ',
        juz: 1,
        page: 1,
      ),
      Ayah(
        number: 6,
        text: 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
        juz: 1,
        page: 1,
      ),
      Ayah(
        number: 43,
        text: 'وَأَقِيمُواْ ٱلصَّلَوٰةَ وَءَاتُواْ ٱلزَّكَوٰةَ وَٱرْكَعُواْ مَعَ ٱلرَّٰكِعِينَ',
        juz: 1,
        page: 7,
      ),
    ];

    test('finds Ayahs without diacritics / tashkeel', () {
      // 1. Search for "الصراط"
      final siratResults = sampleAyahs.where((a) => a.matches('الصراط')).toList();
      expect(siratResults.length, 1);
      expect(siratResults.first.number, 6);

      // 2. Search for "مالك"
      final malikResults = sampleAyahs.where((a) => a.matches('مالك')).toList();
      expect(malikResults.length, 1);
      expect(malikResults.first.number, 4);

      // 3. Search for "الصلاة" and "الصلاه"
      final salahResults1 = sampleAyahs.where((a) => a.matches('الصلاة')).toList();
      final salahResults2 = sampleAyahs.where((a) => a.matches('الصلاه')).toList();
      expect(salahResults1.length, 1);
      expect(salahResults2.length, 1);
      expect(salahResults1.first.number, 43);

      // 4. Search for "الزكاة" and "الزكاه"
      final zakahResults = sampleAyahs.where((a) => a.matches('الزكاة')).toList();
      expect(zakahResults.length, 1);
      expect(zakahResults.first.number, 43);

      // 5. Search for "الرحمن"
      final rahmanResults = sampleAyahs.where((a) => a.matches('الرحمن')).toList();
      expect(rahmanResults.length, 1);
      expect(rahmanResults.first.number, 1);
    });
  });
}
