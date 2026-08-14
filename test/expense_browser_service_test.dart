import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/expense_browser_service.dart';

void main() {
  const service = ExpenseBrowserService();
  const categories = [
    ExpenseCategory(id: 'vehicle', name: 'Araç'),
    ExpenseCategory(id: 'market', name: 'Market'),
  ];

  final expenses = [
    ExpenseItem(
      id: '1',
      categoryId: 'vehicle',
      name: 'Araç Sigortası',
      quantity: 1,
      unitPrice: 8500,
      spentAt: DateTime(2026, 7, 21, 10),
    ),
    ExpenseItem(
      id: '2',
      categoryId: 'market',
      name: 'Yoğurt+Tuz+Sandviç',
      quantity: 1,
      unitPrice: 4300,
      spentAt: DateTime(2026, 7, 22, 11),
    ),
    ExpenseItem(
      id: '3',
      categoryId: 'market',
      name: 'Ekmek',
      quantity: 1,
      unitPrice: 7483,
      spentAt: DateTime(2026, 7, 23, 12),
      note: 'Akşam alışverişi',
    ),
    ExpenseItem(
      id: '4',
      categoryId: 'market',
      name: 'Su faturası',
      quantity: 1,
      unitPrice: 4570,
      spentAt: DateTime(2026, 7, 24, 9),
    ),
  ];

  test('giderleri tarih ve Türkçe gün adıyla gruplar', () {
    final groups = service.browse(expenses: expenses, categories: categories);

    expect(groups, hasLength(4));
    expect(service.dayLabel(DateTime(2026, 7, 23)), '23.07.2026 Perşembe');
    expect(groups.first.day, DateTime(2026, 7, 24));
  });

  test('en yüksek ve en düşük günlük toplam doğru sıralanır', () {
    final highest = service.browse(
      expenses: expenses,
      categories: categories,
      sort: ExpenseDaySort.highestTotal,
    );
    final lowest = service.browse(
      expenses: expenses,
      categories: categories,
      sort: ExpenseDaySort.lowestTotal,
    );

    expect(highest.first.day, DateTime(2026, 7, 21));
    expect(highest.first.total, 8500);
    expect(lowest.first.day, DateTime(2026, 7, 22));
    expect(lowest.first.total, 4300);
  });

  test('Türkçe karakter, bitişik ifade, tarih ve gün adı araması çalışır', () {
    List<ExpenseDayGroup> search(String query) => service.browse(
      expenses: expenses,
      categories: categories,
      query: query,
    );

    expect(search('arac').single.items.single.name, 'Araç Sigortası');
    expect(search('yoğurt').single.items.single.name, 'Yoğurt+Tuz+Sandviç');
    expect(search('yogurttuz').single.items.single.name, 'Yoğurt+Tuz+Sandviç');
    expect(search('23.07.26').single.items.single.name, 'Ekmek');
    expect(search('perşembe').single.items.single.name, 'Ekmek');
  });

  test('10 bin gideri eksiksiz ve gün gruplu işler', () {
    final many = List<ExpenseItem>.generate(
      10000,
      (index) => ExpenseItem(
        id: 'expense-$index',
        categoryId: index.isEven ? 'vehicle' : 'market',
        name: index.isEven ? 'Araç gideri $index' : 'Market gideri $index',
        quantity: 1,
        unitPrice: (index % 500 + 1).toDouble(),
        spentAt: DateTime(2020, 1, 1).add(Duration(days: index % 2000)),
      ),
    );

    final stopwatch = Stopwatch()..start();
    final groups = service.browse(
      expenses: many,
      categories: categories,
      sort: ExpenseDaySort.highestTotal,
    );
    stopwatch.stop();

    expect(
      groups.fold<int>(0, (sum, group) => sum + group.items.length),
      10000,
    );
    expect(groups.length, lessThanOrEqualTo(2000));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 15)));
  });
}
