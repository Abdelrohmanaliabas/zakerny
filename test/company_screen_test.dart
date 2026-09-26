import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/features/company/data/models/company_info_model.dart';
import 'package:zakerny/src/features/company/presentation/screens/company_screen.dart';

void main() {
  test('CompanyInfoModel fallback in Zakerny has Maestro Zone details without personal info', () {
    final model = CompanyInfoModel.fallback();
    expect(model.companyName, 'مايسترو زون');
    expect(model.companyNameEn, 'Maestro Zone');
    expect(model.developers.length, 1);
    expect(model.developers.first.name, 'فريق تطوير وبرمجة مايسترو زون');
    expect(model.developers.first.hasPhone, false);
    expect(model.developers.first.hasWhatsapp, false);
    expect(model.projects.isNotEmpty, true);
    expect(model.socialLinks.hasWebsite, true);
    expect(model.support.email, 'support@zonesc.cloud');
  });

  testWidgets('CompanyScreen renders correctly without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CompanyScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CompanyScreen), findsOneWidget);
    expect(find.text('مايسترو زون'), findsOneWidget);
    expect(find.text('تواصل معنا وفريق العمل'), findsOneWidget);
    expect(find.text('معرض الأعمال والمشاريع'), findsOneWidget);
  });
}
