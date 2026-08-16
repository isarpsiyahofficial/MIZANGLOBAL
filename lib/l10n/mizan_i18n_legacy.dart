import 'dart:convert';

import 'package:flutter/material.dart' as material;

import 'mizan_es.dart';
import 'mizan_pt_br.dart';
import 'mizan_pt_br_dynamic.dart';
import 'mizan_pt_pt.dart';
import 'mizan_pt_pt_dynamic.dart';
import 'mizan_fr.dart';
import 'mizan_fr_dynamic.dart';
import 'mizan_de.dart';
import 'mizan_de_dynamic.dart';
import 'mizan_it.dart';
import 'mizan_it_dynamic.dart';
import 'mizan_nl.dart';
import 'mizan_nl_dynamic.dart';
import 'mizan_pl.dart';
import 'mizan_pl_dynamic.dart';
import 'mizan_ro.dart';
import 'mizan_ro_dynamic.dart';
import 'mizan_el.dart';
import 'mizan_el_dynamic.dart';
import 'mizan_ru.dart';
import 'mizan_ru_dynamic.dart';
import 'mizan_uk.dart';
import 'mizan_uk_dynamic.dart';
import 'mizan_ar.dart';
import 'mizan_ar_dynamic.dart';
import 'mizan_fa.dart';
import 'mizan_fa_dynamic.dart';
import 'mizan_he.dart';
import 'mizan_he_dynamic.dart';
import 'mizan_hi.dart';
import 'mizan_hi_dynamic.dart';
import 'mizan_bn.dart';
import 'mizan_bn_dynamic.dart';

/// Runtime localization for the fully integrated languages in MİZAN.
///
/// Turkish source text is retained as the stable key so older records and
/// backups never need to be rewritten. Only system-authored text is passed to
/// this class; user-authored names, notes and descriptions must remain raw.
abstract final class MizanI18n {
  // dart format off
  static const supportedLanguageTags = <String>{
    'tr',
    'en',
    'es',
    'pt-BR',
    'pt-PT',
    'fr',
    'de',
    'it',
    'nl',
    'pl',
    'ro',
    'el',
    'ru',
    'uk',
    'ar',
    'fa',
    'he',
    'hi',
    'bn'
  };
  // dart format on

  static String _languageTag = 'tr';
  static String _currencyCode = 'TRY';

  static String get languageTag => _languageTag;
  static bool get isTurkish => _languageTag == 'tr';
  static bool get isEnglish => _languageTag == 'en';
  static bool get isSpanish => _languageTag == 'es';
  static bool get isPortugueseBr => _languageTag == 'pt-BR';
  static bool get isPortuguesePt => _languageTag == 'pt-PT';
  static bool get isFrench => _languageTag == 'fr';
  static bool get isGerman => _languageTag == 'de';
  static bool get isItalian => _languageTag == 'it';
  static bool get isDutch => _languageTag == 'nl';
  static bool get isPolish => _languageTag == 'pl';
  static bool get isRomanian => _languageTag == 'ro';
  static bool get isGreek => _languageTag == 'el';
  static bool get isRussian => _languageTag == 'ru';
  static bool get isUkrainian => _languageTag == 'uk';
  static bool get isArabic => _languageTag == 'ar';
  static bool get isPersian => _languageTag == 'fa';
  static bool get isHebrew => _languageTag == 'he';
  static bool get isHindi => _languageTag == 'hi';
  static bool get isBengali => _languageTag == 'bn';
  static String get destructiveConfirmation => switch (_languageTag) {
    'en' => 'I CONFIRM',
    'es' => 'CONFIRMO',
    'pt-BR' => 'CONFIRMO',
    'pt-PT' => 'CONFIRMO',
    'fr' => 'JE CONFIRME',
    'de' => 'ICH BESTÄTIGE',
    'it' => 'CONFERMO',
    'nl' => 'IK BEVESTIG',
    'pl' => 'POTWIERDZAM',
    'ro' => 'CONFIRM',
    'el' => 'ΕΠΙΒΕΒΑΙΩΝΩ',
    'ru' => 'ПОДТВЕРЖДАЮ',
    'uk' => 'ПІДТВЕРДЖУЮ',
    'ar' => 'أؤكد',
    'fa' => 'تأیید می‌کنم',
    'he' => 'אני מאשר',
    'hi' => 'मैं सहमत हूँ',
    'bn' => 'আমি নিশ্চিত করছি',
    _ => 'ONAYLIYORUM',
  };
  static String get currencyCode => _currencyCode;

  static String normalizeLanguageTag(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('_', '-');
    if (normalized == 'en' || normalized.startsWith('en-')) return 'en';
    if (normalized == 'es' || normalized.startsWith('es-')) return 'es';
    if (normalized == 'pt-br') return 'pt-BR';
    if (normalized == 'pt-pt') return 'pt-PT';
    if (normalized == 'fr' || normalized.startsWith('fr-')) return 'fr';
    if (normalized == 'de' || normalized.startsWith('de-')) return 'de';
    if (normalized == 'it' || normalized.startsWith('it-')) return 'it';
    if (normalized == 'nl' || normalized.startsWith('nl-')) return 'nl';
    if (normalized == 'pl' || normalized.startsWith('pl-')) return 'pl';
    if (normalized == 'ro' || normalized.startsWith('ro-')) return 'ro';
    if (normalized == 'el' || normalized.startsWith('el-')) return 'el';
    if (normalized == 'ru' || normalized.startsWith('ru-')) return 'ru';
    if (normalized == 'uk' || normalized.startsWith('uk-')) return 'uk';
    if (normalized == 'ar' || normalized.startsWith('ar-')) return 'ar';
    if (normalized == 'fa' || normalized.startsWith('fa-')) return 'fa';
    if (normalized == 'he' ||
        normalized.startsWith('he-') ||
        normalized == 'iw' ||
        normalized.startsWith('iw-')) {
      return 'he';
    }
    if (normalized == 'hi' || normalized.startsWith('hi-')) return 'hi';
    if (normalized == 'bn' || normalized.startsWith('bn-')) return 'bn';
    return 'tr';
  }

  static bool isSupported(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('_', '-');
    return normalized == 'tr' ||
        normalized.startsWith('tr-') ||
        normalized == 'en' ||
        normalized.startsWith('en-') ||
        normalized == 'es' ||
        normalized.startsWith('es-') ||
        normalized == 'pt-br' ||
        normalized == 'pt-pt' ||
        normalized == 'fr' ||
        normalized.startsWith('fr-') ||
        normalized == 'de' ||
        normalized.startsWith('de-') ||
        normalized == 'it' ||
        normalized.startsWith('it-') ||
        normalized == 'nl' ||
        normalized.startsWith('nl-') ||
        normalized == 'pl' ||
        normalized.startsWith('pl-') ||
        normalized == 'ro' ||
        normalized.startsWith('ro-') ||
        normalized == 'el' ||
        normalized.startsWith('el-') ||
        normalized == 'ru' ||
        normalized.startsWith('ru-') ||
        normalized == 'uk' ||
        normalized.startsWith('uk-') ||
        normalized == 'ar' ||
        normalized.startsWith('ar-') ||
        normalized == 'fa' ||
        normalized.startsWith('fa-') ||
        normalized == 'he' ||
        normalized.startsWith('he-') ||
        normalized == 'iw' ||
        normalized.startsWith('iw-') ||
        normalized == 'hi' ||
        normalized.startsWith('hi-') ||
        normalized == 'bn' ||
        normalized.startsWith('bn-');
  }

  static void setLanguageTag(String? value) {
    _languageTag = normalizeLanguageTag(value);
  }

