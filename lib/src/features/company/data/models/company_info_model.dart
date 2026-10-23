class CompanyInfoModel {
  const CompanyInfoModel({
    required this.companyName,
    this.companyNameEn = 'COMMIT_',
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
          : 'COMMIT_',
      companyNameEn:
          (json['company_name_en'] as String?)?.trim().isNotEmpty == true
          ? (json['company_name_en'] as String).trim()
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
    );
  }

  static CompanyInfoModel fallback() {
    return const CompanyInfoModel(
      companyName: 'COMMIT_',
      companyNameEn: 'COMMIT_',
      taglineAr: 'نلتزم. نبني. نُطلق.',
      taglineEn: 'We commit. We build. We ship.',
      aboutAr:
          'استوديو هندسي متخصص في تطوير البرمجيات الدقيقة وعالية الأداء. نتشارك مع رواد الأعمال والشركات لبناء وإطلاق تطبيقات ومنصات حيوية لا تقبل المساومة على الجودة.',
      aboutEn:
          'We are a specialized software studio focused on craft, performance, and reliability. We partner with founders and enterprises to engineer mission-critical applications.',
      portfolioUrl: 'https://commit.zonesc.cloud/',
      socialLinks: SocialLinksModel(
        facebook: 'https://www.facebook.com/profile.php?id=61594574024377',
        instagram: 'https://www.instagram.com/commit_tech/',
        tiktok: '',
        linkedin: 'https://www.linkedin.com/in/abdelrahmanabas23',
        github: 'https://github.com/Abdelrohmanaliabas',
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
          titleAr: 'تطبيق ذكرني (Zekrni)',
          titleEn: 'Zekrni Islamic Companion',
          descriptionAr:
              'تطبيق إسلامي Offline-first للأذكار والتسابيح والتنبيهات المجدولة والمحتوى الصوتي عالي الدقة.',
          descriptionEn:
              'An offline-first Islamic companion app designed for Athkar, smart Tasbeeh counter, background alerts, and high-fidelity offline audio.',
          category: 'Offline-first Mobile App',
          projectUrl: 'https://commit.zonesc.cloud/en',
        ),
        ProjectShowcaseModel(
          titleAr: 'منصة وتطبيق Zone',
          titleEn: 'Zone Platform & Logistics',
          descriptionAr:
              'منصة متعددة الأطراف لإدارة المتاجر والمنتجات والطلبات والتوصيل والإشعارات الفورية.',
          descriptionEn:
              'A multi-vendor ecosystem orchestrating merchants, product catalogs, order pipelines, driver delivery, and real-time alerts.',
          category: 'Multi-Vendor & Logistics Platform',
          projectUrl: 'https://commit.zonesc.cloud/en',
        ),
        ProjectShowcaseModel(
          titleAr: 'منصة وتطبيق Fitness Way',
          titleEn: 'Fitness Way Gym & Coaching',
          descriptionAr:
              'منصة متكاملة لإدارة الصالات الرياضية والاشتراكات والمدربين والخطط التدريبية.',
          descriptionEn:
              'A full fitness-tech ecosystem connecting gym operations, coaches, and athletes through subscriptions and workout tracking.',
          category: 'Fitness & Gym Management',
          projectUrl: 'https://commit.zonesc.cloud/en',
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
  });

  final String facebook;
  final String instagram;
  final String tiktok;
  final String linkedin;
  final String website;
  final String github;

  bool get hasFacebook => facebook.trim().isNotEmpty;
  bool get hasInstagram => instagram.trim().isNotEmpty;
  bool get hasTiktok => tiktok.trim().isNotEmpty;
  bool get hasLinkedin => linkedin.trim().isNotEmpty;
  bool get hasWebsite => website.trim().isNotEmpty;
  bool get hasGithub => github.trim().isNotEmpty;

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) {
    return SocialLinksModel(
      facebook: (json['facebook'] as String?)?.trim() ?? '',
      instagram: (json['instagram'] as String?)?.trim() ?? '',
      tiktok: (json['tiktok'] as String?)?.trim() ?? '',
      linkedin: (json['linkedin'] as String?)?.trim() ?? '',
      website: (json['website'] as String?)?.trim() ?? '',
      github: (json['github'] as String?)?.trim() ?? '',
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
  });

  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String category;
  final String projectUrl;

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
      descriptionAr: (json['description_ar'] as String?)?.trim() ?? '',
      descriptionEn: (json['description_en'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? '',
      projectUrl: (json['project_url'] as String?)?.trim() ?? '',
    );
  }
}
