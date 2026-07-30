import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controllers/mizan_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/mizan_models.dart';
import '../services/expense_browser_service.dart';
import '../services/report_service.dart';
import '../widgets/mizan_cards.dart';
import 'people_screen.dart';

enum _ExpenseView { daily, payments, all }

extension on _ExpenseView {
  String get label => switch (this) {
    _ExpenseView.daily => 'Günlük harcamalar',
    _ExpenseView.payments => 'Ödemeler',
    _ExpenseView.all => 'Bütün harcamalar',
  };
}

enum _ExpensePeriod { thisMonth, days30, days90, custom, all }

extension on _ExpensePeriod {
  String get label => switch (this) {
    _ExpensePeriod.thisMonth => 'Bu ay',
    _ExpensePeriod.days30 => 'Son 30 gün',
    _ExpensePeriod.days90 => 'Son 90 gün',
    _ExpensePeriod.custom => 'Tarih aralığı',
    _ExpensePeriod.all => 'Tümü',
  };
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({required this.controller, super.key});

  final MizanController controller;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  static const _pageSize = 60;
  static const _browser = ExpenseBrowserService();

  String? selectedCategoryId;
  _ExpenseView expenseView = _ExpenseView.daily;
  _ExpensePeriod period = _ExpensePeriod.thisMonth;
  DateTime? customStart;
  DateTime? customEnd;
  ExpenseDaySort daySort = ExpenseDaySort.newest;
  final TextEditingController searchController = TextEditingController();
  final Set<int> expandedDays = <int>{};
  int visibleGroupLimit = _pageSize;
  bool autoExpandTopDay = true;
  MizanState? _cachedState;
  String? _cachedExpenseKey;
  List<ExpenseDayGroup> _cachedGroups = const [];
  List<ReportPaymentDetail> _cachedPaymentDetails = const [];

