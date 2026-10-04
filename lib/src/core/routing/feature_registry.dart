import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/adhkar/application/adhkar_controller.dart';
import '../../features/adhkar/data/adhkar_repository.dart';
import '../../features/adhkar/presentation/adhkar_screen.dart';
import '../../features/hadith/application/hadith_controller.dart';
import '../../features/hadith/data/hadith_repository.dart';
import '../../features/hadith/presentation/hadith_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/prayer_times/application/prayer_controller.dart';
import '../../features/prayer_times/data/prayer_repository.dart';
import '../../features/prayer_times/presentation/prayer_times_screen.dart';
import '../../features/qibla/application/qibla_controller.dart';
import '../../features/qibla/data/qibla_repository.dart';
import '../../features/qibla/presentation/qibla_screen.dart';
import '../../features/quran/application/quran_controller.dart';
import '../../features/quran/data/quran_repository.dart';
import '../../features/quran/presentation/quran_bookmark_screen.dart';
import '../../features/quran/presentation/quran_reader_screen.dart';
import '../../features/quran/presentation/quran_screen.dart';
import '../../features/recitations/application/recitations_controller.dart';
import '../../features/recitations/data/recitation_repository.dart';
import '../../features/recitations/data/recitation_service.dart';
import '../../features/recitations/presentation/recitations_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/company/presentation/screens/company_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/occasions/presentation/occasions_screen.dart';
import '../../features/prayer_times/presentation/prayer_clock_screen.dart';
import '../../features/khatmah/application/khatmah_controller.dart';
import '../../features/khatmah/data/khatmah_repository.dart';
import '../../features/khatmah/presentation/khatmah_screen.dart';
import '../../features/card_designer/presentation/card_designer_screen.dart';
import '../../features/ibadah_tracker/application/ibadah_controller.dart';
import '../../features/ibadah_tracker/data/ibadah_repository.dart';
import '../../features/ibadah_tracker/presentation/ibadah_tracker_screen.dart';
import '../../features/dua_tawashih/application/dua_tawashih_controller.dart';
import '../../features/dua_tawashih/data/dua_tawashih_repository.dart';
import '../../features/dua_tawashih/presentation/dua_tawashih_screen.dart';
import '../../features/qadaa_tracker/application/qadaa_controller.dart';
import '../../features/qadaa_tracker/data/qadaa_repository.dart';
import '../../features/qadaa_tracker/presentation/qadaa_tracker_screen.dart';
import '../notifications/notification_service.dart';
import '../storage/app_local_store.dart';
import 'app_feature.dart';

