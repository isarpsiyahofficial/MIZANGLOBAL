import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fr.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('French source contains exactly 791 reviewed static values', () {
    expect(mizanFrench.length, 791);
    expect(
      mizanFrench.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('French is enabled and regional aliases resolve to fr', () {
    expect(MizanI18n.isSupported('fr'), isTrue);
    expect(MizanI18n.isSupported('fr-FR'), isTrue);
    expect(MizanI18n.isSupported('fr_FR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('FR_fr'), 'fr');
  });

  test('French uses native France-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'EUR');

    expect(MizanI18n.text('Ana sayfa'), 'Accueil');
    expect(MizanI18n.text('Kayıtlar'), 'Dossiers');
    expect(MizanI18n.text('Ayarlar'), 'Paramètres');
    expect(MizanI18n.text('Kaydet'), 'Enregistrer');
    expect(MizanI18n.text('Sil'), 'Supprimer');
    expect(MizanI18n.text('Gelir'), 'Revenu');
    expect(MizanI18n.text('Abonelik'), 'Abonnement');
    expect(MizanI18n.text('Ev kredisi'), 'Crédit immobilier');
    expect(MizanI18n.text('KMH hesabı'), 'Compte avec découvert autorisé');
    expect(MizanI18n.text('Senet'), 'Billet à ordre');
    expect(MizanI18n.destructiveConfirmation, 'JE CONFIRME');
  });

  test('French dynamic copy applies singular plural and agreement', () {
    MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Il reste 1 jour');
    expect(MizanI18n.text('3 gün kaldı'), 'Il reste 3 jours');
    expect(MizanI18n.text('Ayın 1. günü'), 'Le 1er du mois');
    expect(MizanI18n.text('Ayın 2. günü'), 'Le 2 du mois');
    expect(MizanI18n.text('1 kişi seçili'), '1 personne sélectionnée');
    expect(MizanI18n.text('2 kişi seçili'), '2 personnes sélectionnées');
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 nouvel élément ; 1 lien mis à jour.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 nouveaux éléments ont été ajoutés ; les données existantes ont été conservées.',
    );
  });

  test('French number date and currency formats follow France conventions', () {
    MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'EUR');

    expect(money(1234567.5), '1\u202F234\u202F567,50\u00A0€');
    expect(decimalText(1250.5), '1250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 août 2026');
    expect(monthLabel(DateTime(2026, 8)), 'août 2026');

    MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'USD');
    expect(money(1234.5), '1\u202F234,50\u00A0USD');
  });

  test(
    'French catalogs display names and retain multilingual aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('fr').nameFor('fr'), 'français');
      expect(catalog.language('pt-PT').nameFor('fr'), 'portugais (Portugal)');
      expect(catalog.country('FR').nameFor('fr'), 'France');
      expect(catalog.country('TR').nameFor('fr'), 'Turquie');
      expect(catalog.currency('EUR').nameFor('fr'), 'euro');
      expect(catalog.currency('USD').nameFor('fr'), 'dollar des États-Unis');
      expect(
        catalog.currencies
            .where((item) => item.matches('dollar etats'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('fr'),
        'dollar des États-Unis',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('US Dollar'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('fr'),
        'dollar des États-Unis',
      );
    },
  );

  test('French never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'EUR');
    final userName = MizanI18n.user('Paramètres Banque');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Paramètres Banque');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Paramètres Banque · Dette totale restante',
    );
  });
}
