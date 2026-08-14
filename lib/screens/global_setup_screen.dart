import '../core/localized_material.dart';

import '../controllers/mizan_controller.dart';
import '../global/global_catalog.dart';
import '../widgets/global_picker_dialog.dart';

class GlobalSetupScreen extends StatefulWidget {
  const GlobalSetupScreen({
    required this.controller,
    required this.catalog,
    super.key,
  });

  final MizanController controller;
  final GlobalCatalog catalog;

  @override
  State<GlobalSetupScreen> createState() => _GlobalSetupScreenState();
}

class _GlobalSetupScreenState extends State<GlobalSetupScreen> {
  String? languageCode;
  String? countryCode;
  String? currencyCode;

  bool get canContinue =>
      languageCode != null && countryCode != null && currencyCode != null;

  @override
  void initState() {
    super.initState();
    final state = widget.controller.state;
    languageCode = state.appLanguageTag.isEmpty ? null : state.appLanguageTag;
    countryCode = state.debtRegionCountryCode.isEmpty
        ? null
        : state.debtRegionCountryCode;
    currencyCode =
        state.defaultCurrencyCode.isEmpty ? null : state.defaultCurrencyCode;
  }

  @override
  Widget build(BuildContext context) {
    MizanI18n.setLanguageTag(languageCode);
    final language =
        languageCode == null ? null : widget.catalog.language(languageCode!);
    final country =
        countryCode == null ? null : widget.catalog.country(countryCode!);
    final currency =
        currencyCode == null ? null : widget.catalog.currency(currencyCode!);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.public, size: 52),
                      const SizedBox(height: 14),
                      Text(
                        'MİZAN GLOBAL',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bu seçimler yalnız ilk kurulumda sorulur. Daha sonra Ayarlar bölümünden değiştirilebilir; mevcut kayıtlar silinmez.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _SetupTile(
                        icon: Icons.translate,
                        title: 'Uygulama dili',
                        value: language == null
                            ? 'Dil seç'
                            : '${language.nativeName} · ${language.nameFor(MizanI18n.languageTag)}',
                        onTap: () async {
                          final selected = await showLanguagePicker(
                            context,
                            catalog: widget.catalog,
                            selectedCode: languageCode,
                          );
                          if (selected != null && mounted) {
                            setState(() => languageCode = selected.code);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _SetupTile(
                        icon: Icons.flag_outlined,
                        title: 'Ülke / borç bölgesi',
                        value: country == null
                            ? 'Ülke seç'
                            : '${country.nameFor(MizanI18n.languageTag)} · ${country.code}',
                        onTap: () async {
                          final selected = await showCountryPicker(
                            context,
                            catalog: widget.catalog,
                            selectedCode: countryCode,
                          );
                          if (selected != null && mounted) {
                            setState(() {
                              countryCode = selected.code;
                              if (currencyCode == null &&
                                  selected.currencyCodes.isNotEmpty) {
                                currencyCode = selected.currencyCodes.first;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _SetupTile(
                        icon: Icons.currency_exchange,
                        title: 'Varsayılan para birimi',
                        value: currency == null
                            ? 'Para birimi seç'
                            : '${currency.code} · ${currency.nameFor(MizanI18n.languageTag)}',
                        onTap: () async {
                          final selected = await showCurrencyPicker(
                            context,
                            catalog: widget.catalog,
                            selectedCode: currencyCode,
                          );
                          if (selected != null && mounted) {
                            setState(() => currencyCode = selected.code);
                          }
                        },
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: canContinue && !widget.controller.isBusy
                            ? () => widget.controller.completeGlobalSetup(
                                  appLanguageTag: languageCode!,
                                  debtRegionCountryCode: countryCode!,
                                  defaultCurrencyCode: currencyCode!,
                                )
                            : null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Kurulumu tamamla'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(value),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
