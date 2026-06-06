import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'api_client.dart';

/// ApiClient — authProvider'a bağımlı değil; döngüsel provider hatasını önler.
/// Token shared_preferences'tan okunur.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    getToken: () async {
      final storage = await ref.read(tokenStorageProvider.future);
      return storage.getToken();
    },
    onUnauthorized: () async {
      final storage = await ref.read(tokenStorageProvider.future);
      await storage.clearAll();
      // Auth state güncellemesi AuthNotifier tarafından dinlenir
      ref.read(unauthorizedTriggerProvider.notifier).state++;
    },
  );
});

/// 401 alındığında auth state'i sıfırlamak için tetikleyici.
final unauthorizedTriggerProvider = StateProvider<int>((ref) => 0);
