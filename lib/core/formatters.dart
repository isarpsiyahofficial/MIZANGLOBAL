import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';

String _arabicDigits(String value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], eastern[index]);
  }
  return result;
}

String _persianDigits(String value) {
  const western = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], persian[index]);
  }
  return result;
}

String _westernDigits(String value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result
        .replaceAll(eastern[index], western[index])
        .replaceAll(persian[index], western[index]);
  }
  return result;
}

String _ltrIsolate(String value) => '\u2066$value\u2069';

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isSameMonth(DateTime value, DateTime month) =>
    value.year == month.year && value.month == month.month;

int calendarDaysBetween(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

String money(num value) {
  final safe = value.isFinite ? value.toDouble() : 0.0;
  final negative = safe < 0;
  final absolute = safe.abs();
  final fixed = absolute.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integerPart = parts.first;
  final decimalPart = parts.last;
  final grouped = StringBuffer();
  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : ((MizanI18n.isFrench || MizanI18n.isPolish)
            ? '\u202F'
            : ((MizanI18n.isArabic || MizanI18n.isPersian)
                  ? '\u066C'
                  : ((MizanI18n.isRussian || MizanI18n.isUkrainian)
                        ? '\u00A0'
                        : (MizanI18n.isPortuguesePt ? ' ' : '.'))));
  final decimalSeparator = MizanI18n.isEnglish
      ? '.'
      : ((MizanI18n.isArabic || MizanI18n.isPersian) ? '\u066B' : ',');
  for (var index = 0; index < integerPart.length; index++) {
    grouped.write(integerPart[index]);
    final remaining = integerPart.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      grouped.write(groupSeparator);
    }
  }
  final rawAmount =
      '${negative ? '-' : ''}${grouped.toString()}$decimalSeparator$decimalPart';
  final amount = MizanI18n.isArabic
      ? _arabicDigits(rawAmount)
      : (MizanI18n.isPersian ? _persianDigits(rawAmount) : rawAmount);
  final code = MizanI18n.currencyCode;
  if (MizanI18n.isTurkish && code == 'TRY') {
    return '$amount TL';
  }
  if (MizanI18n.isPortugueseBr && code == 'BRL') {
    return 'R\$ $amount';
  }
  if (MizanI18n.isPortuguesePt && code == 'EUR') {
    return '$amount €';
  }
  if (MizanI18n.isDutch) {
    return code == 'EUR' ? '€\u00A0$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isPolish) {
    if (code == 'PLN') return '$amount\u00A0zł';
    return '$amount\u00A0$code';
  }
  if (MizanI18n.isRomanian) {
    if (code == 'RON') return '$amount\u00A0lei';
    return '$amount\u00A0$code';
  }
  if (MizanI18n.isGreek) {
    if (code == 'EUR') return '$amount\u00A0€';
    return '$amount\u00A0$code';
  }
  if (MizanI18n.isRussian) {
    if (code == 'RUB') return '$amount\u00A0₽';
    return '$amount\u00A0$code';
  }
  if (MizanI18n.isUkrainian) {
    if (code == 'UAH') return '$amount\u00A0₴';
    return '$amount\u00A0$code';
  }
  if (MizanI18n.isArabic) {
    if (code == 'SAR') return '$amount\u00A0ر.س';
    if (code == 'AED') return '$amount\u00A0د.إ';
    return '$amount\u00A0${_ltrIsolate(code)}';
  }
  if (MizanI18n.isPersian) {
    if (code == 'IRR') return '$amount\u00A0ریال';
    return '$amount\u00A0${_ltrIsolate(code)}';
  }
  if (MizanI18n.isFrench || MizanI18n.isGerman || MizanI18n.isItalian) {
    return code == 'EUR' ? '$amount\u00A0€' : '$amount\u00A0$code';
  }
  return '$code $amount';
}

