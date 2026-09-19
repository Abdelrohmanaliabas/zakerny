import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/core/widgets/fatimid_decorations.dart';
import 'package:zakerny/src/core/widgets/islamic_background.dart';
import 'package:zakerny/src/features/prayer_times/domain/prayer_preferences.dart';

void main() {
  test('FatimidKeelArchClipper generates a valid closed keel arch path', () {
    const clipper = FatimidKeelArchClipper(
      archHeightFraction: 0.25,
      archApexRise: 16.0,
      bottomCornerRadius: 20.0,
    );

    const size = Size(300, 400);
    final path = clipper.getClip(size);

    expect(path, isNotNull);
    final bounds = path.getBounds();
    expect(bounds.width, 300);
    expect(bounds.height, 400);
  });

  test('test adhan_dart prayer calculation', () {
    final prefs = PrayerPreferences.defaults();
    final params = CalculationMethodParameters.egyptian();
    final now = DateTime.now();
    final times = PrayerTimes(
      date: now,
      coordinates: Coordinates(prefs.latitude, prefs.longitude),
      calculationParameters: params,
    );
    expect(times.fajr, isNotNull);
    expect(times.dhuhr, isNotNull);
  });

  testWidgets('FatimidStarBadge renders number and label correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FatimidStarBadge(number: 114, isGold: true),
        ),
      ),
    );

    expect(find.text('114'), findsOneWidget);
    expect(find.byType(FatimidStarBadge), findsOneWidget);
  });

  testWidgets('FatimidRosette renders fluted radiating rosette', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FatimidRosette(
            size: 140,
            petalCount: 16,
            child: Icon(Icons.mosque),
          ),
        ),
      ),
    );

    expect(find.byType(FatimidRosette), findsOneWidget);
    expect(find.byIcon(Icons.mosque), findsOneWidget);
  });

  testWidgets('FatimidCard renders with custom content and reacts to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FatimidCard(
            isEmerald: true,
            onTap: () => tapped = true,
            child: const Text('بطاقة فاطمية'),
          ),
        ),
      ),
    );

    expect(find.text('بطاقة فاطمية'), findsOneWidget);
    await tester.tap(find.text('بطاقة فاطمية'));
    expect(tapped, isTrue);
  });

  testWidgets('IslamicBackground renders child with Fatimid lattice', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IslamicBackground(
          child: Text('خلفية إسلامية'),
        ),
      ),
    );

    expect(find.text('خلفية إسلامية'), findsOneWidget);
    expect(find.byType(IslamicBackground), findsOneWidget);
  });
}
