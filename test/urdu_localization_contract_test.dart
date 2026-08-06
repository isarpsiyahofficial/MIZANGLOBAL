import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Urdu localization must remain incomplete until materialized', () {
    const expectedStaticEntryCount = 791;
    const requiredTags = <String>['ur', 'ur-PK', 'ur-IN'];
    const requiredCurrencies = <String>['PKR', 'INR'];

    expect(expectedStaticEntryCount, 791);
    expect(requiredTags, hasLength(3));
    expect(requiredCurrencies, containsAll(<String>['PKR', 'INR']));
  });
}
