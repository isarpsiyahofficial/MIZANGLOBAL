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
        locale: Locale('pt', 'BR'),
        home: Scaffold(body: SizedBox(key: hostKey)),
      ),
    );
    await renderFrame(tester);
    return tester.element(find.byKey(hostKey));
  }

  Future<void> enterSearch(WidgetTester tester, String query) async {
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, query);
    await renderFrame(tester);
  }

  Future<void> closeDialog<T>(
    WidgetTester tester,
    Future<T?> routeFuture,
  ) async {
    Navigator.of(tester.element(find.byType(Dialog))).pop();
    await renderFrame(tester);
    await routeFuture.timeout(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets(
    'pt-BR language picker displays only Portuguese names while every alias remains searchable',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
      final catalog = await GlobalCatalogRepository.load();
      final context = await pumpHost(tester);
      final routeFuture = showLanguagePicker(
        context,
        catalog: catalog,
        selectedCode: 'pt-BR',
      );
      await renderFrame(tester);

      expect(find.text('Selecionar idioma'), findsOneWidget);
      expect(rowText('português (Brasil)'), findsOneWidget);
      expect(rowText('espanhol'), findsOneWidget);
      expect(rowText('inglês'), findsOneWidget);
      expect(rowText('turco'), findsOneWidget);
      expect(rowText('PT-BR'), findsOneWidget);
      expect(rowText('ES'), findsOneWidget);
      expect(rowText('EN'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('English'), findsNothing);
      expect(rowText('Türkçe'), findsNothing);
      expect(rowText('Español'), findsNothing);

      await enterSearch(tester, 'Türkçe');
      expect(rowText('turco'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('Türkçe'), findsNothing);
      expect(rowText('inglês'), findsNothing);

      await closeDialog(tester, routeFuture);
    },
  );

  testWidgets(
    'pt-BR country picker keeps native English and other-language aliases search-only',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
      final catalog = await GlobalCatalogRepository.load();
      final context = await pumpHost(tester);
      final routeFuture = showCountryPicker(
        context,
        catalog: catalog,
        selectedCode: 'BR',
      );
      await renderFrame(tester);
      expect(find.text('Selecionar país'), findsOneWidget);

      await enterSearch(tester, 'Türkiye');
      expect(rowText('Turquia'), findsOneWidget);
      expect(rowText('TR'), findsOneWidget);
      expect(rowText('Türkiye'), findsNothing);
      expect(rowText('Turkey'), findsNothing);
      expect(rowText('Turquía'), findsNothing);

      await enterSearch(tester, 'Deutschland');
      expect(rowText('Alemanha'), findsOneWidget);
      expect(rowText('DE'), findsOneWidget);
      expect(rowText('Deutschland'), findsNothing);
      expect(rowText('Germany'), findsNothing);
      expect(rowText('Alemania'), findsNothing);

      await closeDialog(tester, routeFuture);
    },
  );

  testWidgets(
    'pt-BR currency picker displays Portuguese currency names for foreign aliases',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
      final catalog = await GlobalCatalogRepository.load();
      final context = await pumpHost(tester);
      final routeFuture = showCurrencyPicker(
        context,
        catalog: catalog,
        selectedCode: 'BRL',
      );
      await renderFrame(tester);
      expect(find.text('Selecionar moeda'), findsOneWidget);

      await enterSearch(tester, 'US Dollar');
      expect(rowText('USD · dólar americano'), findsOneWidget);
      expect(rowText('US Dollar'), findsNothing);
      expect(rowText('United States Dollar'), findsNothing);
      expect(rowText('dólar estadounidense'), findsNothing);

      await closeDialog(tester, routeFuture);
    },
  );
}
