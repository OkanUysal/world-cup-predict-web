import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:world_cup_predict_web/core/api/api_exception.dart';
import 'package:world_cup_predict_web/repositories/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('login reaches the network (expect API error, not provider error)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repo = container.read(authRepositoryProvider);

    try {
      await repo.login(
        name: 'test_user',
        password: 'wrongpass',
        channelCode: 'TEST01',
      );
      fail('Expected login to fail');
    } on ApiException catch (e) {
      // Network worked — got an API-level error
      expect(e.message, isNot(contains('minified')));
      expect(e.message, isNotEmpty);
    }
  });
}
