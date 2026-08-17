import 'dart:convert';

import 'package:flutter/material.dart' as material;

import 'mizan_i18n_legacy.dart' as legacy;
import 'mizan_fil.dart';
import 'mizan_fil_dynamic.dart';
import 'mizan_id.dart';
import 'mizan_id_dynamic.dart';
import 'mizan_ja.dart';
import 'mizan_ja_dynamic.dart';
import 'mizan_ko.dart';
import 'mizan_ko_dynamic.dart';
import 'mizan_ms.dart';
import 'mizan_ms_dynamic.dart';
import 'mizan_sw.dart';
import 'mizan_sw_dynamic.dart';
import 'mizan_th.dart';
import 'mizan_th_dynamic.dart';
import 'mizan_ur.dart';
import 'mizan_ur_dynamic.dart';
import 'mizan_vi.dart';
import 'mizan_vi_dynamic.dart';
import 'mizan_zh.dart';
import 'mizan_zh_dynamic.dart';

/// Runtime localization facade. Previously accepted languages remain delegated
/// byte-for-byte to the preserved legacy runtime. New languages are isolated
/// additions and never rewrite earlier language data.
abstract final class MizanI18n {
  static const supportedLanguageTags = <String>{
    ...legacy.MizanI18n.supportedLanguageTags,
    'ur',
    'id',
    'ms',
    'fil',
    'ko',
    'ja',
    'zh',
    'vi',
    'th',
    'sw',
  };

  static String _languageTag = 'tr';
  static String _currencyCode = 'TRY';
  static String get languageTag => _languageTag;
  static String get currencyCode => _currencyCode;
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
  static bool get isUrdu => _languageTag == 'ur';
  static bool get isIndonesian => _languageTag == 'id';
  static bool get isMalay => _languageTag == 'ms';
  static bool get isFilipino => _languageTag == 'fil';
  static bool get isKorean => _languageTag == 'ko';
  static bool get isJapanese => _languageTag == 'ja';
  static bool get isChinese => _languageTag == 'zh';
  static bool get isVietnamese => _languageTag == 'vi';
  static bool get isThai => _languageTag == 'th';
  static bool get isSwahili => _languageTag == 'sw';

  static const _runtimeLabelValueKeys = <String>{
    'Aylık tutar',
    'Ödeme tarihi',
    'Gecikme',
    'Ödenmeyen aylar',
    'Kalan taksit sayısı',
    'Limit',
    'Kullanılan limit',
    'Borç tarihi',
    'Ödeme sıklığı',
    'Düzenli ödeme',
    'Çek no',
    'Düzenleyen',
    'Banka bilgisi',
    'Senet no',
    'Senet',
    'Fatura düzeni',
    'Ödeme günü',
    'İlk fatura ayı',
    'Kayıtlı değişken tutarlar',
    'Abone no',
    'Sözleşme / tesisat no',
    'Tekrar sıklığı',
    'Sözleşme no',
    'Kayıt türü',
    'İlk ödeme ayı',
    'IBAN',
    'Sözleşme başlangıcı',
    'Sözleşme bitişi',
  };

  static const _runtimeUserValueLabels = <String>{
    'Çek no',
    'Düzenleyen',
    'Banka bilgisi',
    'Senet no',
    'Abone no',
    'Sözleşme / tesisat no',
    'Sözleşme no',
    'IBAN',
  };

  static final RegExp _runtimeLocalizableValue = RegExp(
    r'^(?:Her ayın \d+\. günü|\d+ gün|\d+ ay)$',
  );

  static String get destructiveConfirmation => switch (_languageTag) {
    'ur' => 'میں تصدیق کرتا ہوں',
    'id' => 'SAYA SETUJU',
    'ms' => 'SAYA SAHKAN',
    'fil' => 'KINUKUMPIRMA KO',
    'ko' => '확인합니다',
    'ja' => '確認します',
    'zh' => '我确认',
    'vi' => 'TÔI XÁC NHẬN',
    'th' => 'ยืนยัน',
    'sw' => 'NINATHIBITISHA',
    _ => legacy.MizanI18n.destructiveConfirmation,
  };

  static String normalizeLanguageTag(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('_', '-');
    if (normalized == 'ur' || normalized.startsWith('ur-')) return 'ur';
    if (normalized == 'id' ||
        normalized.startsWith('id-') ||
        normalized == 'in' ||
        normalized.startsWith('in-'))
      return 'id';
    if (normalized == 'ms' || normalized.startsWith('ms-')) return 'ms';
    if (normalized == 'fil' ||
        normalized.startsWith('fil-') ||
        normalized == 'tl' ||
        normalized.startsWith('tl-'))
      return 'fil';
    if (normalized == 'ko' || normalized.startsWith('ko-')) return 'ko';
    if (normalized == 'ja' || normalized.startsWith('ja-')) return 'ja';
    if (normalized == 'zh' ||
        normalized.startsWith('zh-') ||
        normalized == 'zh-cn' ||
        normalized == 'zh-hans' ||
        normalized.startsWith('zh-hans-'))
      return 'zh';
    if (normalized == 'vi' || normalized.startsWith('vi-')) return 'vi';
    if (normalized == 'th' || normalized.startsWith('th-')) return 'th';
    if (normalized == 'sw' || normalized.startsWith('sw-')) return 'sw';
    return legacy.MizanI18n.normalizeLanguageTag(value);
  }

