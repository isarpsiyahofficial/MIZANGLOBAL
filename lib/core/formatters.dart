import 'package:flutter/material.dart' show Color;

import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';
import 'formatters_legacy.dart' as legacy;

DateTime dateOnly(DateTime value) => legacy.dateOnly(value);
bool isSameDay(DateTime a, DateTime b) => legacy.isSameDay(a, b);
bool isSameMonth(DateTime value, DateTime month) =>
    legacy.isSameMonth(value, month);
int calendarDaysBetween(DateTime from, DateTime to) =>
    legacy.calendarDaysBetween(from, to);
String _ltrIsolate(String value) => '\u2066$value\u2069';
String _groupThousands(String value, String separator) {
  final negative = value.startsWith('-');
  final digits = negative ? value.substring(1) : value;
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    output.write(digits[index]);
    final remaining = digits.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) output.write(separator);
  }
  return '${negative ? '-' : ''}$output';
}

String _groupIndian(String value) {
  final negative = value.startsWith('-');
  final digits = negative ? value.substring(1) : value;
  if (digits.length <= 3) return '${negative ? '-' : ''}$digits';
  final tail = digits.substring(digits.length - 3);
  var head = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) groups.insert(0, head);
  return '${negative ? '-' : ''}${groups.join(',')},$tail';
}

bool get _usesNewLocaleFormatter =>
    MizanI18n.isUrdu ||
    MizanI18n.isIndonesian ||
    MizanI18n.isMalay ||
    MizanI18n.isFilipino ||
    MizanI18n.isKorean ||
    MizanI18n.isJapanese ||
    MizanI18n.isChinese ||
    MizanI18n.isVietnamese ||
    MizanI18n.isThai ||
    MizanI18n.isSwahili;

String money(num value, {String? currencyCode}) {
  final code = (currencyCode ?? MizanI18n.currencyCode).trim().toUpperCase();
  if (!_usesNewLocaleFormatter) {
    return legacy.money(value, currencyCode: code);
  }
  final safe = value.isFinite ? value.toDouble() : 0.0;
  if (MizanI18n.isKorean && code == 'KRW') {
    final rounded = safe.round();
    return 'KRW\u00A0₩${_groupThousands(rounded.toString(), ',')}';
  }
  if (MizanI18n.isJapanese && code == 'JPY') {
    final rounded = safe.round();
    return 'JPY\u00A0¥${_groupThousands(rounded.toString(), ',')}';
  }
  if (MizanI18n.isVietnamese && code == 'VND') {
    final rounded = safe.round();
    return '${_groupThousands(rounded.toString(), '.')}\u00A0₫';
  }
  final fixed = safe.abs().toStringAsFixed(2).split('.');
  final signedInteger = '${safe < 0 ? '-' : ''}${fixed.first}';
  if (MizanI18n.isIndonesian) {
    final amount = '${_groupThousands(signedInteger, '.')},${fixed.last}';
    return code == 'IDR' ? 'Rp$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isVietnamese) {
    final amount = '${_groupThousands(signedInteger, '.')},${fixed.last}';
    return '$code\u00A0$amount';
  }
  if (MizanI18n.isMalay) {
    final amount = '${_groupThousands(signedInteger, ',')}.${fixed.last}';
    return code == 'MYR' ? 'RM$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isFilipino) {
    final amount = '${_groupThousands(signedInteger, ',')}.${fixed.last}';
    return code == 'PHP' ? '₱$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isThai) {
    final amount = '${_groupThousands(signedInteger, ',')}.${fixed.last}';
    return code == 'THB' ? '฿$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isSwahili) {
    final amount = '${_groupThousands(signedInteger, ',')}.${fixed.last}';
    return code == 'TZS' ? 'TSh\u00A0$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isChinese) {
    final amount = '${_groupThousands(signedInteger, ',')}.${fixed.last}';
    return code == 'CNY' ? 'CNY\u00A0¥$amount' : '$code\u00A0$amount';
  }
  if (MizanI18n.isKorean || MizanI18n.isJapanese) {
    final amount = '${_groupThousands(signedInteger, ',')}.${fixed.last}';
    return '$code\u00A0$amount';
  }
  final grouped = code == 'INR'
      ? _groupIndian(signedInteger)
      : _groupThousands(signedInteger, ',');
  final amount = '$grouped.${fixed.last}';
  if (code == 'PKR') return _ltrIsolate('PKR\u00A0$amount');
  if (code == 'INR') return _ltrIsolate('₹$amount');
  return _ltrIsolate('$code\u00A0$amount');
}

String moneyForCurrency(num value, String currencyCode) =>
    money(value, currencyCode: currencyCode);