String decimalText(num value) {
  final rounded = value.toStringAsFixed(2);
  final hasDecimals = !rounded.endsWith('.00');
  final rawInteger = hasDecimals
      ? rounded.substring(0, rounded.length - 3)
      : rounded.substring(0, rounded.length - 3);
  var integerPart = rawInteger;
  if (MizanI18n.isPolish ||
      MizanI18n.isRomanian ||
      MizanI18n.isGreek ||
      MizanI18n.isRussian ||
      MizanI18n.isUkrainian ||
      MizanI18n.isArabic ||
      MizanI18n.isPersian) {
    final negative = integerPart.startsWith('-');
    final digits = negative ? integerPart.substring(1) : integerPart;
    final grouped = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      grouped.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        grouped.write(
          (MizanI18n.isArabic || MizanI18n.isPersian)
              ? '\u066C'
              : ((MizanI18n.isRomanian || MizanI18n.isGreek)
                    ? '.'
                    : (MizanI18n.isPolish ? '\u202F' : '\u00A0')),
        );
      }
    }
    integerPart = '${negative ? '-' : ''}${grouped.toString()}';
  }
  if (!hasDecimals) {
    return MizanI18n.isArabic
        ? _arabicDigits(integerPart)
        : (MizanI18n.isPersian ? _persianDigits(integerPart) : integerPart);
  }
  final decimalPart = rounded.substring(rounded.length - 2);
  if (MizanI18n.isEnglish) return '$rawInteger.$decimalPart';
  if (MizanI18n.isArabic) {
    return _arabicDigits('$integerPart\u066B$decimalPart');
  }
  if (MizanI18n.isPersian) {
    return _persianDigits('$integerPart\u066B$decimalPart');
  }
  return '$integerPart,$decimalPart';
}

double parseMoney(String input) {
  var clean = _westernDigits(input)
      .replaceAll('\u066C', ',')
      .replaceAll('\u066B', '.')
      .trim()
      .toLowerCase()
      .replaceAll('₺', '')
      .replaceAll('tl', '')
      .replaceAll(RegExp(r'\s+'), '');
  if (clean.isEmpty) {
    throw FormatException(MizanI18n.text('Tutar boş bırakılamaz.'));
  }
  final negative = clean.startsWith('-');
  clean = clean.replaceAll('-', '');
  if (!RegExp(r'^\d+[\d.,]*$').hasMatch(clean)) {
    throw FormatException(MizanI18n.text('Geçerli bir para tutarı girin.'));
  }

  final commaCount = ','.allMatches(clean).length;
  final dotCount = '.'.allMatches(clean).length;
  String normalized;

  if (commaCount > 0 && dotCount > 0) {
    final lastComma = clean.lastIndexOf(',');
    final lastDot = clean.lastIndexOf('.');
    final decimalSeparator = lastComma > lastDot ? ',' : '.';
    final thousandsSeparator = decimalSeparator == ',' ? '.' : ',';
    normalized = clean.replaceAll(thousandsSeparator, '');
    normalized = normalized.replaceAll(decimalSeparator, '.');
  } else if (commaCount + dotCount == 0) {
    normalized = clean;
  } else {
    final separator = commaCount > 0 ? ',' : '.';
    final count = commaCount + dotCount;
    if (count > 1) {
      final segments = clean.split(separator);
      final allThousands = segments.skip(1).every((part) => part.length == 3);
      if (!allThousands) {
        throw FormatException(MizanI18n.text('Tutar biçimi anlaşılamadı.'));
      }
      normalized = segments.join();
    } else {
      final separatorIndex = clean.indexOf(separator);
      final decimals = clean.length - separatorIndex - 1;
      if (decimals == 0) {
        normalized = clean.substring(0, separatorIndex);
      } else if (decimals <= 2) {
        normalized = clean.replaceAll(separator, '.');
      } else if (decimals == 3 && separatorIndex > 0) {
        normalized = clean.replaceAll(separator, '');
      } else {
        throw FormatException(
          MizanI18n.text('En fazla iki kuruş hanesi girilebilir.'),
        );
      }
    }
  }

  final parsed = double.tryParse(normalized);
  if (parsed == null || !parsed.isFinite) {
    throw FormatException(MizanI18n.text('Geçerli bir para tutarı girin.'));
  }
  final result = negative ? -parsed : parsed;
  return double.parse(result.toStringAsFixed(2));
}

double parsePositiveDecimal(String input, {String fieldName = 'Değer'}) {
  final normalized = _westernDigits(input)
      .replaceAll('\u066C', '')
      .replaceAll('\u066B', '.')
      .trim()
      .replaceAll(',', '.');
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || value <= 0) {
    throw FormatException(MizanI18n.text('$fieldName sıfırdan büyük olmalı.'));
  }
  return value;
}

