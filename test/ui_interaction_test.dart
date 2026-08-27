import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/expense_browser_service.dart';

import 'test_support.dart';

Future<MizanController> _pump(
  WidgetTester tester,
  MizanState state, {
  Size size = const Size(412, 915),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = MizanController(
    MemoryStore(state),
    scheduler: SpyScheduler(),
  );
  await controller.load();
  await tester.pumpWidget(MizanApp(controller: controller));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return controller;
}

Future<void> _tapNavigation(WidgetTester tester, IconData icon) async {
  final navigation = find.byType(NavigationBar);
  final rail = find.byType(NavigationRail);
  final root = navigation.evaluate().isNotEmpty ? navigation : rail;
  final target = find.descendant(of: root, matching: find.byIcon(icon));
  expect(target, findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _scrollTap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.scrollUntilVisible(
    target,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gelir girilmediyse ana sayfa bunu açıkça belirtir', (
    tester,
  ) async {
    await _pump(tester, MizanState.empty());
    expect(find.text('Gelir bilgisi belirtilmemiş'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kalan toplam borç kartı bölüm detaylarını açar', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await tester.tap(find.text('Kalan toplam borç'));
    await tester.pumpAndSettle();

    expect(find.text('Kalan toplam borç detayı'), findsOneWidget);
    expect(find.text('Banka borçları'), findsOneWidget);
    expect(find.text('Kişisel ve kurumsal borçlar'), findsOneWidget);
    expect(find.text('Fatura'), findsOneWidget);
    expect(find.text('Abonelikler'), findsOneWidget);
    expect(find.text('Kira ve taksitler'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Abonelikler ana sayfada doğrudan görünür ve kayıtları açar', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    final subscriptions = find.byKey(const ValueKey('dashboard-subscriptions'));
    await tester.scrollUntilVisible(
      subscriptions,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(subscriptions, findsOneWidget);
    expect(
      find.descendant(of: subscriptions, matching: find.text('Abonelikler')),
      findsOneWidget,
    );

    await tester.tap(subscriptions);
    await tester.pumpAndSettle();
    expect(find.text('Dijital hizmet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kritik ödemeye dokununca doğru kayıt ayrıntısı açılır', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _scrollTap(tester, 'Kart borcu');

    expect(find.text('Kalan borç'), findsOneWidget);
    final paymentHistory = find.text('Ödeme geçmişi');
    await tester.scrollUntilVisible(
      paymentHistory,
      220,
      scrollable: find.byType(Scrollable).last,
    );
    expect(paymentHistory, findsOneWidget);
    expect(find.text('Ödeme ekle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kayıtlar ekranı kişiyi ve beş grubu açık biçimde ayırır', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);

    expect(find.text('Kayıt sahibi'), findsOneWidget);
    for (final title in const [
      'Banka Borçları',
      'Kişisel ve Kurumsal Borçlar',
      'Fatura',
      'Abonelikler',
      'Kira ve Taksitler',
    ]) {
      final target = find.text(title);
      await tester.scrollUntilVisible(
        target,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(target, findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ayarlar ekranında tehlikeli sıfırlama ve pil menüsü yoktur', (
    tester,
  ) async {
    await _pump(tester, MizanState.empty());
    await _tapNavigation(tester, Icons.storefront_outlined);
    final settingsAction = find.byKey(const ValueKey('store-open-settings'));
    if (settingsAction.evaluate().isNotEmpty) {
      await tester.tap(settingsAction);
      await tester.pumpAndSettle();
    }

    expect(find.text('Pil optimizasyonu'), findsNothing);
    expect(find.textContaining('örnek kayıtlarla sıfırla'), findsNothing);
    expect(find.text('Bildirim sistemi'), findsNothing);
    expect(find.text('Otomatik senkronizasyon'), findsNothing);
    expect(find.textContaining('özel bildirim saati'), findsNothing);
    expect(find.text('Ses ve titreşim'), findsNothing);
    final backupLock = find.byKey(const ValueKey('backup-pro-locked'));
    await tester.scrollUntilVisible(
      backupLock,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(backupLock, findsOneWidget);
    expect(
      find.byKey(const ValueKey('backup-pro-lock-banner')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('backup-export-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('backup-import-enabled')), findsNothing);
    expect(find.text('Anlık yerel kayıt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Giderler ve Raporlar ilk bakışta sade başlıklarla açılır', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.shopping_bag_outlined);
    expect(find.text('Giderler'), findsWidgets);
    expect(find.text('Bugün'), findsOneWidget);
    expect(find.text('Bu ay'), findsWidgets);
    expect(find.text('Filtreleme ve arama'), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-search-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-day-sort')), findsOneWidget);
    final dailyExpenses = find.text('Günlük harcamalar');
    await tester.scrollUntilVisible(
      dailyExpenses,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(dailyExpenses, findsOneWidget);
    expect(find.text('Ödemeler'), findsWidgets);
    expect(find.text('Bütün harcamalar'), findsWidgets);

    await _tapNavigation(tester, Icons.bar_chart_outlined);
    expect(find.text('Rapor kapsamı'), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);
    expect(find.text('Haftalık'), findsOneWidget);
    expect(find.text('Aylık'), findsOneWidget);
    expect(find.text('Yıllık'), findsOneWidget);
    expect(find.text('Tüm zamanlar'), findsOneWidget);
    await tester.tap(find.text('Tüm zamanlar'));
    await tester.pumpAndSettle();
    expect(find.text('Tüm kayıt geçmişi'), findsOneWidget);
    expect(find.textContaining('İlk kayıttan bugüne kadar'), findsOneWidget);
    await tester.tap(find.text('Aylık'));
    await tester.pumpAndSettle();
    expect(find.text(monthLabel(DateTime.now())), findsOneWidget);
    final pdfLock = find.byKey(const ValueKey('pdf-pro-locked'));
    await tester.scrollUntilVisible(
      pdfLock,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(pdfLock, findsOneWidget);
    expect(find.byKey(const ValueKey('pdf-preview-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('pdf-save-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('pdf-share-enabled')), findsNothing);
    final combinedReport = find.textContaining(
      'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit',
    );
    await tester.scrollUntilVisible(
      combinedReport,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(combinedReport, findsOneWidget);
    final actualPayments = find.text('Gerçekleşen harcamaların dağılımı');
    await tester.scrollUntilVisible(
      actualPayments,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(actualPayments, findsOneWidget);
    final distribution = find.text('Kalan ödeme yükünün dağılımı');
    await tester.scrollUntilVisible(
      distribution,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(distribution, findsOneWidget);
    final expenseDistribution = find.text('Gider dağılımı');
    await tester.scrollUntilVisible(
      expenseDistribution,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(expenseDistribution, findsOneWidget);
    expect(find.text('Kalan taksit sayıları'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kayıt sahibi özet kartları ayrıntı listesini açar', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);

    await tester.tap(find.text('Kalan toplam'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kalan toplam'), findsWidgets);
    expect(find.textContaining('Toplam'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapor kalan ve gecikmiş kartları ayrıntı açar', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.bar_chart_outlined);

    final remaining = find.text('Kalan ödeme yükü');
    await tester.scrollUntilVisible(
      remaining,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    final remainingCard = find.ancestor(
      of: remaining,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(remainingCard);
    await tester.pumpAndSettle();
    await tester.tap(remainingCard);
    await tester.pumpAndSettle();
    expect(find.text('Kalan ödeme yükü ayrıntıları'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gider araması günü açar ve Türkçe eşleşme yapar', (
    tester,
  ) async {
    final today = dateOnly(DateTime.now());
    final previousDay = today.subtract(const Duration(days: 1));
    final state = comprehensiveState(reference: today).copyWith(
      expenses: [
        ExpenseItem(
          id: 'expense-vehicle',
          categoryId: 'category-1',
          name: 'Araç Sigortası',
          quantity: 1,
          unitPrice: 9800,
          spentAt: today,
        ),
        ExpenseItem(
          id: 'expense-yogurt',
          categoryId: 'category-1',
          name: 'Yoğurt+Tuz+Sandviç',
          quantity: 1,
          unitPrice: 300,
          spentAt: previousDay,
        ),
      ],
    );
    await _pump(tester, state);
    await _tapNavigation(tester, Icons.shopping_bag_outlined);

    final search = find.byKey(const ValueKey('expense-search-field'));
    await tester.enterText(search, 'arac');
    await tester.pumpAndSettle();
    final matchingDay = find.text(
      const ExpenseBrowserService().dayLabel(today),
    );
    final expenseScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      matchingDay,
      180,
      scrollable: expenseScrollable,
    );
    await tester.drag(expenseScrollable, const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(matchingDay, findsOneWidget);
    final matchingDayHeader = find.ancestor(
      of: matchingDay,
      matching: find.byType(InkWell),
    );
    expect(matchingDayHeader, findsOneWidget);
    await tester.tap(matchingDayHeader);
    await tester.pumpAndSettle();
    expect(find.text('Araç Sigortası'), findsOneWidget);
    expect(find.text('Yoğurt+Tuz+Sandviç'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fatura ve kira formları aylık gün mantığını kullanır', (
    tester,
  ) async {
    await _pump(
      tester,
      MizanState(
        people: const [PersonAccount(id: 'p', name: 'Kişi')],
        expenseCategories: const [],
        expenses: const [],
      ),
      size: const Size(500, 1200),
    );
    await _tapNavigation(tester, Icons.people_alt_outlined);

    await _scrollTap(tester, 'Fatura');
    await tester.tap(find.text('Fatura ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Fatura düzeni'), findsOneWidget);
    expect(find.byKey(const ValueKey('bill-payment-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('bill-period-amount')), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    await _scrollTap(tester, 'Kira ve Taksitler');
    await tester.tap(find.text('Kira / taksit ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Kayıt türü'), findsOneWidget);
    expect(find.byKey(const ValueKey('rent-payment-day')), findsOneWidget);
    expect(find.text('İlk ödeme ayı'), findsOneWidget);
    expect(find.text('Son ödeme tarihi'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yeni kişisel borç ve abonelik formları doğru alanları açar', (
    tester,
  ) async {
    await _pump(
      tester,
      MizanState(
        people: const [PersonAccount(id: 'p', name: 'Kişi')],
        expenseCategories: const [],
        expenses: const [],
      ),
      size: const Size(500, 1200),
    );
    await _tapNavigation(tester, Icons.people_alt_outlined);

    await _scrollTap(tester, 'Kişisel ve Kurumsal Borçlar');
    await tester.tap(find.text('Kişisel / kurumsal borç ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Alacaklı türü'), findsOneWidget);
    expect(find.text('Borç başlığı'), findsOneWidget);
    expect(find.text('Son ödeme tarihi'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    await _scrollTap(tester, 'Abonelikler');
    await tester.tap(find.text('Abonelik ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Abonelik türü'), findsOneWidget);
    expect(find.text('Sıradaki ödeme tarihi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kişi işlemleri kişi detayları alanında toplanır', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);

    expect(find.text('Kişiyi düzenle'), findsNothing);
    expect(find.text('Kişiyi sil'), findsNothing);
    final personDetailsButton = find.widgetWithText(
      FilledButton,
      'Kişi detaylarını aç',
    );
    await tester.scrollUntilVisible(
      personDetailsButton,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(personDetailsButton);
    await tester.pumpAndSettle();
    await tester.tap(personDetailsButton);
    await tester.pumpAndSettle();

    expect(find.text('Kişi detayları'), findsOneWidget);
    final detailScrollable = find.byType(Scrollable).last;
    final bankRecord = find.text('Kart borcu');
    await tester.scrollUntilVisible(
      bankRecord,
      220,
      scrollable: detailScrollable,
    );
    expect(bankRecord, findsOneWidget);
    final personalRecord = find.text('Senet ödemesi');
    await tester.scrollUntilVisible(
      personalRecord,
      220,
      scrollable: detailScrollable,
    );
    expect(personalRecord, findsOneWidget);
    final editPerson = find.text('Kişiyi düzenle');
    await tester.scrollUntilVisible(
      editPerson,
      220,
      scrollable: detailScrollable,
    );
    expect(editPerson, findsOneWidget);
    final deletePerson = find.text('Kişiyi sil');
    await tester.scrollUntilVisible(
      deletePerson,
      120,
      scrollable: detailScrollable,
    );
    expect(deletePerson, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('banka borcu formu tarih yöntemi seçtirir', (tester) async {
    final state = comprehensiveState(reference: DateTime.now());
    final controller = await _pump(tester, state, size: const Size(500, 1200));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    final bankTitle = find.text('Kullanıcının bankası');
    await tester.scrollUntilVisible(
      bankTitle,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(bankTitle, findsOneWidget);
    final bankActions = find.byTooltip('Banka grubu işlemleri');
    await tester.ensureVisible(bankActions);
    await tester.tap(bankActions);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borç ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Borç ürünü ekle'), findsOneWidget);

    expect(find.text('Ödeme tarihi yöntemi'), findsOneWidget);
    expect(find.text('Son ödeme tarihi'), findsWidgets);
    await tester.tap(find.text('Son ödeme tarihi').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Her ayın belirli günü').last);
    await tester.pumpAndSettle();
    expect(find.text('Her ayın kaçıncı günü?'), findsOneWidget);
    expect(controller.state.people.single.banks.single.products, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ödeme ekleme türü taksit kapama ve kısmi ödeme sunar', (
    tester,
  ) async {
    await _pump(
      tester,
      comprehensiveState(reference: DateTime.now()),
      size: const Size(500, 1200),
    );
    await _scrollTap(tester, 'Kart borcu');
    final addPayment = find.text('Ödeme ekle');
    await tester.scrollUntilVisible(
      addPayment,
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(addPayment);
    await tester.pumpAndSettle();

    expect(find.text('Ödeme türü'), findsOneWidget);
    expect(find.text('Taksit ödemesi'), findsOneWidget);
    expect(find.text('Kalan tutar: 9.000,00 TL'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);

    await tester.tap(find.text('Taksit ödemesi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borç kapama').last);
    await tester.pumpAndSettle();
    expect(find.text('9000'), findsOneWidget);

    await tester.tap(find.text('Borç kapama'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kısmi ödeme').last);
    await tester.pumpAndSettle();
    final amountField = find.widgetWithText(TextFormField, 'Ödeme tutarı');
    expect(amountField, findsOneWidget);
    await tester.enterText(amountField, '750');
    expect(find.text('750'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapor kişi filtresi belirli kişileri çoklu seçtirir', (
    tester,
  ) async {
    final base = comprehensiveState(reference: DateTime.now());
    final state = base.copyWith(
      people: [
        ...base.people,
        const PersonAccount(id: 'person-2', name: 'Ayşe'),
      ],
    );
    await _pump(tester, state);
    await _tapNavigation(tester, Icons.bar_chart_outlined);
    final peopleFilterButton = find.widgetWithText(
      OutlinedButton,
      'Tüm kişiler',
    );
    await tester.scrollUntilVisible(
      peopleFilterButton,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(peopleFilterButton);
    await tester.pumpAndSettle();
    await tester.tap(peopleFilterButton);
    await tester.pumpAndSettle();
    expect(find.text('Kişi kapsamı'), findsOneWidget);
    expect(find.text('Tüm kişileri kapsa'), findsOneWidget);
    expect(find.text('İbrahim'), findsOneWidget);
    expect(find.text('Ayşe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('shipping ayarlarında bildirim sistemi tamamen yoktur', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.storefront_outlined);
    final settingsAction = find.byKey(const ValueKey('store-open-settings'));
    if (settingsAction.evaluate().isNotEmpty) {
      await tester.tap(settingsAction);
      await tester.pumpAndSettle();
    }

    for (final removedCopy in const [
      'Bildirim sistemi',
      'Bildirim izni',
      'Dakik bildirim izni',
      'Planlanan bildirim',
      'Otomatik senkronizasyon',
      'Bildirimleri yeniden planla',
      'Bildirim izinlerini aç',
      'Dakik bildirim iznini aç',
      'Ödeme hatırlatması 1',
      'Hatırlatmayı düzenle',
      '1 dakika sonra test bildirimi',
      'Ses ve titreşim',
    ]) {
      expect(find.text(removedCopy), findsNothing, reason: removedCopy);
    }
    expect(find.text('Anlık yerel kayıt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
