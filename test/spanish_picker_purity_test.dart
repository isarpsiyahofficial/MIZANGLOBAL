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

  Future<void> pumpPickerHost(
    WidgetTester tester, {
    required GlobalCatalog catalog,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => showLanguagePicker(
                    context,
                    catalog: catalog,
                    selectedCode: 'es',
                  ),
                  child: const Text('language-picker'),
                ),
                ElevatedButton(
                  onPressed: () => showCountryPicker(
                    context,
                    catalog: catalog,
                    selectedCode: 'ES',
                  ),
                  child: const Text('country-picker'),
                ),
                ElevatedButton(
                  onPressed: () => showCurrencyPicker(
                    context,
                    catalog: catalog,
                    selectedCode: 'EUR',
                  ),
                  child: const Text('currency-picker'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterSearch(WidgetTester tester, String query) async {
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, query);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Spanish language picker displays only Spanish names while native aliases remain searchable',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      await pumpPickerHost(tester, catalog: catalog);

      await tester.tap(find.text('language-picker'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar idioma'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Inglés'), findsOneWidget);
      expect(find.text('Turco'), findsOneWidget);
      expect(find.text('ES'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('TR'), findsOneWidget);
      expect(find.text('English'), findsNothing);
      expect(find.text('Türkçe'), findsNothing);

      await enterSearch(tester, 'Türkçe');
      expect(find.text('Turco'), findsOneWidget);
      expect(find.text('TR'), findsOneWidget);
      expect(find.text('Türkçe'), findsNothing);
      expect(find.text('Inglés'), findsNothing);

      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Spanish country picker keeps native and English aliases search-only',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      await pumpPickerHost(tester, catalog: catalog);

      await tester.tap(find.text('country-picker'));
      await tester.pumpAndSettle();
      expect(find.text('Seleccionar país'), findsOneWidget);

      await enterSearch(tester, 'Türkiye');
      expect(find.text('Turquía'), findsOneWidget);
      expect(find.text('TR'), findsOneWidget);
      expect(find.text('Türkiye'), findsNothing);
      expect(find.text('Turkey'), findsNothing);

      await enterSearch(tester, 'Deutschland');
      expect(find.text('Alemania'), findsOneWidget);
      expect(find.text('DE'), findsOneWidget);
      expect(find.text('Deutschland'), findsNothing);
      expect(find.text('Germany'), findsNothing);

      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Spanish currency picker displays Spanish currency names for English aliases',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      await pumpPickerHost(tester, catalog: catalog);

      await tester.tap(find.text('currency-picker'));
      await tester.pumpAndSettle();
      expect(find.text('Seleccionar moneda'), findsOneWidget);

      await enterSearch(tester, 'United States dollar');
      expect(find.text('USD · dólar estadounidense'), findsOneWidget);
      expect(find.text('United States dollar'), findsNothing);
      expect(find.text('US dollar'), findsNothing);
      expect(find.text('dólar estadounidense'), findsNothing);

      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
