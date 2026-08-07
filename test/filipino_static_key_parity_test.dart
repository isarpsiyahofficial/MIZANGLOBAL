import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fil.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';

void main() {
  test('Filipino owns all and only the 791 stable product keys', () {
    expect(mizanFilipino, hasLength(791));
    expect(mizanIndonesian, hasLength(791));
    expect(mizanFilipino.keys.toSet(), mizanIndonesian.keys.toSet());
  });
}
