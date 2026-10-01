/// أداة متقدمة لتطبيع ومعالجة النصوص العربية والقرآنية برسم المصحف العثماني
class ArabicTextUtils {
  /// تعبير نمطي للرموز وعلامات الوقف والسجدات والأحزاب والرموز القرآنية غير الحرفية
  static final RegExp _quranicMarksRegex = RegExp(
    r'[\u06D6-\u06DC\u06DF-\u06E4\u06E7-\u06EA\u06ED\u06DD\u06DE\u06E9\uFEFF\u200B-\u200D]',
  );

  /// تعبير نمطي لجميع حركات التشكيل والتنوين والشدة والسكون والمد والتطويل
  static final RegExp _tashkeelRegex = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0640]',
  );

  /// تحويل الخصائص الصوتية للرسم العثماني إلى مقابلها الإملائي القياسي قبل نزع التشكيل
  static String _standardizeQuranicText(String text) {
    if (text.isEmpty) return '';
    var s = text;

    // إزالة مسافات المحاذاة والرموز الصفرية
    s = s.replaceAll(RegExp(r'[\uFEFF\u200B-\u200D]'), '');

    // استبدال الواو والياء الصغيرتين
    s = s.replaceAll('\u06E5', 'و');
    s = s.replaceAll('\u06E6', 'ي');

    // استبدال رسم الواو التي تعلوها ألف خنجرية بألف (الصلوة -> الصلاة، الزكوة -> الزكاة، الحيوة -> الحياة)
    s = s.replaceAll(RegExp(r'و[\u064B-\u065F]*\u0670|وٰ'), 'ا');

    // الكلمات الخاصة التي حذفت منها الألف رسماً في المصحف والإملاء القياسي الحديث
    // لتوحيدها سواء بحث المستخدم بالألف أو بدونها (الرحمن / الرحمان، هذا / هاذا، ذلك / ذالك، إلخ)
    s = s.replaceAll(RegExp(r'ر[\u064B-\u065F]*ح[\u064B-\u065F\u06E1]*م[\u064B-\u065F]*[ٰا\u0670]ن'), 'رحمن');
    s = s.replaceAll(RegExp(r'ه[\u064B-\u065F]*[ٰا\u0670]ذ[\u064B-\u065F]*ا'), 'هذا');
    s = s.replaceAll(RegExp(r'ه[\u064B-\u065F]*[ٰا\u0670]ذ[\u064B-\u065F]*[هة]'), 'هذه');
    s = s.replaceAll(RegExp(r'ه[\u064B-\u065F]*[ٰا\u0670][\u064B-\u065F]*و[\u064B-\u065F]*ل[\u064B-\u065F]*[اآء]'), 'هولاء');
    s = s.replaceAll(RegExp(r'ذ[\u064B-\u065F]*[ٰا\u0670]ل[\u064B-\u065F]*ك'), 'ذلك');
    s = s.replaceAll(RegExp(r'ل[\u064B-\u065F]*[ٰا\u0670]ك[\u064B-\u065F]*ن'), 'لكن');
    s = s.replaceAll(RegExp(r'[إا][\u064B-\u065F]*ل[\u064B-\u065F]*[ٰا\u0670]ه'), 'اله');

    // تحويل باقي الألفات الخنجرية في سائر الكلمات إلى ألف مدية عادية
    // مثل: صِرَٰط -> صراط، مَٰلِك -> مالك، كِتَٰب -> كتاب، سُبۡحَٰن -> سبحان، ٱلْعَٰلَمِين -> العالمين
    s = s.replaceAll('\u0670', 'ا');

    return s;
  }

  /// إزالة علامات التشكيل والتطويل والرموز القرآنية من النص
  static String removeTashkeel(String text) {
    if (text.isEmpty) return '';
    var s = _standardizeQuranicText(text);
    s = s.replaceAll(_quranicMarksRegex, '');
    s = s.replaceAll(_tashkeelRegex, '');
    return s;
  }

  /// تطبيع الحروف العربية وتوحيد الهمزات والتاء المربوطة والألف المقصورة
  static String normalize(String text) {
    if (text.isEmpty) return '';
    var normalized = removeTashkeel(text);

    // توحيد جميع صور الألف والهمزات إلى ألف مجردة
    normalized = normalized.replaceAll(RegExp(r'[أإآٱٲٳٵ]'), 'ا');

    // توحيد الهمزة على الواو والياء والسطر
    normalized = normalized.replaceAll('ؤ', 'و');
    normalized = normalized.replaceAll('ئ', 'ي');
    normalized = normalized.replaceAll('ء', '');

    // توحيد التاء المربوطة والهاء
    normalized = normalized.replaceAll('ة', 'ه');

    // توحيد الألف المقصورة والياء
    normalized = normalized.replaceAll('ى', 'ي');

    // توحيد الكلمات الشائعة التي تكتب برسمين
    normalized = normalized.replaceAll('رحمان', 'رحمن');
    normalized = normalized.replaceAll('هاذا', 'هذا');
    normalized = normalized.replaceAll('هاذه', 'هذه');
    normalized = normalized.replaceAll('هاولاء', 'هولاء');
    normalized = normalized.replaceAll('ذالك', 'ذلك');
    normalized = normalized.replaceAll('لاكن', 'لكن');
    normalized = normalized.replaceAll('الاه', 'اله');
    normalized = normalized.replaceAll('سموات', 'سماوات');

    // إزالة الفراغات المكررة وتحويل للحروف الصغيرة إن وجدت حروف لاتينية
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    return normalized;
  }

  /// فحص الاحتواء عندما يكون المصدر والبحث قد تم تطبيعهما مسبقاً (لأداء فائق السرعة في البحث)
  static bool containsNormalized(String cleanSource, String cleanQuery) {
    if (cleanQuery.isEmpty) return true;
    if (cleanSource.contains(cleanQuery)) return true;

    // دعم إضافي لإزالة كلمة "سورة " في حال البحث عن أسماء السور
    final sourceWithoutSurah = cleanSource.replaceFirst('سوره ', '');
    final queryWithoutSurah = cleanQuery.replaceFirst('سوره ', '');
    if (sourceWithoutSurah.contains(queryWithoutSurah)) return true;

    // مطابقة مرنة للفراغات (لتغطية رسم الكلمات الموصولة في المصحف مثل يَٰأَيُّهَا، يَٰبَنِي، مَالِ هَٰذَا)
    final noSpaceSource = cleanSource.replaceAll(' ', '');
    final noSpaceQuery = cleanQuery.replaceAll(' ', '');
    if (noSpaceQuery.length >= 3 && noSpaceSource.contains(noSpaceQuery)) {
      return true;
    }

    return false;
  }

  /// فحص احتواء نص المصدر على عبارة البحث بعد تطبيع الاثنين
  static bool contains(String source, String query) {
    final cleanQuery = normalize(query);
    if (cleanQuery.isEmpty) return true;

    final cleanSource = normalize(source);
    return containsNormalized(cleanSource, cleanQuery);
  }

  /// تحويل الأرقام الإنجليزية (0-9) إلى الأرقام العربية المشرقية (٠-٩)
  static String toArabicDigits(dynamic input) {
    if (input == null) return '';
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    var str = input.toString();
    for (int i = 0; i < english.length; i++) {
      str = str.replaceAll(english[i], arabic[i]);
    }
    return str;
  }
}

