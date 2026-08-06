import 'dart:convert';

import 'package:flutter/material.dart' as material;

import 'mizan_i18n_legacy.dart' as legacy;
import 'mizan_ur.dart';
import 'mizan_ur_dynamic.dart';

/// Runtime localization facade.
///
/// The previously accepted languages are delegated byte-for-byte to the
/// preserved legacy runtime. Urdu is added here without changing any earlier
/// language map or dynamic grammar implementation.
abstract final class MizanI18n {
  static const supportedLanguageTags = <String>{
    ...legacy.MizanI18n.supportedLanguageTags,
    'ur',
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

  static String get destructiveConfirmation => isUrdu
      ? 'میں تصدیق کرتا ہوں'
      : legacy.MizanI18n.destructiveConfirmation;

  static String normalizeLanguageTag(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('_', '-');
    if (normalized == 'ur' || normalized.startsWith('ur-')) return 'ur';
    return legacy.MizanI18n.normalizeLanguageTag(value);
  }

  static bool isSupported(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('_', '-');
    return normalized == 'ur' ||
        normalized.startsWith('ur-') ||
        legacy.MizanI18n.isSupported(value);
  }

  static void setLanguageTag(String? value) {
    _languageTag = normalizeLanguageTag(value);
    legacy.MizanI18n.setLanguageTag(isUrdu ? 'tr' : _languageTag);
  }

  static void setProfile({String? languageTag, String? currencyCode}) {
    setLanguageTag(languageTag);
    final normalizedCurrency = (currencyCode ?? '').trim().toUpperCase();
    _currencyCode = RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency)
        ? normalizedCurrency
        : 'TRY';
    legacy.MizanI18n.setProfile(
      languageTag: isUrdu ? 'tr' : _languageTag,
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

  static String text(String source, {String? languageTag}) {
    final effective = languageTag == null
        ? _languageTag
        : normalizeLanguageTag(languageTag);
    if (effective != 'ur') {
      return legacy.MizanI18n.text(source, languageTag: effective);
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

    var result = visibleSource.isEmpty
        ? visibleSource
        : (mizanUrdu[visibleSource] ??
              translateUrduReviewedDynamic(
                visibleSource,
                (value) => text(value, languageTag: 'ur'),
              ));
    for (final entry in protected.entries) {
      result = result.replaceAll(entry.key, '\u2068${entry.value}\u2069');
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
