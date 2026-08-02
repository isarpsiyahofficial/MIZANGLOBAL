import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('European Portuguese is enabled as an exact regional locale', () {
    expect(MizanI18n.isSupported('pt-PT'), isTrue);
    expect(MizanI18n.isSupported('pt_PT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('PT_pt'), 'pt-PT');
    expect(MizanI18n.isSupported('pt'), isFalse);
  });

  test('pt-PT uses native finance and interface terminology', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    expect(MizanI18n.text('Ayarlar'), 'Definições');
    expect(MizanI18n.text('Kayıtlar'), 'Registos');
    expect(MizanI18n.text('Kaydet'), 'Guardar');
    expect(MizanI18n.text('Sil'), 'Eliminar');
    expect(MizanI18n.text('Gelir'), 'Rendimento');
    expect(MizanI18n.text('Abonelik'), 'Subscrição');
    expect(MizanI18n.text('Ev kredisi'), 'Crédito à habitação');
    expect(MizanI18n.text('Araç kredisi'), 'Crédito automóvel');
    expect(MizanI18n.text('Kira ve Taksitler'), 'Rendas e prestações');
    expect(MizanI18n.destructiveConfirmation, 'CONFIRMO');
    expect(money(1234567.5), '1 234 567,50 €');
    expect(shortDate(DateTime(2026, 8, 1)), '1 ago 2026');
    expect(monthLabel(DateTime(2026, 8)), 'agosto de 2026');
  });

  test(
    'pt-PT catalogs display European Portuguese while aliases remain searchable',
    () async {
      MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();
      expect(
        catalog.language('pt-PT').nameFor('pt-PT'),
        'português (Portugal)',
      );
      expect(catalog.country('PT').nameFor('pt-PT'), 'Portugal');
      expect(catalog.country('TR').nameFor('pt-PT'), 'Turquia');
      expect(catalog.currency('EUR').nameFor('pt-PT'), 'euro');
      expect(
        catalog.currency('USD').nameFor('pt-PT'),
        'dólar dos Estados Unidos',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('US Dollar'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('pt-PT'),
        'dólar dos Estados Unidos',
      );
    },
  );

  test('user-authored text is preserved under pt-PT', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');
    final userName = MizanI18n.user('Configurações Banco');
    final note = MizanI18n.user('Not: Aluguel personalizado');
    expect(MizanI18n.text(userName), 'Configurações Banco');
    expect(MizanI18n.text(note), 'Not: Aluguel personalizado');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Configurações Banco · Dívida total restante',
    );
  });
}
