import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stylehub_store/core/constants/app_colors.dart';
import 'package:stylehub_store/core/widgets/app_loading.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: Scaffold(body: child),
    );
  }

  testWidgets('AppLoading renders skeleton content instead of a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(const AppLoading(layout: AppLoadingLayout.productGrid)),
    );

    expect(
      find.byWidgetPredicate((widget) => widget is Skeletonizer),
      findsWidgets,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('AppLoading skeleton does not expose fake product data', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(const AppLoading(layout: AppLoadingLayout.marketplace)),
    );

    expect(find.textContaining(r'$'), findsNothing);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.textContaining('Product'), findsNothing);
  });
}
