import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/local_store.dart';

import 'test_support.dart';

class _LocaleCase {
  const _LocaleCase(this.tag, this.country, this.currency);

  final String tag;
  final String country;
  final String currency;
}

const _localeCases = <_LocaleCase>[
  _LocaleCase('tr', 'TR', 'TRY'),
  _LocaleCase('en', 'US', 'USD'),
  _LocaleCase('es', 'ES', 'EUR'),
  _LocaleCase('pt-BR', 'BR', 'BRL'),
  _LocaleCase('pt-PT', 'PT', 'EUR'),
  _LocaleCase('fr', 'FR', 'EUR'),
  _LocaleCase('de', 'DE', 'EUR'),
  _LocaleCase('it', 'IT', 'EUR'),
  _LocaleCase('nl', 'NL', 'EUR'),
  _LocaleCase('pl', 'PL', 'PLN'),
  _LocaleCase('ro', 'RO', 'RON'),
  _LocaleCase('el', 'GR', 'EUR'),
  _LocaleCase('ru', 'RU', 'RUB'),
  _LocaleCase('uk', 'UA', 'UAH'),
  _LocaleCase('ar', 'SA', 'SAR'),
  _LocaleCase('fa', 'IR', 'IRR'),
  _LocaleCase('he', 'IL', 'ILS'),
  _LocaleCase('hi', 'IN', 'INR'),
  _LocaleCase('bn', 'BD', 'BDT'),
  _LocaleCase('ur', 'PK', 'PKR'),
  _LocaleCase('id', 'ID', 'IDR'),
  _LocaleCase('ms', 'MY', 'MYR'),
  _LocaleCase('fil', 'PH', 'PHP'),
  _LocaleCase('vi', 'VN', 'VND'),
  _LocaleCase('th', 'TH', 'THB'),
  _LocaleCase('sw', 'TZ', 'TZS'),
  _LocaleCase('zh', 'CN', 'CNY'),
  _LocaleCase('ja', 'JP', 'JPY'),
  _LocaleCase('ko', 'KR', 'KRW'),
];

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

_LocaleCase get _locale => _localeCases.singleWhere(
  (item) => item.tag == _requestedTag,
  orElse: () => throw StateError('Unsupported locale: $_requestedTag'),
);

final _now = DateTime(2026, 8, 19, 8);

MizanState _stateFor(_LocaleCase locale) =>
    comprehensiveState(reference: _now, currencyCode: locale.currency).copyWith(
      setupCompleted: true,
      appLanguageTag: locale.tag,
      debtRegionCountryCode: locale.country,
      defaultCurrencyCode: locale.currency,
      recentCurrencyCodes: [locale.currency, 'USD', 'EUR'],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locale = _locale;

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test(
    '${locale.tag}: backup recovery banner uses persisted profile language',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'mizan-recovery-${locale.tag}-',
      );
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final store = LocalStore(directory: directory);
      final state = _stateFor(locale);
      MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
      await store.save(state);

      final primary = File('${directory.path}/mizan_state.json');
      final backup = File('${directory.path}/mizan_state.backup.json');
      await primary.copy(backup.path);
      await primary.writeAsString('{broken-primary', flush: true);

      MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();

      expect(controller.storageReady, isTrue);
      expect(controller.state.appLanguageTag, locale.tag);
      expect(MizanI18n.languageTag, locale.tag);
      final expected = MizanI18n.text(
        'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.',
        languageTag: locale.tag,
      );
      expect(controller.loadMessage, expected);
      if (locale.tag != 'tr' &&
          expected != 'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.') {
        expect(
          controller.loadMessage,
          isNot('Ana kayıt okunamadı; son sağlam yedek geri yüklendi.'),
        );
      }
    },
  );

  test(
    '${locale.tag}: changing language clears a previously localized status banner',
    () async {
      final controller = MizanController(
        MemoryStore(_stateFor(locale)),
        scheduler: SpyScheduler(),
      );
      await controller.load();
      await controller.restoreFromBackup(_stateFor(locale));
      expect(controller.loadMessage, isNotNull);

      var languageCallbackCount = 0;
      controller.onLanguageChanged = () {
        languageCallbackCount++;
        controller.clearMessages();
      };
      final target = locale.tag == 'en' ? _localeCases[5] : _localeCases[1];
      await controller.updateGlobalPreferences(
        appLanguageTag: target.tag,
        debtRegionCountryCode: target.country,
        defaultCurrencyCode: target.currency,
      );

      expect(languageCallbackCount, 1);
      expect(controller.state.appLanguageTag, target.tag);
      expect(MizanI18n.languageTag, target.tag);
      expect(controller.loadMessage, isNull);
      expect(controller.lastError, isNull);
    },
  );
}
