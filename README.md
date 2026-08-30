# ذكرني Zekrni

تطبيق Flutter عربي RTL يعمل Offline-first لمواقيت الصلاة، المصحف، الأحاديث، والتلاوات المحملة.

## التشغيل

```bash
flutter pub get
flutter run
```

## البيانات المحلية

- المصحف: استبدل `assets/quran/quran.json` بملف كامل بنفس البنية: قائمة `surahs` وبداخل كل سورة `id`, `name`, `ayahs`.
- الأحاديث: استبدل `assets/hadith/hadith.json` بقائمة `hadiths` وبداخل كل حديث `id`, `collection`, `title`, `text`.
- التلاوات: عدل `assets/recitations/reciters.json`. لإضافة شيخ جديد أضف عنصرًا جديدًا يحتوي `id`, `name`, وقائمة `surahs` مع رابط MP3 اختياري في `url`.

## المعمارية

كل Feature مستقلة داخل:

```text
lib/src/features/{feature_name}/
  data/
  domain/
  application/
  presentation/
```

القراءة الأساسية لا تعتمد على API. التخزين المحلي يمر عبر `AppLocalStore`، والتنبيهات داخل `lib/src/core/notifications/`.

## الأذونات

Android:
- `ACCESS_FINE_LOCATION` و`ACCESS_COARSE_LOCATION` لاستخدام الموقع اختياريًا.
- `POST_NOTIFICATIONS` للتنبيهات.
- `SCHEDULE_EXACT_ALARM` عند الحاجة لجدولة أدق حسب سياسة الجهاز.

iOS:
- `NSLocationWhenInUseUsageDescription` لحساب مواقيت الصلاة من الموقع الحالي.
- يجب طلب إذن التنبيهات من النظام عند تفعيل الجدولة.

## الفحص

```bash
flutter analyze
flutter test
```
