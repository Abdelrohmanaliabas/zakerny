import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/app_local_store.dart';
import '../domain/tafsir_models.dart';

class TafsirService {
  TafsirService(this._store, {Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  final AppLocalStore _store;
  final Dio _dio;

  static const _prefEditionKey = 'quran_preferred_tafsir_edition';

  String getPreferredEdition() =>
      _store.getString(_prefEditionKey) ?? 'ar.muyassar';

  Future<void> setPreferredEdition(String id) =>
      _store.setString(_prefEditionKey, id);

  Future<AyahTafsir> getAyahTafsir({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
    String? editionId,
  }) async {
    final activeEditionId = editionId ?? getPreferredEdition();
    final edition = supportedTafsirs.firstWhere(
      (e) => e.id == activeEditionId,
      orElse: () => supportedTafsirs.first,
    );

    final cacheKey = 'quran_tafsir_${activeEditionId}_${surahId}_$ayahNumber';

    // 1. فحص الذاكرة المحلية المخزنة مسبقاً
    final cached = _store.getJson(cacheKey);
    if (cached != null) {
      try {
        return AyahTafsir.fromJson(cached);
      } catch (_) {}
    }

    // 2. محاولة جلب التفسير من المصادر البرمجية المعتمدة
    try {
      final fetchedText = await _fetchFromApi(
        surahId: surahId,
        ayahNumber: ayahNumber,
        editionId: activeEditionId,
      );

      if (fetchedText != null && fetchedText.trim().isNotEmpty) {
        final result = AyahTafsir(
          surahId: surahId,
          surahName: surahName,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
          editionId: edition.id,
          editionName: edition.name,
          text: fetchedText.trim(),
          isCached: true,
        );
        // حفظ في التخزين المحلي للاستخدام بدون إنترنت لاحقاً
        await _store.setJson(cacheKey, result.toJson());
        return result;
      }
    } catch (e) {
      debugPrint('Error fetching online tafsir ($activeEditionId): $e');
    }

    // 3. الاحتياط المحلي الفوري للآيات والسور الشائعة عند انقطاع الإنترنت
    final offlineText = _getOfflineFallback(
      surahId: surahId,
      ayahNumber: ayahNumber,
      editionId: activeEditionId,
    );

    if (offlineText != null) {
      return AyahTafsir(
        surahId: surahId,
        surahName: surahName,
        ayahNumber: ayahNumber,
        ayahText: ayahText,
        editionId: edition.id,
        editionName: edition.name,
        text: offlineText,
        isCached: true,
      );
    }

    throw Exception(
      'تعذر تحميل تفسير الآية الكريمة، يرجى التحقق من الاتصال بالإنترنت والمحاولة مجدداً.',
    );
  }

  Future<String?> _fetchFromApi({
    required int surahId,
    required int ayahNumber,
    required String editionId,
  }) async {
    // المصدر الأول: مجمع الملك فهد والتفاسير العربية الميسرة (AlQuran Cloud API)
    if (editionId == 'ar.muyassar' || editionId == 'ar.jalalayn') {
      try {
        final url =
            'https://api.alquran.cloud/v1/ayah/$surahId:$ayahNumber/editions/$editionId';
        final response = await _dio.get(url);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'];
          if (data is List && data.isNotEmpty) {
            final first = data.first;
            if (first is Map && first['text'] != null) {
              return first['text'].toString();
            }
          } else if (data is Map && data['text'] != null) {
            return data['text'].toString();
          }
        }
      } catch (_) {}
    }

    // المصدر الثاني: تفاسير السعدي وابن كثير عبر القرآن الكريم التوثيقي
    if (editionId == 'ar.saadi' || editionId == 'ar.ibnkathir') {
      try {
        final tafsirResourceId = editionId == 'ar.saadi' ? 168 : 169;
        final url =
            'https://api.quran.com/api/v4/quran/tafsirs/$tafsirResourceId?verse_key=$surahId:$ayahNumber';
        final response = await _dio.get(url);
        if (response.statusCode == 200 && response.data != null) {
          final tafsirs = response.data['tafsirs'] as List?;
          if (tafsirs != null && tafsirs.isNotEmpty) {
            final rawHtml = tafsirs.first['text']?.toString() ?? '';
            final clean = rawHtml
                .replaceAll(RegExp(r'<[^>]*>'), ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
            if (clean.isNotEmpty) return clean;
          }
        }
      } catch (_) {}

      // احتياط تلقائي إلى التفسير الميسر المعتمد في حال تعذر السيرفر الإضافي
      try {
        final fallbackUrl =
            'https://api.alquran.cloud/v1/ayah/$surahId:$ayahNumber/editions/ar.muyassar';
        final fallbackResponse = await _dio.get(fallbackUrl);
        if (fallbackResponse.statusCode == 200 && fallbackResponse.data != null) {
          final data = fallbackResponse.data['data'];
          if (data is List && data.isNotEmpty) {
            final first = data.first;
            if (first is Map && first['text'] != null) {
              return first['text'].toString();
            }
          } else if (data is Map && data['text'] != null) {
            return data['text'].toString();
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// تفاسير مدمجة أوفلاين لأشهر السور والآيات للعمل حتى بدون اتصال
  String? _getOfflineFallback({
    required int surahId,
    required int ayahNumber,
    required String editionId,
  }) {
    // سورة الفاتحة (1:1 - 1:7)
    if (surahId == 1) {
      const fatihaMuyassar = {
        1: 'أبتدئ قراءة القرآن باسم الله مستعيناً به، (الله) علم على الرب تبارك وتعالى المعبود بحق دون سواه، وهو أخص أسماء الله تعالى. (الرحمن) ذي الرحمة العامة لجميع خلقه، (الرحيم) بالمؤمنين.',
        2: 'الثناء الكامل لله بصفات كماله، وبنعمه الظاهرة والباطنة الدينية والدنيوية، وهو المربي لجميع خلقه بنعمه، وخالق العالمين ومالكهم ومدبر أمورهم.',
        3: 'الذي اتصف بالرحمة الواسعة العظيمة التي وسعت كل شيء، الرحيم بعباده المؤمنين.',
        4: 'وهو سبحانه وحده مالك يوم القيامة والجزاء والحساب، وتخصيص الملك بيوم الدين؛ لأنه لا يدعي أحد يومئذ مُلكاً.',
        5: 'نخصك وحدك بالعبادة، ونستعين بك وحدك في جميع أمورنا، فالأمر كله بيدك.',
        6: 'دُلَّنا وأرشدنا، ووفقنا إلى الصراط المستقيم، وثبِّتنا عليه، وهو الإسلام دين الحق والهدى.',
        7: 'صراط الذين أنعمت عليهم من النبيين والصدِّيقين والشهداء والصالحين، غير صراط المغضوب عليهم وهم الذين علموا الحق ولم يعملوا به، ولا الضالين وهم الذين عبدوا الله على جهل وضلال.',
      };
      return fatihaMuyassar[ayahNumber];
    }

    // آية الكرسي (2:255)
    if (surahId == 2 && ayahNumber == 255) {
      return 'الله الذي لا يستحق الألوهية والعبودية إلا هو، الحي القيوم القائم على تدبير شؤون خلقه، لا تأخذه سنة (نعاس) ولا نوم، له ما في السماوات وما في الأرض ملكاً وخلقاً وتدبيراً، من ذا الذي يشفع عنده إلا بإذنه، يعلم ما بين أيديهم وما خلفهم، وسع كرسيه السماوات والأرض ولا يؤوده حفظهما وهو العلي العظيم.';
    }

    // سورة الإخلاص (112)
    if (surahId == 112) {
      const ikhlas = {
        1: 'قل يا محمد لهؤلاء المشركين: هو الله المنفرد بالألوهية والربوبية والأسماء والصفات، لا شريك له.',
        2: 'الله الصمد: الذي تصمد وتلجأ إليه جميع الخلائق في حوائجها ورغائبها لكماله وغناه.',
        3: 'لم يلد أحداً، ولم يولد من أحد؛ لتنزهه عن المشابهة والولد والوالد.',
        4: 'ولم يكن له كفؤاً ولا مكافئاً ولا مثيلاً أحد من خلقه سبحانه وتعالى.',
      };
      return ikhlas[ayahNumber];
    }

    // سورة الفلق (113)
    if (surahId == 113) {
      const falaq = {
        1: 'قل أعوذ وأعتصم برب الفلق، وهو الصبح وفالقه.',
        2: 'من شر جميع مخلوقات الله وشرورها وأذاها.',
        3: 'ومن شر ليل مظلم إذا دخل ظلامه وتغلغل في الوجود.',
        4: 'ومن شر السواحر اللاتي ينفثن في العقد حين يسحرن الناس.',
        5: 'ومن شر حاسد مبغض للنعمة إذا حسد الناس وتمنى زوالها عنهم.',
      };
      return falaq[ayahNumber];
    }

    // سورة الناس (114)
    if (surahId == 114) {
      const nas = {
        1: 'قل أعوذ وألتجئ برب الناس وخالقهم ومدبر أمورهم.',
        2: 'ملك الناس المتصرف فيهم بتمام القدرة والسلطان.',
        3: 'إله الناس ومعبودهم الحق الذي لا معبود سواه.',
        4: 'من أذى الشيطان الموسوس الذي يخنس ويتوارى إذا ذُكر الله تعالى.',
        5: 'الذي يبث الوساوس والشرور في صدور وقلوب الناس.',
        6: 'من شياطين الجن وشياطين الإنس.',
      };
      return nas[ayahNumber];
    }

    return null;
  }
}
