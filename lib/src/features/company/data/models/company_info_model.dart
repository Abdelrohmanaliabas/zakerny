class CompanyInfoModel {
  const CompanyInfoModel({
    required this.companyName,
    this.companyNameEn = 'Maestro Zone',
    required this.taglineAr,
    required this.taglineEn,
    required this.aboutAr,
    required this.aboutEn,
    required this.portfolioUrl,
    required this.socialLinks,
    required this.support,
    required this.developers,
    required this.projects,
  });

  final String companyName;
  final String companyNameEn;
  final String taglineAr;
  final String taglineEn;
  final String aboutAr;
  final String aboutEn;
  final String portfolioUrl;
  final SocialLinksModel socialLinks;
  final SupportContactModel support;
  final List<DeveloperModel> developers;
  final List<ProjectShowcaseModel> projects;

  String localizedCompanyName(bool isArabic) => isArabic
      ? companyName
      : (companyNameEn.isNotEmpty ? companyNameEn : companyName);

  String localizedTagline(bool isArabic) => isArabic ? taglineAr : taglineEn;
  String localizedAbout(bool isArabic) => isArabic ? aboutAr : aboutEn;

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      companyName: (json['company_name'] as String?)?.trim().isNotEmpty == true
          ? (json['company_name'] as String).trim()
          : 'مايسترو زون',
      companyNameEn:
          (json['company_name_en'] as String?)?.trim().isNotEmpty == true
              ? (json['company_name_en'] as String).trim()
              : 'Maestro Zone',
      taglineAr: (json['tagline_ar'] as String?)?.trim().isNotEmpty == true
          ? (json['tagline_ar'] as String).trim()
          : 'حلول برمجية متكاملة للأنظمة والتطبيقات السحابية',
      taglineEn: (json['tagline_en'] as String?)?.trim().isNotEmpty == true
          ? (json['tagline_en'] as String).trim()
          : 'Comprehensive Digital Solutions & Cloud Platforms',
      aboutAr: (json['about_ar'] as String?)?.trim().isNotEmpty == true
          ? (json['about_ar'] as String).trim()
          : 'نبتكر ونطور منصات وتطبيقات ذكية تربط الخدمات والأنظمة في منظومة تقنية واحدة متكاملة وسريعة.',
      aboutEn: (json['about_en'] as String?)?.trim().isNotEmpty == true
          ? (json['about_en'] as String).trim()
          : 'We innovate and develop smart platforms and applications connecting services in a unified digital ecosystem.',
      portfolioUrl: (json['portfolio_url'] as String?)?.trim() ?? 'https://zonesc.cloud/',
      socialLinks: SocialLinksModel.fromJson(
        (json['social_links'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      support: SupportContactModel.fromJson(
        (json['support'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      developers: (json['developers'] as List?)
              ?.whereType<Map>()
              .map((item) =>
                  DeveloperModel.fromJson(item.cast<String, dynamic>()))
              .toList() ??
          const [],
      projects: (json['projects'] as List?)
              ?.whereType<Map>()
              .map((item) =>
                  ProjectShowcaseModel.fromJson(item.cast<String, dynamic>()))
              .toList() ??
          const [],
    );
  }

  static CompanyInfoModel fallback() {
    return const CompanyInfoModel(
      companyName: 'مايسترو زون',
      companyNameEn: 'Maestro Zone',
      taglineAr: 'حلول برمجية متكاملة للأنظمة والتطبيقات السحابية',
      taglineEn: 'Comprehensive Digital Solutions & Cloud Platforms',
      aboutAr:
          'نبتكر ونطور منصات وتطبيقات ذكية تربط الخدمات والأنظمة في منظومة تقنية متكاملة وسريعة.',
      aboutEn:
          'We innovate and develop smart platforms and applications connecting services in a unified digital ecosystem.',
      portfolioUrl: 'https://zonesc.cloud/',
      socialLinks: SocialLinksModel(
        facebook: '',
        instagram: '',
        tiktok: '',
        linkedin: '',
        website: 'https://zonesc.cloud/',
      ),
      support: SupportContactModel(
        email: 'support@zonesc.cloud',
        phone: '',
        whatsapp: '',
      ),
      developers: [
        DeveloperModel(
          name: 'فريق تطوير وبرمجة مايسترو زون',
          nameEn: 'Maestro Zone Engineering Team',
          role: 'مهندسو تطوير البرمجيات والتطبيقات',
          roleEn: 'Lead Software & Mobile Engineers',
          phone: '',
          whatsapp: '',
          email: 'dev@zonesc.cloud',
          linkedinUrl: '',
          githubUrl: '',
          portfolioUrl: '',
          bio: 'هندسة وبرمجة تطبيقات الهواتف والأنظمة السحابية بأحدث المعايير الاحترافية.',
          bioEn:
              'Architecting high-performance mobile apps and scalable cloud ecosystems.',
        ),
      ],
      projects: [
        ProjectShowcaseModel(
          titleAr: 'تطبيق ذكرني (Zakerny App)',
          titleEn: 'Zakerny App',
          descriptionAr:
              'رفيق المسلم الشامل للأذكار، القرآن الكريم، والتنبيهات الإسلامية الذكية.',
          descriptionEn:
              'Comprehensive Islamic app for Quran, Adhkar, and intelligent prayer notifications.',
          category: 'Mobile & Desktop App',
          projectUrl: 'https://zonesc.cloud/',
        ),
        ProjectShowcaseModel(
          titleAr: 'منصة وتطبيق مايسترو زون',
          titleEn: 'Maestro Zone App & Platform',
          descriptionAr:
              'تطبيق ومنصة متطورة للخدمات والطلب مع شبكة ربط ذكية.',
          descriptionEn:
              'All-in-one mobile app and cloud logistics platform.',
          category: 'Mobile App',
          projectUrl: 'https://zonesc.cloud/',
        ),
        ProjectShowcaseModel(
          titleAr: 'بوابات مايسترو زون لإدارة التجار ونقاط البيع',
          titleEn: 'Maestro Zone Merchant & POS Gateways',
          descriptionAr:
              'لوحة تحكم إدارية وتشغيلية متقدمة لإدارة الفروع، المخازن، ونقاط البيع.',
          descriptionEn:
              'Complete management suite for catalog, orders, inventory, and POS.',
          category: 'Web & Desktop SaaS',
          projectUrl: 'https://zonesc.cloud/',
        ),
        ProjectShowcaseModel(
          titleAr: 'سحابة مايسترو زون والخدمات الرقمية',
          titleEn: 'Maestro Zone Cloud & Digital Services',
          descriptionAr:
              'بنية تحتية سحابية متقدمة لربط الخدمات والتطبيقات الرقمية وتوفير أعلى موثوقية.',
          descriptionEn:
              'Unified cloud backend, realtime event processing, and digital APIs.',
          category: 'Cloud Infrastructure',
          projectUrl: 'https://zonesc.cloud/',
        ),
      ],
    );
  }
}

class SocialLinksModel {
  const SocialLinksModel({
    required this.facebook,
    required this.instagram,
    required this.tiktok,
    required this.linkedin,
    required this.website,
  });

  final String facebook;
  final String instagram;
  final String tiktok;
  final String linkedin;
  final String website;

  bool get hasFacebook => facebook.trim().isNotEmpty;
  bool get hasInstagram => instagram.trim().isNotEmpty;
  bool get hasTiktok => tiktok.trim().isNotEmpty;
  bool get hasLinkedin => linkedin.trim().isNotEmpty;
  bool get hasWebsite => website.trim().isNotEmpty;

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) {
    return SocialLinksModel(
      facebook: (json['facebook'] as String?)?.trim() ?? '',
      instagram: (json['instagram'] as String?)?.trim() ?? '',
      tiktok: (json['tiktok'] as String?)?.trim() ?? '',
      linkedin: (json['linkedin'] as String?)?.trim() ?? '',
      website: (json['website'] as String?)?.trim() ?? '',
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

  String localizedName(bool isArabic) => isArabic
      ? name
      : (nameEn.isNotEmpty ? nameEn : name);

  String localizedRole(bool isArabic) => isArabic
      ? role
      : (roleEn.isNotEmpty ? roleEn : role);

  String localizedBio(bool isArabic) => isArabic
      ? bio
      : (bioEn.isNotEmpty ? bioEn : bio);

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
  });

  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String category;
  final String projectUrl;

  bool get hasUrl => projectUrl.trim().isNotEmpty;

  String localizedTitle(bool isArabic) => isArabic
      ? titleAr
      : (titleEn.isNotEmpty ? titleEn : titleAr);

  String localizedDescription(bool isArabic) => isArabic
      ? descriptionAr
      : (descriptionEn.isNotEmpty ? descriptionEn : descriptionAr);

  factory ProjectShowcaseModel.fromJson(Map<String, dynamic> json) {
    return ProjectShowcaseModel(
      titleAr: (json['title_ar'] as String?)?.trim() ?? '',
      titleEn: (json['title_en'] as String?)?.trim() ?? '',
      descriptionAr: (json['description_ar'] as String?)?.trim() ?? '',
      descriptionEn: (json['description_en'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? '',
      projectUrl: (json['project_url'] as String?)?.trim() ?? '',
    );
  }
}
