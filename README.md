# ذكرني Zekrni

تطبيق Flutter عربي RTL يعمل Offline-first لمواقيت الصلاة، المصحف، الأحاديث، والتلاوات المحملة.

## التشغيل

```bash
flutter pub get
flutter run
```

## الواجهة

- يدعم Light / Dark / System theme من شاشة الإعدادات.
- التصميم مستوحى من مرجع الواجهة: خلفية هندسية هادئة، أخضر mint/زمردي، وذهبي خفيف لعناصر التحديد.
- الشاشة الرئيسية تعرض الصلاة القادمة، اختصارات عملية، متابعة القراءة، آخر حديث، والتلاوات المحملة.

## البيانات المحلية

- المصحف: `assets/quran/quran.json` يحتوي الآن على المصحف كاملًا: 114 سورة و6236 آية.
- الأحاديث: استبدل `assets/hadith/hadith.json` بقائمة `hadiths` وبداخل كل حديث `id`, `collection`, `title`, `text`.
- التلاوات: عدل `assets/recitations/reciters.json`. لإضافة شيخ جديد أضف عنصرًا يحتوي `id`, `name`, وقائمة `surahs` مع رابط MP3 اختياري في `url`.

## مصادر API اختيارية

القراءة الأساسية لا تعتمد على API، لكن يوجد `ContentApiService` لاستخدامات التحديث الاختيارية:

- Quran text/audio: `https://alquran.cloud/api`
- Quran audio CDN: `https://alquran.cloud/cdn`
- MP3Quran reciters/download links: `https://www.mp3quran.net/ar/api`
- Hadith public JSON/CDN: `https://github.com/fawazahmed0/hadith-api`

ملاحظة: Sunnah.com وHadithAPI يعرضان API للأحاديث لكن يحتاجان API key، لذلك الأنسب للتطبيق Offline-first هو شحن ملف أحاديث محلي أو تنزيل dataset مرة واحدة ثم تخزينه.

## المعمارية

كل Feature مستقلة داخل:

```text
lib/src/features/{feature_name}/
  data/
  domain/
  application/
  presentation/
```

التخزين المحلي يمر عبر `AppLocalStore`، والتنبيهات داخل `lib/src/core/notifications/`. تجميع المسارات في `feature_registry.dart` حتى يمكن إزالة Feature بتعديل التسجيل الخاص بها.

## الأذونات

Android:
- `ACCESS_FINE_LOCATION` و`ACCESS_COARSE_LOCATION` لاستخدام الموقع اختياريًا.
- `POST_NOTIFICATIONS` للتنبيهات.
- `SCHEDULE_EXACT_ALARM` عند الحاجة لجدولة أدق حسب سياسة الجهاز.
- تم تفعيل Core library desugaring المطلوب للتنبيهات.
- صوت الأذان موجود في `android/app/src/main/res/raw/adhan.mp3` ويستخدمه channel باسم `prayer_times_adhan`.
- إذا كانت نسخة قديمة من التطبيق مثبتة قبل إضافة صوت الأذان، احذف التطبيق وثبته مرة أخرى حتى يعيد Android إنشاء قناة التنبيهات بالصوت الجديد.

iOS:
- `NSLocationWhenInUseUsageDescription` لحساب مواقيت الصلاة من الموقع الحالي.
- يجب طلب إذن التنبيهات من النظام عند تفعيل الجدولة.
- صوت iOS المخصص موجود في `ios/Runner/adhan.caf` ومضاف إلى Resources.

## صوت الأذان

مصدر الصوت: Internet Archive - Adhan Notifications، Public Domain Mark 1.0.

## الفحص

```bash
flutter analyze
flutter test
flutter build apk --debug
```
