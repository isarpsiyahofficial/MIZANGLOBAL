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

  Future<BuildContext> pumpHost(WidgetTester tester) async {
    const hostKey = ValueKey<String>('picker-host');
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt', 'PT'),
        home: Scaffold(body: SizedBox(key: hostKey)),
      ),
    );
    await renderFrame(tester);
    return tester.element(find.byKey(hostKey));
  }

  Future<void> search(WidgetTester tester, String value) async {
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, value);
    await renderFrame(tester);
  }

  Future<void> closeDialog<T>(
    WidgetTester tester,
    Future<T?> routeFuture,
  ) async {
    final dialogContext = tester.element(find.byType(Dialog));
    Navigator.of(dialogContext).pop();
    await renderFrame(tester);
    await routeFuture.timeout(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets(
    'pt-PT language picker shows only European Portuguese names while aliases remain searchable',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      final context = await pumpHost(tester);
      final routeFuture = showLanguagePicker(
        context,
        catalog: catalog,
        selectedCode: 'pt-PT',
      );
      await renderFrame(tester);

      expect(find.text('Selecionar idioma'), findsOneWidget);
      expect(rowText('português (Portugal)'), findsOneWidget);
      expect(rowText('português (Brasil)'), findsOneWidget);
      expect(rowText('turco'), findsOneWidget);
      expect(rowText('inglês'), findsOneWidget);
      expect(rowText('espanhol'), findsOneWidget);
      expect(rowText('Português (Portugal)'), findsNothing);
      expect(rowText('Türkçe'), findsNothing);
      expect(rowText('English'), findsNothing);
      expect(rowText('Español'), findsNothing);

      await search(tester, 'Türkçe');
      expect(rowText('turco'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('Türkçe'), findsNothing);
      expect(rowText('inglês'), findsNothing);

      await closeDialog(tester, routeFuture);
    },
  );

  testWidgets(
    'pt-PT country picker keeps native English Spanish and pt-BR names search-only',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      final context = await pumpHost(tester);
      final routeFuture = showCountryPicker(
        context,
        catalog: catalog,
        selectedCode: 'PT',
      );
      await renderFrame(tester);
      expect(find.text('Selecionar país'), findsOneWidget);

      await search(tester, 'Türkiye');
      expect(rowText('Turquia'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('Türkiye'), findsNothing);
      expect(rowText('Turkey'), findsNothing);
      expect(rowText('Turquía'), findsNothing);

      await search(tester, 'Deutschland');
      expect(rowText('Alemanha'), findsOneWidget);
      expect(rowText('DE'), findsOneWidget);
      expect(rowText('Deutschland'), findsNothing);
      expect(rowText('Germany'), findsNothing);
      expect(rowText('Alemania'), findsNothing);

      await closeDialog(tester, routeFuture);
    },
  );

  testWidgets(
    'pt-PT currency picker displays European Portuguese names for foreign aliases',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      final context = await pumpHost(tester);
      final routeFuture = showCurrencyPicker(
        context,
        catalog: catalog,
        selectedCode: 'EUR',
      );
      await renderFrame(tester);
      expect(find.text('Selecionar moeda'), findsOneWidget);

      await search(tester, 'US Dollar');
      expect(rowText('USD · dólar dos Estados Unidos'), findsOneWidget);
      expect(rowText('US Dollar'), findsNothing);
      expect(rowText('United States Dollar'), findsNothing);
      expect(rowText('dólar estadounidense'), findsNothing);
      expect(rowText('dólar americano'), findsNothing);

      await closeDialog(tester, routeFuture);
    },
  );
}