String decimalText(num value) {
  if (!_usesNewLocaleFormatter) return legacy.decimalText(value);
  if ((MizanI18n.isKorean && MizanI18n.currencyCode == 'KRW') ||
      (MizanI18n.isJapanese && MizanI18n.currencyCode == 'JPY') ||
      (MizanI18n.isVietnamese && MizanI18n.currencyCode == 'VND')) {
    final separator = MizanI18n.isVietnamese ? '.' : ',';
    return _groupThousands(value.round().toString(), separator);
  }
  final rounded = value.toStringAsFixed(2);
  final parts = rounded.split('.');
  if (MizanI18n.isIndonesian || MizanI18n.isVietnamese) {
    final integer = _groupThousands(parts.first, '.');
    return parts.last == '00' ? integer : '$integer,${parts.last}';
  }
  if (MizanI18n.isMalay ||
      MizanI18n.isFilipino ||
      MizanI18n.isKorean ||
      MizanI18n.isJapanese ||
      MizanI18n.isChinese ||
      MizanI18n.isThai ||
      MizanI18n.isSwahili) {
    final integer = _groupThousands(parts.first, ',');
    return parts.last == '00' ? integer : '$integer.${parts.last}';
  }
  final integer = MizanI18n.currencyCode == 'INR'
      ? _groupIndian(parts.first)
      : parts.first;
  return parts.last == '00' ? integer : '$integer.${parts.last}';
}

