import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stylehub_store/app.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';

void main() {
  testWidgets('renders LY STORE app after splash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    final mockDataService = await MockDataService.create(
      localStorageService: localStorageService,
    );

    await tester.pumpWidget(
      StyleHubBootstrap(
        localStorageService: localStorageService,
        mockDataService: mockDataService,
      ),
    );

    expect(find.text('LY STORE'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
