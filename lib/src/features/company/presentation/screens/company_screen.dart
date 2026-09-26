import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/fatimid_decorations.dart';
import '../../data/models/company_info_model.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final CompanyInfoModel _info = CompanyInfoModel.fallback();

  Future<void> _launchUrlString(BuildContext context, String urlString) async {
    final trimmed = urlString.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (trimmed.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('قريباً - يجري تجهيز المنصة الرسمية.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(trimmed);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger.showSnackBar(
          SnackBar(content: Text('تعذر فتح الرابط: $trimmed')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('تعذر فتح الرابط: $trimmed')),
      );
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final clean = email.trim();
    if (clean.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: clean,
        query: 'subject=استفسار بخصوص تطبيق ذكرني / مايسترو زون',
      );
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: clean));
        messenger.showSnackBar(
          SnackBar(content: Text('تم نسخ البريد الإلكتروني: $clean')),
        );
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: clean));
      messenger.showSnackBar(
        SnackBar(content: Text('تم نسخ البريد الإلكتروني: $clean')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'تواصل معنا وفريق العمل',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero Card
                  _buildHeroCard(context, isDark),
                  const SizedBox(height: 18),

                  // 2. Portfolio & Projects Section
                  _buildSectionHeader(
                    context,
                    icon: Icons.layers_outlined,
                    title: 'معرض الأعمال والمشاريع',
                    subtitle: 'تصفح أحدث الأنظمة والتطبيقات البرمجية',
                  ),
                  const SizedBox(height: 10),
                  _buildPortfolioCard(context, isDark),
                  const SizedBox(height: 20),

                  // 3. Social Media Channels
                  _buildSectionHeader(
                    context,
                    icon: Icons.share_rounded,
                    title: 'صفحاتنا على وسائل التواصل',
                    subtitle: 'تواصل معنا وتابع جديد مشاريعنا على منصاتنا الرسمية',
                  ),
                  const SizedBox(height: 10),
                  _buildSocialGrid(context, isDark),
                  const SizedBox(height: 20),

                  // 4. Development Team
                  _buildSectionHeader(
                    context,
                    icon: Icons.code_rounded,
                    title: 'فريق التطوير والبرمجة',
                    subtitle: 'تواصل مباشرة مع مهندسي ومطوري الأنظمة',
                  ),
                  const SizedBox(height: 10),
                  _buildDevTeamCard(context, isDark),
                  const SizedBox(height: 20),

                  // 5. Support & Direct Contact
                  _buildSectionHeader(
                    context,
                    icon: Icons.support_agent_rounded,
                    title: 'الدعم الفني والتواصل المباشر',
                    subtitle: 'فريق الدعم الفني جاهز للإجابة على استفساراتكم',
                  ),
                  const SizedBox(height: 10),
                  _buildSupportCard(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? FatimidColors.goldLight : const Color(0xFF825F05),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF9CB8AE) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark) {
    return FatimidCard(
      isEmerald: true,
      elevation: 4,
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.diamond_outlined,
                    color: Color(0xFF261800),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _info.companyName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _info.companyNameEn,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: FatimidColors.goldLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: FatimidColors.goldLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _info.taglineAr,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _info.aboutAr,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: Color(0xFFE6F4EE),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _launchUrlString(context, _info.portfolioUrl),
            icon: const Icon(Icons.language_rounded, size: 18),
            label: const Text(
              'زيارة المنصة الرسمية',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: FatimidColors.goldPrimary,
              foregroundColor: const Color(0xFF2B1D00),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, bool isDark) {
    return FatimidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: FatimidColors.goldPrimary,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'معرض المشاريع والأنظمة',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'تصفح سابقة أعمالنا وتطبيقاتنا الحية في مختلف القطاعات الرقمية',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF9CB8AE) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _info.projects.map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132821) : const Color(0xFFF6F8F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: FatimidColors.goldPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.titleAr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF103024),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _launchUrlString(context, _info.portfolioUrl),
              icon: const Icon(Icons.travel_explore_rounded, size: 18),
              label: const Text(
                'زيارة معرض الأعمال',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: FatimidColors.goldPrimary,
                foregroundColor: const Color(0xFF261800),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialGrid(BuildContext context, bool isDark) {
    final channels = [
      _SocialChannel(
        name: 'صفحة الفيسبوك',
        subtitle: 'متابعة التحديثات والمنشورات',
        icon: Icons.facebook,
        url: _info.socialLinks.facebook,
        color: const Color(0xFF1877F2),
      ),
      _SocialChannel(
        name: 'حساب الإنستجرام',
        subtitle: 'صور وفيديوهات وتغطيات حصرية',
        icon: Icons.camera_alt_outlined,
        url: _info.socialLinks.instagram,
        color: const Color(0xFFE4405F),
      ),
      _SocialChannel(
        name: 'حساب لينكد إن',
        subtitle: 'شبكة الأعمال والمسيرة المهنية',
        icon: Icons.business_center_outlined,
        url: _info.socialLinks.linkedin,
        color: const Color(0xFF0A66C2),
      ),
      _SocialChannel(
        name: 'الموقع الإلكتروني',
        subtitle: 'بوابة المنظومة الشاملة',
        icon: Icons.language_rounded,
        url: _info.socialLinks.website,
        color: const Color(0xFF10B981),
      ),
    ];

    return Column(
      children: channels.map((c) {
        final isConfigured = c.url.trim().isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FatimidCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => _launchUrlString(context, c.url),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: c.color.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(c.icon, color: c.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isConfigured
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : FatimidColors.goldPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isConfigured ? 'مفعل' : 'قريباً',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isConfigured
                                    ? const Color(0xFF10B981)
                                    : FatimidColors.goldPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF9CB8AE) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isConfigured ? Icons.open_in_new_rounded : Icons.schedule_rounded,
                  size: 18,
                  color: isConfigured
                      ? const Color(0xFF10B981)
                      : (isDark ? const Color(0xFF86A398) : const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDevTeamCard(BuildContext context, bool isDark) {
    final dev = _info.developers.isNotEmpty
        ? _info.developers.first
        : null;

    if (dev == null) return const SizedBox.shrink();

    return FatimidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'م',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF261800),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dev.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dev.role,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: FatimidColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dev.bio,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: isDark ? const Color(0xFFD4E3DC) : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dev.hasEmail)
                OutlinedButton.icon(
                  onPressed: () => _launchEmail(context, dev.email),
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: const Text('إيميل المطور'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F3A2E),
                    side: BorderSide(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              if (dev.hasPortfolio)
                OutlinedButton.icon(
                  onPressed: () => _launchUrlString(context, dev.portfolioUrl),
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: const Text('الملف التعريفي'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F3A2E),
                    side: BorderSide(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, bool isDark) {
    return FatimidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: Color(0xFF0D9488),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فريق الدعم الفني والمساعدة',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'نحن هنا للإجابة عن أسئلتكم ومساعدتكم على مدار الساعة',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _launchEmail(context, _info.support.email),
            icon: const Icon(Icons.mail_outline_rounded, size: 18),
            label: Text(
              'مراسلة الدعم الفني (${_info.support.email})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialChannel {
  const _SocialChannel({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.url,
    required this.color,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final String url;
  final Color color;
}