double parseMoney(String input) {
  var prepared = input;
  if (MizanI18n.isUrdu) {
    prepared = prepared
        .replaceAll(RegExp('PKR', caseSensitive: false), '')
        .replaceAll('₨', '');
  } else if (MizanI18n.isIndonesian) {
    prepared = prepared
        .replaceAll(RegExp('IDR', caseSensitive: false), '')
        .replaceAll(RegExp('Rp', caseSensitive: false), '');
  } else if (MizanI18n.isMalay) {
    prepared = prepared
        .replaceAll(RegExp('MYR', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bRM', caseSensitive: false), '');
  } else if (MizanI18n.isFilipino) {
    prepared = prepared
        .replaceAll(RegExp('PHP', caseSensitive: false), '')
        .replaceAll('₱', '');
  } else if (MizanI18n.isKorean) {
    prepared = prepared
        .replaceAll(RegExp('KRW', caseSensitive: false), '')
        .replaceAll('₩', '')
        .replaceAll('원', '');
  } else if (MizanI18n.isJapanese) {
    prepared = prepared
        .replaceAll(RegExp('JPY', caseSensitive: false), '')
        .replaceAll('¥', '')
        .replaceAll('￥', '')
        .replaceAll('円', '');
  } else if (MizanI18n.isChinese) {
    prepared = prepared
        .replaceAll(RegExp('CNY', caseSensitive: false), '')
        .replaceAll('¥', '')
        .replaceAll('￥', '')
        .replaceAll('元', '');
  } else if (MizanI18n.isVietnamese) {
    prepared = prepared
        .replaceAll(RegExp('VND', caseSensitive: false), '')
        .replaceAll('₫', '');
  } else if (MizanI18n.isThai) {
    prepared = prepared
        .replaceAll(RegExp('THB', caseSensitive: false), '')
        .replaceAll('฿', '');
  } else if (MizanI18n.isSwahili) {
    prepared = prepared
        .replaceAll(RegExp('TZS', caseSensitive: false), '')
        .replaceAll(RegExp('TSh', caseSensitive: false), '');
  }
  return legacy.parseMoney(prepared);
}

double parsePositiveDecimal(String input, {String fieldName = 'Değer'}) =>
    legacy.parsePositiveDecimal(input, fieldName: fieldName);
int? parseOptionalPositiveInt(String input, {String fieldName = 'Değer'}) =>
    legacy.parseOptionalPositiveInt(input, fieldName: fieldName);
int? parseOptionalNonNegativeInt(String input, {String fieldName = 'Değer'}) =>
    legacy.parseOptionalNonNegativeInt(input, fieldName: fieldName);

const _urduMonths = <String>[
  'جنوری',
  'فروری',
  'مارچ',
  'اپریل',
  'مئی',
  'جون',
  'جولائی',
  'اگست',
  'ستمبر',
  'اکتوبر',
  'نومبر',
  'دسمبر',
];
const _indonesianShortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
const _indonesianMonths = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
const _malayShortMonths = <String>[
  'Jan',
  'Feb',
  'Mac',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Ogo',
  'Sep',
  'Okt',
  'Nov',
  'Dis',
];
const _malayMonths = <String>[
  'Januari',
  'Februari',
  'Mac',
  'April',
  'Mei',
  'Jun',
  'Julai',
  'Ogos',
  'September',
  'Oktober',
  'November',
  'Disember',
];
const _filipinoShortMonths = <String>[
  'Ene',
  'Peb',
  'Mar',
  'Abr',
  'May',
  'Hun',
  'Hul',
  'Ago',
  'Set',
  'Okt',
  'Nob',
  'Dis',
];
const _filipinoMonths = <String>[
  'Enero',
  'Pebrero',
  'Marso',
  'Abril',
  'Mayo',
  'Hunyo',
  'Hulyo',
  'Agosto',
  'Setyembre',
  'Oktubre',
  'Nobyembre',
  'Disyembre',
];
const _vietnameseMonths = <String>[
  'tháng 1',
  'tháng 2',
  'tháng 3',
  'tháng 4',
  'tháng 5',
  'tháng 6',
  'tháng 7',
  'tháng 8',
  'tháng 9',
  'tháng 10',
  'tháng 11',
  'tháng 12',
];
const _thaiMonths = <String>[
  'มกราคม',
  'กุมภาพันธ์',
  'มีนาคม',
  'เมษายน',
  'พฤษภาคม',
  'มิถุนายน',
  'กรกฎาคม',
  'สิงหาคม',
  'กันยายน',
  'ตุลาคม',
  'พฤศจิกายน',
  'ธันวาคม',
];
const _swahiliMonths = <String>[
  'Januari',
  'Februari',
  'Machi',
  'Aprili',
  'Mei',
  'Juni',
  'Julai',
  'Agosti',
  'Septemba',
  'Oktoba',
  'Novemba',
  'Desemba',
];

String shortDate(DateTime value) {
  if (MizanI18n.isUrdu)
    return '${value.day} ${_urduMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isIndonesian)
    return '${value.day} ${_indonesianShortMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isMalay)
    return '${value.day} ${_malayShortMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isFilipino)
    return '${_filipinoShortMonths[value.month - 1]} ${value.day}, ${value.year}';
  if (MizanI18n.isKorean) return '${value.year}년 ${value.month}월 ${value.day}일';
  if (MizanI18n.isJapanese) return '${value.year}年${value.month}月${value.day}日';
  if (MizanI18n.isChinese) return '${value.year}年${value.month}月${value.day}日';
  if (MizanI18n.isVietnamese)
    return '${value.day}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  if (MizanI18n.isThai)
    return '${value.day} ${_thaiMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isSwahili)
    return '${value.day} ${_swahiliMonths[value.month - 1]} ${value.year}';
  return legacy.shortDate(value);
}

String monthLabel(DateTime value) {
  if (MizanI18n.isUrdu) return '${_urduMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isIndonesian)
    return '${_indonesianMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isMalay)
    return '${_malayMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isFilipino)
    return '${_filipinoMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isKorean) return '${value.year}년 ${value.month}월';
  if (MizanI18n.isJapanese) return '${value.year}年${value.month}月';
  if (MizanI18n.isChinese) return '${value.year}年${value.month}月';
  if (MizanI18n.isVietnamese)
    return '${_vietnameseMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isThai) return '${_thaiMonths[value.month - 1]} ${value.year}';
  if (MizanI18n.isSwahili)
    return '${_swahiliMonths[value.month - 1]} ${value.year}';
  return legacy.monthLabel(value);
}

String get mizanCalculationWarning => MizanI18n.text(
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.',
);
String recordTimingLabel(RecordReference record, DateTime reference) {
  if (record.status == PaymentStatus.overdue)
    return MizanI18n.text('${record.overdueDays} gün gecikmede');
  final days = calendarDaysBetween(reference, record.dueDate);
  if (days == 0) return MizanI18n.text('Son ödeme bugün');
  if (days > 0) return MizanI18n.text('$days gün kaldı');
  return MizanI18n.text('${days.abs()} gün gecikmede');
}

String paymentTimingLabel(
  PaymentStatus status,
  DateTime dueDate,
  DateTime reference,
) {
  final days = calendarDaysBetween(reference, dueDate);
  if (status == PaymentStatus.overdue || days < 0)
    return MizanI18n.text('${days.abs()} gün gecikmede');
  if (days == 0) return MizanI18n.text('Son ödeme bugün');
  return MizanI18n.text('$days gün kaldı');
}

String timeLabel(int hour, int minute) {
  final value =
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  return MizanI18n.isUrdu ? _ltrIsolate(value) : value;
}

String newId(String prefix) => legacy.newId(prefix);
int stableNotificationId(String value) => legacy.stableNotificationId(value);
Color statusColor(PaymentStatus status) => legacy.statusColor(status);
