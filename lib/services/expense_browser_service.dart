import '../core/formatters.dart';
import '../models/mizan_models.dart';

enum ExpenseDaySort {
  newest('Yeniden eskiye'),
  oldest('Eskiden yeniye'),
  highestTotal('En yüksek harcama günü'),
  lowestTotal('En düşük harcama günü');

  const ExpenseDaySort(this.label);
  final String label;
}

class ExpenseDayGroup {
  const ExpenseDayGroup({
    required this.day,
    required this.items,
    required this.total,
    required this.totalsByCurrency,
  });

  final DateTime day;
  final List<ExpenseItem> items;
  final double total;
  final Map<String, double> totalsByCurrency;
}

class ExpenseBrowserService {
  const ExpenseBrowserService();

  static const _turkishWeekdays = <int, String>{
    DateTime.monday: 'Pazartesi',
    DateTime.tuesday: 'Salı',
    DateTime.wednesday: 'Çarşamba',
    DateTime.thursday: 'Perşembe',
    DateTime.friday: 'Cuma',
    DateTime.saturday: 'Cumartesi',
    DateTime.sunday: 'Pazar',
  };

  String weekdayLabel(DateTime value) => _turkishWeekdays[value.weekday] ?? '';

  String dayLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} ${weekdayLabel(value)}';

  bool matchesSearch(String query, Iterable<String> values) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return true;
    final searchable = _normalize(values.join(' '));
    final compactQuery = normalizedQuery.replaceAll(' ', '');
    final compactSearchable = searchable.replaceAll(' ', '');
    if (searchable.contains(normalizedQuery) ||
        (compactQuery.isNotEmpty && compactSearchable.contains(compactQuery))) {
      return true;
    }
    final words = normalizedQuery
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    return words.isNotEmpty && words.every(searchable.contains);
  }

  List<ExpenseDayGroup> browse({
    required Iterable<ExpenseItem> expenses,
    required Iterable<ExpenseCategory> categories,
    String query = '',
    String? categoryId,
    DateTime? start,
    DateTime? endInclusive,
    ExpenseDaySort sort = ExpenseDaySort.newest,
  }) {
    final categoryNames = <String, String>{
      for (final category in categories) category.id: category.name,
    };
    final normalizedQuery = _normalize(query);
    final compactQuery = normalizedQuery.replaceAll(' ', '');
    final words = normalizedQuery
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    final groups = <int, List<ExpenseItem>>{};
    for (final expense in expenses) {
      if (categoryId != null && expense.categoryId != categoryId) continue;
      final spentDay = DateTime(
        expense.spentAt.year,
        expense.spentAt.month,
        expense.spentAt.day,
      );
      if (start != null && spentDay.isBefore(dateOnly(start))) continue;
      if (endInclusive != null && spentDay.isAfter(dateOnly(endInclusive))) {
        continue;
      }
      if (normalizedQuery.isNotEmpty &&
          !_matches(
            expense,
            categoryNames[expense.categoryId] ?? '',
            normalizedQuery,
            compactQuery,
            words,
          )) {
        continue;
      }
      final key = spentDay.year * 10000 + spentDay.month * 100 + spentDay.day;
      groups.putIfAbsent(key, () => <ExpenseItem>[]).add(expense);
    }

    final result = groups.entries
        .map((entry) {
          final day = DateTime(
            entry.key ~/ 10000,
            (entry.key ~/ 100) % 100,
            entry.key % 100,
          );
          final items = entry.value
            ..sort((a, b) {
              final byTime = b.spentAt.compareTo(a.spentAt);
              if (byTime != 0) return byTime;
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });
          final totalsByCurrency = <String, double>{};
          for (final item in items) {
            totalsByCurrency[item.currencyCode] =
                (totalsByCurrency[item.currencyCode] ?? 0) + item.totalAmount;
          }
          return ExpenseDayGroup(
            day: day,
            items: List<ExpenseItem>.unmodifiable(items),
            total: totalsByCurrency.length == 1
                ? totalsByCurrency.values.single
                : 0,
            totalsByCurrency: Map<String, double>.unmodifiable(
              totalsByCurrency,
            ),
          );
        })
        .toList(growable: false);

    final resultCurrencies = <String>{
      for (final group in result) ...group.totalsByCurrency.keys,
    };
    final canCompareAmounts = resultCurrencies.length == 1;
    result.sort(
      (a, b) => switch (sort) {
        ExpenseDaySort.newest => b.day.compareTo(a.day),
        ExpenseDaySort.oldest => a.day.compareTo(b.day),
        ExpenseDaySort.highestTotal =>
          canCompareAmounts
              ? (b.total.compareTo(a.total) != 0
                    ? b.total.compareTo(a.total)
                    : b.day.compareTo(a.day))
              : b.day.compareTo(a.day),
        ExpenseDaySort.lowestTotal =>
          canCompareAmounts
              ? (a.total.compareTo(b.total) != 0
                    ? a.total.compareTo(b.total)
                    : b.day.compareTo(a.day))
              : b.day.compareTo(a.day),
      },
    );
    return result;
  }

  bool _matches(
    ExpenseItem item,
    String categoryName,
    String normalizedQuery,
    String compactQuery,
    List<String> words,
  ) {
    final date = shortDate(item.spentAt);
    final shortYear =
        '${item.spentAt.day.toString().padLeft(2, '0')}.${item.spentAt.month.toString().padLeft(2, '0')}.${(item.spentAt.year % 100).toString().padLeft(2, '0')}';
    final searchable = _normalize(
      '${item.name} ${item.note} $categoryName $date $shortYear ${weekdayLabel(item.spentAt)}',
    );
    final compact = searchable.replaceAll(' ', '');
    if (searchable.contains(normalizedQuery) ||
        (compactQuery.isNotEmpty && compact.contains(compactQuery))) {
      return true;
    }
    return words.isNotEmpty && words.every(searchable.contains);
  }

  String _normalize(String source) {
    var text = source.trim().toLowerCase();
    const replacements = <String, String>{
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
    };
    replacements.forEach((from, to) => text = text.replaceAll(from, to));
    text = text.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
