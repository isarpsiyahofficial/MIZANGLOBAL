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
        locale: const Locale('pt', 'BR'),
        home: Scaffold(body: dialog),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  testWidgets('pt-BR picker rows render only Brazilian Portuguese names', (
    tester,
  ) async {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
    final catalog = await GlobalCatalogRepository.load();

    await pumpDialog(
      tester,
      buildLanguagePickerDialog(
        catalog: catalog,
        selectedCode: 'pt-BR',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Selecionar idioma'), findsOneWidget);
    expect(rowText('português (Brasil)'), findsOneWidget);
    expect(rowText('espanhol'), findsOneWidget);
    expect(rowText('inglês'), findsOneWidget);
    expect(rowText('turco'), findsOneWidget);
    expect(rowText('English'), findsNothing);
    expect(rowText('Türkçe'), findsNothing);

    await pumpDialog(
      tester,
      buildCountryPickerDialog(
        catalog: catalog,
        selectedCode: 'BR',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Selecionar país'), findsOneWidget);
    expect(rowText('Brasil'), findsOneWidget);
    expect(rowText('Turquia'), findsOneWidget);
    expect(rowText('Türkiye'), findsNothing);

    await pumpDialog(
      tester,
      buildCurrencyPickerDialog(
        catalog: catalog,
        selectedCode: 'BRL',
        autofocusSearch: false,
      ),
    );
    expect(find.text('Selecionar moeda'), findsOneWidget);
    expect(rowText('BRL · real brasileiro'), findsOneWidget);
    expect(rowText('USD · dólar americano'), findsOneWidget);
    expect(rowText('US Dollar'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
  });

  test('pt-BR aliases remain searchable while results stay localized', () async {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
    final catalog = await GlobalCatalogRepository.load();

    final turkish = catalog.languages.singleWhere(
      (item) => item.matches('Türkçe'),
    );
    expect(turkish.code, 'tr');
    expect(turkish.nameFor('pt-BR'), 'turco');

    final turkey = catalog.countries.singleWhere(
      (item) => item.matches('Türkiye'),
    );
    expect(turkey.code, 'TR');
    expect(turkey.nameFor('pt-BR'), 'Turquia');

    final germany = catalog.countries.singleWhere(
      (item) => item.matches('Deutschland'),
    );
    expect(germany.code, 'DE');
    expect(germany.nameFor('pt-BR'), 'Alemanha');

    final dollar = catalog.currencies.singleWhere(
      (item) => item.code == 'USD' && item.matches('US Dollar'),
    );
    expect(dollar.nameFor('pt-BR'), 'dólar americano');
  });
}
