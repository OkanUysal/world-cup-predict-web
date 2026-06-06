import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');

  runApp(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWith(
          (ref) => ref.watch(apiClientOverrideProvider),
        ),
      ],
      child: const WorldCupApp(),
    ),
  );
}