  ({List<ExpenseDayGroup> groups, List<ReportPaymentDetail> payments})
  _computedData(MizanState state, ({DateTime? start, DateTime? end}) range) {
    final key =
        '${selectedCategoryId ?? 'all'}|${period.name}|${range.start?.toIso8601String() ?? ''}|${range.end?.toIso8601String() ?? ''}|${daySort.name}|${searchController.text.trim().toLowerCase()}';
    if (identical(_cachedState, state) && _cachedExpenseKey == key) {
      return (groups: _cachedGroups, payments: _cachedPaymentDetails);
    }
    final groups = _browser.browse(
      expenses: state.expenses,
      categories: state.expenseCategories,
      query: searchController.text,
      categoryId: selectedCategoryId,
      start: range.start,
      endInclusive: range.end,
      sort: daySort,
    );
    final payments = const MizanReportService()
        .paymentDetailsForRange(
          state: state,
          start: range.start,
          endInclusive: range.end,
        )
        .where((detail) {
          return _browser.matchesSearch(searchController.text, [
            detail.personName,
            detail.recordTitle,
            detail.recordSubtitle,
            detail.payment.note,
            detail.payment.method,
            _paymentRecordLabel(detail.type),
            _browser.dayLabel(detail.payment.paidAt),
            shortDate(detail.payment.paidAt),
          ]);
        })
        .toList(growable: false);
    _cachedState = state;
    _cachedExpenseKey = key;
    _cachedGroups = groups;
    _cachedPaymentDetails = payments;
    return (groups: groups, payments: payments);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {
      visibleGroupLimit = _pageSize;
      expandedDays.clear();
      autoExpandTopDay = true;
    });
  }

  int _dayKey(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

  ({DateTime? start, DateTime? end}) _range(DateTime now) => switch (period) {
    _ExpensePeriod.thisMonth => (
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1, 0),
    ),
    _ExpensePeriod.days30 => (
      start: dateOnly(now).subtract(const Duration(days: 29)),
      end: dateOnly(now),
    ),
    _ExpensePeriod.days90 => (
      start: dateOnly(now).subtract(const Duration(days: 89)),
      end: dateOnly(now),
    ),
    _ExpensePeriod.custom => (
      start: customStart ?? DateTime(now.year, now.month),
      end: customEnd ?? dateOnly(now),
    ),
    _ExpensePeriod.all => (start: null, end: null),
  };

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    if (selectedCategoryId != null &&
        !state.expenseCategories.any((item) => item.id == selectedCategoryId)) {
      selectedCategoryId = null;
    }
    final now = DateTime.now();
    final range = _range(now);
    final computed = _computedData(state, range);
    final groups = computed.groups;
    final visibleGroups = groups
        .take(visibleGroupLimit)
        .toList(growable: false);
    final visibleItems = groups.fold<int>(
      0,
      (sum, group) => sum + group.items.length,
    );
    final visibleTotal = groups.fold<double>(
      0,
      (sum, group) => sum + group.total,
    );
    final categoryById = <String, ExpenseCategory>{
      for (final category in state.expenseCategories) category.id: category,
    };
    final paymentDetails = computed.payments;
    final paymentTotal = paymentDetails.fold<double>(
      0,
      (sum, item) => sum + item.payment.amount,
    );
    final autoExpandedKey =
        groups.isNotEmpty &&
            autoExpandTopDay &&
            (daySort == ExpenseDaySort.highestTotal ||
                daySort == ExpenseDaySort.lowestTotal)
        ? _dayKey(groups.first.day)
        : null;
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;

    return ListView(
      key: const PageStorageKey('expenses'),
      scrollCacheExtent: const ScrollCacheExtent.pixels(2400),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 110),
      children: [
        PageHeader(
          title: 'Giderler',
          subtitle:
              'Harcamalar gün gün gruplanır; arama ve günlük toplam sıralaması uzun yıllarda da kontrollü çalışır.',
          action: FilledButton.icon(
            onPressed: () => _showExpenseForm(context),
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Gider ekle'),
          ),
        ),
        const SizedBox(height: 18),
        AdaptiveGrid(
          minTileWidth: 175,
          children: [
            MetricCard(
              label: 'Bugün',
              value: money(state.expenseTotalForDay(now)),
              color: MizanTheme.green,
              icon: Icons.today_outlined,
            ),
            MetricCard(
              label: 'Bu ay',
              value: money(state.expenseTotalForMonth(now)),
              color: MizanTheme.blue,
              icon: Icons.calendar_month_outlined,
            ),
            MetricCard(
              label: '${period.label} normal gider',
              value: money(visibleTotal),
              icon: Icons.shopping_bag_outlined,
            ),
            MetricCard(
              label: '${period.label} ödemeler',
              value: money(paymentTotal),
              color: MizanTheme.blue,
              icon: Icons.payments_outlined,
            ),
            MetricCard(
              label: '${period.label} bütün harcamalar',
              value: money(visibleTotal + paymentTotal),
              color: MizanTheme.orange,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(
                  'Filtreleme ve arama',
                  subtitle:
                      'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.',
                  action: TextButton.icon(
                    onPressed: () => _showCategoryManager(context),
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Kategoriler'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('expense-search-field'),
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Gider veya tarih ara',
                    hintText: 'Araç, yoğurt, 23.07.2026, Perşembe…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Aramayı temizle',
                            onPressed: searchController.clear,
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ExpenseDaySort>(
                  key: const ValueKey('expense-day-sort'),
                  isExpanded: true,
                  initialValue: daySort,
                  decoration: const InputDecoration(
                    labelText: 'Günleri sırala',
                    prefixIcon: Icon(Icons.sort),
                  ),
                  items: [
                    for (final item in ExpenseDaySort.values)
                      DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      daySort = value;
                      visibleGroupLimit = _pageSize;
                      expandedDays.clear();
                      autoExpandTopDay = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      selected: selectedCategoryId == null,
                      label: const Text('Tüm kategoriler'),
                      onSelected: (_) => setState(() {
                        selectedCategoryId = null;
                        visibleGroupLimit = _pageSize;
                        expandedDays.clear();
                        autoExpandTopDay = true;
                      }),
                    ),
                    for (final category in state.expenseCategories)
                      ChoiceChip(
                        selected: selectedCategoryId == category.id,
                        label: Text(category.name),
                        onSelected: (_) => setState(() {
                          selectedCategoryId = category.id;
                          visibleGroupLimit = _pageSize;
                          expandedDays.clear();
                        }),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Kategori ekle'),
                      onPressed: () => _showCategoryForm(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in _ExpensePeriod.values)
                      ChoiceChip(
                        selected: period == item,
                        label: Text(item.label),
                        onSelected: (_) async {
                          if (item == _ExpensePeriod.custom) {
                            await _selectCustomRange(context);
                            return;
                          }
                          setState(() {
                            period = item;
                            visibleGroupLimit = _pageSize;
                            expandedDays.clear();
                            autoExpandTopDay = true;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _ExpenseView.values)
                  ChoiceChip(
                    selected: expenseView == item,
                    label: Text(item.label),
                    onSelected: (_) => setState(() => expenseView = item),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (expenseView == _ExpenseView.daily ||
            expenseView == _ExpenseView.all) ...[
          SectionTitle(
            'Günlük harcamalar',
            subtitle:
                '${groups.length} gün · $visibleItems kayıt · ${money(visibleTotal)}',
          ),
          const SizedBox(height: 10),
          if (state.expenseCategories.isEmpty)
            EmptyState(
              title: 'Önce kategori ekleyin',
              message:
                  'Market, ulaşım veya kullanıcıya özel başka bir kategori ekledikten sonra gider kaydı oluşturabilirsiniz.',
              action: FilledButton.icon(
                onPressed: () => _showCategoryForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Kategori ekle'),
              ),
            )
          else if (groups.isEmpty)
            EmptyState(
              title: 'Eşleşen gider bulunamadı',
              message:
                  'Seçili kategori, dönem ve arama ifadesine uyan kayıt yok.',
              action: FilledButton.icon(
                onPressed: () => _showExpenseForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Gider ekle'),
              ),
            )
          else
            for (final group in visibleGroups) ...[
              _ExpenseDayCard(
                key: ValueKey('expense-day-${_dayKey(group.day)}'),
                group: group,
                dayLabel: _browser.dayLabel(group.day),
                expanded:
                    expandedDays.contains(_dayKey(group.day)) ||
                    autoExpandedKey == _dayKey(group.day),
                categoryById: categoryById,
                onToggle: () => setState(() {
                  final key = _dayKey(group.day);
                  if (autoExpandedKey == key) {
                    autoExpandTopDay = false;
                    return;
                  }
                  if (!expandedDays.add(key)) expandedDays.remove(key);
                }),
                onEdit: (item) => _showExpenseForm(context, item: item),
                onDelete: (item) => _confirmDeleteExpense(context, item),
              ),
              const SizedBox(height: 10),
            ],
          if (visibleGroups.length < groups.length)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OutlinedButton.icon(
                key: const ValueKey('expenses-load-more'),
                onPressed: () => setState(() => visibleGroupLimit += _pageSize),
                icon: const Icon(Icons.expand_more),
                label: Text(
                  'Daha fazla gün göster (${groups.length - visibleGroups.length} kaldı)',
                ),
              ),
            ),
        ],
        if (expenseView == _ExpenseView.payments ||
            expenseView == _ExpenseView.all) ...[
          if (expenseView == _ExpenseView.all) const SizedBox(height: 18),
          SectionTitle(
            'Ödemeler',
            subtitle: '${paymentDetails.length} ödeme · ${money(paymentTotal)}',
          ),
          const SizedBox(height: 10),
          _PaymentExpenseGroups(
            details: paymentDetails,
            sort: daySort,
            browser: _browser,
            controller: widget.controller,
          ),
        ],
        if (expenseView == _ExpenseView.all) ...[
          const SizedBox(height: 18),
          const Text(
            'Bütün harcamalar görünümünde günlük harcamalar ve ödemeler ayrı başlıklar altında tutulur; yalnız toplamları birlikte hesaplanır.',
            style: TextStyle(
              color: MizanTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectCustomRange(BuildContext context) async {
    final today = dateOnly(DateTime.now());
    final initialStart =
        customStart ?? today.subtract(const Duration(days: 29));
    final initialEnd = customEnd ?? today;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 20),
      lastDate: DateTime(today.year + 20, 12, 31),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'Tarih aralığı seçin',
      cancelText: 'Vazgeç',
      confirmText: 'Uygula',
      saveText: 'Uygula',
    );
    if (!mounted || picked == null) return;
    setState(() {
      customStart = dateOnly(picked.start);
      customEnd = dateOnly(picked.end);
      period = _ExpensePeriod.custom;
      visibleGroupLimit = _pageSize;
      expandedDays.clear();
      autoExpandTopDay = true;
    });
  }

  Future<void> _showCategoryManager(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            final categories = widget.controller.state.expenseCategories;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Gider kategorileri',
                    style: Theme.of(sheetContext).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kategori silinirse yalnız o kategoriye bağlı giderler açık onayla silinir.',
                    style: TextStyle(color: MizanTheme.muted),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showCategoryForm(sheetContext),
                    icon: const Icon(Icons.add),
                    label: const Text('Kategori ekle'),
                  ),
                  const SizedBox(height: 10),
                  for (final category in categories)
                    ListTile(
                      title: Text(category.name),
                      subtitle: Text(
                        '${widget.controller.state.expensesForCategory(category.id).length} gider · ${money(widget.controller.state.expenseTotalForCategory(category.id))}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _showCategoryForm(
                              sheetContext,
                              category: category,
                            );
                          } else if (value == 'delete') {
                            await _showDeleteCategory(sheetContext, category);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                          PopupMenuItem(value: 'delete', child: Text('Sil')),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCategoryForm(
    BuildContext context, {
    ExpenseCategory? category,
  }) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: category?.name ?? '');
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            category == null ? 'Kategori ekle' : 'Kategoriyi düzenle',
          ),
          content: Form(
            key: key,
            child: TextFormField(
              controller: name,
              autofocus: true,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Kategori adı'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Kategori adı boş bırakılamaz.'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(key.currentState?.validate() ?? false)) return;
                if (category == null) {
                  await widget.controller.addExpenseCategory(name.text);
                } else {
                  await widget.controller.renameExpenseCategory(
                    categoryId: category.id,
                    name: name.text,
                  );
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      );
    } finally {
      await Future<void>.delayed(kThemeAnimationDuration);
      name.dispose();
    }
  }

  Future<void> _showDeleteCategory(
    BuildContext context,
    ExpenseCategory category,
  ) async {
    final key = GlobalKey<FormState>();
    final confirmation = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Kategoriyi sil'),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${category.name} kategorisi ve yalnız bu kategoriye bağlı giderler silinecek.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmation,
                  decoration: const InputDecoration(
                    labelText: 'ONAYLIYORUM yazın',
                  ),
                  validator: (value) => value?.trim() == 'ONAYLIYORUM'
                      ? null
                      : 'Tam olarak ONAYLIYORUM yazılmalı.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: MizanTheme.red),
              onPressed: () async {
                if (!(key.currentState?.validate() ?? false)) return;
                await widget.controller.deleteExpenseCategory(
                  categoryId: category.id,
                  confirmation: confirmation.text,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Kategoriyi sil'),
            ),
          ],
        ),
      );
    } finally {
      await Future<void>.delayed(kThemeAnimationDuration);
      confirmation.dispose();
    }
  }

  Future<void> _showExpenseForm(
    BuildContext context, {
    ExpenseItem? item,
  }) async {
    final categories = widget.controller.state.expenseCategories;
    if (categories.isEmpty) {
      await _showCategoryForm(context);
      if (!context.mounted) {
        return;
      }
      if (widget.controller.state.expenseCategories.isEmpty) {
        return;
      }
    }
    final currentCategories = widget.controller.state.expenseCategories;
    final key = GlobalKey<FormState>();
    var categoryId =
        item?.categoryId ?? selectedCategoryId ?? currentCategories.first.id;
    var spentAt = item?.spentAt ?? dateOnly(DateTime.now());
    final name = TextEditingController(text: item?.name ?? '');
    final quantity = TextEditingController(
      text: item == null ? '1' : decimalText(item.quantity),
    );
    final unitPrice = TextEditingController(
      text: item == null ? '' : decimalText(item.unitPrice),
    );
    final note = TextEditingController(text: item?.note ?? '');
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(item == null ? 'Gider ekle' : 'Gideri düzenle'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 560,
                maxHeight: MediaQuery.sizeOf(dialogContext).height * .72,
              ),
              child: Form(
                key: key,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: categoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: [
                          for (final category in currentCategories)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: (value) => setDialogState(
                          () => categoryId = value ?? categoryId,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: name,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Gider adı',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Gider adı boş bırakılamaz.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: quantity,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Adet / miktar',
                        ),
                        validator: (value) {
                          try {
                            parsePositiveDecimal(
                              value ?? '',
                              fieldName: 'Adet',
                            );
                            return null;
                          } on FormatException catch (error) {
                            return error.message;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: unitPrice,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Birim fiyat',
                        ),
                        validator: (value) {
                          try {
                            if (parseMoney(value ?? '') < 0) {
                              return 'Birim fiyat negatif olamaz.';
                            }
                            return null;
                          } on FormatException catch (error) {
                            return error.message;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: dialogContext,
                            initialDate: spentAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            setDialogState(() => spentAt = selected);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text('Tarih: ${shortDate(spentAt)}'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: note,
                        maxLength: 240,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(labelText: 'Not'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!(key.currentState?.validate() ?? false)) return;
                  if (item == null) {
                    await widget.controller.addExpense(
                      categoryId: categoryId,
                      name: name.text,
                      quantity: parsePositiveDecimal(quantity.text),
                      unitPrice: parseMoney(unitPrice.text),
                      spentAt: spentAt,
                      note: note.text,
                    );
                  } else {
                    await widget.controller.updateExpense(
                      expenseId: item.id,
                      categoryId: categoryId,
                      name: name.text,
                      quantity: parsePositiveDecimal(quantity.text),
                      unitPrice: parseMoney(unitPrice.text),
                      spentAt: spentAt,
                      note: note.text,
                    );
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      );
    } finally {
      await Future<void>.delayed(kThemeAnimationDuration);
      name.dispose();
      quantity.dispose();
      unitPrice.dispose();
      note.dispose();
    }
  }

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    ExpenseItem item,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gideri sil'),
        content: Text('${item.name} gider kaydı silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MizanTheme.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (accepted == true) await widget.controller.deleteExpense(item.id);
  }
}

String _paymentRecordLabel(RecordType type) => switch (type) {
  RecordType.debt => 'Banka / kredi',
  RecordType.personalDebt => 'Kişisel / kurumsal',
  RecordType.bill => 'Fatura',
  RecordType.subscription => 'Abonelik',
  RecordType.rent => 'Kira / taksit',
};

IconData _paymentRecordIcon(RecordType type) => switch (type) {
  RecordType.debt => Icons.account_balance_outlined,
  RecordType.personalDebt => Icons.handshake_outlined,
  RecordType.bill => Icons.receipt_long_outlined,
  RecordType.subscription => Icons.autorenew_outlined,
  RecordType.rent => Icons.home_work_outlined,
};

class _PaymentExpenseGroups extends StatefulWidget {
  const _PaymentExpenseGroups({
    required this.details,
    required this.sort,
    required this.browser,
    required this.controller,
  });

  final List<ReportPaymentDetail> details;
  final ExpenseDaySort sort;
  final ExpenseBrowserService browser;
  final MizanController controller;

  @override
  State<_PaymentExpenseGroups> createState() => _PaymentExpenseGroupsState();
}

class _PaymentExpenseGroupsState extends State<_PaymentExpenseGroups> {
  static const _pageSize = 60;
  int visibleDayLimit = _pageSize;

  @override
  void didUpdateWidget(covariant _PaymentExpenseGroups oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.details, widget.details) ||
        oldWidget.sort != widget.sort) {
      visibleDayLimit = _pageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <int, List<ReportPaymentDetail>>{};
    for (final detail in widget.details) {
      final day = dateOnly(detail.payment.paidAt);
      final key = day.year * 10000 + day.month * 100 + day.day;
      groups.putIfAbsent(key, () => <ReportPaymentDetail>[]).add(detail);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) {
        final aTotal = a.value.fold<double>(
          0,
          (sum, item) => sum + item.payment.amount,
        );
        final bTotal = b.value.fold<double>(
          0,
          (sum, item) => sum + item.payment.amount,
        );
        return switch (widget.sort) {
          ExpenseDaySort.newest => b.key.compareTo(a.key),
          ExpenseDaySort.oldest => a.key.compareTo(b.key),
          ExpenseDaySort.highestTotal =>
            bTotal.compareTo(aTotal) != 0
                ? bTotal.compareTo(aTotal)
                : b.key.compareTo(a.key),
          ExpenseDaySort.lowestTotal =>
            aTotal.compareTo(bTotal) != 0
                ? aTotal.compareTo(bTotal)
                : b.key.compareTo(a.key),
        };
      });
    if (entries.isEmpty) {
      return const EmptyState(
        title: 'Ödeme bulunamadı',
        message: 'Seçili filtrede kaydedilmiş ödeme yok.',
      );
    }
    final visible = entries.take(visibleDayLimit).toList(growable: false);
    return Column(
      children: [
        for (final entry in visible)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              key: PageStorageKey('payment-day-${entry.key}'),
              title: Text(
                widget.browser.dayLabel(
                  DateTime(
                    entry.key ~/ 10000,
                    (entry.key ~/ 100) % 100,
                    entry.key % 100,
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                '${entry.value.length} ödeme · ${money(entry.value.fold<double>(0, (sum, item) => sum + item.payment.amount))}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              children: [
                for (final detail in entry.value)
                  MizanListCard(
                    title: '${detail.personName} · ${detail.recordTitle}',
                    subtitle:
                        '${_paymentRecordLabel(detail.type)} · ${detail.recordSubtitle}${detail.payment.note.trim().isEmpty ? '' : '\n${detail.payment.note.trim()}'}',
                    icon: _paymentRecordIcon(detail.type),
                    leadingColor: MizanTheme.blue,
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 118),
                      child: Text(
                        money(detail.payment.amount),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    onTap: () => showRecordDetails(
                      context: context,
                      controller: widget.controller,
                      personId: detail.personId,
                      type: detail.type,
                      sourceId: detail.recordId,
                      bankId: detail.bankId,
                    ),
                  ),
              ],
            ),
          ),
        if (visible.length < entries.length)
          OutlinedButton.icon(
            key: const ValueKey('payment-days-load-more'),
            onPressed: () => setState(() => visibleDayLimit += _pageSize),
            icon: const Icon(Icons.expand_more),
            label: Text(
              'Daha fazla ödeme günü göster '
              '(${entries.length - visible.length} kaldı)',
            ),
          ),
      ],
    );
  }
}

class _ExpenseDayCard extends StatefulWidget {
  const _ExpenseDayCard({
    super.key,
    required this.group,
    required this.dayLabel,
    required this.expanded,
    required this.categoryById,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseDayGroup group;
  final String dayLabel;
  final bool expanded;
  final Map<String, ExpenseCategory> categoryById;
  final VoidCallback onToggle;
  final ValueChanged<ExpenseItem> onEdit;
  final ValueChanged<ExpenseItem> onDelete;

  @override
  State<_ExpenseDayCard> createState() => _ExpenseDayCardState();
}

class _ExpenseDayCardState extends State<_ExpenseDayCard> {
  static const _itemPageSize = 50;
  int visibleItemLimit = _itemPageSize;

  @override
  void didUpdateWidget(covariant _ExpenseDayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.day != widget.group.day ||
        oldWidget.group.items.length != widget.group.items.length) {
      visibleItemLimit = _itemPageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.group.items
        .take(visibleItemLimit)
        .toList(growable: false);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: MizanTheme.blue.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: MizanTheme.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dayLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.group.items.length} gider kaydı',
                          style: const TextStyle(color: MizanTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 122),
                    child: Text(
                      money(widget.group.total),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(widget.expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (widget.expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Column(
                children: [
                  for (final item in visibleItems) ...[
                    _ExpenseCard(
                      item: item,
                      category:
                          widget.categoryById[item.categoryId] ??
                          ExpenseCategory(
                            id: item.categoryId,
                            name: 'Kategori bulunamadı',
                          ),
                      onEdit: () => widget.onEdit(item),
                      onDelete: () => widget.onDelete(item),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (visibleItems.length < widget.group.items.length)
                    OutlinedButton.icon(
                      key: ValueKey(
                        'expense-day-more-${widget.group.day.toIso8601String()}',
                      ),
                      onPressed: () =>
                          setState(() => visibleItemLimit += _itemPageSize),
                      icon: const Icon(Icons.expand_more),
                      label: Text(
                        'Bu günden daha fazla göster '
                        '(${widget.group.items.length - visibleItems.length} kaldı)',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.item,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseItem item;
  final ExpenseCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => MizanListCard(
    title: item.name,
    subtitle:
        '${category.name} · ${shortDate(item.spentAt)}\n${decimalText(item.quantity)} × ${money(item.unitPrice)}${item.note.isEmpty ? '' : ' · ${item.note}'}',
    leadingColor: Color(category.colorValue),
    icon: Icons.shopping_bag_outlined,
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              money(item.totalAmount),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 2),
          PopupMenuButton<String>(
            tooltip: 'Gider işlemleri',
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Düzenle')),
              PopupMenuItem(value: 'delete', child: Text('Sil')),
            ],
          ),
        ],
      ),
    ),
    onTap: onEdit,
  );
}