int? parseOptionalPositiveInt(String input, {String fieldName = 'Değer'}) {
  final clean = _westernDigits(input).trim();
  if (clean.isEmpty) {
    return null;
  }
  final value = int.tryParse(clean);
  if (value == null || value <= 0) {
    throw FormatException(
      MizanI18n.text('$fieldName pozitif tam sayı olmalı.'),
    );
  }
  return value;
}

int? parseOptionalNonNegativeInt(String input, {String fieldName = 'Değer'}) {
  final clean = _westernDigits(input).trim();
  if (clean.isEmpty) {
    return null;
  }
  final value = int.tryParse(clean);
  if (value == null || value < 0) {
    throw FormatException(
      MizanI18n.text('$fieldName sıfır veya pozitif tam sayı olmalı.'),
    );
  }
  return value;
}

String shortDate(DateTime value) {
  const trMonths = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];
  const enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const esMonths = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  const ptBrMonths = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  const frMonths = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  const deMonths = [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Juni',
    'Juli',
    'Aug.',
    'Sept.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];
  const itMonths = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];
  const nlMonths = [
    'jan',
    'feb',
    'mrt',
    'apr',
    'mei',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'dec',
  ];
  const plMonths = [
    'sty',
    'lut',
    'mar',
    'kwi',
    'maj',
    'cze',
    'lip',
    'sie',
    'wrz',
    'paź',
    'lis',
    'gru',
  ];
  const roMonths = [
    'ian.',
    'feb.',
    'mar.',
    'apr.',
    'mai',
    'iun.',
    'iul.',
    'aug.',
    'sept.',
    'oct.',
    'nov.',
    'dec.',
  ];
  const elMonths = [
    'Ιαν',
    'Φεβ',
    'Μαρ',
    'Απρ',
    'Μαΐ',
    'Ιουν',
    'Ιουλ',
    'Αυγ',
    'Σεπ',
    'Οκτ',
    'Νοε',
    'Δεκ',
  ];
  const ruMonths = [
    'янв.',
    'февр.',
    'мар.',
    'апр.',
    'мая',
    'июн.',
    'июл.',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.',
  ];
  const ukMonths = [
    'січ.',
    'лют.',
    'бер.',
    'квіт.',
    'трав.',
    'черв.',
    'лип.',
    'серп.',
    'вер.',
    'жовт.',
    'лист.',
    'груд.',
  ];
  const arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  const faMonths = [
    'ژانویه',
    'فوریه',
    'مارس',
    'آوریل',
    'مه',
    'ژوئن',
    'ژوئیه',
    'اوت',
    'سپتامبر',
    'اکتبر',
    'نوامبر',
    'دسامبر',
  ];
  if (MizanI18n.isEnglish) {
    return '${enMonths[value.month - 1]} ${value.day}, ${value.year}';
  }
  if (MizanI18n.isGerman) {
    return '${value.day}. ${deMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isItalian) {
    return '${value.day} ${itMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isDutch) {
    return '${value.day} ${nlMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isPolish) {
    return '${value.day} ${plMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRomanian) {
    return '${value.day} ${roMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isGreek) {
    return '${value.day} ${elMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRussian) {
    return '${value.day} ${ruMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isUkrainian) {
    return '${value.day} ${ukMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isArabic) {
    return _arabicDigits(
      '${value.day} ${arMonths[value.month - 1]} ${value.year}',
    );
  }
  if (MizanI18n.isPersian) {
    return _persianDigits(
      '${value.day} ${faMonths[value.month - 1]} ${value.year}',
    );
  }
  final months = MizanI18n.isSpanish
      ? esMonths
      : (MizanI18n.isFrench
            ? frMonths
            : ((MizanI18n.isPortugueseBr || MizanI18n.isPortuguesePt)
                  ? ptBrMonths
                  : trMonths));
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String monthLabel(DateTime value) {
  const trMonths = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  const enMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  const esMonths = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  const ptBrMonths = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  const frMonths = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  const deMonths = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  const itMonths = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];
  const nlMonths = [
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
  const plMonths = [
    'styczeń',
    'luty',
    'marzec',
    'kwiecień',
    'maj',
    'czerwiec',
    'lipiec',
    'sierpień',
    'wrzesień',
    'październik',
    'listopad',
    'grudzień',
  ];
  const roMonths = [
    'ianuarie',
    'februarie',
    'martie',
    'aprilie',
    'mai',
    'iunie',
    'iulie',
    'august',
    'septembrie',
    'octombrie',
    'noiembrie',
    'decembrie',
  ];
  const elMonths = [
    'Ιανουάριος',
    'Φεβρουάριος',
    'Μάρτιος',
    'Απρίλιος',
    'Μάιος',
    'Ιούνιος',
    'Ιούλιος',
    'Αύγουστος',
    'Σεπτέμβριος',
    'Οκτώβριος',
    'Νοέμβριος',
    'Δεκέμβριος',
  ];
  const ruMonths = [
    'январь',
    'февраль',
    'март',
    'апрель',
    'май',
    'июнь',
    'июль',
    'август',
    'сентябрь',
    'октябрь',
    'ноябрь',
    'декабрь',
  ];
  const ukMonths = [
    'січень',
    'лютий',
    'березень',
    'квітень',
    'травень',
    'червень',
    'липень',
    'серпень',
    'вересень',
    'жовтень',
    'листопад',
    'грудень',
  ];
  const arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  const faMonths = [
    'ژانویه',
    'فوریه',
    'مارس',
    'آوریل',
    'مه',
    'ژوئن',
    'ژوئیه',
    'اوت',
    'سپتامبر',
    'اکتبر',
    'نوامبر',
    'دسامبر',
  ];
  if (MizanI18n.isEnglish) {
    return '${enMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isSpanish) {
    return '${esMonths[value.month - 1]} de ${value.year}';
  }
  if (MizanI18n.isFrench) {
    return '${frMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isGerman) {
    return '${deMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isItalian) {
    return '${itMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isDutch) {
    return '${nlMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isPolish) {
    return '${plMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRomanian) {
    return '${roMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isGreek) {
    return '${elMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRussian) {
    return '${ruMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isUkrainian) {
    return '${ukMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isArabic) {
    return _arabicDigits('${arMonths[value.month - 1]} ${value.year}');
  }
  if (MizanI18n.isPersian) {
    return _persianDigits('${faMonths[value.month - 1]} ${value.year}');
  }
  if (MizanI18n.isPortugueseBr || MizanI18n.isPortuguesePt) {
    return '${ptBrMonths[value.month - 1]} de ${value.year}';
  }
  return '${trMonths[value.month - 1]} ${value.year}';
}

