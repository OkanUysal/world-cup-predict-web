import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:world_cup_predict_web/core/api/api_providers.dart';
import 'package:world_cup_predict_web/repositories/auth_repository.dart';

void main() {
  test('api providers resolve without circular dependency', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(apiClientProvider), returnsNormally);
    expect(() => container.read(authRepositoryProvider), returnsNormally);
  });
}
