/// أداة لتطبيع ومعالجة النصوص العربية والبحث بدون تشكيل
class ArabicTextUtils {
  /// تعبير نمطي لجميع علامات التشكيل والتنوين والشدة والسكون والمدود القرآنية
  static final RegExp _tashkeelRegex = RegExp(
    r'[\u0617-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]',
  );

  /// إزالة علامات التشكيل والتطويل من النص العربي
  static String removeTashkeel(String text) {
    return text.replaceAll(_tashkeelRegex, '');
  }

  /// تطبيع الحروف العربية وتوحيد الهمزات والتاء المربوطة والألف المقصورة
  static String normalize(String text) {
    if (text.isEmpty) return '';
    var normalized = removeTashkeel(text);

    // توحيد جميع صور الألف والهمزات إلى ألف مجردة
    normalized = normalized.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // توحيد الهمزة على الواو والياء والسطر
    normalized = normalized.replaceAll('ؤ', 'و');
    normalized = normalized.replaceAll('ئ', 'ي');
    normalized = normalized.replaceAll('ء', '');

    // توحيد التاء المربوطة والهاء
    normalized = normalized.replaceAll('ة', 'ه');

    // توحيد الألف المقصورة والياء
    normalized = normalized.replaceAll('ى', 'ي');

    // إزالة الفراغات المكررة وتحويل للحروف الصغيرة إن وجدت حروف لاتينية
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    return normalized;
  }

  /// فحص احتواء نص المصدر على عبارة البحث بعد تطبيع الاثنين
  static bool contains(String source, String query) {
    final cleanQuery = normalize(query);
    if (cleanQuery.isEmpty) return true;

    final cleanSource = normalize(source);
    if (cleanSource.contains(cleanQuery)) return true;

    // دعم إضافي لإزالة كلمة "سورة " في حال البحث عن أسماء السور
    final sourceWithoutSurah = cleanSource.replaceFirst('سوره ', '');
    final queryWithoutSurah = cleanQuery.replaceFirst('سوره ', '');
    return sourceWithoutSurah.contains(queryWithoutSurah);
  }
}