String get mizanCalculationWarning => MizanI18n.text(
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.',
);

String recordTimingLabel(RecordReference record, DateTime reference) {
  if (record.status == PaymentStatus.overdue) {
    return MizanI18n.text('${record.overdueDays} gün gecikmede');
  }
  final days = calendarDaysBetween(reference, record.dueDate);
  if (days == 0) {
    return MizanI18n.text('Son ödeme bugün');
  }
  if (days > 0) {
    return MizanI18n.text('$days gün kaldı');
  }
  return MizanI18n.text('${days.abs()} gün gecikmede');
}

String paymentTimingLabel(
  PaymentStatus status,
  DateTime dueDate,
  DateTime reference,
) {
  final days = calendarDaysBetween(reference, dueDate);
  if (status == PaymentStatus.overdue || days < 0) {
    return MizanI18n.text('${days.abs()} gün gecikmede');
  }
  if (days == 0) {
    return MizanI18n.text('Son ödeme bugün');
  }
  return MizanI18n.text('$days gün kaldı');
}

String timeLabel(int hour, int minute) {
  final value =
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  return MizanI18n.isArabic || MizanI18n.isPersian ? _ltrIsolate(value) : value;
}

String newId(String prefix) {
  final random = math.Random().nextInt(1 << 32).toRadixString(16);
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$random';
}

int stableNotificationId(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}

Color statusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.active:
      return const Color(0xFF1F7A5A);
    case PaymentStatus.upcoming:
      return const Color(0xFFD88218);
    case PaymentStatus.overdue:
      return const Color(0xFFC33A3A);
    case PaymentStatus.completed:
      return const Color(0xFF325DDE);
    case PaymentStatus.passive:
      return const Color(0xFF6D7889);
  }
}
