import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () async {
    final gate = Completer<void>();
    expect(gate.isCompleted, isFalse);
  });
}
