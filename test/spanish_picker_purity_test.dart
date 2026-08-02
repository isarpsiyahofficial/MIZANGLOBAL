import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('picker builders render selected-language names and stable codes', () {
    final source = File(
      'lib/widgets/global_picker_dialog.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('titleOf: (item) => item.nameFor(MizanI18n.languageTag),'),
    );
    expect(
      source,
      contains(
        "titleOf: (item) => '\${item.code} · \${item.nameFor(MizanI18n.languageTag)}',",
      ),
    );
    expect(source, contains('subtitleOf: (item) => item.code.toUpperCase(),'));
    expect(source, contains('subtitleOf: (item) => item.code,'));
    expect(source, isNot(contains('titleOf: (item) => item.searchNames')));
    expect(source, isNot(contains('titleOf: (item) => item.nativeName')));
  });

  test(
    'Spanish aliases remain searchable while results stay localized',
    () async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();

      final turkish = catalog.languages.singleWhere(
        (item) => item.matches('Türkçe'),
      );
      expect(turkish.code, 'tr');
      expect(turkish.nameFor('es'), 'Turco');

      final english = catalog.languages.singleWhere(
        (item) => item.matches('English'),
      );
      expect(english.code, 'en');
      expect(english.nameFor('es'), 'Inglés');

      final turkey = catalog.countries.singleWhere(
        (item) => item.matches('Türkiye'),
      );
      expect(turkey.code, 'TR');
      expect(turkey.nameFor('es'), 'Turquía');

      final germany = catalog.countries.singleWhere(
        (item) => item.matches('Deutschland'),
      );
      expect(germany.code, 'DE');
      expect(germany.nameFor('es'), 'Alemania');

      final dollar = catalog.currencies.singleWhere(
        (item) => item.code == 'USD' && item.matches('US Dollar'),
      );
      expect(dollar.nameFor('es'), 'dólar estadounidense');
    },
  );
}
