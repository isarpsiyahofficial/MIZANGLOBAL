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

String money(num value) {
  if (!MizanI18n.isUrdu && !MizanI18n.isIndonesian) {
    return legacy.money(value);
  }
  final safe = value.isFinite ? value.toDouble() : 0.0;
  final fixed = safe.abs().toStringAsFixed(2).split('.');
  final signedInteger = '${safe < 0 ? '-' : ''}${fixed.first}';

  if (MizanI18n.isIndonesian) {
    final amount = '${_groupThousands(signedInteger, '.')},${fixed.last}';
    return MizanI18n.currencyCode == 'IDR'
        ? 'Rp$amount'
        : '${MizanI18n.currencyCode}\u00A0$amount';
  }

  final grouped = MizanI18n.currencyCode == 'INR'
      ? _groupIndian(signedInteger)
      : _groupThousands(signedInteger, ',');
  final amount = '$grouped.${fixed.last}';
  if (MizanI18n.currencyCode == 'PKR') {
    return _ltrIsolate('PKR\u00A0$amount');
  }
  if (MizanI18n.currencyCode == 'INR') {
    return _ltrIsolate('₹$amount');
  }
  return _ltrIsolate('${MizanI18n.currencyCode}\u00A0$amount');
}

String decimalText(num value) {
  if (!MizanI18n.isUrdu && !MizanI18n.isIndonesian) {
    return legacy.decimalText(value);
  }
  final rounded = value.toStringAsFixed(2);
  final parts = rounded.split('.');
  if (MizanI18n.isIndonesian) {
    final integer = _groupThousands(parts.first, '.');
    return parts.last == '00' ? integer : '$integer,${parts.last}';
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
  }
  return legacy.parseMoney(prepared);
}

double parsePositiveDecimal(String input, {String fieldName = 'Değer'}) =>
    legacy.parsePositiveDecimal(input, fieldName: fieldName);

int? parseOptionalPositiveInt(String input, {String fieldName = 'Değer'}) =>
    legacy.parseOptionalPositiveInt(input, fieldName: fieldName);

int? parseOptionalNonNegativeInt(
  String input, {
  String fieldName = 'Değer',
}) => legacy.parseOptionalNonNegativeInt(input, fieldName: fieldName);

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

String shortDate(DateTime value) {
  if (MizanI18n.isUrdu) {
    return '${value.day} ${_urduMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isIndonesian) {
    return '${value.day} ${_indonesianShortMonths[value.month - 1]} ${value.year}';
  }
  return legacy.shortDate(value);
}

String monthLabel(DateTime value) {
  if (MizanI18n.isUrdu) {
    return '${_urduMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isIndonesian) {
    return '${_indonesianMonths[value.month - 1]} ${value.year}';
  }
  return legacy.monthLabel(value);
}

String get mizanCalculationWarning => MizanI18n.text(
  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.',
);

String recordTimingLabel(RecordReference record, DateTime reference) {
  if (record.status == PaymentStatus.overdue) {
    return MizanI18n.text('${record.overdueDays} gün gecikmede');
  }
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
  if (status == PaymentStatus.overdue || days < 0) {
    return MizanI18n.text('${days.abs()} gün gecikmede');
  }
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
