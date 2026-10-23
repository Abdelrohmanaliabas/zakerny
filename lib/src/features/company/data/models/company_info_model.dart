class CompanyInfoModel {
  const CompanyInfoModel({
    required this.companyName,
    this.companyNameEn = 'COMMIT_',
    this.brandDisplay = 'COMMIT_',
    required this.taglineAr,
    required this.taglineEn,
    required this.aboutAr,
    required this.aboutEn,
    required this.portfolioUrl,
    required this.socialLinks,
    required this.support,
    required this.developers,
    required this.projects,
    this.services = const [],
  });

  final String companyName;
  final String companyNameEn;
  final String brandDisplay;
  final String taglineAr;
  final String taglineEn;
  final String aboutAr;
  final String aboutEn;
  final String portfolioUrl;
  final SocialLinksModel socialLinks;
  final SupportContactModel support;
  final List<DeveloperModel> developers;
  final List<ProjectShowcaseModel> projects;
  final List<CompanyServiceModel> services;

  String localizedCompanyName(bool isArabic) => isArabic
      ? (companyName.isNotEmpty ? companyName : brandDisplay)
      : (companyNameEn.isNotEmpty ? companyNameEn : companyName);

  String localizedTagline(bool isArabic) => isArabic ? taglineAr : taglineEn;
  String localizedAbout(bool isArabic) => isArabic ? aboutAr : aboutEn;

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      companyName: (json['company_name'] as String?)?.trim().isNotEmpty == true
          ? (json['company_name'] as String).trim()
          : 'كوميت',
      companyNameEn:
          (json['company_name_en'] as String?)?.trim().isNotEmpty == true
              ? (json['company_name_en'] as String).trim()
              : 'COMMIT_',
      brandDisplay:
          (json['brand_display'] as String?)?.trim().isNotEmpty == true
              ? (json['brand_display'] as String).trim()
              : 'COMMIT_',
      taglineAr: (json['tagline_ar'] as String?)?.trim().isNotEmpty == true
          ? (json['tagline_ar'] as String).trim()
          : 'نلتزم. نبني. نُطلق.',
      taglineEn: (json['tagline_en'] as String?)?.trim().isNotEmpty == true
          ? (json['tagline_en'] as String).trim()
          : 'We commit. We build. We ship.',
      aboutAr: (json['about_ar'] as String?)?.trim().isNotEmpty == true
          ? (json['about_ar'] as String).trim()
          : 'استوديو هندسي متخصص في تطوير البرمجيات الدقيقة وعالية الأداء. نتشارك مع رواد الأعمال والشركات لبناء وإطلاق تطبيقات ومنصات حيوية لا تقبل المساومة على الجودة.',
      aboutEn: (json['about_en'] as String?)?.trim().isNotEmpty == true
          ? (json['about_en'] as String).trim()
          : 'We are a specialized software studio focused on craft, performance, and reliability. We partner with founders and enterprises to engineer mission-critical applications.',
      portfolioUrl:
          (json['portfolio_url'] as String?)?.trim().isNotEmpty == true
              ? (json['portfolio_url'] as String).trim()
              : 'https://commit.zonesc.cloud/',
      socialLinks: SocialLinksModel.fromJson(
        (json['social_links'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      support: SupportContactModel.fromJson(
        (json['support'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      developers:
          (json['developers'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => DeveloperModel.fromJson(item.cast<String, dynamic>()),
              )
              .toList() ??
          const [],
      projects:
          (json['projects'] as List?)
              ?.whereType<Map>()
              .map(
                (item) =>
                    ProjectShowcaseModel.fromJson(item.cast<String, dynamic>()),
              )
              .toList() ??
          const [],
      services:
          (json['services'] as List?)
              ?.whereType<Map>()
              .map(
                (item) =>
                    CompanyServiceModel.fromJson(item.cast<String, dynamic>()),
              )
              .toList() ??
          const [],
    );
  }

  static CompanyInfoModel fallback() {
    return const CompanyInfoModel(
      companyName: 'كوميت',
      companyNameEn: 'COMMIT_',
      brandDisplay: 'COMMIT_',
      taglineAr: 'نلتزم. نبني. نُطلق.',
      taglineEn: 'We commit. We build. We ship.',
      aboutAr:
          'استوديو هندسي متخصص في تطوير البرمجيات الدقيقة وعالية الأداء. نتشارك مع رواد الأعمال والشركات لبناء وإطلاق تطبيقات ومنصات حيوية لا تقبل المساومة على الجودة، من التخطيط المعماري حتى بيئات الإنتاج المستقرة.',
      aboutEn:
          'A specialized software engineering studio focused on precision, performance, and reliability. We partner with founders and enterprises to design, architect, and ship production-grade digital applications.',
      portfolioUrl: 'https://commit.zonesc.cloud/',
      socialLinks: SocialLinksModel(
        facebook: 'https://www.facebook.com/profile.php?id=61594574024377',
        instagram: 'https://www.instagram.com/commit_tech/',
        tiktok: '',
        linkedin: 'https://www.linkedin.com/in/abdelrahmanabas23',
        github: 'https://github.com/Abdelrohmanaliabas',
        xUrl: 'https://x.com/commit_studio',
        website: 'https://commit.zonesc.cloud/',
      ),
      support: SupportContactModel(
        email: 'abdelrahmanali2310@gmail.com',
        phone: '+201067794270',
        whatsapp: '+201067794270',
      ),
      developers: [
        DeveloperModel(
          name: 'م. عبدالرحمن علي',
          nameEn: 'Eng. Abdelrahman Ali',
          role: 'مؤسس وقائد هندسة البرمجيات',
          roleEn: 'Lead Software Engineer & Studio Founder',
          phone: '+201067794270',
          whatsapp: '+201067794270',
          email: 'abdelrahmanali2310@gmail.com',
          linkedinUrl: 'https://www.linkedin.com/in/abdelrahmanabas23',
          githubUrl: 'https://github.com/Abdelrohmanaliabas',
          portfolioUrl: 'https://commit.zonesc.cloud/',
          bio:
              'مهندس برمجيات متخصص في بناء معمارية الأنظمة الموزعة وتطبيقات الهاتف عالية الاعتمادية ومنصات الويب السحابية المعقدة.',
          bioEn:
              'Lead Software Engineer specialized in distributed systems architecture, reliable mobile applications, and enterprise cloud solutions.',
        ),
      ],
      projects: [
        ProjectShowcaseModel(
          titleAr: 'تطبيق ذكّرني (Zekrni)',
          titleEn: 'Zekrni Islamic Companion',
          slug: 'zekrni',
          descriptionAr:
              'تطبيق إسلامي Offline-first للأذكار، والتسابيح الذكية، والقرآن الكريم، ومواقيت الصلاة، والتلاوات الصوتية المحملة أوفلاين مع محرك اهتزازات haptic وتصميم فاطمي فاخر.',
          descriptionEn:
              'An offline-first Islamic companion app designed for Athkar, smart Tasbeeh counter, prayer times, background alerts, and high-fidelity offline audio.',
          category: 'Offline-First Mobile & Desktop',
          projectUrl: 'https://commit.zonesc.cloud/projects/zekrni',
          badgeText: 'نظام حي ومعتمد',
          technologies: [
            'Flutter',
            'Dart',
            'Offline-First',
            'Audio Engine',
            'Windows & Mobile',
          ],
        ),
        ProjectShowcaseModel(
          titleAr: 'منصة وتطبيق Zone',
          titleEn: 'Zone Multi-Vendor & Logistics',
          slug: 'zone',
          descriptionAr:
              'منصة متعددة الأطراف لإدارة المتاجر والمنتجات والطلبات والتوصيل مع تتبع جغرافي لحظي، لوحات تحكم مركزية، وتنبيهات فورية عبر Firebase.',
          descriptionEn:
              'A multi-vendor ecosystem orchestrating merchants, product catalogs, order pipelines, driver delivery, and real-time alerts.',
          category: 'Multi-Vendor & Logistics Platform',
          projectUrl: 'https://commit.zonesc.cloud/projects/zone',
          badgeText: 'منصة إنتاجية متكاملة',
          technologies: [
            'Flutter',
            'Laravel API',
            'MySQL',
            'Firebase Realtime',
            'Geo-Tracking',
          ],
        ),
        ProjectShowcaseModel(
          titleAr: 'منصة وتطبيق Fitness Way',
          titleEn: 'Fitness Way Gym & Coaching',
          slug: 'fitness-way',
          descriptionAr:
              'منظومة إدارة شاملة للصالات الرياضية، الاشتراكات، تحضير QR الذكي، إدارة المدربين والمتدربين، جداول التمارين والتغذية وتقارير تشغيلية متقدمة.',
          descriptionEn:
              'A full fitness-tech ecosystem connecting gym operations, coaches, and athletes through subscriptions, workout tracking, and QR check-in.',
          category: 'Fitness & Gym Management OS',
          projectUrl: 'https://commit.zonesc.cloud/projects/fitness-way',
          badgeText: 'منصة تشغيلية حية',
          technologies: [
            'Flutter Cross-Platform',
            'Riverpod',
            'Sanctum Auth',
            'QR Attendance',
            'PDF Reports',
          ],
        ),
      ],
      services: [
        CompanyServiceModel(
          titleAr: 'تطبيقات الجوال والديسكتوب',
          titleEn: 'Cross-Platform Mobile & Desktop Apps',
          descriptionAr:
              'هندسة تطبيقات فائقة السلاسة والأداء لأنظمة Android و iOS و Windows باستخدام أحدث مكتبات Flutter وبمعمارية نظيفة وقابلة للتوسع.',
          descriptionEn:
              'Engineering ultra-smooth, responsive applications for Android, iOS, and Windows powered by Flutter and clean architectural patterns.',
          badge: 'Flutter & Dart',
          iconCode: 'devices',
        ),
        CompanyServiceModel(
          titleAr: 'المنصات السحابية والـ APIs',
          titleEn: 'Cloud Platforms & Modular APIs',
          descriptionAr:
              'بناء بوابات وواجهات برمجية RESTful متينة بنظام Laravel، وقواعد بيانات محسنة للتحميل العالي مع توثيق أمني وتكاملات معقدة.',
          descriptionEn:
              'Architecting robust RESTful backends and modular APIs using Laravel and optimized relational databases for high concurrency.',
          badge: 'Laravel & Cloud',
          iconCode: 'cloud',
        ),
        CompanyServiceModel(
          titleAr: 'معمارية العمل بدون إنترنت',
          titleEn: 'Offline-First & Local Persistence',
          descriptionAr:
              'تصميم وتطبيق معمارية Offline-First تضمن عمل التطبيقات بكفاءة تامة بدون اتصال بالإنترنت، مع آليات مزامنة موثوقة عند عودة الاتصال.',
          descriptionEn:
              'Designing resilient offline-first systems ensuring full application functionality without internet, with seamless syncing.',
          badge: 'Offline-First',
          iconCode: 'offline',
        ),
        CompanyServiceModel(
          titleAr: 'الأنظمة اللحظية والتتبع الحي',
          titleEn: 'Realtime Pipelines & Geo-Services',
          descriptionAr:
              'تطوير خطوط معالجة الأحداث الفورية، التنبيهات الذكية عبر Firebase، والتتبع المكاني اللحظي لكباتن التوصيل والخدمات اللوجستية.',
          descriptionEn:
              'Realtime event-driven pipelines, instant alerts via Firebase, and precise geolocation tracking for logistics and delivery fleets.',
          badge: 'Realtime & Maps',
          iconCode: 'gps',
        ),
      ],
    );
  }
}

class SocialLinksModel {
  const SocialLinksModel({
    required this.facebook,
    required this.instagram,
    this.tiktok = '',
    required this.linkedin,
    required this.website,
    this.github = '',
    this.xUrl = '',
  });

  final String facebook;
  final String instagram;
  final String tiktok;
  final String linkedin;
  final String website;
  final String github;
  final String xUrl;

  bool get hasFacebook => facebook.trim().isNotEmpty;
  bool get hasInstagram => instagram.trim().isNotEmpty;
  bool get hasTiktok => tiktok.trim().isNotEmpty;
  bool get hasLinkedin => linkedin.trim().isNotEmpty;
  bool get hasWebsite => website.trim().isNotEmpty;
  bool get hasGithub => github.trim().isNotEmpty;
  bool get hasX => xUrl.trim().isNotEmpty;

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) {
    return SocialLinksModel(
      facebook: (json['facebook'] as String?)?.trim() ?? '',
      instagram: (json['instagram'] as String?)?.trim() ?? '',
      tiktok: (json['tiktok'] as String?)?.trim() ?? '',
      linkedin: (json['linkedin'] as String?)?.trim() ?? '',
      website: (json['website'] as String?)?.trim() ?? '',
      github: (json['github'] as String?)?.trim() ?? '',
      xUrl: (json['x'] as String?)?.trim() ?? (json['x_url'] as String?)?.trim() ?? '',
    );
  }
}

class SupportContactModel {
  const SupportContactModel({
    required this.email,
    required this.phone,
    required this.whatsapp,
  });

  final String email;
  final String phone;
  final String whatsapp;

  bool get hasEmail => email.trim().isNotEmpty;
  bool get hasPhone => phone.trim().isNotEmpty;
  bool get hasWhatsapp => whatsapp.trim().isNotEmpty;

  factory SupportContactModel.fromJson(Map<String, dynamic> json) {
    return SupportContactModel(
      email: (json['email'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      whatsapp: (json['whatsapp'] as String?)?.trim() ?? '',
    );
  }
}

class DeveloperModel {
  const DeveloperModel({
    required this.name,
    required this.nameEn,
    required this.role,
    required this.roleEn,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.portfolioUrl,
    required this.bio,
    required this.bioEn,
  });

  final String name;
  final String nameEn;
  final String role;
  final String roleEn;
  final String phone;
  final String whatsapp;
  final String email;
  final String linkedinUrl;
  final String githubUrl;
  final String portfolioUrl;
  final String bio;
  final String bioEn;

  bool get hasPhone => phone.trim().isNotEmpty;
  bool get hasWhatsapp => whatsapp.trim().isNotEmpty;
  bool get hasEmail => email.trim().isNotEmpty;
  bool get hasLinkedin => linkedinUrl.trim().isNotEmpty;
  bool get hasGithub => githubUrl.trim().isNotEmpty;
  bool get hasPortfolio => portfolioUrl.trim().isNotEmpty;

  String localizedName(bool isArabic) =>
      isArabic ? name : (nameEn.isNotEmpty ? nameEn : name);

  String localizedRole(bool isArabic) =>
      isArabic ? role : (roleEn.isNotEmpty ? roleEn : role);

  String localizedBio(bool isArabic) =>
      isArabic ? bio : (bioEn.isNotEmpty ? bioEn : bio);

  factory DeveloperModel.fromJson(Map<String, dynamic> json) {
    return DeveloperModel(
      name: (json['name'] as String?)?.trim() ?? '',
      nameEn: (json['name_en'] as String?)?.trim() ?? '',
      role: (json['role'] as String?)?.trim() ?? '',
      roleEn: (json['role_en'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      whatsapp: (json['whatsapp'] as String?)?.trim() ?? '',
      email: (json['email'] as String?)?.trim() ?? '',
      linkedinUrl: (json['linkedin_url'] as String?)?.trim() ?? '',
      githubUrl: (json['github_url'] as String?)?.trim() ?? '',
      portfolioUrl: (json['portfolio_url'] as String?)?.trim() ?? '',
      bio: (json['bio'] as String?)?.trim() ?? '',
      bioEn: (json['bio_en'] as String?)?.trim() ?? '',
    );
  }
}

class ProjectShowcaseModel {
  const ProjectShowcaseModel({
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.category,
    required this.projectUrl,
    this.slug = '',
    this.badgeText = '',
    this.technologies = const [],
  });

  final String titleAr;
  final String titleEn;
  final String slug;
  final String descriptionAr;
  final String descriptionEn;
  final String category;
  final String projectUrl;
  final String badgeText;
  final List<String> technologies;

  bool get hasUrl => projectUrl.trim().isNotEmpty;

  String localizedTitle(bool isArabic) =>
      isArabic ? titleAr : (titleEn.isNotEmpty ? titleEn : titleAr);

  String localizedDescription(bool isArabic) => isArabic
      ? descriptionAr
      : (descriptionEn.isNotEmpty ? descriptionEn : descriptionAr);

  factory ProjectShowcaseModel.fromJson(Map<String, dynamic> json) {
    return ProjectShowcaseModel(
      titleAr: (json['title_ar'] as String?)?.trim() ?? '',
      titleEn: (json['title_en'] as String?)?.trim() ?? '',
      slug: (json['slug'] as String?)?.trim() ?? '',
      descriptionAr: (json['description_ar'] as String?)?.trim() ?? '',
      descriptionEn: (json['description_en'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? '',
      projectUrl: (json['project_url'] as String?)?.trim() ?? '',
      badgeText: (json['badge_text'] as String?)?.trim() ?? '',
      technologies: (json['technologies'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class CompanyServiceModel {
  const CompanyServiceModel({
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.badge,
    required this.iconCode,
  });

  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String badge;
  final String iconCode;

  String localizedTitle(bool isArabic) =>
      isArabic ? titleAr : (titleEn.isNotEmpty ? titleEn : titleAr);

  String localizedDescription(bool isArabic) => isArabic
      ? descriptionAr
      : (descriptionEn.isNotEmpty ? descriptionEn : descriptionAr);

  factory CompanyServiceModel.fromJson(Map<String, dynamic> json) {
    return CompanyServiceModel(
      titleAr: (json['title_ar'] as String?)?.trim() ?? '',
      titleEn: (json['title_en'] as String?)?.trim() ?? '',
      descriptionAr: (json['description_ar'] as String?)?.trim() ?? '',
      descriptionEn: (json['description_en'] as String?)?.trim() ?? '',
      badge: (json['badge'] as String?)?.trim() ?? '',
      iconCode: (json['icon_code'] as String?)?.trim() ?? '',
    );
  }
}
