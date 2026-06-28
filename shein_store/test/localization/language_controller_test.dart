import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylehub_store/controllers/language_controller.dart';
import 'package:stylehub_store/core/widgets/app_confirmation_dialog.dart';
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

  Future<LanguageController> buildControllerWithoutInitialize([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    final localStorage = await LocalStorageService.create();
    final mockDataService = await MockDataService.create(
      localStorageService: localStorage,
    );
    return LanguageController(
      localStorageService: localStorage,
      mockDataService: mockDataService,
    );
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
    expect(
      tester.getCenter(find.text('Shop')).dx <
          tester.getCenter(find.text('Me')).dx,
      isTrue,
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
    expect(
      tester.getCenter(find.text('تسوق')).dx >
          tester.getCenter(find.text('أنا')).dx,
      isTrue,
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

    await controller.setEnglish();
    await tester.pumpAndSettle();

    expect(find.text('Shop'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Shop'))),
      TextDirection.ltr,
    );
  });

  test('Language preference persists after controller recreation', () async {
    final firstController = await buildController();
    await firstController.setArabic();

    final secondController = await buildController({'app_locale': 'ar'});
    expect(secondController.selectedLanguage, AppLanguage.arabic);
    expect(secondController.locale, const Locale('ar'));
  });

  test(
    'Saved language is applied synchronously before first app frame',
    () async {
      final arabicController = await buildControllerWithoutInitialize({
        'app_locale': 'ar',
      });
      expect(arabicController.locale, const Locale('ar'));
      expect(
        arabicController.directionFor(arabicController.locale!),
        TextDirection.rtl,
      );

      final englishController = await buildControllerWithoutInitialize({
        'app_locale': 'en',
      });
      expect(englishController.locale, const Locale('en'));
      expect(
        englishController.directionFor(englishController.locale!),
        TextDirection.ltr,
      );
    },
  );

  testWidgets('Confirmation dialog follows Arabic RTL direction', (
    tester,
  ) async {
    await _pumpLocalizedApp(
      tester,
      const Locale('ar'),
      Builder(
        builder: (context) => FilledButton(
          onPressed: () => AppConfirmationDialog.show(
            context,
            title: 'تأكيد العملية',
            message: 'هل تريد المتابعة؟',
            confirmLabel: 'تأكيد',
            cancelLabel: 'إلغاء',
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد العملية'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('تأكيد العملية'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Confirmation dialog follows English LTR direction', (
    tester,
  ) async {
    await _pumpLocalizedApp(
      tester,
      const Locale('en'),
      Builder(
        builder: (context) => FilledButton(
          onPressed: () => AppConfirmationDialog.show(
            context,
            title: 'Confirm action',
            message: 'Do you want to continue?',
            confirmLabel: 'Confirm',
            cancelLabel: 'Cancel',
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm action'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Confirm action'))),
      TextDirection.ltr,
    );
  });
}

void _noop(int _) {}

Future<void> _pumpLocalizedApp(
  WidgetTester tester,
  Locale locale,
  Widget child,
) {
  return tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}
