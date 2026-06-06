import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'config/api_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');

  debugPrint('API base URL: ${ApiConfig.baseUrl}');

  runApp(
    const ProviderScope(
      child: WorldCupApp(),
    ),
  );
}
