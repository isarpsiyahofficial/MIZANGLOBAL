import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('pt-PT dynamic grammar uses European Portuguese singular and plural', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Falta 1 dia');
    expect(MizanI18n.text('3 gün kaldı'), 'Faltam 3 dias');
    expect(MizanI18n.text('1 kişi seçili'), '1 pessoa selecionada');
    expect(MizanI18n.text('2 kişi seçili'), '2 pessoas selecionadas');
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 registo novo; 1 ligação atualizada.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 registos novos foram adicionados; os dados existentes foram preservados.',
    );
  });

  test('pt-PT reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(reference: now, currencyCode: 'EUR')
        .copyWith(
          appLanguageTag: 'pt-PT',
          debtRegionCountryCode: 'PT',
          defaultCurrencyCode: 'EUR',
        );
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'pt-PT');
    expect(report.currencyCode, 'EUR');
    expect(report.filter.period.label, 'Mensal');
    expect(report.range.label, 'agosto de 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Despesas'),
    );
    expect(report.selectedPersonNames, contains('İbrahim'));
    expect(report.paymentDetails, isEmpty);
    expect(
      report.remainingDetails.map((item) => item.title),
      contains('Kart borcu'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('\u{E000}')),
      isFalse,
    );
    expect(
      report.remainingDetails.any(
        (item) =>
            item.title.contains('\u{E000}') ||
            item.subtitle.contains('\u{E000}'),
      ),
      isFalse,
    );
  });

  test('pt-PT destructive confirmation accepts only exact CONFIRMO', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'pt-PT',
      debtRegionCountryCode: 'PT',
      defaultCurrencyCode: 'EUR',
    );
    final controller = MizanController(
      MemoryStore(state),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    final categoryId = controller.state.expenseCategories.first.id;

    for (final wrong in const ['ONAYLIYORUM', 'I CONFIRM', 'confirmo']) {
      await expectLater(
        controller.deleteExpenseCategory(
          categoryId: categoryId,
          confirmation: wrong,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isTrue,
    );

    await controller.deleteExpenseCategory(
      categoryId: categoryId,
      confirmation: 'CONFIRMO',
    );
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isFalse,
    );
    expect(
      controller.state.expenses.any((item) => item.categoryId == categoryId),
      isFalse,
    );
    controller.dispose();
  });

  test('pt-PT selection is wired to the complete main-shell vocabulary', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains("'pt-PT' => const Locale('pt', 'PT')"));
    expect(mainSource, contains("Locale('pt', 'PT')"));

    final shellCopy = <String, String>{
      'Ana sayfa': 'Início',
      'Kayıtlar': 'Registos',
      'Giderler': 'Despesas',
      'Raporlar': 'Relatórios',
      'Ayarlar': 'Definições',
      'Uygulama dili': 'Idioma da aplicação',
      'Dil, ülke ve para birimi': 'Idioma, país e moeda',
      'Kişi ekle': 'Adicionar pessoa',
      'Gider ekle': 'Adicionar despesa',
    };

    for (final entry in shellCopy.entries) {
      final localized = MizanI18n.text(entry.key);
      expect(localized, entry.value, reason: entry.key);
      expect(localized, isNot(equals(entry.key)));
    }

    expect(MizanI18n.languageTag, 'pt-PT');
    expect(MizanI18n.currencyCode, 'EUR');
    expect(MizanI18n.text('Ayarlar'), isNot('Configurações'));
    expect(MizanI18n.text('Ana sayfa'), isNot('Home'));
    expect(MizanI18n.text('Kişi ekle'), isNot('Añadir persona'));
  });
}
