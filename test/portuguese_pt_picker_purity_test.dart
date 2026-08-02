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
        locale: const Locale('pt', 'PT'),
        home: Scaffold(body: dialog),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  Future<void> closeHost(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('pt-PT picker rows render only European Portuguese names', (
    tester,
  ) async {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    await pumpDialog(
      tester,
      buildLanguagePickerDialog(
        catalog: catalog,
        selectedCode: 'pt-PT',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Selecionar idioma'), findsOneWidget);
    expect(rowText('português (Portugal)'), findsOneWidget);
    expect(rowText('português (Brasil)'), findsOneWidget);
    expect(rowText('turco'), findsOneWidget);
    expect(rowText('inglês'), findsOneWidget);
    expect(rowText('espanhol'), findsOneWidget);
    expect(rowText('Türkçe'), findsNothing);
    expect(rowText('English'), findsNothing);
    expect(rowText('Español'), findsNothing);

    await pumpDialog(
      tester,
      buildCountryPickerDialog(
        catalog: catalog,
        selectedCode: 'PT',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Selecionar país'), findsOneWidget);
    expect(rowText('Portugal'), findsOneWidget);
    expect(rowText('Turquia'), findsOneWidget);
    expect(rowText('Türkiye'), findsNothing);
    expect(rowText('Turkey'), findsNothing);

    await pumpDialog(
      tester,
      buildCurrencyPickerDialog(
        catalog: catalog,
        selectedCode: 'EUR',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Selecionar moeda'), findsOneWidget);
    expect(rowText('EUR · euro'), findsOneWidget);
    expect(rowText('USD · dólar dos Estados Unidos'), findsOneWidget);
    expect(rowText('US Dollar'), findsNothing);
    expect(rowText('dólar americano'), findsNothing);

    await closeHost(tester);
  });

  test('pt-PT aliases remain searchable while results stay localized', () async {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    final turkish = catalog.languages.singleWhere(
      (item) => item.matches('Türkçe'),
    );
    expect(turkish.code, 'tr');
    expect(turkish.nameFor('pt-PT'), 'turco');

    final turkey = catalog.countries.singleWhere(
      (item) => item.matches('Türkiye'),
    );
    expect(turkey.code, 'TR');
    expect(turkey.nameFor('pt-PT'), 'Turquia');

    final germany = catalog.countries.singleWhere(
      (item) => item.matches('Deutschland'),
    );
    expect(germany.code, 'DE');
    expect(germany.nameFor('pt-PT'), 'Alemanha');

    final dollar = catalog.currencies.singleWhere(
      (item) => item.code == 'USD' && item.matches('US Dollar'),
    );
    expect(dollar.nameFor('pt-PT'), 'dólar dos Estados Unidos');
  });
}
