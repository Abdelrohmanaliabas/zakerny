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
        await Clipboard.setData(ClipboardData(text: trimmed));
        messenger.showSnackBar(
          SnackBar(content: Text('تم نسخ الرابط للحافظة: $trimmed')),
        );
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: trimmed));
      messenger.showSnackBar(
        SnackBar(content: Text('تم نسخ الرابط للحافظة: $trimmed')),
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
        query: 'subject=استفسار بخصوص مشاريع وأنظمة COMMIT_',
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

  Future<void> _launchWhatsapp(BuildContext context, String rawPhone) async {
    final clean = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return;
    await _launchUrlString(context, 'https://wa.me/$clean');
  }

  Future<void> _launchPhoneCall(BuildContext context, String rawPhone) async {
    final clean = rawPhone.trim();
    if (clean.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = Uri(scheme: 'tel', path: clean);
      final launched = await launchUrl(uri);
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: clean));
        messenger.showSnackBar(
          SnackBar(content: Text('تم نسخ رقم الهاتف: $clean')),
        );
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: clean));
      messenger.showSnackBar(
        SnackBar(content: Text('تم نسخ رقم الهاتف: $clean')),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: FatimidColors.goldGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'COMMIT_',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Color(0xFF261800),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'الاستوديو المطور وفريق العمل',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Studio Terminal & Hero Card
                  _buildHeroCard(context, isDark),
                  const SizedBox(height: 24),

                  // 2. Featured Projects Section
                  _buildSectionHeader(
                    context,
                    codePrefix: '// 01 • FEATURED WORK',
                    icon: Icons.layers_outlined,
                    title: 'معرض المشاريع والأنظمة الحية',
                    subtitle:
                        'تطبيقات ومنصات برمجية حية قمنا بتصميمها وهندستها وإطلاقها لبيئات الإنتاج',
                  ),
                  const SizedBox(height: 12),
                  ..._info.projects.map(
                    (project) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildProjectCard(context, project, isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildPortfolioBanner(context, isDark),
                  const SizedBox(height: 26),

                  // 3. Capabilities & Services
                  if (_info.services.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      codePrefix: '// 02 • CAPABILITIES',
                      icon: Icons.developer_mode_rounded,
                      title: 'مجالات وهندسة البرمجيات',
                      subtitle:
                          'القدرات والخدمات الهندسية المتقدمة التي يقدمها استوديو COMMIT_',
                    ),
                    const SizedBox(height: 12),
                    _buildServicesGrid(context, isDark),
                    const SizedBox(height: 26),
                  ],

                  // 4. Engineering Leadership
                  _buildSectionHeader(
                    context,
                    codePrefix: '// 03 • LEADERSHIP',
                    icon: Icons.terminal_rounded,
                    title: 'فريق القيادة والبرمجة',
                    subtitle:
                        'تواصل مباشر مع مؤسس الاستوديو ومهندسي الأنظمة المعمارية',
                  ),
                  const SizedBox(height: 12),
                  _buildDevTeamCard(context, isDark),
                  const SizedBox(height: 26),

                  // 5. Official Social Channels
                  _buildSectionHeader(
                    context,
                    codePrefix: '// 04 • CHANNELS',
                    icon: Icons.share_rounded,
                    title: 'صفحاتنا ومنصاتنا الرسمية',
                    subtitle:
                        'تواصل معنا وتابع أحدث التحديثات والمشاريع على شبكاتنا المعتمدة',
                  ),
                  const SizedBox(height: 12),
                  _buildSocialGrid(context, isDark),
                  const SizedBox(height: 26),

                  // 6. Direct Support & Project Inquiries
                  _buildSectionHeader(
                    context,
                    codePrefix: '// 05 • SUPPORT & INQUIRIES',
                    icon: Icons.support_agent_rounded,
                    title: 'الدعم الفني وطلب المشاريع البرمجية',
                    subtitle:
                        'فريقنا جاهز لمناقشة أفكاركم وبناء وتطوير أنظمتكم البرمجية أو تقديم المساعدة الفنية',
                  ),
                  const SizedBox(height: 12),
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
    required String codePrefix,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: FatimidColors.goldPrimary.withValues(
              alpha: isDark ? 0.15 : 0.1,
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            codePrefix,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: FatimidColors.goldPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: FatimidColors.goldPrimary.withValues(
                  alpha: isDark ? 0.18 : 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    isDark ? FatimidColors.goldLight : const Color(0xFF825F05),
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
                      fontSize: 15.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFF9CB8AE)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark) {
    return FatimidCard(
      isEmerald: true,
      elevation: 5,
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal bar header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FatimidColors.goldLight.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    r'$ git commit -m "We commit. We build. We ship."',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: FatimidColors.goldLight,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Studio Badge
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.code_rounded,
                    color: Color(0xFF261800),
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _info.brandDisplay,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: FatimidColors.goldPrimary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: FatimidColors.goldLight.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: const Text(
                            'SOFTWARE STUDIO',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: FatimidColors.goldLight,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'استوديو كوميت لهندسة وتطوير البرمجيات',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4E8DF),
                      ),
                    ),
                    const SizedBox(height: 6),
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
                          fontWeight: FontWeight.w800,
                          color: FatimidColors.goldLight,
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
              height: 1.65,
              color: Color(0xFFE6F4EE),
            ),
          ),
          const SizedBox(height: 18),

          // Key metrics row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _MetricChip(
                icon: Icons.layers_rounded,
                label: '3+ أنظمة إنتاجية حية',
              ),
              _MetricChip(
                icon: Icons.offline_bolt_rounded,
                label: 'Offline-First & Cloud',
              ),
              _MetricChip(
                icon: Icons.verified_user_rounded,
                label: 'هندسة معمارية دقيقة',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _launchUrlString(context, _info.portfolioUrl),
                icon: const Icon(Icons.language_rounded, size: 18),
                label: const Text(
                  'زيارة موقع الاستوديو | commit.zonesc.cloud',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: FatimidColors.goldPrimary,
                  foregroundColor: const Color(0xFF2B1D00),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
              if (_info.support.hasWhatsapp)
                OutlinedButton.icon(
                  onPressed: () =>
                      _launchWhatsapp(context, _info.support.whatsapp),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'تواصل مباشر عبر واتساب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: FatimidColors.goldLight.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    ProjectShowcaseModel project,
    bool isDark,
  ) {
    IconData projectIcon;
    Color iconColor;
    if (project.slug == 'zekrni') {
      projectIcon = Icons.menu_book_rounded;
      iconColor = const Color(0xFF10B981);
    } else if (project.slug == 'zone') {
      projectIcon = Icons.store_mall_directory_rounded;
      iconColor = const Color(0xFF0284C7);
    } else {
      projectIcon = Icons.fitness_center_rounded;
      iconColor = const Color(0xFFEA580C);
    }

    return FatimidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Icon(projectIcon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.titleAr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        if (project.badgeText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              project.badgeText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.category,
                      style: TextStyle(
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
            project.descriptionAr,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: isDark ? const Color(0xFFD4E3DC) : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 14),

          // Tech stack chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.technologies.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF132821)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  tech,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchUrlString(context, project.projectUrl),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(
                'استعراض تفاصيل ${project.titleAr} على المنصة',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? Colors.white
                    : const Color(0xFF0F3A2E),
                side: BorderSide(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F2C22), Color(0xFF081C15)],
              )
            : const LinearGradient(
                colors: [Color(0xFFF7F5EE), Color(0xFFEFEAD8)],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: FatimidColors.goldPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'استكشف معرض المشاريع والمنصات الكامل',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                ),
                Text(
                  'تصفح كافة دراسات الحالة والمعماريات البرمجية على موقعنا الرسمي',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF9CB8AE)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => _launchUrlString(context, _info.portfolioUrl),
            style: FilledButton.styleFrom(
              backgroundColor: FatimidColors.goldPrimary,
              foregroundColor: const Color(0xFF261800),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text(
              'زيارة المعرض ↗',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 540;
        final services = _info.services;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 145,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final svc = services[index];
            IconData svcIcon = Icons.developer_mode_rounded;
            if (svc.iconCode == 'devices') {
              svcIcon = Icons.devices_rounded;
            } else if (svc.iconCode == 'cloud') {
              svcIcon = Icons.cloud_done_rounded;
            } else if (svc.iconCode == 'offline') {
              svcIcon = Icons.offline_pin_rounded;
            } else if (svc.iconCode == 'gps') {
              svcIcon = Icons.near_me_rounded;
            }

            return FatimidCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: FatimidColors.goldPrimary.withValues(
                            alpha: isDark ? 0.2 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          svcIcon,
                          color: FatimidColors.goldPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          svc.titleAr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          svc.badge,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      svc.descriptionAr,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.45,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDevTeamCard(BuildContext context, bool isDark) {
    final dev = _info.developers.isNotEmpty ? _info.developers.first : null;
    if (dev == null) return const SizedBox.shrink();

    return FatimidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'م',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
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
                    Row(
                      children: [
                        Text(
                          dev.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FatimidColors.goldPrimary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'المؤسس',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: FatimidColors.goldPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dev.role,
                      style: const TextStyle(
                        fontSize: 12,
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
              height: 1.6,
              color: isDark ? const Color(0xFFD4E3DC) : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Interactive Developer Links
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dev.hasWhatsapp)
                FilledButton.tonalIcon(
                  onPressed: () => _launchWhatsapp(context, dev.whatsapp),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                  ),
                  label: const Text('واتساب المهندس'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF10B981,
                    ).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFF10B981),
                  ),
                ),
              if (dev.hasEmail)
                OutlinedButton.icon(
                  onPressed: () => _launchEmail(context, dev.email),
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: const Text('إيميل المطور'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF0F3A2E),
                    side: BorderSide(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              if (dev.hasLinkedin)
                OutlinedButton.icon(
                  onPressed: () => _launchUrlString(context, dev.linkedinUrl),
                  icon: const Icon(Icons.business_center_outlined, size: 16),
                  label: const Text('حساب لينكد إن'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A66C2),
                    side: BorderSide(
                      color: const Color(0xFF0A66C2).withValues(alpha: 0.4),
                    ),
                  ),
                ),
              if (dev.hasGithub)
                OutlinedButton.icon(
                  onPressed: () => _launchUrlString(context, dev.githubUrl),
                  icon: const Icon(Icons.code_rounded, size: 16),
                  label: const Text('مستودع GitHub'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF24292F),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
              if (dev.hasPortfolio)
                OutlinedButton.icon(
                  onPressed: () => _launchUrlString(context, dev.portfolioUrl),
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: const Text('الملف التعريفي'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF0F3A2E),
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

  Widget _buildSocialGrid(BuildContext context, bool isDark) {
    final channels = [
      _SocialChannel(
        name: 'الموقع الإلكتروني الرسمي',
        subtitle: 'بوابة استوديو COMMIT_ الشاملة',
        icon: Icons.language_rounded,
        url: _info.socialLinks.website,
        color: const Color(0xFF10B981),
      ),
      _SocialChannel(
        name: 'صفحة الفيسبوك',
        subtitle: 'متابعة التحديثات والمنشورات الرسمية',
        icon: Icons.facebook,
        url: _info.socialLinks.facebook,
        color: const Color(0xFF1877F2),
      ),
      _SocialChannel(
        name: 'حساب الإنستجرام',
        subtitle: 'صور وفيديوهات وتغطيات حصرية للأنظمة',
        icon: Icons.camera_alt_outlined,
        url: _info.socialLinks.instagram,
        color: const Color(0xFFE4405F),
      ),
      _SocialChannel(
        name: 'حساب لينكد إن',
        subtitle: 'شبكة الأعمال والمسيرة المهنية للاستوديو',
        icon: Icons.business_center_outlined,
        url: _info.socialLinks.linkedin,
        color: const Color(0xFF0A66C2),
      ),
      if (_info.socialLinks.hasGithub)
        _SocialChannel(
          name: 'مستودع جيت هَب (GitHub)',
          subtitle: 'الكود المصدري ومستودعات الاستوديو البرمجية',
          icon: Icons.code_rounded,
          url: _info.socialLinks.github,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF24292F),
        ),
      if (_info.socialLinks.hasX)
        _SocialChannel(
          name: 'منصة إكس (X / تويتر)',
          subtitle: 'تغطيات تقنية وتحديثات فورية',
          icon: Icons.alternate_email_rounded,
          url: _info.socialLinks.xUrl,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
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
                    border: Border.all(color: c.color.withValues(alpha: 0.35)),
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
                                  ? const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.15)
                                  : FatimidColors.goldPrimary.withValues(
                                      alpha: 0.15,
                                    ),
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
                          color: isDark
                              ? const Color(0xFF9CB8AE)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isConfigured
                      ? Icons.open_in_new_rounded
                      : Icons.schedule_rounded,
                  size: 18,
                  color: isConfigured
                      ? const Color(0xFF10B981)
                      : (isDark
                            ? const Color(0xFF86A398)
                            : const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
                      'الدعم الفني واستشارات المشاريع',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'جاهزون للإجابة على استفساراتكم والتعاون لبناء تطبيقاتكم وأنظمتكم البرمجية',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
              'مراسلة الدعم والطلبات (${_info.support.email})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
          if (_info.support.hasWhatsapp) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _launchWhatsapp(context, _info.support.whatsapp),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(
                'محادثة مباشرة عبر واتساب (${_info.support.whatsapp})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
          if (_info.support.hasPhone) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _launchPhoneCall(context, _info.support.phone),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: Text(
                'اتصال هاتفي مباشر (${_info.support.phone})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? Colors.white
                    : const Color(0xFF0F3A2E),
                side: BorderSide(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FatimidColors.goldLight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FatimidColors.goldLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