  static void setProfile({String? languageTag, String? currencyCode}) {
    setLanguageTag(languageTag);
    final normalizedCurrency = (currencyCode ?? '').trim().toUpperCase();
    _currencyCode = RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency)
        ? normalizedCurrency
        : 'TRY';
  }

  static String user(String value) {
    if (value.contains('\u{E000}') && value.contains('\u{E001}')) {
      return value;
    }
    final encoded = base64Url.encode(utf8.encode(value));
    return '\u{E000}$encoded\u{E001}';
  }

  static String notificationText(String value) {
    const defaults = <String>{
      'Sabah gider',
      'Bugünkü giderlerini işlemeyi unutma.',
      'Öğlen gider',
      'Öğlene kadar yaptığın harcamaları ekleyebilirsin.',
      'Akşam gider',
      'Günü kapatmadan giderlerini kontrol et.',
      'Ödeme hatırlatması 1',
      'Ödeme hatırlatması 2',
      'Ödeme hatırlatması 3',
      'Yaklaşan ve gecikmiş ödemelerini kontrol et.',
      'Günün ödeme planını gözden geçir.',
    };
    return defaults.contains(value) ? text(value) : user(value);
  }

  static String text(String source, {String? languageTag}) {
    final protected = <String, String>{};
    final visibleSource = source.replaceAllMapped(
      RegExp('\u{E000}([A-Za-z0-9_\\-=]+)\u{E001}'),
      (match) {
        final token = '__MIZAN_USER_${protected.length}__';
        try {
          protected[token] = utf8.decode(base64Url.decode(match[1]!));
        } on Object {
          protected[token] = '';
        }
        return token;
      },
    );
    final effective = languageTag == null
        ? _languageTag
        : normalizeLanguageTag(languageTag);
    String result;
    if (visibleSource.isEmpty || effective == 'tr') {
      result = visibleSource;
    } else if (effective == 'en') {
      result =
          _english[visibleSource] ?? _translateEnglishDynamic(visibleSource);
    } else if (effective == 'es') {
      result =
          mizanSpanish[visibleSource] ??
          translateSpanishDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'es'),
          );
    } else if (effective == 'pt-BR') {
      result =
          mizanPortugueseBr[visibleSource] ??
          translatePortugueseBrReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-BR'),
          );
    } else if (effective == 'pt-PT') {
      result =
          mizanPortuguesePt[visibleSource] ??
          translatePortuguesePtReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-PT'),
          );
    } else if (effective == 'fr') {
      result =
          mizanFrench[visibleSource] ??
          translateFrenchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fr'),
          );
    } else if (effective == 'de') {
      result =
          mizanGerman[visibleSource] ??
          translateGermanReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'de'),
          );
    } else if (effective == 'it') {
      result =
          mizanItalian[visibleSource] ??
          translateItalianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'it'),
          );
    } else if (effective == 'nl') {
      result =
          mizanDutch[visibleSource] ??
          translateDutchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'nl'),
          );
    } else if (effective == 'pl') {
      result =
          mizanPolish[visibleSource] ??
          translatePolishReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pl'),
          );
    } else if (effective == 'ro') {
      result =
          mizanRomanian[visibleSource] ??
          translateRomanianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ro'),
          );
    } else if (effective == 'el') {
      result =
          mizanGreek[visibleSource] ??
          translateGreekReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'el'),
          );
    } else if (effective == 'ru') {
      result =
          mizanRussian[visibleSource] ??
          translateRussianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ru'),
          );
    } else if (effective == 'uk') {
      result =
          mizanUkrainian[visibleSource] ??
          translateUkrainianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'uk'),
          );
    } else if (effective == 'ar') {
      result =
          mizanArabic[visibleSource] ??
          translateArabicReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ar'),
          );
    } else if (effective == 'fa') {
      result =
          mizanPersian[visibleSource] ??
          translatePersianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fa'),
          );
    } else if (effective == 'he') {
      result =
          mizanHebrew[visibleSource] ??
          translateHebrewReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'he'),
          );
    } else if (effective == 'hi') {
      result =
          mizanHindi[visibleSource] ??
          translateHindiReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'hi'),
          );
    } else {
      result =
          mizanBengali[visibleSource] ??
          translateBengaliReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'bn'),
          );
    }
    for (final entry in protected.entries) {
      final visibleUser =
          effective == 'ar' || effective == 'fa' || effective == 'he'
          ? '\u2068${entry.value}\u2069'
          : entry.value;
      result = result.replaceAll(entry.key, visibleUser);
    }
    return result;
  }

  static String? nullable(String? source, {String? languageTag}) =>
      source == null ? null : text(source, languageTag: languageTag);

  static material.InputDecoration inputDecoration(
    material.InputDecoration source, {
    String? languageTag,
  }) => source.copyWith(
    labelText: nullable(source.labelText, languageTag: languageTag),
    hintText: nullable(source.hintText, languageTag: languageTag),
    helperText: nullable(source.helperText, languageTag: languageTag),
    errorText: nullable(source.errorText, languageTag: languageTag),
    prefixText: nullable(source.prefixText, languageTag: languageTag),
    suffixText: nullable(source.suffixText, languageTag: languageTag),
    counterText: nullable(source.counterText, languageTag: languageTag),
    semanticCounterText: nullable(
      source.semanticCounterText,
      languageTag: languageTag,
    ),
  );

  static String _translateEnglishDynamic(String source) {
    var value = source;
    for (final pattern in _patterns) {
      final match = pattern.regExp.firstMatch(value);
      if (match != null) return pattern.builder(match);
    }
    for (final entry in _phrases) {
      value = value.replaceAll(entry.$1, entry.$2);
    }
    return value;
  }

  static const Map<String, String> _english = <String, String>{
    'MİZAN Aylık Raporu': 'MİZAN Monthly Report',
    'Aktif': 'Active',
    'Yaklaşıyor': 'Due soon',
    'Gecikmede': 'Overdue',
    'Tamamlandı': 'Completed',
    'Pasif': 'Inactive',
    'KMH hesabı': 'Overdraft account',
    'Kredi kartı': 'Credit card',
    'Kredi': 'Loan',
    'Araç kredisi': 'Vehicle loan',
    'Ev kredisi': 'Mortgage',
    'Nakit avans': 'Cash advance',
    'Taksitli nakit avans': 'Installment cash advance',
    'Özel borç türü': 'Custom debt type',
    'Son ödeme tarihi': 'Due date',
    'Her ayın belirli günü': 'A specific day of each month',
    'Taksit ödemesi': 'Installment payment',
    'Borç kapama': 'Pay off debt',
    'Kısmi ödeme': 'Partial payment',
    'Günde 1 kez': 'Once a day',
    'Günde 2 kez': 'Twice a day',
    'Günde 3 kez': 'Three times a day',
    'Cihazın varsayılan bildirim sesi': 'Device default notification sound',
    'Sessiz': 'Silent',
    'Tek seferlik': 'One-time',
    'Günlük': 'Daily',
    'Haftalık': 'Weekly',
    'Aylık': 'Monthly',
    'Elektrik': 'Electricity',
    'Su': 'Water',
    'Telefon': 'Phone',
    'İnternet': 'Internet',
    'Doğalgaz': 'Natural gas',
    'Özel fatura': 'Custom bill',
    'Tek dönem faturası': 'One-time bill',
    'Her ay tekrarlayan fatura': 'Recurring monthly bill',
    'Ev kirası': 'Residential rent',
    'Ürün taksiti': 'Product installment',
    'Özel oluştur': 'Custom',
    'Kişi': 'Person',
    'Şirket / Kurum': 'Company / Organization',
    'Çek': 'Cheque',
    'Senet': 'Promissory note',
    'Esnaf / İşletme': 'Merchant / Business',
    'Aile / Yakın': 'Family / Relative',
    'Diğer': 'Other',
    'Tek ödeme': 'One-time payment',
    'İki haftada bir': 'Every two weeks',
    'Üç aylık': 'Quarterly',
    'Yıllık': 'Yearly',
    'Özel aralık': 'Custom interval',
    'Dijital hizmet': 'Digital service',
    'Üyelik': 'Membership',
    'Sigorta': 'Insurance',
    'Eğitim': 'Education',
    'Bakım / servis': 'Maintenance / service',
    'Diğer abonelik': 'Other subscription',
    'Banka borcu': 'Bank debt',
    'Kişisel / kurumsal borç': 'Personal / business debt',
    'Fatura': 'Bill',
    'Abonelik': 'Subscription',
    'Kira / taksit': 'Rent / installment',
    'Ana sayfa': 'Home',
    'Kayıtlar': 'Records',
    'Giderler': 'Expenses',
    'Raporlar': 'Reports',
    'Ayarlar': 'Settings',
    'Kapat': 'Close',
    'Kaydet': 'Save',
    'Vazgeç': 'Cancel',
    'Sil': 'Delete',
    'Düzenle': 'Edit',
    'Ekle': 'Add',
    'Devam et': 'Continue',
    'Geri': 'Back',
    'Tamam': 'Done',
    'Onayla': 'Confirm',
    'Aramayı temizle': 'Clear search',
    'Eşleşen sonuç bulunamadı.': 'No matching results found.',
    'Dil seç': 'Select language',
    'Dil ara': 'Search languages',
    'Ülke seç': 'Select country',
    'Ülke adı veya kod ara': 'Search by country name or code',
    'Para birimi seç': 'Select currency',
    'Ad, ISO kodu veya sembol ara': 'Search by name, ISO code, or symbol',
    'Uygulama dili': 'App language',
    'Ülke / borç bölgesi': 'Country / debt region',
    'Varsayılan para birimi': 'Default currency',
    'Kurulumu tamamla': 'Complete setup',
    'MİZAN GLOBAL': 'MİZAN GLOBAL',
    'Bu seçimler yalnız ilk kurulumda sorulur. Daha sonra Ayarlar bölümünden değiştirilebilir; mevcut kayıtlar silinmez.':
        'These choices are requested only during the initial setup. You can change them later in Settings without deleting any existing records.',
    'Yalnızca tamamen entegre edilmiş bir dil seçilebilir.':
        'Only a fully integrated language can be selected.',
    'Dil, ülke ve para birimi': 'Language, country, and currency',
    'Bu seçimleri değiştirmek kayıtları, ödemeleri veya geçmişi silmez.':
        'Changing these choices does not delete records, payments, or history.',
    'Profil kayıtları korunur': 'Your records are preserved',
    'Dil, ülke veya varsayılan para birimi değiştiğinde mevcut kişi, borç, fatura, gider, gelir ve ödeme kayıtları değiştirilmez.':
        'Changing the language, country, or default currency does not alter existing people, debt, bill, expense, income, or payment records.',
    'Bildirim sistemi': 'Notification system',
    'Bildirim izni': 'Notification permission',
    'Dakik bildirim izni': 'Exact alarm permission',
    'Açık': 'On',
    'Kapalı': 'Off',
    'Dakik teslim için izin gerekli': 'Permission required for exact delivery',
    'Bildirim planı bilgisi': 'Notification schedule information',
    'Otomatik senkronizasyon': 'Automatic synchronization',
    'Ödeme hatırlatmaları': 'Payment reminders',
    'Saat ekle': 'Add time',
    'Ses ve titreşim': 'Sound and vibration',
    'Titreşim açık': 'Vibration on',
    'Titreşim kapalı': 'Vibration off',
    'Vade kayıtları değiştirilmez': 'Due-date records are not changed',
    'Günlük gider hatırlatmaları': 'Daily expense reminders',
    'Yerel veri güvenliği': 'Local data security',
    'Anlık yerel kayıt': 'Instant local saving',
    'Doğrulanmış yedek kopya': 'Verified backup copy',
    'CSV yedekleme': 'CSV backup',
    'CSV yedeğini dışa aktar': 'Export CSV backup',
    'CSV yedeğini mevcut verilerle birleştir':
        'Merge CSV backup with existing data',
    'İlişkiler korunur': 'Relationships are preserved',
    'Ana durumu ve Android izinlerini burada yönet. Hatırlatma saati ve mesajı ilgili kaydın ayrıntısındadır.':
        'Manage the main status and Android permissions here. Each reminder\'s time and message are available in the related record details.',
    'Etkin hatırlatmalar seçilen gün ve dakikada planlanır.':
        'Enabled reminders are scheduled for the selected day and exact minute.',
    'Hatırlatmalar durdurulur; kayıtlar ve ayarlar silinmez.':
        'Reminders are stopped; records and settings are not deleted.',
    'Android bildirim izni kapalı. İzin açılmadan hiçbir MİZAN bildirimi oluşturulmaz.':
        'Android notification permission is off. MİZAN cannot create notifications until permission is granted.',
    'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.':
        'Android\'s exact alarm permission is off. MİZAN does not use approximate scheduling; enable this permission for delivery at the selected hour and minute.',
    'Kayıt değişiklikleri üst üste bindirilmeden sırayla işlenir. Yalnız sıradaki gerekli bildirimler dakik biçimde yenilenir; gereksiz günlük kopyalar oluşturulmaz.':
        'Record changes are processed sequentially without overlapping. Only the next required notifications are refreshed with exact timing; unnecessary daily duplicates are not created.',
    'Her kart yalnız özet gösterir. Saat, mesaj ve açık/kapalı durumu karta dokununca düzenlenir.':
        'Each card shows a summary only. Tap a card to edit its time, message, and on/off status.',
    'Bildirim planlaması yalnız hatırlatma oluşturur; ödeme, taksit, gider veya geçmiş kaydı üretmez.':
        'Notification scheduling creates reminders only; it never creates payment, installment, expense, or history records.',
    'Her gider hatırlatmasının saatini, mesajını ve açık/kapalı durumunu kendi ayrıntısından düzenle.':
        'Edit each expense reminder\'s time, message, and on/off status in its details.',
    'Her değişiklik cihazda anında kaydedilir; sağlam kayıt doğrulanmadan üzerine yazılmaz.':
        'Every change is saved to the device immediately; valid data is never overwritten before the new save is verified.',
    'Kişiler, borçlar, faturalar, abonelikler, ödemeler, notlar, gelirler ve giderler her işlemden sonra cihazdaki dosyaya yazılır.':
        'People, debts, bills, subscriptions, payments, notes, income, and expenses are written to the on-device file after every action.',
    'Yeni kayıt doğrulandıktan sonra ana dosya değiştirilir; son sağlam kopya ayrıca korunur.':
        'The main file is replaced only after the new data is verified; the last valid copy is preserved separately.',
    'Yedek içe aktarılırken mevcut kayıtlar silinmez. Ortak kayıtlar atlanır, yalnız yeni kayıtlar ve eksik ilişkiler eklenir.':
        'Importing a backup does not delete existing records. Matching records are skipped; only new records and missing relationships are added.',
    'Kişi, banka, borç, ödeme, not, kategori, gider, gelir ve bildirim saatleri kendi kimlik ve bağlantılarıyla aktarılır. Aynı kayıt ikinci kez yazılmaz.':
        'People, banks, debts, payments, notes, categories, expenses, income, and notification times are transferred with their original IDs and relationships. The same record is never written twice.',
    'Uygulama dili seçilmelidir.': 'An app language must be selected.',
    'Ülke kodu geçersiz.': 'Invalid country code.',
    'Para birimi kodu geçersiz.': 'Invalid currency code.',
    'Tamamlanmış profilde uygulama dili eksik.':
        'The completed profile is missing an app language.',
    'Tamamlanmış profilde ülke kodu geçersiz.':
        'The completed profile has an invalid country code.',
    'Tamamlanmış profilde para birimi kodu geçersiz.':
        'The completed profile has an invalid currency code.',
    'Global katalog henüz yüklenmedi.':
        'The global catalog has not loaded yet.',
    'Global katalog sayıları doğrulanamadı.':
        'The global catalog counts could not be verified.',
    'Bildirim izni veya zamanlama servisi açılamadı:':
        'Notification permission or the scheduling service could not be opened:',
    'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.':
        'Local storage could not be opened safely. New writes have been stopped to protect the existing files.',
    'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
        'Notification permission is off. MİZAN will resynchronize automatically after the Android permission is enabled.',
    'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.':
        'Exact alarm permission is off. MİZAN will resynchronize automatically after the Android permission is enabled.',
    'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi:':
        'The record was saved, but notifications could not be synchronized automatically:',
    'Kişi adı': 'Person name',
    'Banka adı': 'Bank name',
    'Toplam borç': 'Total debt',
    'Aylık tutar': 'Monthly amount',
    'Gecikme günü': 'Days overdue',
    'Limit': 'Limit',
    'Kullanılan limit': 'Used limit',
    'Açıklama': 'Description',
    'Düzenli ödeme tutarı': 'Regular payment amount',
    'Borç başlığı': 'Debt title',
    'Alacaklı adı': 'Creditor name',
    'Çek numarası': 'Cheque number',
    'Düzenleyen': 'Issuer',
    'Banka bilgisi': 'Bank information',
    'Senet numarası': 'Promissory note number',
    'Ödeme planı tutarı': 'Payment plan amount',
    'Abonelik tutarı': 'Subscription amount',
    'Abonelik türü': 'Subscription type',
    'Abonelik başlığı': 'Subscription title',
    'Sağlayıcı adı': 'Provider name',
    'Abone numarası': 'Subscriber number',
    'Sözleşme numarası': 'Contract number',
    'Fatura tutarı': 'Bill amount',
    'Dönem fatura tutarı': 'Billing-period amount',
    'Kurum adı': 'Institution name',
    'Kira/taksit tutarı': 'Rent/installment amount',
    'Kira/taksit başlığı': 'Rent/installment title',
    'Alıcı adı': 'Recipient name',
    'IBAN': 'IBAN',
    'Adet': 'Quantity',
    'Birim fiyat': 'Unit price',
    'Gider adı': 'Expense name',
    'Gider notu': 'Expense note',
    'Ödeme tutarı': 'Payment amount',
    'Ödeme notu': 'Payment note',
    'Ödeme yöntemi': 'Payment method',
    'Not': 'Note',
    'Notlar': 'Notes',
    'Kategori adı': 'Category name',
    'Gelir tutarı': 'Income amount',
    'Gelir türü': 'Income type',
    'Gelir notu': 'Income note',
    'Hatırlatma adı': 'Reminder name',
    'Bildirim mesajı': 'Notification message',
    'Geçici': 'Temporary',
    'Ödeme hatırlatması': 'Payment reminder',
    'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
        'Review your upcoming and overdue payments.',
    'En fazla 10 ödeme bildirimi eklenebilir.':
        'You can add up to 10 payment notifications.',
    'Ödeme bildirim saati bulunamadı.': 'Payment notification time not found.',
    'Bildirim saati geçersiz.': 'Invalid notification time.',
    'En az bir ödeme bildirim saati bulunmalıdır.':
        'At least one payment notification time is required.',
    'Gelir kaydı bulunamadı.': 'Income record not found.',
    'Haftalık gelir için geçerli bir gün seçilmelidir.':
        'Select a valid weekday for weekly income.',
    'Aylık gelir günü 1 ile 31 arasında olmalıdır.':
        'The monthly income day must be between 1 and 31.',
    'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.':
        'Payday tracking is available only for weekly and monthly income.',
    'Bu gelir için yatış günü takibi açık değil.':
        'Payday tracking is not enabled for this income.',
    'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.':
        'This income period has already been marked as received.',
    'Geri alınacak gelir işareti yok.':
        'There is no income receipt status to undo.',
    'Bildirim ayarı bulunamadı.': 'Notification setting not found.',
    'Ödeme kalan borçtan büyük olamaz.':
        'The payment cannot exceed the remaining debt.',
    'Borç kaydı bulunamadı.': 'Debt record not found.',
    'Ödeme kalan fatura tutarından büyük olamaz.':
        'The payment cannot exceed the remaining bill amount.',
    'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.':
        'The payment cannot exceed the subscription\'s remaining amount for this period.',
    'Ödeme kalan kira/taksit tutarından büyük olamaz.':
        'The payment cannot exceed the remaining rent/installment amount.',
    'Ödeme kaydı bulunamadı.': 'Payment record not found.',
    'Güncellenen ödeme toplam tutarı aşamaz.':
        'The updated payment cannot exceed the total amount.',
    'Toplam borç, daha önce ödenen tutardan düşük olamaz.':
        'Total debt cannot be lower than the amount already paid.',
    'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.':
        'The bill amount cannot be lower than the amount already paid.',
    'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.':
        'The rent/installment amount cannot be lower than the amount already paid.',
    'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.':
        'A monthly amount is required when a specific day of each month is selected.',
    'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.':
        'Overdue-month selection is available only with a monthly payment day.',
    'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.':
        'The selected overdue month\'s due date cannot be in the future.',
    'Kullanılan limit toplam limiti aşamaz.':
        'Used credit cannot exceed the total limit.',
    'Son ödeme tarihi borç tarihinden önce olamaz.':
        'The due date cannot be earlier than the debt date.',
    'Taksitli borçta ödeme tutarı girilmelidir.':
        'A payment amount is required for installment debt.',
    'Özel ödeme aralığı gün olarak girilmelidir.':
        'Enter the custom payment interval in days.',
    'Çek numarası boş bırakılamaz.': 'Cheque number is required.',
    'Senet numarası boş bırakılamaz.': 'Promissory note number is required.',
    'Abonelik ödeme sıklığı tek ödeme olamaz.':
        'A subscription cannot use a one-time payment frequency.',
    'Aylık fatura günü 1 ile 31 arasında olmalıdır.':
        'The monthly bill day must be between 1 and 31.',
    'Ödeme günü 1 ile 31 arasında olmalı.':
        'The payment day must be between 1 and 31.',
    'Ürün taksitinde toplam taksit sayısı gereklidir.':
        'The total number of installments is required for a product installment.',
    'Sözleşme bitişi başlangıçtan önce olamaz.':
        'The contract end date cannot be earlier than the start date.',
    'Bir borç kaydında ödeme toplamı borcu aşıyor.':
        'Payments on a debt record exceed the debt amount.',
    'Bir kişisel borçta ödeme toplamı borcu aşıyor.':
        'Payments on a personal debt exceed the debt amount.',
    'Bir fatura kaydında ödeme toplamı tutarı aşıyor.':
        'Payments on a bill exceed the bill amount.',
    'Aylık fatura ödeme günü geçersiz.': 'Invalid monthly bill payment day.',
    'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.':
        'The billing-period amount must be greater than zero.',
    'Bir kira kaydında ödeme toplamı tutarı aşıyor.':
        'Payments on a rent record exceed the amount due.',
    'Bir gider kaydı bulunmayan kategoriye bağlı.':
        'An expense is linked to a category that does not exist.',
    'Kişi bulunamadı.': 'Person not found.',
    'Banka kaydı bulunamadı.': 'Bank record not found.',
    'Kişisel/kurumsal borç bulunamadı.': 'Personal/business debt not found.',
    'Abonelik kaydı bulunamadı.': 'Subscription record not found.',
    'Fatura kaydı bulunamadı.': 'Bill record not found.',
    'Kira/taksit kaydı bulunamadı.': 'Rent/installment record not found.',
    'Gider kategorisi bulunamadı.': 'Expense category not found.',
    'Gider kaydı bulunamadı.': 'Expense record not found.',
    'Bu kişide aynı banka adı zaten var.':
        'This person already has a bank with the same name.',
    'Bu kategori adı zaten kullanılıyor.':
        'This category name is already in use.',
    'Banka borcu kaydı bulunamadı.': 'Bank debt record not found.',
    'Toplam taksit pozitif olmalı.':
        'The total number of installments must be positive.',
    'Taksit ilerlemesi negatif olamaz.':
        'Installment progress cannot be negative.',
    'Taksit ilerlemesi toplam taksiti aşamaz.':
        'Installment progress cannot exceed the total number of installments.',
    'Tutar boş bırakılamaz.': 'Amount is required.',
    'Geçerli bir para tutarı girin.': 'Enter a valid monetary amount.',
    'Tutar biçimi anlaşılamadı.': 'The amount format could not be recognized.',
    'En fazla iki kuruş hanesi girilebilir.':
        'Enter no more than two decimal places.',
    'Değer': 'Value',
    'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.':
        'Lefferion Prime - MİZAN may make mistakes. Please verify due dates, overdue status, and payment information before proceeding.',
    'Son ödeme bugün': 'Due today',
    'Ocak': 'January',
    'Şubat': 'February',
    'Mart': 'March',
    'Nisan': 'April',
    'Mayıs': 'May',
    'Haziran': 'June',
    'Temmuz': 'July',
    'Ağustos': 'August',
    'Eylül': 'September',
    'Ekim': 'October',
    'Kasım': 'November',
    'Aralık': 'December',
    'Oca': 'Jan',
    'Şub': 'Feb',
    'Mar': 'Mar',
    'Nis': 'Apr',
    'May': 'May',
    'Haz': 'Jun',
    'Tem': 'Jul',
    'Ağu': 'Aug',
    'Eyl': 'Sep',
    'Eki': 'Oct',
    'Kas': 'Nov',
    'Ara': 'Dec',
    'Bildirim servisi bu platformda etkin değil.':
        'The notification service is not available on this platform.',
    'Gider bildirimleri': 'Expense notifications',
    'Ödeme bildirimleri': 'Payment notifications',
    'Günlük gider kaydı bildirimleri': 'Daily expense entry notifications',
    'Tüm kayıt türlerinin son ödeme bildirimleri':
        'Due-date notifications for all record types',
    'Android dışında gerçek zamanlama yapılmaz.':
        'Real scheduling is available only on Android.',
    'Bildirim izni kapalı.': 'Notification permission is off.',
    'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.':
        'Exact alarm permission is off. Enable it for delivery at the selected hour and minute.',
    'Dakik bildirim izni verilmedi.': 'Exact alarm permission was not granted.',
    'Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.':
        'Notification permission is off. No new notifications were created.',
    'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.':
        'Exact alarm permission is off. Android cancels existing exact schedules; the schedule must be rebuilt after permission is granted.',
    'Bildirim izni kapalı. Önce bildirim iznini açın.':
        'Notification permission is off. Enable notification permission first.',
    'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.':
        'Exact alarm permission was not granted. The test will not run using approximate timing.',
    'MİZAN bildirim testi': 'MİZAN notification test',
    'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.':
        'This test was created with the configured exact notification system.',
    'Yedek kayıt doğrulanamadı.': 'The backup could not be verified.',
    'Ana kayıt okunamadı; son sağlam yedek geri yüklendi.':
        'The main data file could not be read; the last valid backup was restored.',
    'Ana ve yedek kayıt dosyaları okunamadı. Dosyalar korunuyor.':
        'Neither the main data file nor the backup could be read. The files have been preserved.',
    'MİZAN kullanıma hazır. İlk kişi veya kaydı ekleyebilirsin.':
        'MİZAN is ready. Add your first person or record to get started.',
    'Geçici kayıt doğrulanamadı.': 'The temporary save could not be verified.',
    'Kayıt doğrulaması başarısız oldu.': 'Data verification failed.',
    'Detayı gör': 'View details',
    'Not ekle': 'Add note',
    'Bu kayda ait not bulunmuyor. Notlar ödeme açıklamalarından ayrı tutulur.':
        'There are no notes for this record. Notes are stored separately from payment descriptions.',
    'Notu sil': 'Delete note',
    'Notları daralt': 'Collapse notes',
    'Not boş bırakılamaz.': 'Note is required.',
    'Yalnızca bu not silinecek. Devam edilsin mi?':
        'Only this note will be deleted. Continue?',
    'Borç, ödeme ve giderlerin sade özeti. Detay görmek için kartlara dokunabilirsin.':
        'A clear summary of your debts, payments, and expenses. Tap a card to view details.',
    'Bu Ayın Ödeme Durumu': 'This Month\'s Payment Status',
    'Gecikmiş ödemeler': 'Overdue payments',
    'Bugünkü normal gider': 'Regular expenses today',
    'Bu ay normal gider': 'Regular expenses this month',
    'Bugünkü ödemelere yapılan gider': 'Payments made today',
    'Bu ay ödemelere yapılan gider': 'Payments made this month',
    'Bugünkü toplam gider': 'Total spending today',
    'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.':
        'Includes regular expenses plus bank debt, personal debt, bill, subscription, rent, and installment payments.',
    'Bu ay toplam gider': 'Total spending this month',
    'Bu ayın normal giderleri ile kaydedilmiş tüm ödeme giderlerinin toplamıdır.':
        'Includes this month\'s regular expenses and all recorded payments.',
    'Kritik ödemeler': 'Critical payments',
    'Gecikmiş veya yedi gün içinde vadesi gelen kayıtlar. Ayrıntı için satıra dokun.':
        'Records that are overdue or due within seven days. Tap a row for details.',
    'Kritik ödeme yok': 'No critical payments',
    'Gecikmiş veya önümüzdeki yedi gün içinde vadesi gelen kayıt bulunmuyor.':
        'There are no overdue records or records due within the next seven days.',
    'Uygulama boş ve kullanıma hazır': 'The app is empty and ready to use',
    'Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.':
        'No sample payments or debts were created. Start by adding your first person in Records.',
    'Gelir bilgileri': 'Income details',
    'Gelir ekle': 'Add income',
    'Gelir kaydı opsiyoneldir. Borç ödemeleri ve giderler gelirden ayrı tutulur; net sonuç raporda hesaplanır.':
        'Income records are optional. Debt payments and expenses are tracked separately from income; the net result is calculated in Reports.',
    'Gelir bilgisi belirtilmemiş': 'No income information provided',
    'Tek seferlik, günlük, haftalık veya aylık gelir ekleyebilirsin.':
        'You can add one-time, daily, weekly, or monthly income.',
    'Gelir yattı': 'Mark as received',
    'Son alınma işaretini geri al': 'Undo latest received status',
    'Arşivden çıkar': 'Restore from archive',
    'Arşivle': 'Archive',
    'Geliri düzenle': 'Edit income',
    'Gelir türü / adı': 'Income type / name',
    'Maaş, ek iş, kira geliri…': 'Salary, freelance work, rental income…',
    'Gelir türü boş bırakılamaz.': 'Income type is required.',
    'Gelir tutarı sıfırdan büyük olmalıdır.':
        'Income amount must be greater than zero.',
    'Gelir sıklığı': 'Income frequency',
    'Yatış gününü takip et': 'Track payday',
    'Opsiyoneldir. Planlanan gün ile gerçek alınma tarihi ayrı tutulur.':
        'Optional. The scheduled payday and the actual received date are tracked separately.',
    'Haftanın hangi günü yatıyor?': 'Which day of the week is it paid?',
    'Her ayın kaçında yatıyor?': 'Which day of the month is it paid?',
    'Ay daha kısaysa o ayın son geçerli günü kullanılır.':
        'If the month is shorter, its last valid day is used.',
    'Gelir başlangıç tarihini seçin': 'Select the income start date',
    'Gelir notu (opsiyonel)': 'Income note (optional)',
    'Salı': 'Tuesday',
    'Çarşamba': 'Wednesday',
    'Perşembe': 'Thursday',
    'Pazartesi': 'Monday',
    'Cuma': 'Friday',
    'Cumartesi': 'Saturday',
    'Pazar': 'Sunday',
    'Gün': 'Day',
    'Başlangıç': 'Start',
    'Arşivde': 'Archived',
    'Gelirin gerçekten alındığı tarihi seçin':
        'Select the date the income was actually received',
    'Kalan toplam borç detayı': 'Total outstanding debt details',
    'Her bölümün toplamı ayrı hesaplanır. Satıra dokunarak yalnız ilgili kayıtları görebilirsin.':
        'Each section is calculated separately. Tap a row to view only the related records.',
    'Ödeme Durumu': 'Payment Status',
    'Açık planlanan kayıtlar ile bu ay gerçekten yapılan ödemeler ayrı gösterilir.':
        'Outstanding scheduled records and payments actually made this month are shown separately.',
    'Açık planlanan ödemeler': 'Outstanding scheduled payments',
    'Açık plan kalmadı': 'No outstanding scheduled payments',
    'Bu aya ait açık veya eksik ödeme bulunmuyor.':
        'There are no outstanding or incomplete payments for this month.',
    'Bu ay yapılan ödemeler': 'Payments made this month',
    'Yapılan ödeme yok': 'No payments made',
    'Bu ay ödeme geçmişine kaydedilmiş işlem bulunmuyor.':
        'There are no transactions recorded in payment history this month.',
    'Kayıt bulunmuyor': 'No records found',
    'Bu başlığa ait açık ödeme kaydı yok.':
        'There are no outstanding payment records under this heading.',
    'Gelir özeti': 'Income summary',
    'Yönet': 'Manage',
    'Bu ay gelir': 'Income this month',
    'Ödemeler sonrası kalan': 'Remaining after payments',
    'Ödeme ve gider sonrası net': 'Net after payments and expenses',
    'Ödemeler': 'Payments',
    'Bütün harcamalar': 'All spending',
    'Bu ay': 'This month',
    'Son 30 gün': 'Last 30 days',
    'Son 90 gün': 'Last 90 days',
    'Tarih aralığı': 'Date range',
    'Tümü': 'All',
    'Harcamalar gün gün gruplanır; arama ve günlük toplam sıralaması uzun yıllarda da kontrollü çalışır.':
        'Spending is grouped by day; search and daily-total sorting remain efficient even across many years of data.',
    'Bugün': 'Today',
    'Filtreleme ve arama': 'Filters and search',
    'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.':
        'Search by date, weekday, expense, category, or note. Accented characters and concatenated terms are supported.',
    'Gider veya tarih ara': 'Search expenses or dates',
    'Araç, yoğurt, 23.07.2026, Perşembe…': 'Car, yogurt, 23/07/2026, Thursday…',
    'Günleri sırala': 'Sort days',
    'Tüm kategoriler': 'All categories',
    'Kategori ekle': 'Add category',
    'Önce kategori ekleyin': 'Add a category first',
    'Market, ulaşım veya kullanıcıya özel başka bir kategori ekledikten sonra gider kaydı oluşturabilirsiniz.':
        'Add a category such as Groceries, Transport, or any custom category before creating an expense.',
    'Eşleşen gider bulunamadı': 'No matching expenses found',
    'Seçili kategori, dönem ve arama ifadesine uyan kayıt yok.':
        'No records match the selected category, period, and search term.',
    'Daha fazla gün göster': 'Show more days',
    'Bütün harcamalar görünümünde günlük harcamalar ve ödemeler ayrı başlıklar altında tutulur; yalnız toplamları birlikte hesaplanır.':
        'In All Spending, daily expenses and payments remain in separate sections; only their totals are combined.',
    'Tarih aralığı seçin': 'Select a date range',
    'Gider kategorileri': 'Expense categories',
    'Kategori silinirse yalnız o kategoriye bağlı giderler açık onayla silinir.':
        'Deleting a category removes only the expenses linked to it, after explicit confirmation.',
    'Kategoriyi düzenle': 'Edit category',
    'Kategori adı boş bırakılamaz.': 'Category name is required.',
    'Kategoriyi sil': 'Delete category',
    'ONAYLIYORUM yazın': 'Type I CONFIRM',
    'Tam olarak ONAYLIYORUM yazılmalı.': 'You must type I CONFIRM exactly.',
    'Gideri düzenle': 'Edit expense',
    'Gider adı boş bırakılamaz.': 'Expense name is required.',
    'Adet / miktar': 'Quantity / amount',
    'Birim fiyat negatif olamaz.': 'Unit price cannot be negative.',
    'Gideri sil': 'Delete expense',
    'Banka / kredi': 'Bank / credit',
    'Kişisel / kurumsal': 'Personal / business',
    'Ödeme bulunamadı': 'No payments found',
    'Seçili filtrede kaydedilmiş ödeme yok.':
        'There are no recorded payments for the selected filter.',
    'Daha fazla ödeme günü göster': 'Show more payment days',
    'Kategori bulunamadı': 'Category not found',
    'Bu günden daha fazla göster': 'Show more from this day',
    'Gider işlemleri': 'Expense actions',
    'Önce kişiyi seç, ardından kayıt türünü aç. Her bölüm birbirinden bağımsız tutulur.':
        'Select a person first, then open a record type. Each section is kept independent.',
    'Kişi ekle': 'Add person',
    'Henüz kişi yok': 'No people yet',
    'Kayıtların birbirine karışmaması için önce ödeme ve gider kayıtlarının sahibi olacak kişiyi ekleyin.':
        'Add the person who will own the payment and expense records first, so records remain separate.',
    'İlk kişiyi ekle': 'Add first person',
    'Kişisel ve Kurumsal Borçlar': 'Personal and Business Debts',
    'Kişi, şirket/kurum, çek, senet, esnaf/işletme, aile/yakın ve diğer alacaklılar':
        'People, companies/institutions, cheques, promissory notes, merchants/businesses, family/relatives, and other creditors',
    'Kişisel / kurumsal borç ekle': 'Add personal / business debt',
    'Banka dışı borç kaydı bulunmuyor.': 'No non-bank debt records found.',
    'Elektrik, su, telefon, internet, doğalgaz ve özel faturalar':
        'Electricity, water, phone, internet, natural gas, and custom bills',
    'Fatura ekle': 'Add bill',
    'Fatura kaydı bulunmuyor.': 'No bill records found.',
    'Belirli aralıklarla tekrarlayan dijital hizmet, üyelik, sigorta, eğitim ve bakım ödemeleri':
        'Recurring digital services, memberships, insurance, education, and maintenance payments',
    'Abonelik ekle': 'Add subscription',
    'Abonelik kaydı bulunmuyor.': 'No subscription records found.',
    'Kira ve Taksitler': 'Rent and Installments',
    'Ev/iş yeri kirası, ürün taksiti ve düzenli ödeme planları':
        'Home/workplace rent, product installments, and recurring payment plans',
    'Kira / taksit ekle': 'Add rent / installment',
    'Kira veya taksit kaydı bulunmuyor.':
        'No rent or installment records found.',
    'Tek dönem': 'One-time',
    'Bu dönem': 'This period',
    'Ödenmemiş toplam': 'Total outstanding',
    'Kayıt sahibi': 'Record owner',
    'Aşağıdaki bütün kayıtlar yalnızca seçili kişiye aittir.':
        'All records below belong only to the selected person.',
    'Kişi seçin': 'Select a person',
    'Kalan toplam': 'Total outstanding',
    'Bu ay planlanan': 'Scheduled this month',
    'Gecikmiş kayıt': 'Overdue record',
    'Kişi detaylarını aç': 'Open person details',
    'Arşivdekileri göster': 'Show archived records',
    'Kişi kaydı bulunamadı.': 'Person record not found.',
    'Gecikmiş kayıtlar': 'Overdue records',
    'Bu başlıkta kayıt bulunmuyor.': 'No records found under this heading.',
    'Kişi detayları': 'Person details',
    'Bu kişiye ait kayıtlar': 'Records for this person',
    'Bu kişiye bağlı açık ödeme kaydı yok.':
        'There are no outstanding payment records linked to this person.',
    'Kişiyi düzenle': 'Edit person',
    'Kişiyi sil': 'Delete person',
    'Banka Borçları': 'Bank Debts',
    'Banka grubu ekle': 'Add bank group',
    'Banka borcu yok': 'No bank debt',
    'Banka adı kullanıcı tarafından yazılır. Hazır banka markası veya logosu kullanılmaz.':
        'The bank name is entered by the user. No preset bank brand or logo is used.',
    'Banka grubu işlemleri': 'Bank group actions',
    'Banka grubunu sil': 'Delete bank group',
    'Grubu sil': 'Delete group',
    'Borç ekle': 'Add debt',
    'Grubu düzenle': 'Edit group',
    'Bu banka grubunda görüntülenecek borç bulunmuyor.':
        'There are no debt records to display in this bank group.',
    'Toplam ödeme': 'Total paid',
    'Ödeme ekle': 'Add payment',
    'Kayıt bilgileri': 'Record details',
    'Ödeme geçmişi': 'Payment history',
    'Yalnızca bu kayda bağlı ödemeler': 'Payments linked only to this record',
    'Ödeme yok': 'No payments',
    'Bu kayda henüz ödeme eklenmedi.':
        'No payments have been added to this record yet.',
    'Ödemeyi sil': 'Delete payment',
    'Ödeme planı': 'Payment plan',
    'Kalan borç': 'Outstanding debt',
    'Ödeme tarihi': 'Payment date',
    'Gecikme': 'Overdue',
    'Ödenmeyen aylar': 'Unpaid months',
    'Kalan taksit sayısı': 'Remaining installments',
    'Borç tarihi': 'Debt date',
    'Ödeme sıklığı': 'Payment frequency',
    'Düzenli ödeme': 'Regular payment',
    'Çek no': 'Cheque no.',
    'Senet no': 'Promissory note no.',
    'Kalan fatura': 'Outstanding bill',
    'Fatura düzeni': 'Billing schedule',
    'Ödeme günü': 'Payment day',
    'İlk fatura ayı': 'First billing month',
    'Kayıtlı değişken tutarlar': 'Saved variable amounts',
    'Abone no': 'Subscriber no.',
    'Sözleşme / tesisat no': 'Contract / installation no.',
    'Bu dönem kalan': 'Remaining this period',
    'Tekrar sıklığı': 'Repeat frequency',
    'Sözleşme no': 'Contract no.',
    'Kalan tutar': 'Remaining amount',
    'Kayıt türü': 'Record type',
    'İlk ödeme ayı': 'First payment month',
    'Sözleşme başlangıcı': 'Contract start',
    'Sözleşme bitişi': 'Contract end',
    'Kaydı sil': 'Delete record',
    'Bu işlem yalnız açık onayla yapılır.':
        'This action requires explicit confirmation.',
    'Toplam taksit': 'Total installments',
    'Kalan taksit sayısı toplam taksit sayısını aşamaz.':
        'Remaining installments cannot exceed total installments.',
    'Kalan taksit sayısı, kayıtlı taksit ödemeleriyle uyumlu değil.':
        'The remaining installment count is inconsistent with recorded installment payments.',
    'Hazır marka listesi yoktur; adı kullanıcı belirler.':
        'There is no preset brand list; the user enters the name.',
    'Borç ürünü ekle': 'Add debt product',
    'Borç ürününü düzenle': 'Edit debt product',
    'Borç türü': 'Debt type',
    'Başlık': 'Title',
    'Ödeme tarihi yöntemi': 'Due-date method',
    'Her ayın kaçıncı günü?': 'Which day of each month?',
    '1 ile 31 arasında bir gün girin.': 'Enter a day between 1 and 31.',
    'Aylık ödeme günü 1 ile 31 arasında olmalıdır.':
        'The monthly payment day must be between 1 and 31.',
    'İlk geçerli vade': 'First valid due date',
    'Güncel manuel gecikme günü': 'Current manual overdue days',
    'Yeni manuel gecikme günü (opsiyonel)':
        'New manual overdue days (optional)',
    'Takvimle otomatik artar. Diğer alanları kaydetmek bu gecikme referansını değiştirmez.':
        'This increases automatically with the calendar. Saving other fields does not change the overdue reference.',
    'Değer değiştirilirse referans tarihi bugün esas alınarak gecikme, bildirim ve rapor hesapları yeniden kurulur.':
        'If changed, overdue, notification, and report calculations are rebuilt using today as the reference date.',
    'Gecikme düzenlemesi açık': 'Overdue adjustment enabled',
    'Gecikme gününü değiştir': 'Change overdue days',
    'Gecikme günü 0 ile 3650 arasında olmalıdır.':
        'Overdue days must be between 0 and 3650.',
    'Kalan taksit sayısı (opsiyonel)': 'Remaining installments (optional)',
    'Ödeme kaydı eklendikçe otomatik azalır.':
        'Decreases automatically as payments are recorded.',
    'Limit (opsiyonel)': 'Limit (optional)',
    'Belirtilmemiş': 'Not specified',
    'Kaldırılacak': 'Will be removed',
    'Gecikme hesabını yeniden kur': 'Rebuild overdue calculation',
    'Bu işlem referans tarihini bugün esas alarak vade, gecikme, bildirim, rapor ve ödeme hesaplarını yeniden hesaplayacaktır.':
        'This action recalculates due dates, overdue status, notifications, reports, and payments using today as the reference date.',
    'Değişikliği onayla': 'Confirm change',
    'Gecikmiş aylar (opsiyonel)': 'Overdue months (optional)',
    'Ödenmeyen ayları seç. Gecikme, seçilen en eski ayın ödeme gününden bugüne otomatik hesaplanır.':
        'Select unpaid months. Overdue time is calculated automatically from the payment day of the earliest selected month through today.',
    'Gecikmiş ay ekle': 'Add overdue month',
    'Ay ve yıl seç': 'Select month and year',
    'Yıl': 'Year',
    'Seç': 'Select',
    'Faturayı düzenle': 'Edit bill',
    'Fatura türü': 'Bill type',
    'Varsayılan aylık tutar': 'Default monthly amount',
    'Her ayın kaçında ödenecek? (1-31)':
        'Which day of the month is it due? (1–31)',
    '29, 30 veya 31 seçildiğinde kısa aylarda ayın son geçerli günü kullanılır.':
        'When 29, 30, or 31 is selected, the last valid day is used in shorter months.',
    'Girilen tutarın ait olduğu ay': 'Month this amount belongs to',
    'Elektrik, su, doğalgaz ve benzeri faturaların tutarı her ay ayrı kaydedilir. Geçmiş ayların tutarı değiştirilmeden raporlarda gerçek ödeme kayıtları kullanılır.':
        'Amounts for electricity, water, natural gas, and similar bills are stored separately for each month. Reports use actual payment records without changing prior months\' amounts.',
    'Tesisat / sözleşme numarası': 'Installation / contract number',
    'Kira / taksiti düzenle': 'Edit rent / installment',
    'Kira başlığı': 'Rent title',
    'Ürün / taksit başlığı': 'Product / installment title',
    'Aylık kira tutarı': 'Monthly rent amount',
    'Toplam ürün bedeli': 'Total product price',
    'Aylık ödeme tutarı': 'Monthly payment amount',
    'Toplam tutar': 'Total amount',
    'Her ay tekrarlayan ödeme': 'Recurring monthly payment',
    'Kapalıysa kayıt tek ödeme olarak değerlendirilir.':
        'When off, the record is treated as a one-time payment.',
    '15 veya 20 gibi yalnız gün numarasını yazın; MİZAN takvimi kendisi takip eder.':
        'Enter only the day number, such as 15 or 20; MİZAN will track the calendar automatically.',
    'Ev sahibi / alıcı': 'Landlord / recipient',
    'Alıcı / satıcı adı': 'Buyer / seller name',
    'IBAN (opsiyonel)': 'IBAN (optional)',
    'Sözleşme başlangıcı (opsiyonel)': 'Contract start (optional)',
    'Sözleşme bitişi (opsiyonel)': 'Contract end (optional)',
    'Kira artış tarihi (opsiyonel)': 'Rent increase date (optional)',
    'Toplam taksit (opsiyonel)': 'Total installments (optional)',
    'Toplam taksit sayısını girin.': 'Enter the total number of installments.',
    'Kalan taksit (opsiyonel)': 'Remaining installments (optional)',
    'Son ödeme tarihi takvimden sabitlenmez. Girilen ödeme günü ve ilk ödeme ayı esas alınır; sonraki aylar gerçek takvime göre otomatik hesaplanır.':
        'The due date is not fixed to one calendar date. The entered payment day and first payment month are used; future months are calculated automatically from the actual calendar.',
    'Kişisel / kurumsal borcu düzenle': 'Edit personal / business debt',
    'Alacaklı türü': 'Creditor type',
    'Borcun oluştuğu tarih': 'Debt date',
    'Taksitli ödeme planı': 'Installment payment plan',
    'Açıksa taksit sayısı ve düzenli ödeme tutarı saklanır.':
        'When enabled, the installment count and regular payment amount are stored.',
    'Özel ödeme aralığı (gün)': 'Custom payment interval (days)',
    'Gün sayısını girin.': 'Enter the number of days.',
    'Toplam taksiti girin.': 'Enter total installments.',
    'Ödeme kaydı eklendikçe kalan taksit sayısı otomatik azalır.':
        'The remaining installment count decreases automatically as payments are recorded.',
    'Çeki düzenleyen kişi / kurum': 'Person / institution issuing the cheque',
    'Banka bilgisi (kullanıcı girişi)': 'Bank information (user entry)',
    'Senet adedi': 'Number of promissory notes',
    'Mevcut senet': 'Current promissory note',
    'Birden fazla senet varsa her biri ayrı vade satırı olarak oluşturulur.':
        'If there are multiple promissory notes, each is created as a separate due-date row.',
    'Aboneliği düzenle': 'Edit subscription',
    'Özel tür adı': 'Custom type name',
    'Dönem tutarı': 'Amount per period',
    'Özel tekrar aralığı (gün)': 'Custom repeat interval (days)',
    'Sıradaki ödeme tarihi': 'Next payment date',
    'Bu kaydın planlanan taksit/dönem tutarı otomatik kullanılır.':
        'The scheduled installment/period amount for this record is used automatically.',
    'Kalan borcun tamamı ödeme tutarı olarak otomatik kullanılır.':
        'The full remaining balance is used automatically as the payment amount.',
    'Kalan borcu aşmayacak ödeme tutarını kendin girebilirsin.':
        'You can enter a payment amount that does not exceed the remaining balance.',
    'Ödemeyi düzenle': 'Edit payment',
    'Ödeme türü': 'Payment type',
    'Ödeme tutarı kalan borçtan büyük olamaz.':
        'The payment amount cannot exceed the remaining balance.',
    'Otomatik tutar ödeme türüne göre hesaplandı. Kısmi ödeme seçilirse elle değiştirilebilir.':
        'The amount was calculated automatically based on the payment type. It can be edited when Partial payment is selected.',
    'Ödeme yöntemi (opsiyonel)': 'Payment method (optional)',
    'Ödeme notu (opsiyonel)': 'Payment note (optional)',
    'Seçilmedi': 'Not selected',
    'Tarihi temizle': 'Clear date',
    'Ödemeleri, giderleri ve kalan yükü aynı filtreyle doğru ve ayrıntılı gösterir.':
        'Shows payments, expenses, and outstanding obligations accurately and in detail using the same filter.',
    'Ödemelere yapılan gider': 'Payments made',
    'Normal giderler': 'Regular expenses',
    'Kalan ödeme yükü': 'Outstanding payment obligations',
    'Gecikmiş': 'Overdue',
    'Gelir ayrıntıları': 'Income details',
    'Serbest girilen gelir türleri ve seçili döneme düşen tutarları gösterilir.':
        'Shows user-entered income types and the amounts that fall within the selected period.',
    'Seçili dönemde gelir oluşmuyor.':
        'No income falls within the selected period.',
    'Gelir bilgisi belirtilmemiş.': 'No income information provided.',
    'Gerçekleşen harcamaların dağılımı': 'Actual spending breakdown',
    'Günlük harcamalar ve ödeme geçmişi ayrı kaynaklar olarak, en yüksek tutardan en düşüğe sıralanır.':
        'Daily expenses and payment history are treated as separate sources and sorted from highest to lowest amount.',
    'Gerçekleşen ödeme ayrıntıları': 'Recorded payment details',
    'Kişi, kayıt, ödeme türü, tarih ve tutar birbirine karışmadan listelenir.':
        'Person, record, payment type, date, and amount are listed without mixing their relationships.',
    'Seçili kapsamda gerçekleşen ödeme bulunmuyor.':
        'No recorded payments were found within the selected scope.',
    'Kalan ödeme yükünün dağılımı': 'Outstanding payment breakdown',
    'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme ve taksit tutarları gösterilir.':
        'Shows the next payments and installments that fall within the selected period, not the entire debt balance.',
    'Kalan ödeme ayrıntıları': 'Outstanding payment details',
    'Seçili dönemde açık ödeme yükü bulunmuyor.':
        'There are no outstanding payment obligations in the selected period.',
    'Gider dağılımı': 'Spending breakdown',
    'Normal giderler ile ödeme kayıtları aynı toplamda yer alır; kaynak türleri ayrı etiketlerle gösterilir.':
        'Regular expenses and payment records are included in the same total while their source types remain separately labeled.',
    'Seçili dönemde gider veya ödeme kaydı yok.':
        'There are no expense or payment records in the selected period.',
    'Bütün harcama ayrıntıları': 'All spending details',
    'Her gün başlık olarak gösterilir. Başlığa dokununca günlük harcamalar ve ödemeler kendi bölümlerinde açılır.':
        'Each day is shown as a heading. Tap it to expand daily expenses and payments in their own sections.',
    'Seçili dönemde gider veya ödeme ayrıntısı bulunmuyor.':
        'No expense or payment details were found in the selected period.',
    'Kişi kapsamı': 'People included',
    'Tüm kişileri kapsa': 'Include all people',
    'Bütün kişilerin ödeme ve borç kayıtları rapora alınır.':
        'Payment and debt records for all people are included in the report.',
    'PDF hazırlanıyor.': 'Preparing PDF.',
    'MİZAN PDF raporunu kaydet': 'Save MİZAN PDF report',
    'PDF raporu kaydedildi.': 'PDF report saved.',
    'PDF raporu kaydedilemedi': 'PDF report could not be saved',
    'PDF raporu paylaşılamadı': 'PDF report could not be shared',
    'Normal gider ayrıntıları': 'Regular expense details',
    'Ödeme ayrıntıları': 'Payment details',
    'Kalan ödeme yükü ayrıntıları': 'Outstanding payment details',
    'Gecikmiş ödeme ayrıntıları': 'Overdue payment details',
    'Yaklaşan ödeme ayrıntıları': 'Upcoming payment details',
    'Normal giderler ve ödemeler ayrı başlıklar altında kalır; yalnız toplam hesaplamada birleşir.':
        'Regular expenses and payments remain under separate headings and are combined only when calculating totals.',
    'Seçili döneme taşınan gecikmiş kayıtlar ile dönemin açık ödeme yükü ayrıntılı gösterilir.':
        'Shows overdue records carried into the selected period together with the period\'s outstanding payment obligations.',
    'Gecikmiş tutar, açık ve ödenmemiş dönemlerin toplamıdır.':
        'The overdue amount is the total of open and unpaid periods.',
    'Raporun referans gününden itibaren önümüzdeki 7 gün içinde vadesi kalan açık kayıtlar gösterilir.':
        'Shows open records due within seven days of the report\'s reference date.',
    'Seçili kapsamda ayrıntı bulunmuyor.':
        'No details were found within the selected scope.',
    'Tüm kişiler': 'All people',
    'Rapor kapsamı': 'Report scope',
    'Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.':
        'The period and people filters are identical in the on-screen report and the PDF.',
    'Tüm kayıt geçmişi': 'Complete record history',
    'Kayıtlı ay bulunmuyor': 'No saved months found',
    'Kayıtlı yıl bulunmuyor': 'No saved years found',
    'Güncel ay her zaman açılır; geçmişte kayıt, ödeme, gider veya gelir bulunan aylar ayrıca seçilebilir.':
        'The current month is always available; previous months with records, payments, expenses, or income can also be selected.',
    'Güncel yıl her zaman açılır; kayıt bulunan geçmiş yıllar ayrıca seçilebilir.':
        'The current year is always available; previous years containing records can also be selected.',
    'İlk kayıttan bugüne kadar bütün ödeme, gider ve gelir hareketleri kapsanır.':
        'Includes all payment, expense, and income activity from the first record through today.',
    'Kalan kayıt durumu (opsiyonel)': 'Outstanding record status (optional)',
    'Tüm durumlar': 'All statuses',
    'Gider kayıtlarında kişi alanı bulunmadığı için giderler seçili dönem kapsamında ve kişi filtresinden bağımsız hesaplanır.':
        'Because expense records do not have a person field, expenses are calculated for the selected period independently of the people filter.',
    'Kayıtlı yılı seç': 'Select a saved year',
    'Kayıtlı ayı seç': 'Select a saved month',
    'Gelir ve net durum': 'Income and net position',
    'Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.':
        'Recorded payments and expenses are deducted from income in sequence.',
    'PDF raporu': 'PDF report',
    'Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.':
        'You can save the same report or send it to the share menu, including WhatsApp.',
    'PDF hazırlanıyor': 'Preparing PDF',
    'PDF indir': 'Download PDF',
    'PDF paylaş': 'Share PDF',
    'Seçili dönem gider özeti': 'Selected-period spending summary',
    'Bütün harcamalar, normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.':
        'All spending is the combined total of regular expenses and bank debt, personal debt, bill, subscription, rent, and installment payments.',
    'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerine yapılan giderlerin toplamıdır. Gelir ayrı gösterilir.':
        'The combined total of regular expenses and payments toward bank debt, personal debt, bills, subscriptions, rent, and installments. Income is shown separately.',
    'Gelir sonrası net': 'Net after income',
    'Kayıt bulunmuyor.': 'No records found.',
    'Daha fazla gider günü göster': 'Show more expense days',
    'Kişi bazında güncel kalan borç': 'Current outstanding debt by person',
    'Kişi ve kayıt türü başlıklarına dokunarak ayrıntıları açıp kapatabilirsiniz. Kayıt satırına dokununca tam kayıt detayı açılır.':
        'Tap person and record-type headings to expand or collapse details. Tap a record row to open its full details.',
    'Toplam kalan': 'Total outstanding',
    'Hafta': 'Week',
    'Tüm zamanlar': 'All time',
    'PDF rapor sayfası görüntüye dönüştürülemedi.':
        'The PDF report page could not be rendered as an image.',
    'Sayfa': 'Page',
    'finans raporu': 'financial report',
    'Kayıtlı kişi yok': 'No saved people',
    'GÜN BAŞLIĞI': 'DAY HEADING',
    'Rapor özeti': 'Report summary',
    'Ödeme kayıtları ve Giderler bölümü birbirine karıştırılmadan hesaplanır.':
        'Payment records and the Expenses section are calculated without mixing their sources.',
    'Ödemeler sonrası kalan gelir': 'Income remaining after payments',
    'Toplam gider sonrası net': 'Net after total spending',
    'Seçili dönemde kalan ödeme yükü':
        'Outstanding payment obligations in the selected period',
    'Gecikmiş ödeme yükü': 'Overdue payment obligations',
    'Yaklaşan ödeme yükü': 'Upcoming payment obligations',
    'Gelir türleri seçili döneme düşen tekrar sayısına göre hesaplanır.':
        'Income types are calculated by the number of occurrences falling within the selected period.',
    'Seçili dönem ve kişi kapsamındaki ödeme geçmişi kayıt türüne göre ayrılır.':
        'Payment history within the selected period and people scope is separated by record type.',
    'Her ödeme yalnız bağlı olduğu kişi ve kayıt altında gösterilir.':
        'Each payment is shown only under its linked person and record.',
    'Gecikmiş kayıtlarda gösterilen taksit ve ana para tutarlarına işleyebilecek faizler, gecikme bedelleri ve diğer olası durum etkenleri dahil değildir.':
        'Installment and principal amounts shown for overdue records do not include potential interest, late fees, or other factors that may apply.',
    'Ödeme kayıtları': 'Payment records',
    'Normal giderler ve ödeme kayıtları aynı rapor toplamına dahil edilir; kaynakları birbirine karıştırılmadan ayrı renklerle gösterilir.':
        'Regular expenses and payment records are included in the same report total and shown in separate colors without mixing their sources.',
    'Seçili dönemde gider veya ödeme kaydı bulunmuyor.':
        'There are no expense or payment records in the selected period.',
    'Günler başlık olarak gösterilir; her günün normal harcamaları ve ödemeleri kendi bölümünde, satır taşması olmadan listelenir.':
        'Days are shown as headings; each day\'s regular expenses and payments are listed in their own sections without text overflow.',
    'Seçili dönemde gider ayrıntısı bulunmuyor.':
        'No expense details were found in the selected period.',
    'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme/taksit tutarları gösterilir.':
        'Shows the next payment/installment amounts falling within the selected period, not the full debt balance.',
    'Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı birlikte sunulur.':
        'Due date, person, record type, overdue duration, and next payment amount are shown together.',
    'Seçili kişilerin bütün açık kayıtları, dönem filtresinden bağımsız güncel bakiye olarak sunulur.':
        'All open records for the selected people are shown as current balances independently of the period filter.',
    'Toplam güncel kalan borç': 'Total current outstanding debt',
    'Bildirim davranışı, yerel kayıt güvenliği ve yedekleme seçenekleri':
        'Notification behavior, local data security, and backup options',
    'Bildirim sistemi açık': 'Notification system enabled',
    'özel bildirim saati': 'custom notification times',
    'Hatırlatmayı düzenle': 'Edit reminder',
    'Durum ve saat': 'Status and time',
    'Bildirim saatini seç': 'Select notification time',
    'Saat ve dakika': 'Hour and minute',
    'Hatırlatma açık': 'Reminder enabled',
    'Seçilen vade günlerinde planlanır.':
        'Scheduled on the selected due dates.',
    'Kayıt korunur ancak bildirim oluşturulmaz.':
        'The record is preserved, but no notification is created.',
    'Dakik bildirim izni kapalı': 'Exact alarm permission is off',
    'MİZAN yaklaşık zamanlama kullanmaz. Kaydettiğinde gerekli Android izin ekranı otomatik açılır; izin verildiğinde bildirimler uygulamaya dönüşte otomatik senkronize edilir.':
        'MİZAN does not use approximate scheduling. When you save, the required Android permission screen opens automatically; after permission is granted, notifications synchronize when you return to the app.',
    '1 dakika sonra test bildirimi': 'Test notification in 1 minute',
    'Bu hatırlatmayı sil': 'Delete this reminder',
    'Ses ve titreşim davranışı': 'Sound and vibration behavior',
    'Bildirim sesi': 'Notification sound',
    'Titreşim': 'Vibration',
    'Sessiz ses seçildiğinde titreşim de kullanılmaz.':
        'Vibration is also disabled when Silent is selected.',
    'Hatırlatmayı sil': 'Delete reminder',
    'Diğer hatırlatmalar ve kayıtlar etkilenmez.':
        'Other reminders and records are not affected.',
    'MİZAN CSV yedeğini kaydet': 'Save MİZAN CSV backup',
    'CSV yedeği oluşturuldu.': 'CSV backup created.',
    'CSV yedeği oluşturulamadı': 'CSV backup could not be created',
    'MİZAN CSV yedeğini seç': 'Select MİZAN CSV backup',
    'Seçilen CSV dosyası okunamadı.':
        'The selected CSV file could not be read.',
    'CSV yedeği birleştirilemedi': 'CSV backup could not be merged',
    'CSV yedeğini birleştir': 'Merge CSV backup',
    'Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.':
        'Existing records will not be deleted or overwritten by matching data from the backup. Only new records and missing child relationships will be added.',
    'Yeni eklenecek': 'New records to add',
    'Eksik ilişkisi tamamlanacak': 'Missing relationships to complete',
    'Ortak kullanıcı kaydı: Yok': 'Matching user records: None',
    'Ortak kullanıcı kaydı atlanacak': 'Matching user records to skip',
    'Verileri birleştir': 'Merge data',
    'Bu alan boş bırakılamaz.': 'This field is required.',
    'Sabah gider': 'Morning expenses',
    'Bugünkü giderlerini işlemeyi unutma.':
        'Don\'t forget to record today\'s expenses.',
    'Öğlen gider': 'Midday expenses',
    'Öğlene kadar yaptığın harcamaları ekleyebilirsin.':
        'You can add the expenses you made before noon.',
    'Akşam gider': 'Evening expenses',
    'Günü kapatmadan giderlerini kontrol et.':
        'Review your expenses before ending the day.',
    'Günün ödeme planını gözden geçir.': 'Review today\'s payment plan.',
    'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.':
        'You must type I CONFIRM exactly to delete the category.',
    'CSV yedeği doğrulandı ve geri yüklendi.':
        'The CSV backup was verified and restored.',
    'CSV yedeği mevcut kayıtlarla birleştirildi: ':
        'The CSV backup was merged with existing records: ',
    'Banka': 'Bank',
    'Borç': 'Debt',
    'Kişisel/kurumsal borç': 'Personal/business debt',
    'Kira': 'Rent',
    'Gider': 'Expense',
    'Eski kayıttan aktarıldı': 'Imported from an older record',
    'Kalan toplam borç': 'Total outstanding debt',
    'Gecikmiş toplam': 'Total overdue',
    'Önümüzdeki 7 gün': 'Next 7 days',
    'Gelir': 'Income',
    'Abonelikler': 'Subscriptions',
    'Kategoriler': 'Categories',
    'ONAYLIYORUM': 'I CONFIRM',
    'Kategori': 'Category',
    'Tutar': 'Amount',
    'Taksit': 'Installment',
    'Ay': 'Month',
    'Bildirim': 'Notification',
    'CSV yedeği boş veya eksik.': 'The CSV backup is empty or incomplete.',
    'Bu dosya MİZAN CSV yedeği değil.': 'This file is not a MİZAN CSV backup.',
    'CSV tam yedek verisi geçersiz.': 'The full CSV backup data is invalid.',
    'CSV içinde tam MİZAN yedeği bulunamadı.':
        'No complete MİZAN backup was found in the CSV file.',
    'Kategorisiz': 'Uncategorized',
    'Günlük harcama': 'Daily expense',
    'Ödeme': 'Payment',
    'LEFFERION PRIME - MIZAN': 'LEFFERION PRIME - MIZAN',
    'LEFFERION PRIME - MİZAN': 'LEFFERION PRIME - MIZAN',
    'maaş': 'salary',
    'Maaş': 'Salary',
    'Banka borçları': 'Bank debts',
    'Kişisel ve kurumsal borçlar': 'Personal and business debts',
    'Kira ve taksitler': 'Rent and installments',
    'Daha fazla ödeme günü göster ': 'Show more payment days ',
    'Bu günden daha fazla göster ': 'Show more from this day ',
    'Günlük harcamalar': 'Daily expenses',
    'Gider ekle': 'Add expense',
    'Banka grubunu düzenle': 'Edit bank group',
    'Daha fazla gider günü göster ': 'Show more expense days ',
    'Kişi kaydı bulunmuyor.': 'No person records found.',
    'MİZAN full backup': 'MİZAN full backup',
    'MİZAN tam yedek': 'MİZAN full backup',
    'Yeniden eskiye': 'Newest first',
    'Eskiden yeniye': 'Oldest first',
    'En yüksek harcama günü': 'Highest-spending day',
    'En düşük harcama günü': 'Lowest-spending day',
    'Kişi kapsamı: Kayıtlı kişi yok': 'People included: No people recorded',
    'Toplam gider': 'Total spending',
    'Gider ayrıntıları': 'Expense details',
    'Ödeme hatırlatması 1': 'Payment reminder 1',
    'Ödeme hatırlatması 2': 'Payment reminder 2',
    'Ödeme hatırlatması 3': 'Payment reminder 3',
    'FileSystemException: ': 'File system error: ',
    'Invalid argument(s): ': 'Invalid argument: ',
    'FormatException: ': 'Invalid format: ',
  };
  static final List<_LocalizedPattern> _patterns = <_LocalizedPattern>[
    _LocalizedPattern(
      RegExp(r'^MİZAN (.+) Raporu$'),
      (m) => 'MİZAN ${m[1]} Report',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) finans raporu$'),
      (m) => '${m[1]} financial report',
    ),
    _LocalizedPattern(
      RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
      (m) => 'LEFFERION PRIME - MIZAN · Page ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) · devam$'),
      (m) => '${text(m[1]!)} · continued',
    ),
    _LocalizedPattern(RegExp(r'^Dönem: (.+)$'), (m) => 'Period: ${m[1]}'),
    _LocalizedPattern(
      RegExp(r'^Kişi kapsamı: (.+)$'),
      (m) => 'People included: ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^Oluşturulma: (.+)$'),
      (m) => 'Generated: ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
      (m) => 'Outstanding plan ${m[1]} · Paid this month ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) Ödeme Durumu$'),
      (m) => '${m[1]} Payment Status',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) açık kayıt · (.+)$'),
      (m) =>
          '${m[1]} ${m[1] == '1' ? "open record" : "open records"} · ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
      (m) =>
          '${m[1]} ${m[1] == '1' ? "daily expense" : "daily expenses"} · ${m[2]} ${m[2] == '1' ? "payment" : "payments"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
      (m) =>
          '${m[1]} ${m[1] == '1' ? "day" : "days"} · ${m[2]} ${m[2] == '1' ? "record" : "records"} · ${m[3]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) ödeme · (.+)$'),
      (m) => '${m[1]} ${m[1] == '1' ? "payment" : "payments"} · ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gider · (.+)$'),
      (m) => '${m[1]} ${m[1] == '1' ? "expense" : "expenses"} · ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gider kaydı$'),
      (m) => '${m[1]} ${m[1] == '1' ? "expense record" : "expense records"}',
    ),
    _LocalizedPattern(
      RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
      (m) => 'Show more days (${m[1]} remaining)',
    ),
    _LocalizedPattern(
      RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
      (m) => 'Show more payment days (${m[1]} remaining)',
    ),
    _LocalizedPattern(
      RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
      (m) => 'Show more expense days (${m[1]} remaining)',
    ),
    _LocalizedPattern(
      RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
      (m) => 'Show more from this day (${m[1]} remaining)',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) için (\d+) gün kaldı$'),
      (m) => '${m[1]} is due in ${m[2]} ${m[2] == '1' ? "day" : "days"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) bugün bekleniyor$'),
      (m) => '${m[1]} is expected today',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) (\d+) gün gecikti$'),
      (m) => '${m[1]} is ${m[2]} ${m[2] == '1' ? "day" : "days"} overdue',
    ),
    _LocalizedPattern(
      RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
      (m) => 'Last received: ${m[1]} · Scheduled ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(
        r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
      ),
      (m) =>
          'The period scheduled for ${m[1]} was recorded as received on ${m[2]}. The fixed payday was not changed.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) gerçek fatura tutarı$'),
      (m) => 'Actual bill amount for ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^Kalan tutar: (.+)$'),
      (m) => 'Remaining amount: ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^Kalan taksit: (\d+)$'),
      (m) => 'Remaining installments: ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
      (m) => 'Delete the expense record ${m[1]}?',
    ),
    _LocalizedPattern(
      RegExp(
        r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
      ),
      (m) =>
          'The ${m[1]} category and only the expenses assigned to it will be deleted.',
    ),
    _LocalizedPattern(
      RegExp(
        r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
      ),
      (m) =>
          '${m[1]} and all records linked to this person will be deleted. This action requires explicit confirmation.',
    ),
    _LocalizedPattern(
      RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
      (m) => 'The PDF report could not be saved: ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
      (m) => 'The PDF report could not be shared: ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(
        r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
      ),
      (m) =>
          '${m[1]} ${m[1] == '1' ? "entry" : "entries"} in the notification schedule could not be written to Android. First error: ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(
        r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
      ),
      (m) =>
          'The notification schedule could not be verified; ${m[1]} ${m[1] == '1' ? "entry is" : "entries are"} missing on Android.',
    ),
    _LocalizedPattern(
      RegExp(r'^Ödeme hatırlatması (\d+)$'),
      (m) => 'Payment reminder ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
      (m) => '${m[1]} new records; ${m[2]} relationships updated${m[3]}.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
      (m) => 'The ${m[1]} record ID is invalid or duplicated.',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gün kaldı$'),
      (m) => '${m[1]} ${m[1] == '1' ? "day" : "days"} remaining',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gün gecikmede$'),
      (m) => '${m[1]} ${m[1] == '1' ? "day" : "days"} overdue',
    ),
    _LocalizedPattern(
      RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
      (m) => 'Payment is ${m[1]} ${m[1] == '1' ? "day" : "days"} overdue.',
    ),
    _LocalizedPattern(
      RegExp(r'^Son ödeme (.+)\.$'),
      (m) => 'Due date: ${m[1]}.',
    ),
    _LocalizedPattern(
      RegExp(r'^Ödeme hatırlatması (\d+)$'),
      (m) => 'Payment reminder ${m[1]}',
    ),
    _LocalizedPattern(
      RegExp(r'^Ayın (\d+)\. günü$'),
      (m) => 'Day ${m[1]} of the month',
    ),
    _LocalizedPattern(
      RegExp(r'^Her ayın (\d+)\. günü$'),
      (m) => 'Day ${m[1]} of each month',
    ),
    _LocalizedPattern(RegExp(r'^Her (.+)$'), (m) => 'Every ${text(m[1]!)}'),
    _LocalizedPattern(RegExp(r'^Başlangıç: (.+)$'), (m) => 'Start: ${m[1]}'),
    _LocalizedPattern(RegExp(r'^Başlangıç (.+)$'), (m) => 'Start ${m[1]}'),
    _LocalizedPattern(RegExp(r'^Toplam (.+)$'), (m) => 'Total ${m[1]}'),
    _LocalizedPattern(RegExp(r'^Kalan (.+)$'), (m) => 'Remaining ${m[1]}'),
    _LocalizedPattern(RegExp(r'^Bu dönem (.+)$'), (m) => 'This period ${m[1]}'),
    _LocalizedPattern(RegExp(r'^Tarih: (.+)$'), (m) => 'Date: ${m[1]}'),
    _LocalizedPattern(RegExp(r'^Not: (.*)$'), (m) => 'Note: ${m[1]}'),
    _LocalizedPattern(
      RegExp(r'^(.+) boş bırakılamaz\.$'),
      (m) => '${text(m[1]!)} is required.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
      (m) => '${text(m[1]!)} can be no longer than ${m[2]} characters.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
      (m) => '${text(m[1]!)} must be greater than zero.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
      (m) => '${text(m[1]!)} must be greater than zero.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) negatif olamaz\.$'),
      (m) => '${text(m[1]!)} cannot be negative.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
      (m) => '${text(m[1]!)} must be a positive whole number.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
      (m) => '${text(m[1]!)} must be zero or a positive whole number.',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) kayıt$'),
      (m) => '${m[1]} ${m[1] == '1' ? "record" : "records"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) ödeme$'),
      (m) => '${m[1]} ${m[1] == '1' ? "payment" : "payments"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gider$'),
      (m) => '${m[1]} ${m[1] == '1' ? "expense" : "expenses"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(\d+) gider kaydı$'),
      (m) => '${m[1]} ${m[1] == '1' ? "expense record" : "expense records"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) · (\d+) kayıt$'),
      (m) => '${m[1]} · ${m[2]} ${m[2] == '1' ? "record" : "records"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) gün$'),
      (m) => '${m[1]} ${m[1] == '1' ? "day" : "days"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) ay$'),
      (m) => '${m[1]} ${m[1] == '1' ? "month" : "months"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) kişi seçili$'),
      (m) => '${m[1]} ${m[1] == '1' ? "person selected" : "people selected"}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
      (m) =>
          '${m[1]} ${m[1] == '1' ? "new record was" : "new records were"} added; existing data was preserved.',
    ),
    _LocalizedPattern(
      RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
      (m) => 'The test was scheduled exactly for ${m[1]}.',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) kaydedilemedi: (.+)$'),
      (m) => '${text(m[1]!)} could not be saved: ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) oluşturulamadı: (.+)$'),
      (m) => '${text(m[1]!)} could not be created: ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) paylaşılamadı: (.+)$'),
      (m) => '${text(m[1]!)} could not be shared: ${m[2]}',
    ),
    _LocalizedPattern(
      RegExp(r'^(.+) birleştirilemedi: (.+)$'),
      (m) => '${text(m[1]!)} could not be merged: ${m[2]}',
    ),
  ];
  static const List<(String, String)> _phrases = <(String, String)>[
    // Longest fragments must stay first. This fallback is only for strings
    // containing runtime values; fixed copy belongs in [_english].
    ('Kişisel ve kurumsal borçlar', 'Personal and business debts'),
    ('Kişisel / kurumsal borç', 'Personal / business debt'),
    ('Kişisel/kurumsal borç', 'Personal/business debt'),
    ('Ödemelere yapılan gider', 'Payments made'),
    ('Bu ay yapılan', 'Paid this month'),
    ('Açık plan', 'Outstanding plan'),
    ('Kalan tutar', 'Remaining amount'),
    ('Kalan toplam borç', 'Total outstanding debt'),
    ('Gecikmiş toplam', 'Total overdue'),
    ('Önümüzdeki 7 gün', 'Next 7 days'),
    ('Son ödeme bugün', 'Due today'),
    ('Banka borçları', 'Bank debts'),
    ('Kira ve taksitler', 'Rent and installments'),
    ('Günlük harcamalar', 'Daily expenses'),
    ('Gider ayrıntıları', 'Expense details'),
    ('Ödeme ayrıntıları', 'Payment details'),
    ('Gerçekleşen ödeme', 'Completed payment'),
    ('Ödeme kayıtları', 'Payment records'),
    ('Normal giderler', 'Regular expenses'),
    ('Toplam gider', 'Total spending'),
    ('Kalan ödeme yükü', 'Outstanding payment burden'),
    ('Gecikmiş ödeme yükü', 'Overdue payment burden'),
    ('Yaklaşan ödeme yükü', 'Upcoming payment burden'),
    ('Kişi kapsamı', 'People included'),
    ('Oluşturulma', 'Generated'),
    ('Dönem', 'Period'),
    ('devam', 'continued'),
  ];
}

class _LocalizedPattern {
  const _LocalizedPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match) builder;
}

extension MizanLocalizedString on String {
  String get l10n => MizanI18n.text(this);
}
