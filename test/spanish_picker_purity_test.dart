import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/widgets/global_picker_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  Finder rowText(String text) =>
      find.descendant(of: find.byType(ListTile), matching: find.text(text));

  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        home: Scaffold(body: dialog),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  testWidgets('Spanish picker rows render only Spanish names', (tester) async {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    await pumpDialog(
      tester,
      buildLanguagePickerDialog(
        catalog: catalog,
        selectedCode: 'es',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Seleccionar idioma'), findsOneWidget);
    expect(rowText('Español'), findsOneWidget);
    expect(rowText('Inglés'), findsOneWidget);
    expect(rowText('Turco'), findsOneWidget);
    expect(rowText('English'), findsNothing);
    expect(rowText('Türkçe'), findsNothing);

    await pumpDialog(
      tester,
      buildCountryPickerDialog(
        catalog: catalog,
        selectedCode: 'ES',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Seleccionar país'), findsOneWidget);
    expect(rowText('España'), findsOneWidget);
    expect(rowText('Turquía'), findsOneWidget);
    expect(rowText('Türkiye'), findsNothing);

    await pumpDialog(
      tester,
      buildCurrencyPickerDialog(
        catalog: catalog,
        selectedCode: 'EUR',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Seleccionar moneda'), findsOneWidget);
    expect(rowText('EUR · euro'), findsOneWidget);
    expect(rowText('USD · dólar estadounidense'), findsOneWidget);
    expect(rowText('US Dollar'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
  });

  test('Spanish aliases remain searchable while results stay localized', () async {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    final turkish = catalog.languages.singleWhere(
      (item) => item.matches('Türkçe'),
    );
    expect(turkish.code, 'tr');
    expect(turkish.nameFor('es'), 'Turco');

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
  });
}
