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
    await _tapNavigation(tester, Icons.settings_outlined);

    expect(find.text('Pil optimizasyonu'), findsNothing);
    expect(find.textContaining('örnek kayıtlarla sıfırla'), findsNothing);
    expect(find.text('Bildirim sistemi'), findsNothing);
    expect(find.text('Otomatik senkronizasyon'), findsNothing);
    expect(find.textContaining('özel bildirim saati'), findsNothing);
    expect(find.text('Ses ve titreşim'), findsNothing);
    final exportButton = find.text('CSV yedeğini dışa aktar');
    await tester.scrollUntilVisible(
      exportButton,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(exportButton, findsOneWidget);
    expect(
      find.text('CSV yedeğini mevcut verilerle birleştir'),
      findsOneWidget,
    );
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
    expect(find.text('Günlük'), findsNothing);
    expect(find.text('Haftalık'), findsNothing);
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

    // This app fixture intentionally has no MonetizationScope. It therefore
    // represents a free user: the real PDF export actions must remain absent,
    // while the PRO lock/sample-preview surface is present.
    expect(find.byKey(const ValueKey('pdf-pro-locked')), findsOneWidget);
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kayıt sahibi özet kartları ayrıntı listesini açar', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await tester.tap(find.text('Kayıt sahibi'));
    await tester.pumpAndSettle();
    expect(find.text('Kayıt sahibi ayrıntıları'), findsOneWidget);
    expect(find.text('İbrahim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapor kalan ve gecikmiş kartları ayrıntı açar', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.bar_chart_outlined);
    await tester.tap(find.text('Kalan ödeme yükü').first);
    await tester.pumpAndSettle();
    expect(find.text('Kalan ödeme yükü ayrıntısı'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gecikmiş').first);
    await tester.pumpAndSettle();
    expect(find.text('Gecikmiş ödeme ayrıntısı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gider araması günü açar ve Türkçe eşleşme yapar', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.shopping_bag_outlined);
    final search = find.byKey(const ValueKey('expense-search-field'));
    await tester.enterText(search, 'alisveris');
    await tester.pumpAndSettle();
    expect(find.text('Alışveriş'), findsOneWidget);
    await tester.tap(find.text('Alışveriş'));
    await tester.pumpAndSettle();
    expect(find.text('Gider ayrıntısı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fatura ve kira formları aylık gün mantığını kullanır', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _scrollTap(tester, 'Fatura');
    await tester.tap(find.text('Yeni fatura'));
    await tester.pumpAndSettle();
    expect(find.text('Ödeme günü'), findsOneWidget);
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _scrollTap(tester, 'Kira ve Taksitler');
    await tester.tap(find.text('Yeni kira / taksit'));
    await tester.pumpAndSettle();
    expect(find.text('Ödeme günü'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yeni kişisel borç ve abonelik formları doğru alanları açar', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _scrollTap(tester, 'Kişisel ve Kurumsal Borçlar');
    await tester.tap(find.text('Yeni borç'));
    await tester.pumpAndSettle();
    expect(find.text('Alacaklı türü'), findsOneWidget);
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _scrollTap(tester, 'Abonelikler');
    await tester.tap(find.text('Yeni abonelik'));
    await tester.pumpAndSettle();
    expect(find.text('Abonelik türü'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kişi işlemleri kişi detayları alanında toplanır', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await tester.tap(find.text('Kişi detaylarını aç'));
    await tester.pumpAndSettle();
    expect(find.text('Kişi ayrıntıları'), findsOneWidget);
    expect(find.text('Kişiyi düzenle'), findsOneWidget);
    expect(find.text('Kişiyi sil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('banka borcu formu tarih yöntemi seçtirir', (tester) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _scrollTap(tester, 'Banka Borçları');
    await tester.tap(find.text('Yeni banka borcu'));
    await tester.pumpAndSettle();
    expect(find.text('Vade yöntemi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ödeme ekleme türü taksit kapama ve kısmi ödeme sunar', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _scrollTap(tester, 'Kart borcu');
    await tester.tap(find.text('Ödeme ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Ödeme türü'), findsOneWidget);
    expect(find.text('Taksit kapama'), findsOneWidget);
    expect(find.text('Kısmi ödeme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapor kişi filtresi belirli kişileri çoklu seçtirir', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.bar_chart_outlined);
    await tester.tap(find.text('Kişiler'));
    await tester.pumpAndSettle();
    expect(find.text('Rapor kişileri'), findsOneWidget);
    expect(find.text('İbrahim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shipping ayarlarında bildirim sistemi tamamen yoktur', (
    tester,
  ) async {
    await _pump(tester, comprehensiveState(reference: DateTime.now()));
    await _tapNavigation(tester, Icons.settings_outlined);
    expect(find.text('Bildirim sistemi'), findsNothing);
    expect(find.text('Ödeme hatırlatması 1'), findsNothing);
    expect(find.text('Hatırlatmayı düzenle'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