List<AppFeature> buildFeatureRegistry({
  required AppLocalStore store,
  required NotificationService notifications,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) {
  final prayer = PrayerController(PrayerRepository(store), notifications);
  final quran = QuranController(QuranRepository(store));
  final hadith = HadithController(HadithRepository(store));
  final adhkar = AdhkarController(AdhkarRepository(store));
  final qibla = QiblaController(QiblaRepository(store));
  final recitationService = RecitationService();
  final recitations = RecitationsController(
    RecitationRepository(store),
    recitationService,
  );
  final duaTawashih = DuaTawashihController(
    repository: DuaTawashihRepository(store),
    recitationService: recitationService,
  );
  final khatmah = KhatmahController(KhatmahRepository(store));
  final ibadah = IbadahController(IbadahRepository(store));
  final qadaa = QadaaController(QadaaRepository(store));

  return [
    AppFeature(
      name: 'home',
      navItem: const AppNavItem(
        route: '/',
        label: 'الرئيسية',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(
            prayer: prayer,
            quran: quran,
            hadith: hadith,
            recitations: recitations,
          ),
        ),
        GoRoute(
          path: '/qibla',
          builder: (context, state) => QiblaScreen(controller: qibla),
        ),
        GoRoute(
          path: '/adhkar',
          builder: (context, state) => AdhkarScreen(controller: adhkar),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/occasions',
          builder: (context, state) => const OccasionsScreen(),
        ),
        GoRoute(
          path: '/prayer-clock',
          builder: (context, state) => PrayerClockScreen(controller: prayer),
        ),
        GoRoute(
          path: '/khatmah',
          builder: (context, state) => KhatmahScreen(controller: khatmah),
        ),
        GoRoute(
          path: '/card-designer',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CardDesignerScreen(
              initialText: extra?['text'] as String?,
              initialReference: extra?['reference'] as String?,
              isQuran: extra?['isQuran'] as bool? ?? true,
            );
          },
        ),
        GoRoute(
          path: '/ibadah-tracker',
          builder: (context, state) => IbadahTrackerScreen(controller: ibadah),
        ),
        GoRoute(
          path: '/dua-tawashih',
          builder: (context, state) {
            final tabParam = state.uri.queryParameters['tab'];
            final int tab;
            if (tabParam == 'ruqyah') {
              tab = 1;
            } else if (tabParam == 'tawashih') {
              tab = 2;
            } else {
              tab = 0;
            }
            return DuaTawashihScreen(
              controller: duaTawashih,
              initialTab: tab,
            );
          },
        ),
        GoRoute(
          path: '/duas',
          builder: (context, state) => DuaTawashihScreen(
            controller: duaTawashih,
            initialTab: 0,
          ),
        ),
        GoRoute(
          path: '/ruqyah',
          builder: (context, state) => DuaTawashihScreen(
            controller: duaTawashih,
            initialTab: 1,
          ),
        ),
        GoRoute(
          path: '/tawashih',
          builder: (context, state) => DuaTawashihScreen(
            controller: duaTawashih,
            initialTab: 2,
          ),
        ),
        GoRoute(
          path: '/qadaa-tracker',
          builder: (context, state) => QadaaTrackerScreen(controller: qadaa),
        ),
        GoRoute(
          path: '/qadaa',
          builder: (context, state) => QadaaTrackerScreen(controller: qadaa),
        ),
      ],
    ),
    AppFeature(
      name: 'prayer_times',
      navItem: const AppNavItem(
        route: '/prayers',
        label: 'الصلاة',
        icon: Icons.access_time_outlined,
        activeIcon: Icons.access_time,
      ),
      routes: [
        GoRoute(
          path: '/prayers',
          builder: (context, state) => PrayerTimesScreen(controller: prayer),
        ),
      ],
    ),
    AppFeature(
      name: 'quran',
      navItem: const AppNavItem(
        route: '/quran',
        label: 'المصحف',
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
      ),
      routes: [
        GoRoute(
          path: '/quran',
          builder: (context, state) => QuranScreen(controller: quran),
        ),
        GoRoute(
          path: '/quran/bookmarks',
          builder: (context, state) => QuranBookmarkScreen(controller: quran),
        ),
        GoRoute(
          path: '/quran/surah/:id',
          builder: (context, state) => QuranReaderScreen(
            controller: quran,
            recitationsController: recitations,
            surahId: int.tryParse(state.pathParameters['id'] ?? '') ?? 1,
            initialAyahNumber: int.tryParse(
              state.uri.queryParameters['ayah'] ?? '',
            ),
          ),
        ),
      ],
    ),
    AppFeature(
      name: 'hadith',
      navItem: const AppNavItem(
        route: '/hadith',
        label: 'الأحاديث',
        icon: Icons.article_outlined,
        activeIcon: Icons.article,
      ),
      routes: [
        GoRoute(
          path: '/hadith',
          builder: (context, state) => HadithScreen(controller: hadith),
        ),
      ],
    ),
    AppFeature(
      name: 'recitations',
      navItem: const AppNavItem(
        route: '/recitations',
        label: 'التلاوات',
        icon: Icons.headphones_outlined,
        activeIcon: Icons.headphones,
      ),
      routes: [
        GoRoute(
          path: '/recitations',
          builder: (context, state) =>
              RecitationsScreen(controller: recitations),
        ),
      ],
    ),
    AppFeature(
      name: 'settings',
      navItem: const AppNavItem(
        route: '/settings',
        label: 'الإعدادات',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
      ),
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsScreen(
            prayer: prayer,
            store: store,
            onThemeModeChanged: onThemeModeChanged,
          ),
        ),
        GoRoute(
          path: '/company',
          builder: (context, state) => const CompanyScreen(),
        ),
        GoRoute(
          path: '/contact-us',
          builder: (context, state) => const CompanyScreen(),
        ),
      ],
    ),
  ];
}

