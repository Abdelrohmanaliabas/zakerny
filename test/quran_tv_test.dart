import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/features/quran/domain/quran_models.dart';
import 'package:zakerny/src/features/quran/presentation/screens/quran_tv_channel_screen.dart';
import 'package:zakerny/src/features/recitations/domain/recitation_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QuranTvChannelScreen renders properly with TV brand, Surah title and backdrop', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const testSurah = Surah(
      id: 1,
      name: 'الفاتحة',
      ayahs: [
        Ayah(number: 1, text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
        Ayah(number: 2, text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
        Ayah(number: 3, text: 'الرَّحْمَٰنِ الرَّحِيمِ'),
      ],
      revelationType: 'Meccan',
    );

    const testReciter = Reciter(
      id: 'alafasy',
      name: 'مشاري العفاسي',
      surahs: [
        RecitationSurah(id: 1, name: 'الفاتحة'),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: QuranTvChannelScreen(
          initialSurah: testSurah,
          reciter: testReciter,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify TV channel brand
    expect(find.text('قناة القرآن الكريم'), findsOneWidget);

    // Verify Surah title
    expect(find.textContaining('الفاتحة'), findsWidgets);

    // Verify Reciter name
    expect(find.text('مشاري العفاسي'), findsOneWidget);

    // Verify scene controls
    expect(find.text('المشاهد (21)'), findsOneWidget);
    expect(find.text('تبديل المشاهد تلقائياً (25ث)'), findsOneWidget);
  });
}
