import 'package:flutter/material.dart';

import 'app.dart';
import 'services/local_storage_service.dart';
import 'services/mock_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorageService = await LocalStorageService.create();
  final mockDataService = await MockDataService.create(
    localStorageService: localStorageService,
  );
  runApp(
    StyleHubBootstrap(
      localStorageService: localStorageService,
      mockDataService: mockDataService,
    ),
  );
}
