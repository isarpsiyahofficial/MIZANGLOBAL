import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_el.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Greek source contains exactly 791 reviewed static values', () {
    expect(mizanGreek.length, 791);
    expect(mizanGreek.values.every((value) => value.trim().isNotEmpty), isTrue);
  });

  test('Greek is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('el'), isTrue);
    expect(MizanI18n.isSupported('el-GR'), isTrue);
    expect(MizanI18n.isSupported('el_GR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('EL_gr'), 'el');
  });

  test('Greek uses Greece-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');

    expect(MizanI18n.text('Ana sayfa'), 'Αρχική');
    expect(MizanI18n.text('Kayıtlar'), 'Εγγραφές');
    expect(MizanI18n.text('Ayarlar'), 'Ρυθμίσεις');
    expect(MizanI18n.text('Kaydet'), 'Αποθήκευση');
    expect(MizanI18n.text('Sil'), 'Διαγραφή');
    expect(MizanI18n.text('Gelir'), 'Εισόδημα');
    expect(MizanI18n.text('Abonelik'), 'Συνδρομή');
    expect(MizanI18n.text('Ev kredisi'), 'Στεγαστικό δάνειο');
    expect(MizanI18n.text('KMH hesabı'), 'Λογαριασμός υπερανάληψης');
    expect(MizanI18n.text('Çek'), 'Επιταγή');
    expect(MizanI18n.text('Senet'), 'Γραμμάτιο');
    expect(MizanI18n.destructiveConfirmation, 'ΕΠΙΒΕΒΑΙΩΝΩ');
  });

  test('Greek dynamic copy applies singular and plural forms', () {
    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Απομένει 1 ημέρα');
    expect(MizanI18n.text('3 gün kaldı'), 'Απομένουν 3 ημέρες');
    expect(
      MizanI18n.text('Ενοίκιο için 1 gün kaldı'),
      'Απομένει 1 ημέρα έως Ενοίκιο',
    );
    expect(
      MizanI18n.text('Ενοίκιο için 2 gün kaldı'),
      'Απομένουν 2 ημέρες έως Ενοίκιο',
    );
    expect(MizanI18n.text('Ayın 1. günü'), '1η ημέρα του μήνα');
    expect(MizanI18n.text('Her ayın 2. günü'), 'Την 2η ημέρα κάθε μήνα');
    expect(MizanI18n.text('1 kişi seçili'), 'Επιλέχθηκε 1 πρόσωπο');
    expect(MizanI18n.text('2 kişi seçili'), 'Επιλέχθηκαν 2 πρόσωπα');
    expect(
      MizanI18n.text('1 açık kayıt · EUR 20'),
      '1 ανοιχτή εγγραφή · EUR 20',
    );
    expect(
      MizanI18n.text('2 açık kayıt · EUR 20'),
      '2 ανοιχτές εγγραφές · EUR 20',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 νέα εγγραφή· ενημερώθηκε 1 συσχέτιση.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Προστέθηκαν 2 νέες εγγραφές· τα υπάρχοντα δεδομένα διατηρήθηκαν.',
    );
  });

  test('Greek number date and currency formats follow el-GR conventions', () {
    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');

    expect(money(1234567.5), '1.234.567,50\u00A0€');
    expect(decimalText(1250.5), '1.250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 Αυγ 2026');
    expect(monthLabel(DateTime(2026, 3)), 'Μάρτιος 2026');

    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'USD');
    expect(money(1234.5), '1.234,50\u00A0USD');
  });

  test(
    'Greek catalogs display names and retain multilingual aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('el').nameFor('el'), 'Ελληνικά');
      expect(
        catalog.language('pt-PT').nameFor('el'),
        'Πορτογαλικά (Πορτογαλία)',
      );
      expect(catalog.country('GR').nameFor('el'), 'Ελλάδα');
      expect(catalog.country('TR').nameFor('el'), 'Τουρκία');
      expect(catalog.currency('EUR').nameFor('el'), 'ευρώ');
      expect(catalog.currency('USD').nameFor('el'), 'δολάριο ΗΠΑ');
      expect(
        catalog.currencies
            .where((item) => item.matches('αμερικανικό δολάριο'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('el'),
        'δολάριο ΗΠΑ',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('τουρκικές λίρες'))
            .singleWhere((item) => item.code == 'TRY')
            .nameFor('el'),
        'τουρκική λίρα',
      );
    },
  );

  test('Greek never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');
    final userName = MizanI18n.user('Ρυθμίσεις Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Ρυθμίσεις Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Ρυθμίσεις Bank · Συνολικό ανεξόφλητο χρέος',
    );
  });

  test('Greek output does not leak another integrated product language', () {
    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');
    const sources = <String>[
      'Ayarlar',
      'Ödemeler',
      'Giderler',
      'Kişisel ve kurumsal borçlar',
      'CSV yedeğini birleştir',
      'PDF raporu',
      'Gecikmiş ödeme yükü',
    ];
    final visible = sources.map(MizanI18n.text).join(' | ');
    for (final foreign in <String>[
      'Setări',
      'Înregistrări',
      'Cheltuieli',
      'Ustawienia',
      'Płatności',
      'Wydatki',
      'Impostazioni',
      'Pagamenti',
      'Spese',
      'Einstellungen',
      'Zahlungen',
      'Ausgaben',
      'Paramètres',
      'Paiements',
      'Dépenses',
      'Configuración',
      'Pagos',
      'Gastos',
      'Instellingen',
      'Registraties',
      'Uitgaven',
    ]) {
      expect(visible, isNot(contains(foreign)));
    }
  });
}
