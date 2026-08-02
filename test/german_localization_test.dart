import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_de.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('German source contains exactly 791 reviewed static values', () {
    expect(mizanGerman.length, 791);
    expect(
      mizanGerman.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('German is enabled and regional aliases resolve to de', () {
    expect(MizanI18n.isSupported('de'), isTrue);
    expect(MizanI18n.isSupported('de-DE'), isTrue);
    expect(MizanI18n.isSupported('de_DE'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('DE_de'), 'de');
  });

  test('German uses native Germany-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'de', currencyCode: 'EUR');

    expect(MizanI18n.text('Ana sayfa'), 'Startseite');
    expect(MizanI18n.text('Kayıtlar'), 'Einträge');
    expect(MizanI18n.text('Ayarlar'), 'Einstellungen');
    expect(MizanI18n.text('Kaydet'), 'Speichern');
    expect(MizanI18n.text('Sil'), 'Löschen');
    expect(MizanI18n.text('Gelir'), 'Einnahme');
    expect(MizanI18n.text('Abonelik'), 'Abonnement');
    expect(MizanI18n.text('Ev kredisi'), 'Immobilienkredit');
    expect(MizanI18n.text('KMH hesabı'), 'Dispositionskreditkonto');
    expect(MizanI18n.text('Senet'), 'Schuldschein');
    expect(MizanI18n.destructiveConfirmation, 'ICH BESTÄTIGE');
  });

  test('German dynamic copy applies singular plural and case', () {
    MizanI18n.setProfile(languageTag: 'de', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Noch 1 Tag');
    expect(MizanI18n.text('3 gün kaldı'), 'Noch 3 Tage');
    expect(
      MizanI18n.text('Miete için 1 gün kaldı'),
      'Bis Miete verbleibt 1 Tag',
    );
    expect(
      MizanI18n.text('Miete için 2 gün kaldı'),
      'Bis Miete verbleiben 2 Tage',
    );
    expect(MizanI18n.text('Ayın 1. günü'), 'Am 1. des Monats');
    expect(MizanI18n.text('Ayın 2. günü'), 'Am 2. des Monats');
    expect(MizanI18n.text('1 kişi seçili'), '1 Person ausgewählt');
    expect(MizanI18n.text('2 kişi seçili'), '2 Personen ausgewählt');
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 neuer Eintrag; 1 Beziehung aktualisiert.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 neue Einträge wurden hinzugefügt; vorhandene Daten blieben erhalten.',
    );
    expect(
      MizanI18n.text(
        'Bildirim planındaki 1 kayıt Android sistemine yazılamadı. İlk hata: X',
      ),
      '1 Eintrag aus dem Benachrichtigungsplan konnte nicht in Android geschrieben werden. Erster Fehler: X',
    );
    expect(
      MizanI18n.text(
        'Bildirim planı doğrulanamadı; Android tarafında 1 kayıt eksik kaldı.',
      ),
      'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlt 1 Eintrag.',
    );
  });

  test('German number date and currency formats follow de-DE conventions', () {
    MizanI18n.setProfile(languageTag: 'de', currencyCode: 'EUR');

    expect(money(1234567.5), '1.234.567,50\u00A0€');
    expect(decimalText(1250.5), '1250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1. Aug. 2026');
    expect(monthLabel(DateTime(2026, 8)), 'August 2026');

    MizanI18n.setProfile(languageTag: 'de', currencyCode: 'USD');
    expect(money(1234.5), '1.234,50\u00A0USD');
  });

  test(
    'German catalogs display names and retain multilingual aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'de', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('de').nameFor('de'), 'Deutsch');
      expect(
        catalog.language('pt-PT').nameFor('de'),
        'Portugiesisch (Portugal)',
      );
      expect(catalog.country('DE').nameFor('de'), 'Deutschland');
      expect(catalog.country('TR').nameFor('de'), 'Türkei');
      expect(catalog.currency('EUR').nameFor('de'), 'Euro');
      expect(catalog.currency('USD').nameFor('de'), 'US-Dollar');
      expect(
        catalog.currencies
            .where((item) => item.matches('amerikanischer dollar'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('de'),
        'US-Dollar',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('US Dollar'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('de'),
        'US-Dollar',
      );
    },
  );

  test('German never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'de', currencyCode: 'EUR');
    final userName = MizanI18n.user('Einstellungen Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Einstellungen Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Einstellungen Bank · Verbleibende Gesamtschuld',
    );
  });
}
