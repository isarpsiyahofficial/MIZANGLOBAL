import '../core/localized_material.dart';

import '../global/global_catalog.dart';

Future<LanguageOption?> showLanguagePicker(
  BuildContext context, {
  required GlobalCatalog catalog,
  String? selectedCode,
}) => showDialog<LanguageOption>(
  context: context,
  builder: (context) => _SearchPickerDialog<LanguageOption>(
    title: 'Dil seç',
    searchHint: 'Dil ara',
    items: catalog.languages
        .where((item) => MizanI18n.supportedLanguageTags.contains(item.code))
        .toList(growable: false),
    matches: (item, query) => item.matches(query),
    selected: (item) => item.code == selectedCode,
    titleOf: (item) => item.nativeName,
    subtitleOf: (item) => item.nameFor(MizanI18n.languageTag),
    valueOf: (item) => item,
  ),
);

Future<CountryOption?> showCountryPicker(
  BuildContext context, {
  required GlobalCatalog catalog,
  String? selectedCode,
}) => showDialog<CountryOption>(
  context: context,
  builder: (context) => _SearchPickerDialog<CountryOption>(
    title: 'Ülke seç',
    searchHint: 'Ülke adı veya kod ara',
    items: catalog.countries,
    matches: (item, query) => item.matches(query),
    selected: (item) => item.code == selectedCode,
    titleOf: (item) => item.nameFor(MizanI18n.languageTag),
    subtitleOf: (item) => '${item.nativeName} · ${item.code}',
    valueOf: (item) => item,
  ),
);

Future<CurrencyOption?> showCurrencyPicker(
  BuildContext context, {
  required GlobalCatalog catalog,
  String? selectedCode,
}) => showDialog<CurrencyOption>(
  context: context,
  builder: (context) => _SearchPickerDialog<CurrencyOption>(
    title: 'Para birimi seç',
    searchHint: 'Ad, ISO kodu veya sembol ara',
    items: catalog.currencies,
    matches: (item, query) => item.matches(query),
    selected: (item) => item.code == selectedCode,
    titleOf: (item) => '${item.code} · ${item.nameFor(MizanI18n.languageTag)}',
    subtitleOf: (item) => item.symbols.join(' / '),
    valueOf: (item) => item,
  ),
);

class _SearchPickerDialog<T> extends StatefulWidget {
  const _SearchPickerDialog({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.matches,
    required this.selected,
    required this.titleOf,
    required this.subtitleOf,
    required this.valueOf,
  });

  final String title;
  final String searchHint;
  final List<T> items;
  final bool Function(T item, String query) matches;
  final bool Function(T item) selected;
  final String Function(T item) titleOf;
  final String Function(T item) subtitleOf;
  final T Function(T item) valueOf;

  @override
  State<_SearchPickerDialog<T>> createState() => _SearchPickerDialogState<T>();
}

class _SearchPickerDialogState<T> extends State<_SearchPickerDialog<T>> {
  final controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => widget.matches(item, query))
        .toList(growable: false);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MizanI18n.text('Kapat'),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: controller,
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                decoration: localizedInputDecoration(
                  InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: MizanI18n.text('Aramayı temizle'),
                            onPressed: () {
                              controller.clear();
                              setState(() => query = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Eşleşen sonuç bulunamadı.'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          selected: widget.selected(item),
                          title: Text(
                            widget.titleOf(item),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(widget.subtitleOf(item)),
                          trailing: widget.selected(item)
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () =>
                              Navigator.pop(context, widget.valueOf(item)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
