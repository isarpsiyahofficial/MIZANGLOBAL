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

  Future<void> renderFrame(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        home: Scaffold(body: dialog),
      ),
    );
    await renderFrame(tester);
  }

  Future<void> enterSearch(WidgetTester tester, String query) async {
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, query);
    await renderFrame(tester);
  }

  Future<void> closeHost(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets(
    'Spanish language picker displays only Spanish names while native aliases remain searchable',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      await pumpDialog(
        tester,
        buildLanguagePickerDialog(catalog: catalog, selectedCode: 'es'),
      );

      expect(find.text('Seleccionar idioma'), findsOneWidget);
      expect(rowText('Español'), findsOneWidget);
      expect(rowText('Inglés'), findsOneWidget);
      expect(rowText('Turco'), findsOneWidget);
      expect(rowText('ES'), findsOneWidget);
      expect(rowText('EN'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('English'), findsNothing);
      expect(rowText('Türkçe'), findsNothing);

      await enterSearch(tester, 'Türkçe');
      expect(rowText('Turco'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('Türkçe'), findsNothing);
      expect(rowText('Inglés'), findsNothing);

      await closeHost(tester);
    },
  );

  testWidgets(
    'Spanish country picker keeps native and English aliases search-only',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      await pumpDialog(
        tester,
        buildCountryPickerDialog(catalog: catalog, selectedCode: 'ES'),
      );
      expect(find.text('Seleccionar país'), findsOneWidget);

      await enterSearch(tester, 'Türkiye');
      expect(rowText('Turquía'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('Türkiye'), findsNothing);
      expect(rowText('Turkey'), findsNothing);

      await enterSearch(tester, 'Deutschland');
      expect(rowText('Alemania'), findsOneWidget);
      expect(rowText('DE'), findsOneWidget);
      expect(rowText('Deutschland'), findsNothing);
      expect(rowText('Germany'), findsNothing);

      await closeHost(tester);
    },
  );

  testWidgets(
    'Spanish currency picker displays Spanish currency names for English aliases',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      await pumpDialog(
        tester,
        buildCurrencyPickerDialog(catalog: catalog, selectedCode: 'EUR'),
      );
      expect(find.text('Seleccionar moneda'), findsOneWidget);

      await enterSearch(tester, 'US Dollar');
      expect(rowText('USD · dólar estadounidense'), findsOneWidget);
      expect(rowText('US Dollar'), findsNothing);
      expect(rowText('United States Dollar'), findsNothing);
      expect(rowText('dólar estadounidense'), findsNothing);

      await closeHost(tester);
    },
  );
}