  static bool isSupported(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('_', '-');
    return normalized == 'ur' ||
        normalized.startsWith('ur-') ||
        normalized == 'id' ||
        normalized.startsWith('id-') ||
        normalized == 'in' ||
        normalized.startsWith('in-') ||
        normalized == 'ms' ||
        normalized.startsWith('ms-') ||
        normalized == 'fil' ||
        normalized.startsWith('fil-') ||
        normalized == 'tl' ||
        normalized.startsWith('tl-') ||
        normalized == 'ko' ||
        normalized.startsWith('ko-') ||
        normalized == 'ja' ||
        normalized.startsWith('ja-') ||
        normalized == 'zh' ||
        normalized.startsWith('zh-') ||
        normalized == 'vi' ||
        normalized.startsWith('vi-') ||
        normalized == 'th' ||
        normalized.startsWith('th-') ||
        normalized == 'sw' ||
        normalized.startsWith('sw-') ||
        legacy.MizanI18n.isSupported(value);
  }

  static bool get _usesIsolatedRuntime =>
      isUrdu ||
      isIndonesian ||
      isMalay ||
      isFilipino ||
      isKorean ||
      isJapanese ||
      isChinese ||
      isVietnamese ||
      isThai ||
      isSwahili;

  static bool _isRtlLanguage(String languageTag) =>
      const {'ar', 'fa', 'he', 'ur'}.contains(languageTag);

  static void setLanguageTag(String? value) {
    _languageTag = normalizeLanguageTag(value);
    legacy.MizanI18n.setLanguageTag(_usesIsolatedRuntime ? 'tr' : _languageTag);
  }

  static void setProfile({String? languageTag, String? currencyCode}) {
    setLanguageTag(languageTag);
    final normalizedCurrency = (currencyCode ?? '').trim().toUpperCase();
    _currencyCode = RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency)
        ? normalizedCurrency
        : 'TRY';
    legacy.MizanI18n.setProfile(
      languageTag: _usesIsolatedRuntime ? 'tr' : _languageTag,
      currencyCode: _currencyCode,
    );
  }

  static String user(String value) => legacy.MizanI18n.user(value);

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

  static String _repairRuntimeLabelValue(
    String source,
    String translated,
    String languageTag,
  ) {
    if (languageTag == 'tr') return translated;
    final separator = source.indexOf(': ');
    if (separator <= 0) return translated;

    final sourceLabel = source.substring(0, separator);
    if (!_runtimeLabelValueKeys.contains(sourceLabel)) return translated;

    final localizedLabel = text(sourceLabel, languageTag: languageTag);
    if (localizedLabel.trim().isEmpty) return translated;

    final sourceValue = source.substring(separator + 2);
    String visibleValue;
    if (_runtimeUserValueLabels.contains(sourceLabel)) {
      visibleValue = sourceValue;
      if (_isRtlLanguage(languageTag) &&
          !sourceValue.contains('__MIZAN_USER_')) {
        visibleValue = '\u2068$sourceValue\u2069';
      }
    } else if (_runtimeLocalizableValue.hasMatch(sourceValue)) {
      visibleValue = text(sourceValue, languageTag: languageTag);
    } else {
      visibleValue = sourceValue;
    }
    return '$localizedLabel: $visibleValue';
  }

  static String text(String source, {String? languageTag}) {
    final effective = languageTag == null
        ? _languageTag
        : normalizeLanguageTag(languageTag);
    const isolated = <String>{
      'ur',
      'id',
      'ms',
      'fil',
      'ko',
      'ja',
      'zh',
      'vi',
      'th',
      'sw',
    };
    if (!isolated.contains(effective)) {
      final translated = legacy.MizanI18n.text(source, languageTag: effective);
      return _repairRuntimeLabelValue(source, translated, effective);
    }

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

    String result;
    if (visibleSource.isEmpty) {
      result = visibleSource;
    } else if (effective == 'ur') {
      result =
          mizanUrdu[visibleSource] ??
          translateUrduReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ur'),
          );
    } else if (effective == 'id') {
      result =
          mizanIndonesian[visibleSource] ??
          translateIndonesianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'id'),
          );
    } else if (effective == 'ms') {
      result =
          mizanMalay[visibleSource] ??
          translateMalayReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ms'),
          );
    } else if (effective == 'fil') {
      result =
          mizanFilipino[visibleSource] ??
          translateFilipinoReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fil'),
          );
    } else if (effective == 'ko') {
      result =
          mizanKorean[visibleSource] ??
          translateKoreanReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ko'),
          );
    } else if (effective == 'ja') {
      result =
          mizanJapanese[visibleSource] ??
          translateJapaneseReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ja'),
          );
    } else if (effective == 'zh') {
      result =
          mizanChinese[visibleSource] ??
          translateChineseReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'zh'),
          );
    } else if (effective == 'vi') {
      result =
          mizanVietnamese[visibleSource] ??
          translateVietnameseReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'vi'),
          );
    } else if (effective == 'th') {
      result =
          mizanThai[visibleSource] ??
          translateThaiReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'th'),
          );
    } else {
      result =
          mizanSwahili[visibleSource] ??
          translateSwahiliReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'sw'),
          );
    }

    result = _repairRuntimeLabelValue(visibleSource, result, effective);
    for (final entry in protected.entries) {
      final visibleUser = effective == 'ur'
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
}
