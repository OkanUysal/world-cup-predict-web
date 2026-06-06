import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'config/api_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformError: $error\n$stack');
    return true;
  };

  try {
    await initializeDateFormatting('tr_TR');
  } catch (e) {
    debugPrint('Date locale init failed: $e');
  }

  debugPrint(
    'API proxy: ${ApiConfig.useProxy ? ApiConfig.proxyUrl : ApiConfig.backendUrl} '
    '(v${ApiConfig.appVersion})',
  );

  runApp(
    const ProviderScope(
      child: WorldCupApp(),
    ),
  );
}
