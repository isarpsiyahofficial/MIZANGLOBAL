import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Italian source contains exactly 791 reviewed static values', () {
    expect(mizanItalian.length, 791);
    expect(
      mizanItalian.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('Italian is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('it'), isTrue);
    expect(MizanI18n.isSupported('it-IT'), isTrue);
    expect(MizanI18n.isSupported('it_IT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('IT_it'), 'it');
  });

  test('Italian uses native Italy-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'it', currencyCode: 'EUR');

    expect(MizanI18n.text('Ana sayfa'), 'Panoramica');
    expect(MizanI18n.text('Kayıtlar'), 'Registrazioni');
    expect(MizanI18n.text('Ayarlar'), 'Impostazioni');
    expect(MizanI18n.text('Kaydet'), 'Salva');
    expect(MizanI18n.text('Sil'), 'Elimina');
    expect(MizanI18n.text('Gelir'), 'Entrata');
    expect(MizanI18n.text('Abonelik'), 'Abbonamento');
    expect(MizanI18n.text('Ev kredisi'), 'Mutuo');
    expect(MizanI18n.text('KMH hesabı'), 'Conto con scoperto');
    expect(MizanI18n.text('Senet'), 'Cambiale');
    expect(MizanI18n.destructiveConfirmation, 'CONFERMO');
  });

  test('Italian dynamic copy applies number gender and verb agreement', () {
    MizanI18n.setProfile(languageTag: 'it', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Manca 1 giorno');
    expect(MizanI18n.text('3 gün kaldı'), 'Mancano 3 giorni');
    expect(
      MizanI18n.text('Affitto için 1 gün kaldı'),
      'Manca 1 giorno per Affitto',
    );
    expect(
      MizanI18n.text('Affitto için 2 gün kaldı'),
      'Mancano 2 giorni per Affitto',
    );
    expect(MizanI18n.text('Ayın 1. günü'), 'Il giorno 1 del mese');
    expect(MizanI18n.text('Her ayın 2. günü'), 'Il giorno 2 di ogni mese');
    expect(MizanI18n.text('1 kişi seçili'), '1 persona selezionata');
    expect(MizanI18n.text('2 kişi seçili'), '2 persone selezionate');
    expect(
      MizanI18n.text('1 açık kayıt · EUR 20'),
      '1 registrazione aperta · EUR 20',
    );
    expect(
      MizanI18n.text('2 açık kayıt · EUR 20'),
      '2 registrazioni aperte · EUR 20',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 nuova registrazione; 1 collegamento aggiornato.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Sono state aggiunte 2 nuove registrazioni; i dati esistenti sono stati mantenuti.',
    );
    expect(
      MizanI18n.text(
        'Bildirim planındaki 1 kayıt Android sistemine yazılamadı. İlk hata: X',
      ),
      'Non è stato possibile scrivere 1 registrazione del piano notifiche nel sistema Android. Primo errore: X',
    );
    expect(
      MizanI18n.text(
        'Bildirim planı doğrulanamadı; Android tarafında 1 kayıt eksik kaldı.',
      ),
      'Non è stato possibile verificare il piano notifiche; in Android manca 1 registrazione.',
    );
  });

  test('Italian number date and currency formats follow it-IT conventions', () {
    MizanI18n.setProfile(languageTag: 'it', currencyCode: 'EUR');

    expect(money(1234567.5), '1.234.567,50\u00A0€');
    expect(decimalText(1250.5), '1250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 ago 2026');
    expect(monthLabel(DateTime(2026, 8)), 'agosto 2026');

    MizanI18n.setProfile(languageTag: 'it', currencyCode: 'USD');
    expect(money(1234.5), '1.234,50\u00A0USD');
  });

  test('Italian catalogs display names and retain multilingual aliases', () async {
    MizanI18n.setProfile(languageTag: 'it', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    expect(catalog.language('it').nameFor('it'), 'italiano');
    expect(catalog.language('pt-PT').nameFor('it'), 'portoghese (Portogallo)');
    expect(catalog.country('IT').nameFor('it'), 'Italia');
    expect(catalog.country('TR').nameFor('it'), 'Turchia');
    expect(catalog.currency('EUR').nameFor('it'), 'euro');
    expect(catalog.currency('USD').nameFor('it'), 'dollaro statunitense');
    expect(
      catalog.currencies
          .where((item) => item.matches('dollaro americano'))
          .singleWhere((item) => item.code == 'USD')
          .nameFor('it'),
      'dollaro statunitense',
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('US dollar'))
          .singleWhere((item) => item.code == 'USD')
          .nameFor('it'),
      'dollaro statunitense',
    );
  });

  test('Italian never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'it', currencyCode: 'EUR');
    final userName = MizanI18n.user('Impostazioni Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Impostazioni Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Impostazioni Bank · Debito residuo totale',
    );
  });
}
