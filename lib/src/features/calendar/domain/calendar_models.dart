enum CalendarViewType { hijri, gregorian }

class IslamicCalendarEvent {
  final String title;
  final String description;
  final int hijriMonth;
  final int hijriDay;
  final bool isHoliday;

  const IslamicCalendarEvent({
    required this.title,
    required this.description,
    required this.hijriMonth,
    required this.hijriDay,
    this.isHoliday = false,
  });
}

class CalendarUtils {
  static const List<IslamicCalendarEvent> islamicEvents = [
    IslamicCalendarEvent(
      title: 'رأس السنة الهجرية',
      description: 'بداية العام الهجري الجديد وهجرة النبي ﷺ',
      hijriMonth: 1,
      hijriDay: 1,
      isHoliday: true,
    ),
    IslamicCalendarEvent(
      title: 'يوم تاسوعاء',
      description: 'صيام تاسوعاء سنة نبوية مؤكدة',
      hijriMonth: 1,
      hijriDay: 9,
    ),
    IslamicCalendarEvent(
      title: 'يوم عاشوراء',
      description: 'صيام يوم عاشوراء يكفر ذنوب سنة ماضية',
      hijriMonth: 1,
      hijriDay: 10,
      isHoliday: true,
    ),
    IslamicCalendarEvent(
      title: 'المولد النبوي الشريف',
      description: 'ذكرى مولد خير البرية محمد ﷺ',
      hijriMonth: 3,
      hijriDay: 12,
      isHoliday: true,
    ),
    IslamicCalendarEvent(
      title: 'ليلة الإسراء والمعراج',
      description: 'ذكرى معجزة الإسراء من المسجد الحرام للمسجد الأقصى والمعراج',
      hijriMonth: 7,
      hijriDay: 27,
    ),
    IslamicCalendarEvent(
      title: 'ليلة النصف من شعبان',
      description: 'ليلة مباركة تُرفع فيها الأعمال إلى الله',
      hijriMonth: 8,
      hijriDay: 15,
    ),
    IslamicCalendarEvent(
      title: 'غرة شهر رمضان المبارك',
      description: 'بداية شهر الصيام والقرآن والرحمات',
      hijriMonth: 9,
      hijriDay: 1,
    ),
    IslamicCalendarEvent(
      title: 'ليلة القدر (المتوقعة في الوتر)',
      description: 'ليلة القدر خير من ألف شهر',
      hijriMonth: 9,
      hijriDay: 27,
    ),
    IslamicCalendarEvent(
      title: 'عيد الفطر المبارك',
      description: 'فرحة إتمام صيام شهر رمضان المبارك',
      hijriMonth: 10,
      hijriDay: 1,
      isHoliday: true,
    ),
    IslamicCalendarEvent(
      title: 'يوم التروية',
      description: 'اليوم الثامن من ذي الحجة وبداية مناسك الحج',
      hijriMonth: 12,
      hijriDay: 8,
    ),
    IslamicCalendarEvent(
      title: 'يوم عرفة',
      description: 'أفضل أيام العام، وصيامه يكفر سنتين',
      hijriMonth: 12,
      hijriDay: 9,
      isHoliday: true,
    ),
    IslamicCalendarEvent(
      title: 'عيد الأضحى المبارك',
      description: 'يوم النحر وذبح الأضاحي وفرحة المسلمين الكبرى',
      hijriMonth: 12,
      hijriDay: 10,
      isHoliday: true,
    ),
  ];

  static final List<String> hijriMonthNames = [
    'المحرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static final List<String> gregorianMonthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static final List<String> weekDayNames = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  /// Find Islamic event for a specific Hijri month and day
  static IslamicCalendarEvent? getEventForHijri(int month, int day) {
    try {
      return islamicEvents.firstWhere(
        (e) => e.hijriMonth == month && e.hijriDay == day,
      );
    } catch (_) {
      return null;
    }
  }

  /// Checks if a day is one of the White Days (الأيام البيض 13, 14, 15)
  static bool isWhiteDay(int hijriDay) {
    return hijriDay >= 13 && hijriDay <= 15;
  }

  /// Checks if a DateTime is Monday or Thursday (Sunnah fasting)
  static bool isSunnahFastingDay(DateTime date) {
    return date.weekday == DateTime.monday || date.weekday == DateTime.thursday;
  }
}
