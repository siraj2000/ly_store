import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylehub_store/controllers/language_controller.dart';
import 'package:stylehub_store/core/theme/app_theme.dart';
import 'package:stylehub_store/l10n/generated/app_localizations.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/views/widgets/common/bottom_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LanguageController> buildController([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    final localStorage = await LocalStorageService.create();
    final mockDataService = await MockDataService.create(
      localStorageService: localStorage,
    );
    final controller = LanguageController(
      localStorageService: localStorage,
      mockDataService: mockDataService,
    );
    await controller.initializeLanguage();
    return controller;
  }

  testWidgets('English localization renders LTR shop label', (tester) async {
    final controller = await buildController({'app_locale': 'en'});

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<LanguageController>(
          builder: (context, language, _) {
            return MaterialApp(
              locale: language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                bottomNavigationBar: BottomNavBar(
                  currentIndex: 0,
                  onTap: _noop,
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shop'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Shop'))),
      TextDirection.ltr,
    );
  });

  testWidgets('Arabic localization renders RTL shop label', (tester) async {
    final controller = await buildController({'app_locale': 'ar'});

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<LanguageController>(
          builder: (context, language, _) {
            return MaterialApp(
              locale: language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                bottomNavigationBar: BottomNavBar(
                  currentIndex: 0,
                  onTap: _noop,
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسوق'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('تسوق'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Runtime language switching updates text direction', (
    tester,
  ) async {
    final controller = await buildController({'app_locale': 'en'});

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<LanguageController>(
          builder: (context, language, _) {
            return MaterialApp(
              locale: language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                bottomNavigationBar: BottomNavBar(
                  currentIndex: 0,
                  onTap: _noop,
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shop'), findsOneWidget);

    await controller.setArabic();
    await tester.pumpAndSettle();

    expect(find.text('تسوق'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('تسوق'))),
      TextDirection.rtl,
    );
  });

  test('Language preference persists after controller recreation', () async {
    final firstController = await buildController();
    await firstController.setArabic();

    final secondController = await buildController({'app_locale': 'ar'});
    expect(secondController.selectedLanguage, AppLanguage.arabic);
    expect(secondController.locale, const Locale('ar'));
  });
}

void _noop(int _) {}
