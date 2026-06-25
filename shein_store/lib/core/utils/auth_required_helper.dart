import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';

class AuthRequiredHelper {
  static Future<void> guard(
    BuildContext context, {
    required FutureOr<void> Function() onAuthenticated,
  }) async {
    await context.read<AuthController>().requireAuth(context, onAuthenticated);
  }
}
